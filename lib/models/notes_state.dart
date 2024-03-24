import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notelytask/models/note.dart';

@JsonSerializable()
class NotesState extends Equatable {
  final List<Note> notes;
  final String? encryptionKey;

  const NotesState({
    this.notes = const [],
    this.encryptionKey,
  });

  factory NotesState.fromJson(Map<String, dynamic> json) {
    final notesList = List<Note>.from(
      json['notes'].map((e) => Note.fromJson(e)),
    );
    return NotesState(
      notes: notesList,
      encryptionKey: json['encryptionKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final notesMap = notes.map((e) => e.toJson()).toList();
    return {
      'notes': notesMap,
      'encryptionKey': encryptionKey,
    };
  }

  NotesState copyWith({
    List<Note>? notes,
    String? encryptionKey,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }

  @override
  List<Object?> get props => [
        notes,
        encryptionKey,
      ];
}
