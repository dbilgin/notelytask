import 'package:equatable/equatable.dart';

class LocalFolderState extends Equatable {
  final bool loading;
  final bool error;
  final String? folderPath;

  const LocalFolderState({
    this.loading = false,
    this.error = false,
    this.folderPath,
  });

  bool isConnected() {
    return folderPath != null;
  }

  factory LocalFolderState.fromJson(Map<String, dynamic> json) {
    return LocalFolderState(
      loading: json['loading'] as bool? ?? false,
      error: json['error'] as bool? ?? false,
      folderPath: json['folderPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'loading': loading,
        'error': error,
        'folderPath': folderPath,
      };

  LocalFolderState copyWith({
    bool? loading,
    bool? error,
    String? folderPath,
  }) {
    return LocalFolderState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      folderPath: folderPath ?? this.folderPath,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        folderPath,
      ];
}
