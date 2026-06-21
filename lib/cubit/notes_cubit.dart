import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/cubit/supabase_sync_cubit.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/util/quill_utils.dart';
import 'package:notelytask/util/update_widget.dart';
import 'package:notelytask/utils.dart';
import 'package:path_provider/path_provider.dart';

class NotesCubit extends HydratedCubit<NotesState> {
  NotesCubit({
    required this.supabaseSyncCubit,
  }) : super(const NotesState());
  final SupabaseSyncCubit supabaseSyncCubit;
  Future<String?>? _missingEncryptionPinPrompt;
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const _legacyFolderPathKey = 'local_folder_path';
  static const _encryptionKeyStoragePrefix = 'supabase_encryption_key';

  @override
  void onChange(Change<NotesState> change) {
    updateWidget(json.encode(toJson(change.nextState)));
    super.onChange(change);
  }

  void invalidateError() {
    supabaseSyncCubit.invalidateError();
  }

  Future<void> createOrUpdateRemoteNotes({
    bool shouldResetIfError = false,
  }) async {
    final jsonMap = state.toJson();
    final stringifiedContent = json.encode(jsonMap);

    return await supabaseSyncCubit.createOrUpdateRemoteNotes(
      shouldResetIfError: shouldResetIfError,
      encryptionKey: state.encryptionKey,
      notesJSONMap: jsonMap,
      stringifiedContent: stringifiedContent,
    );
  }

  Future<bool> deleteFileAndUpdate(String noteId, FileData fileData) async {
    final remoteDeleteResult = await supabaseSyncCubit.deleteFile(fileData);
    if (!remoteDeleteResult) return false;
    _deleteNoteFileData(
      noteId,
      fileData.name,
    );
    await createOrUpdateRemoteNotes();
    return true;
  }

  Future<bool> deleteFile(FileData fileData) async {
    return await supabaseSyncCubit.deleteFile(fileData);
  }

  Future<bool> uploadNewFileAndNotes(
    String noteId,
    String fileName,
    Uint8List data,
  ) async {
    final safeFileName = nonExistentFileName(
      fileName: fileName,
      notes: state.notes,
    );

    final fileData = await supabaseSyncCubit.uploadNewFile(
      safeFileName,
      data,
    );

    if (fileData == null) {
      return false;
    }
    _addNoteFileData(
      noteId: noteId,
      fileName: fileData.name,
      fileId: fileData.id,
    );

    await createOrUpdateRemoteNotes();
    return true;
  }

  bool isConnected() {
    return supabaseSyncCubit.isConnected();
  }

  void reset({
    bool shouldError = false,
  }) {
    const newState = NotesState(
      encryptionKey: null,
      notes: [],
    );
    emit(newState);
  }

  Future<void> getAndUpdateLocalNotes({
    required BuildContext context,
  }) async {
    if (!supabaseSyncCubit.isConnected()) {
      return;
    }

    await _loadStoredEncryptionKeyIfNeeded();
    final encryptionKeyUsed = state.encryptionKey;

    final result = await supabaseSyncCubit.getRemoteNotes(
      encryptionKey: encryptionKeyUsed,
    );

    final notesString = result.notesString;

    if (result.decryptionFailed) {
      await clearEncryptionKey();
      return;
    }

    if (result.pinNeeded && context.mounted) {
      final pinResult = await _requestMissingEncryptionPin(context);
      if (pinResult == null) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      await setEncryptionKey(pinResult);
      if (!context.mounted) {
        return;
      }
      return getAndUpdateLocalNotes(
        context: context,
      );
    }

    if (notesString == null) {
      if (state.notes.isEmpty || !context.mounted) {
        return;
      }
      final shouldUploadLocal = await syncUploadLocalDialog(
        context: context,
      );
      if (shouldUploadLocal == true) {
        await _importLegacyAttachments();
        await createOrUpdateRemoteNotes();
      }
      return;
    }

    final finalContent = json.decode(notesString);
    final remoteNotes = fromJson(finalContent);
    final notesToStore =
        remoteNotes.encryptionKey == null && encryptionKeyUsed != null
            ? NotesState(
                notes: remoteNotes.notes,
                encryptionKey: encryptionKeyUsed,
              )
            : remoteNotes;
    final localNotesContent = json.encode(
      state.notes.map((note) => note.toJson()).toList(),
    );
    final remoteNotesContent = json.encode(
      remoteNotes.notes.map((note) => note.toJson()).toList(),
    );

    if (state.notes.isNotEmpty &&
        localNotesContent != remoteNotesContent &&
        context.mounted) {
      final choice = await syncConflictDialog(context: context);
      if (choice == SyncConflictChoice.keepLocal) {
        await _importLegacyAttachments();
        await createOrUpdateRemoteNotes();
        return;
      }
      if (choice == SyncConflictChoice.cancel) {
        return;
      }
    }

    emit(notesToStore);
  }

