import 'package:equatable/equatable.dart';
import 'package:notelytask/models/note.dart';

class NotesState extends Equatable {
  final List<Note> notes;

  const NotesState({
    this.notes = const [],
  });

  factory NotesState.fromJson(Map<String, dynamic> json) {
    final notesList = List<Note>.from(
      json['notes'].map((e) => Note.fromJson(e)),
    );
    return NotesState(
      notes: notesList,
    );
  }

  Map<String, dynamic> toJson() {
    final notesMap = notes.map((e) => e.toJson()).toList();
    return {
      'notes': notesMap,
    };
  }

  NotesState copyWith({
    List<Note>? notes,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        notes,
      ];
}
