import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/note.dart';

class NotesCubit extends HydratedCubit<List<Note>> {
  NotesCubit() : super([]);

  void addNote(Note note) {
    state.add(note);
    emit(state);
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
    return {'notes': state.map((e) => e.toJson()).toList()};
  }
}
