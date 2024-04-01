import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SettingsState extends Equatable {
  final String? selectedNoteId;
  final bool markdownEnabled;

  const SettingsState({
    this.selectedNoteId,
    this.markdownEnabled = false,
  });

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      selectedNoteId: json['selectedNoteId'] as String?,
      markdownEnabled: json['markdownEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedNoteId': selectedNoteId,
        'markdownEnabled': markdownEnabled,
      };

  SettingsState copyWith({
    String? selectedNoteId,
    bool? markdownEnabled,
  }) {
    return SettingsState(
      selectedNoteId: selectedNoteId ?? this.selectedNoteId,
      markdownEnabled: markdownEnabled ?? this.markdownEnabled,
    );
  }

  @override
  List<Object?> get props => [
        selectedNoteId,
        markdownEnabled,
      ];
}
