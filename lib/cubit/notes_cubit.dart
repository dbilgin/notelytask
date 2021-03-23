import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/note.dart';

class NotesCubit extends HydratedCubit<List<Note>> {
  NotesCubit() : super([]);

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

    emit([...state]);
  }

  void deleteNote(Note note) {
    var index = state.indexWhere((element) => element.id == note.id);
    note.isDeleted = true;
    state[index] = note;
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
