import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/repository/google_drive_repo.dart';

class NotesCubit extends HydratedCubit<List<Note>> {
  NotesCubit({
    required GoogleDriveRepo googleDriveRepo,
  })   : _googleDriveRepo = googleDriveRepo,
        super([]) {
    _googleDriveRepo.listenDriveEnabled((value) {
      if (!value) {
        _googleDriveRepo.removeAll();
      } else {
        _driveUploadHandler(state);
      }
    });

    _setInitialFromDrive();
  }

  final GoogleDriveRepo _googleDriveRepo;

  Future<void> _setInitialFromDrive() async {
    if (_googleDriveRepo.isDriveUploadEnabled()) {
      var mapped = await _googleDriveRepo.readNoteFile();
      if (mapped == null) return;

      List<Note> listData = fromJson(mapped);
      emit(listData);
    }
  }

  void _driveUploadHandler(List<Note> newState) async {
    if (!_googleDriveRepo.isDriveUploadEnabled()) {
      return;
    }

    var stringified = json.encode(toJson(newState));
    _googleDriveRepo.sendToDrive(stringified);
  }

  void setNote(Note note) {
    var index = state.indexWhere((element) => element.id == note.id);
    if (note.title.isEmpty && note.text.isEmpty) {
      if (index != -1) deleteNote(note);
      return;
    }

    if (index == -1) {
      state.add(note);
    } else {
      state[index] = note;
    }

    var newState = [...state];
    _driveUploadHandler(newState);
    emit([...state]);
  }

  void deleteNote(Note note) {
    var index = state.indexWhere((element) => element.id == note.id);
    note.isDeleted = true;
    state[index] = note;

    var newState = [...state];
    _driveUploadHandler(newState);
    emit([...state]);
  }

  @override
  List<Note> fromJson(Map<String, dynamic> json) {
    return List<Note>.from(
      json['notes'].map((e) {
        var note = Note.fromJson(e);
        return note;
      }),
    );
  }

  @override
  Map<String, dynamic> toJson(List<Note> state) {
    var map = {'notes': state.map((e) => e.toJson()).toList()};
    return map;
  }
}
