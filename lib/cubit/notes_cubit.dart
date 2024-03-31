import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/util/update_widget.dart';
import 'package:notelytask/utils.dart';

class NotesCubit extends HydratedCubit<NotesState> {
  NotesCubit({
    required this.githubCubit,
  }) : super(const NotesState());
  final GithubCubit githubCubit;

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
    return await githubCubit.createOrUpdateRemoteNotes(
      shouldResetIfError: shouldResetIfError,
      encryptionKey: state.encryptionKey,
      notesJSONMap: jsonMap,
    );
  }

  Future<bool> deleteFileAndUpdate(String noteId, FileData fileData) async {
    final remoteDeleteResult = await githubCubit.deleteFile(fileData);
    if (!remoteDeleteResult) return false;
    _deleteNoteFileData(
      noteId,
      fileData.name,
    );
    createOrUpdateRemoteNotes();
    return true;
  }

  Future<bool> deleteFile(FileData fileData) async {
    return await githubCubit.deleteFile(fileData);
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
    final fileData = await githubCubit.uploadNewFile(
      safeFileName,
      data,
    );

    if (fileData == null) return;
    _addNoteFileData(
      noteId: noteId,
      fileName: fileData.name,
      fileSha: fileData.sha,
    );

    await createOrUpdateRemoteNotes();
  }

  bool isLoggedIn() {
    return githubCubit.isLoggedIn();
  }

  Future<void> setRemoteConnection(
    String ownerRepo,
    bool keepLocal,
    Future<String?> Function() enterEncryptionKeyDialog,
  ) async {
    final connectionResult = await githubCubit.setRepoUrl(
      ownerRepo,
      keepLocal,
      enterEncryptionKeyDialog,
    );

    if (connectionResult.shouldCreateRemote) {
      await createOrUpdateRemoteNotes(shouldResetIfError: false);
      return;
    }

    final content = connectionResult.content;

    if (content != null) {
      final finalContent = json.decode(content);
      final notes = fromJson(finalContent);
      emit(notes);
    }
  }

  Future<void> getAndUpdateNotes({
    required BuildContext context,
    String? redirectNoteId,
  }) async {
    final result = await githubCubit.getAndUpdateNotes(
      context: context,
      encryptionKey: state.encryptionKey,
      redirectNoteId: redirectNoteId,
    );
    if (result == null) {
      emit(const NotesState());
    } else {
      final finalContent = json.decode(result);
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

  Future<String?> getFileLocalPath(String fileName) async {
    return await githubCubit.getFileLocalPath(fileName);
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
    required String fileSha,
  }) {
    final noteIndex = state.notes.indexWhere((element) => element.id == noteId);
    List<Note> updatedNotes = List<Note>.from(state.notes);

    if (noteIndex == -1) {
      final newNote = Note.generateNew()
          .copyWith(fileDataList: [FileData(name: fileName, sha: fileSha)]);
      updatedNotes.add(newNote);
    } else {
      List<FileData> updatedFileDataList =
          List<FileData>.from(state.notes[noteIndex].fileDataList)
            ..add(FileData(name: fileName, sha: fileSha));
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
