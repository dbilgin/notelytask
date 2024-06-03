// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      fileDataList: (json['fileDataList'] as List<dynamic>?)
              ?.map((e) => FileData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          initialFileData,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.text,
      'date': instance.date.toIso8601String(),
      'fileDataList': instance.fileDataList.map((e) => e.toJson()).toList(),
      'isDeleted': instance.isDeleted,
    };
