import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/note.dart';

class SelectedNoteCubit extends HydratedCubit<Note?> {
  SelectedNoteCubit() : super(null);

  void setNote(Note? note) {
    emit(note);
  }

  @override
  Note? fromJson(Map<String, dynamic>? json) {
    var note = json != null ? Note.fromJson(json) : null;
    return note;
  }

  @override
  Map<String, dynamic>? toJson(Note? state) {
    return state?.toJson();
  }
}
