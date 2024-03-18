import 'package:hydrated_bloc/hydrated_bloc.dart';

class SelectedNoteCubit extends HydratedCubit<String?> {
  SelectedNoteCubit() : super(null);

  void setNoteId(String? noteId) {
    emit(noteId);
  }

  @override
  String? fromJson(Map<String, dynamic>? json) {
    var note = json != null ? json['note'] : null;
    return note;
  }

  @override
  Map<String, dynamic>? toJson(String? state) {
    return {'note': state};
  }
}