  Future<Note?> getNoteById(String noteId) async {
    return state.notes.firstWhere((n) => n.id == noteId);
  }

  Future<String?> getFileLocalPath(FileData fileData) async {
    if (kIsWeb || !supabaseSyncCubit.isConnected()) {
      return null;
    }

    final bytes = await getFileBytes(fileData);
    if (bytes == null) {
      return null;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${fileData.name}');
    await file.writeAsBytes(bytes, mode: FileMode.write);
    return file.path;
  }

  Future<Uint8List?> getFileBytes(FileData fileData) async {
    if (!supabaseSyncCubit.isConnected()) {
      return null;
    }

    return await supabaseSyncCubit.downloadFile(fileData);
  }

  Future<void> setEncryptionKey(String? key) async {
    final storageKey = _encryptionKeyStorageKey;
    if (storageKey != null) {
      if (key == null) {
        await _secureStorage.delete(key: storageKey);
      } else {
        await _secureStorage.write(key: storageKey, value: key);
      }
    }

    final newState = NotesState(
      notes: state.notes,
      encryptionKey: key,
    );
    emit(newState);
  }

  Future<void> _loadStoredEncryptionKeyIfNeeded() async {
    if (state.encryptionKey != null) {
      return;
    }

    final storageKey = _encryptionKeyStorageKey;
    if (storageKey == null) {
      return;
    }

    final storedKey = await _secureStorage.read(key: storageKey);
    if (storedKey == null || storedKey.isEmpty) {
      return;
    }

    emit(
      NotesState(
        notes: state.notes,
        encryptionKey: storedKey,
      ),
    );
  }

  Future<String?> _requestMissingEncryptionPin(BuildContext context) {
    final existingPrompt = _missingEncryptionPinPrompt;
    if (existingPrompt != null) {
      return existingPrompt;
    }

    if (!context.mounted) {
      return Future.value(null);
    }

    final prompt = encryptionKeyDialog(
      context: context,
      title: 'Encryption Pin Missing',
      text: 'Your notes are encrypted but you have no pin saved locally.',
      isPinRequired: true,
    );
    _missingEncryptionPinPrompt = prompt;
    prompt.whenComplete(() {
      if (identical(_missingEncryptionPinPrompt, prompt)) {
        _missingEncryptionPinPrompt = null;
      }
    });
    return prompt;
  }

  String? get _encryptionKeyStorageKey {
    final userId = supabaseSyncCubit.currentUserId;
    if (userId == null) {
      return null;
    }
    return '${_encryptionKeyStoragePrefix}_$userId';
  }

  Future<void> _importLegacyAttachments() async {
    if (kIsWeb || state.notes.isEmpty || !supabaseSyncCubit.isConnected()) {
      return;
    }

    final folderPath = await _secureStorage.read(key: _legacyFolderPathKey);
    if (folderPath == null || folderPath.isEmpty) {
      return;
    }

    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      return;
    }

    var changed = false;
    final updatedNotes = <Note>[];

    for (final note in state.notes) {
      final updatedFiles = <FileData>[];
      for (final fileData in note.fileDataList) {
        if (fileData.id.contains('/')) {
          updatedFiles.add(fileData);
          continue;
        }

        final legacyFile = File('${folder.path}/${fileData.name}');
        if (!await legacyFile.exists()) {
          updatedFiles.add(fileData);
          continue;
        }

        final uploaded = await supabaseSyncCubit.uploadNewFile(
          fileData.name,
          await legacyFile.readAsBytes(),
        );
        updatedFiles.add(uploaded ?? fileData);
        changed = changed || uploaded != null;
      }
      updatedNotes.add(note.copyWith(fileDataList: updatedFiles));
    }

    if (changed) {
      emit(state.copyWith(notes: updatedNotes));
    }
  }

