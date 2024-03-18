import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/util/update_widget.dart';

class NotesCubit extends HydratedCubit<List<Note>> {
  NotesCubit() : super([]);

  @override
  void onChange(Change<List<Note>> change) {
    updateWidget(json.encode(toJson(change.nextState)));
    super.onChange(change);
  }

  String nonExistentFileName({required String fileName}) {
    var files = state.expand((e) => e.fileDataList);
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
    var index = state.indexWhere((element) => element.id == note.id);
    if (note.title.isEmpty && note.text.isEmpty && note.fileDataList.isEmpty) {
      if (index != -1) deleteNotePermanently(note.id);
      return;
    }

    if (index == -1) {
      state.add(note);
    } else {
      state[index] = note;
    }

    emit([...state]);
  }

  void addNoteFileData({
    required String noteId,
    required String fileName,
    required String fileSha,
  }) {
    var noteIndex = state.indexWhere((element) => element.id == noteId);
    if (noteIndex == -1) {
      return;
    }

    state[noteIndex].fileDataList = [
      ...state[noteIndex].fileDataList,
      FileData(name: fileName, sha: fileSha)
    ];
    emit([...state]);
  }

  void deleteNoteFileData(String noteId, String fileName) {
    final index = state.indexWhere((element) => element.id == noteId);
    if (index == -1) {
      return;
    }

    final fileIndex = state[index]
        .fileDataList
        .indexWhere((element) => element.name == fileName);
    state[index].fileDataList.removeAt(fileIndex);

    emit([...state]);
  }

  void deleteNotePermanently(String noteId) {
    var index = state.indexWhere((element) => element.id == noteId);
    state.removeAt(index);

    emit([...state]);
  }

  void deleteNote(Note note) {
    var index = state.indexWhere((element) => element.id == note.id);
    note.isDeleted = true;
    state[index] = note;

    emit([...state]);
  }

  void restoreNote(Note note) {
    var index = state.indexWhere((element) => element.id == note.id);
    note.isDeleted = false;
    state[index] = note;

    emit([...state]);
  }

  @override
  List<Note> fromJson(Map<String, dynamic> json) {
    var list = List<Note>.from(
      json['notes'].map((e) {
        var note = Note.fromJson(e);
        return note;
      }),
    );
    return list;
  }

  @override
  Map<String, dynamic> toJson(List<Note> state) {
    var map = {'notes': state.map((e) => e.toJson()).toList()};
    return map;
  }
}
