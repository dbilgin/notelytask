import 'package:equatable/equatable.dart';

class GoogleDriveState extends Equatable {
  final bool loading;
  final bool error;

  final String? accessToken;
  final String? idToken;
  final String? fileId;

  const GoogleDriveState({
    this.loading = false,
    this.error = false,
    this.accessToken,
    this.idToken,
    this.fileId,
  });

  bool isLoggedIn() {
    final idToken = this.idToken;
    final accessToken = this.accessToken;
    final fileId = this.fileId;
    return idToken != null && accessToken != null && fileId != null;
  }

  factory GoogleDriveState.fromJson(Map<String, dynamic> json) {
    return GoogleDriveState(
      loading: json['loading'] as bool? ?? false,
      error: json['error'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      idToken: json['idToken'] as String?,
      fileId: json['fileId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'loading': loading,
        'error': error,
        'accessToken': accessToken,
        'idToken': idToken,
        'fileId': fileId,
      };

  GoogleDriveState copyWith({
    bool? loading,
    bool? error,
    String? accessToken,
    String? idToken,
    String? fileId,
  }) {
    return GoogleDriveState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      fileId: fileId ?? this.fileId,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        accessToken,
        idToken,
        fileId,
      ];
}
