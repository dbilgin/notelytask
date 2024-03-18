import 'package:json_annotation/json_annotation.dart';
import 'package:notelytask/models/file_data.dart';

part 'note.g.dart';

const List<FileData> initialFileData = [];

@JsonSerializable()
class Note {
  final String id;
  final String title;
  final String text;
  final DateTime date;
  List<FileData> fileDataList;
  bool isDeleted;

  Note({
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
        date: DateTime.now(),
        isDeleted: note?.isDeleted ?? false,
        fileDataList: note?.fileDataList ?? [],
      );

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
