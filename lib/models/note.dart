import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String title;
  final String text;
  final DateTime date;
  bool isDeleted;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    this.isDeleted = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

// flutter packages pub run build_runner build
