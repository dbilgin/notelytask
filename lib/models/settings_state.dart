import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notelytask/theme.dart';

@JsonSerializable()
class SettingsState extends Equatable {
  final String? selectedNoteId;
  final bool markdownEnabled;
  final AppTheme selectedTheme;

  const SettingsState({
    this.selectedNoteId,
    this.markdownEnabled = false,
    this.selectedTheme = AppTheme.defaultDark,
  });

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      selectedNoteId: json['selectedNoteId'] as String?,
      markdownEnabled: json['markdownEnabled'] as bool? ?? false,
      selectedTheme: AppTheme.values.firstWhere(
        (theme) => theme.toString() == json['selectedTheme'],
        orElse: () => AppTheme.defaultDark,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedNoteId': selectedNoteId,
        'markdownEnabled': markdownEnabled,
        'selectedTheme': selectedTheme.toString(),
      };

  SettingsState copyWith({
    String? selectedNoteId,
    bool? markdownEnabled,
    AppTheme? selectedTheme,
  }) {
    return SettingsState(
      selectedNoteId: selectedNoteId ?? this.selectedNoteId,
      markdownEnabled: markdownEnabled ?? this.markdownEnabled,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  @override
  List<Object?> get props => [
        selectedNoteId,
        markdownEnabled,
        selectedTheme,
      ];
}
