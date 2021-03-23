import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/note.dart';

class SelectedNoteCubit extends Cubit<Note?> {
  SelectedNoteCubit() : super(null);

  void setNote(Note? note) {
    emit(note);
  }

  Note? getNote() {
    return state;
  }
}
