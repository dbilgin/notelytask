import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notelytask/theme.dart';

@JsonSerializable()
class SettingsState extends Equatable {
  final String? selectedNoteId;
  final AppTheme selectedTheme;

  const SettingsState({
    this.selectedNoteId,
    this.selectedTheme = AppTheme.defaultDark,
  });

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      selectedNoteId: json['selectedNoteId'] as String?,
      selectedTheme: AppTheme.values.firstWhere(
        (theme) => theme.toString() == json['selectedTheme'],
        orElse: () => AppTheme.defaultDark,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedNoteId': selectedNoteId,
        'selectedTheme': selectedTheme.toString(),
      };

  SettingsState copyWith({
    String? selectedNoteId,
    AppTheme? selectedTheme,
  }) {
    return SettingsState(
      selectedNoteId: selectedNoteId ?? this.selectedNoteId,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  @override
  List<Object?> get props => [
        selectedNoteId,
        selectedTheme,
      ];
}
