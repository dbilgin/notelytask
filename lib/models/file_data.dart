import 'package:json_annotation/json_annotation.dart';

part 'file_data.g.dart';

@JsonSerializable(explicitToJson: true)
class FileData {
  final String name;
  final String sha;

  FileData({
    required this.name,
    required this.sha,
  });

  factory FileData.fromJson(Map<String, dynamic> json) =>
      _$FileDataFromJson(json);
  Map<String, dynamic> toJson() => _$FileDataToJson(this);
}
