// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) {
  return Note(
    id: json['id'] as String,
    title: json['title'] as String,
    text: json['text'] as String,
    date: DateTime.parse(json['date'] as String),
    isDeleted: json['isDeleted'] as bool,
  );
}

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.text,
      'date': instance.date.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
