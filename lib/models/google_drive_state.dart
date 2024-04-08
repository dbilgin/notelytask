import 'package:equatable/equatable.dart';

class GoogleDriveState extends Equatable {
  final bool loading;
  final bool error;

  final String? accessToken;
  final String? idToken;

  const GoogleDriveState({
    this.loading = false,
    this.error = false,
    this.accessToken,
    this.idToken,
  });

  factory GoogleDriveState.fromJson(Map<String, dynamic> json) {
    return GoogleDriveState(
      loading: json['loading'] as bool? ?? false,
      error: json['error'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      idToken: json['idToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'loading': loading,
        'error': error,
        'accessToken': accessToken,
        'idToken': idToken,
      };

  GoogleDriveState copyWith({
    bool? loading,
    bool? error,
    String? accessToken,
    String? idToken,
  }) {
    return GoogleDriveState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        accessToken,
        idToken,
      ];
}
