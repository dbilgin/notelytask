import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/google_drive_cubit.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/util/update_widget.dart';
import 'package:notelytask/utils.dart';

class NotesCubit extends HydratedCubit<NotesState> {
  NotesCubit({
    required this.githubCubit,
    required this.googleDriveCubit,
  }) : super(const NotesState());
  final GithubCubit githubCubit;
  final GoogleDriveCubit googleDriveCubit;

  @override
  void onChange(Change<NotesState> change) {
    updateWidget(json.encode(toJson(change.nextState)));
    super.onChange(change);
  }

  void invalidateError() {
    githubCubit.invalidateError();
  }

  Future<void> createOrUpdateRemoteNotes({
    bool shouldResetIfError = true,
  }) async {
    final jsonMap = state.toJson();

    if (githubCubit.state.isLoggedIn()) {
      return await githubCubit.createOrUpdateRemoteNotes(
        shouldResetIfError: shouldResetIfError,
        encryptionKey: state.encryptionKey,
        notesJSONMap: jsonMap,
      );
    } else if (googleDriveCubit.state.accessToken != null) {
      return await googleDriveCubit.createOrUpdateRemoteNotes(
        shouldResetIfError: shouldResetIfError,
        encryptionKey: state.encryptionKey,
        notesJSONMap: jsonMap,
      );
    }
  }

  Future<bool> deleteFileAndUpdate(String noteId, FileData fileData) async {
    final deleteFile = githubCubit.state.isLoggedIn()
        ? githubCubit.deleteFile
        : googleDriveCubit.deleteFile;
    final remoteDeleteResult = await deleteFile(fileData);
    if (!remoteDeleteResult) return false;
    _deleteNoteFileData(
      noteId,
      fileData.name,
    );
    await createOrUpdateRemoteNotes();
    return true;
  }

  Future<bool> deleteFile(FileData fileData) async {
    final deleteFile = githubCubit.state.isLoggedIn()
        ? githubCubit.deleteFile
        : googleDriveCubit.deleteFile;
    return await deleteFile(fileData);
  }

  Future<void> uploadNewFileAndNotes(
    String noteId,
    String fileName,
    Uint8List data,
  ) async {
    final safeFileName = nonExistentFileName(
      fileName: fileName,
      notes: state.notes,
    );

    final uploadNewFile = githubCubit.state.isLoggedIn()
        ? githubCubit.uploadNewFile
        : googleDriveCubit.uploadNewFile;

    final fileData = await uploadNewFile(
      safeFileName,
      data,
    );

    if (fileData == null) {
      return;
    }
    _addNoteFileData(
      noteId: noteId,
      fileName: fileData.name,
      fileId: fileData.id,
    );

    return await createOrUpdateRemoteNotes();
  }

  bool isLoggedIn() {
    return githubCubit.state.isLoggedIn() ||
        googleDriveCubit.state.isLoggedIn();
  }

  Future<bool> setRemoteConnection({
    required bool keepLocal,
    required Future<String?> Function() enterEncryptionKeyDialog,
    String? ownerRepo,
    String? fileId,
  }) async {
    final connectionResult = ownerRepo != null
        ? await githubCubit.setRepoUrl(
            ownerRepo,
            keepLocal,
            enterEncryptionKeyDialog,
          )
        : await googleDriveCubit.setFileId(
            fileId: fileId,
            enterEncryptionKeyDialog: enterEncryptionKeyDialog,
          );

    if (connectionResult.shouldCreateRemote) {
      await createOrUpdateRemoteNotes(shouldResetIfError: false);
      return true;
    }

    final content = connectionResult.content;

    if (content != null) {
      final finalContent = json.decode(content);
      final notes = fromJson(finalContent);
      emit(notes);
      return true;
    }
    return false;
  }

  void reset({
    bool shouldError = false,
  }) {
    if (githubCubit.state.isLoggedIn()) {
      githubCubit.reset(shouldError: shouldError);
    } else {
      googleDriveCubit.reset(shouldError: shouldError);
    }

    const newState = NotesState(
      encryptionKey: null,
      notes: [],
    );
    emit(newState);
  }

  Future<void> getAndUpdateLocalNotes({
    required BuildContext context,
    String? redirectNoteId,
  }) async {
    if (!githubCubit.state.isLoggedIn() &&
        !googleDriveCubit.state.isLoggedIn()) {
      return;
    }

    final getRemoteNotes = githubCubit.state.isLoggedIn()
        ? githubCubit.getRemoteNotes
        : googleDriveCubit.getRemoteNotes;

    final result = await getRemoteNotes(
      context: context,
      encryptionKey: state.encryptionKey,
    );

    final notesString = result.notesString;

    if (result.pinNeeded && context.mounted) {
      final pinResult = await encryptionKeyDialog(
        context: context,
        title: 'Encryption Pin Missing',
        text: 'Your notes are encrypted but you have no pin saved locally.',
        isPinRequired: true,
      );
      if (pinResult == null) {
        reset(shouldError: true);
        return;
      }

      if (!context.mounted) {
        reset(shouldError: true);
        return;
      }

      setEncryptionKey(pinResult);
      return getAndUpdateLocalNotes(
        context: context,
        redirectNoteId: redirectNoteId,
      );
    }

    if (notesString == null) {
      reset(shouldError: true);
    } else {
      final finalContent = json.decode(notesString);
      final list = fromJson(finalContent);
      emit(list);
    }

    if (redirectNoteId != null) {
      final note = state.notes
          .where((n) => n.id == redirectNoteId && !n.isDeleted)
          .toList();
      if (note.isNotEmpty) {
        if (!context.mounted) return;
        navigateToDetails(
          context: context,
          isDeletedList: false,
          note: note[0],
        );
      }
    }
  }

  Future<String?> getFileLocalPath(FileData fileData) async {
    if (githubCubit.state.isLoggedIn()) {
      return await githubCubit.getFileLocalPath(fileData.name);
    } else if (googleDriveCubit.state.isLoggedIn()) {
      return await googleDriveCubit.getFileLocalPath(fileData);
    }
    return null;
  }

  void setEncryptionKey(String? key) {
    final newState = NotesState(
      notes: state.notes,
      encryptionKey: key,
    );
    emit(newState);
  }

  void setNote(Note note) {
    final index = state.notes.indexWhere((element) => element.id == note.id);
    List<Note> updatedNotes = List<Note>.from(state.notes);

    if (note.title.isEmpty && note.text.isEmpty && note.fileDataList.isEmpty) {
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
