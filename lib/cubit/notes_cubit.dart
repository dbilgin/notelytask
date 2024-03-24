import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/util/update_widget.dart';

class NotesCubit extends HydratedCubit<NotesState> {
  NotesCubit() : super(const NotesState());

  @override
  void onChange(Change<NotesState> change) {
    updateWidget(json.encode(toJson(change.nextState)));
    super.onChange(change);
  }

  String nonExistentFileName({required String fileName}) {
    var files = state.notes.expand((e) => e.fileDataList);
    var fileNames = files.map((e) => e.name);
    var exists = fileNames.contains(fileName);

    if (!exists) {
      return fileName;
    } else {
      int index = fileName.lastIndexOf('.');
      String withoutExtension = fileName.substring(0, index);
      String extension = fileName.substring(index);

      return nonExistentFileName(
        fileName: '${withoutExtension}_$extension',
      );
    }
  }

  void setNote(Note note) {
    var index = state.notes.indexWhere((element) => element.id == note.id);
    if (note.title.isEmpty && note.text.isEmpty && note.fileDataList.isEmpty) {
      if (index != -1) deleteNotePermanently(note.id);
      return;
    }

    if (index == -1) {
      state.notes.add(note);
    } else {
      state.notes[index] = note;
    }

    emit(state.copyWith());
  }

  void addNoteFileData({
    required String noteId,
    required String fileName,
    required String fileSha,
  }) {
    final newFileData = FileData(name: fileName, sha: fileSha);
    final noteIndex = state.notes.indexWhere((element) => element.id == noteId);
    if (noteIndex == -1) {
      final newNote = Note.generateNew();
      newNote.fileDataList = [newFileData];
      state.notes.add(newNote);
    } else {
      state.notes[noteIndex].fileDataList = [
        ...state.notes[noteIndex].fileDataList,
        newFileData,
      ];
    }

    emit(state.copyWith());
  }

  void deleteNoteFileData(String noteId, String fileName) {
    final index = state.notes.indexWhere((element) => element.id == noteId);
    if (index == -1) {
      return;
    }

    final fileIndex = state.notes[index].fileDataList
        .indexWhere((element) => element.name == fileName);
    state.notes[index].fileDataList.removeAt(fileIndex);

    emit(state.copyWith());
  }

  void deleteNotePermanently(String noteId) {
    var index = state.notes.indexWhere((element) => element.id == noteId);
    state.notes.removeAt(index);

    emit(state.copyWith());
  }

  void deleteNote(Note note) {
    var index = state.notes.indexWhere((element) => element.id == note.id);
    note.isDeleted = true;
    state.notes[index] = note;

    emit(state.copyWith());
  }

  void restoreNote(Note note) {
    var index = state.notes.indexWhere((element) => element.id == note.id);
    note.isDeleted = false;
    state.notes[index] = note;

    emit(state.copyWith());
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
