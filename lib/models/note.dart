import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notelytask/models/file_data.dart';

part 'note.g.dart';

const List<FileData> initialFileData = [];

@JsonSerializable(explicitToJson: true)
class Note extends Equatable {
  final String id;
  final String title;
  final String text;
  final DateTime date;
  final List<FileData> fileDataList;
  final bool isDeleted;

  const Note({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    this.fileDataList = initialFileData,
    this.isDeleted = false,
  });

  factory Note.generateNew({Note? note}) => Note(
        id: note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: note?.title ?? '',
        text: note?.text ?? '',
        date: note?.date ?? DateTime.now(),
        isDeleted: note?.isDeleted ?? false,
        fileDataList: note?.fileDataList ?? [],
      );

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? title,
    String? text,
    DateTime? date,
    List<FileData>? fileDataList,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      date: date ?? this.date,
      fileDataList: fileDataList ?? this.fileDataList,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        text,
        date,
        fileDataList,
        isDeleted,
      ];
}
