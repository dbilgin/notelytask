import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/theme.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void setSelectedNoteId(String? noteId) {
    final newState = SettingsState(
      markdownEnabled: state.markdownEnabled,
      selectedNoteId: noteId,
      selectedTheme: state.selectedTheme,
    );
    emit(newState);
  }

  void toggleMarkdown() {
    final newState = state.copyWith(markdownEnabled: !state.markdownEnabled);
    emit(newState);
  }

  void setTheme(AppTheme theme) {
    final newState = state.copyWith(selectedTheme: theme);
    emit(newState);
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) {
    return SettingsState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return state.toJson();
  }
}
