import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  unconfigured,
  loading,
  unauthenticated,
  mfaEnrollmentRequired,
  mfaVerificationRequired,
  authenticated,
  passwordRecovery,
}

class AuthMfaEnrollment extends Equatable {
  final String factorId;
  final String uri;
  final String qrCode;
  final String secret;

  const AuthMfaEnrollment({
    required this.factorId,
    required this.uri,
    required this.qrCode,
    required this.secret,
  });

  @override
  List<Object?> get props => [factorId, uri, qrCode, secret];
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final List<Factor> mfaFactors;
  final AuthMfaEnrollment? mfaEnrollment;
  final String? error;
  final String? message;

  const AuthState({
    required this.status,
    this.user,
    this.mfaFactors = const [],
    this.mfaEnrollment,
    this.error,
    this.message,
  });

  const AuthState.unconfigured()
      : status = AuthStatus.unconfigured,
        user = null,
        mfaFactors = const [],
        mfaEnrollment = null,
        error = null,
        message = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        mfaFactors = const [],
        mfaEnrollment = null,
        error = null,
        message = null;

  const AuthState.unauthenticated({
    this.error,
    this.message,
  })  : status = AuthStatus.unauthenticated,
        user = null,
        mfaFactors = const [],
        mfaEnrollment = null;

  const AuthState.mfaEnrollmentRequired({
    required this.user,
    this.mfaFactors = const [],
    this.mfaEnrollment,
    this.error,
    this.message,
  }) : status = AuthStatus.mfaEnrollmentRequired;

  const AuthState.mfaVerificationRequired({
    required this.user,
    required this.mfaFactors,
    this.error,
    this.message,
  })  : status = AuthStatus.mfaVerificationRequired,
        mfaEnrollment = null;

  const AuthState.authenticated({
    required this.user,
    this.mfaFactors = const [],
    this.message,
  })  : status = AuthStatus.authenticated,
        mfaEnrollment = null,
        error = null;

  const AuthState.passwordRecovery({
    required this.user,
    this.message,
  })  : status = AuthStatus.passwordRecovery,
        mfaFactors = const [],
        mfaEnrollment = null,
        error = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get hasVerifiedTotp => mfaFactors.any(
        (factor) =>
            factor.factorType == FactorType.totp &&
            factor.status == FactorStatus.verified,
      );

  @override
  List<Object?> get props => [
        status,
        user?.id,
        mfaFactors,
        mfaEnrollment,
        error,
        message,
      ];
}