  Future<void> clearEncryptionKey() async {
    await setEncryptionKey(null);
  }

  void setNote(Note note) {
    final index = state.notes.indexWhere((element) => element.id == note.id);
    List<Note> updatedNotes = List<Note>.from(state.notes);

    if (note.title.isEmpty &&
        note.fileDataList.isEmpty &&
        extractPlainTextFromDelta(note.text).trim().isEmpty) {
      if (index != -1) {
        updatedNotes.removeAt(index);
        emit(state.copyWith(notes: updatedNotes));
      }
      return;
    }

    if (index == -1) {
      updatedNotes.add(note);
    } else {
      updatedNotes[index] = note;
    }

    emit(state.copyWith(notes: updatedNotes));
  }

  void deleteNotePermanently(String noteId) {
    final noteIndex = state.notes.indexWhere((element) => element.id == noteId);
    if (noteIndex == -1) {
      return;
    }

    List<Note> updatedNotes = List<Note>.from(state.notes);
    updatedNotes.removeAt(noteIndex);

    emit(state.copyWith(notes: updatedNotes));
  }

  void deleteNote(Note note) {
    final noteIndex =
        state.notes.indexWhere((element) => element.id == note.id);
    if (noteIndex == -1) {
      return;
    }

    List<Note> updatedNotes = List<Note>.from(state.notes);
    updatedNotes[noteIndex] = note.copyWith(isDeleted: true);

    emit(state.copyWith(notes: updatedNotes));
  }

  void restoreNote(Note note) {
    final noteIndex =
        state.notes.indexWhere((element) => element.id == note.id);
    if (noteIndex == -1) {
      return;
    }

    List<Note> updatedNotes = List<Note>.from(state.notes);
    updatedNotes[noteIndex] = note.copyWith(isDeleted: false);

    emit(state.copyWith(notes: updatedNotes));
  }

  void _addNoteFileData({
    required String noteId,
    required String fileName,
    required String fileId,
  }) {
    final noteIndex = state.notes.indexWhere((element) => element.id == noteId);
    List<Note> updatedNotes = List<Note>.from(state.notes);

    if (noteIndex == -1) {
      final newNote = Note.generateNew()
          .copyWith(fileDataList: [FileData(name: fileName, id: fileId)]);
      updatedNotes.add(newNote);
    } else {
      List<FileData> updatedFileDataList =
          List<FileData>.from(state.notes[noteIndex].fileDataList)
            ..add(FileData(name: fileName, id: fileId));
      updatedNotes[noteIndex] =
          state.notes[noteIndex].copyWith(fileDataList: updatedFileDataList);
    }

    emit(state.copyWith(notes: updatedNotes));
  }

  void _deleteNoteFileData(String noteId, String fileName) {
    final noteIndex = state.notes.indexWhere((element) => element.id == noteId);
    if (noteIndex == -1) {
      return;
    }

    List<Note> updatedNotes = List<Note>.from(state.notes);
    List<FileData> updatedFileDataList =
        List<FileData>.from(updatedNotes[noteIndex].fileDataList);
    final fileIndex =
        updatedFileDataList.indexWhere((element) => element.name == fileName);

    if (fileIndex != -1) {
      updatedFileDataList.removeAt(fileIndex);
      updatedNotes[noteIndex] =
          updatedNotes[noteIndex].copyWith(fileDataList: updatedFileDataList);
      emit(state.copyWith(notes: updatedNotes));
    }
  }

  @override
  NotesState fromJson(Map<String, dynamic> json) {
    return NotesState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(NotesState state) {
    return state.toJson();
  }
}
