import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  unconfigured,
  loading,
  unauthenticated,
  authenticated,
  passwordRecovery,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? message;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.message,
  });

  const AuthState.unconfigured()
      : status = AuthStatus.unconfigured,
        user = null,
        error = null,
        message = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        error = null,
        message = null;

  const AuthState.unauthenticated({
    this.error,
    this.message,
  })  : status = AuthStatus.unauthenticated,
        user = null;

  const AuthState.authenticated({
    required this.user,
    this.message,
  })  : status = AuthStatus.authenticated,
        error = null;

  const AuthState.passwordRecovery({
    required this.user,
    this.message,
  })  : status = AuthStatus.passwordRecovery,
        error = null;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.passwordRecovery;

  @override
  List<Object?> get props => [
        status,
        user?.id,
        error,
        message,
      ];
}
