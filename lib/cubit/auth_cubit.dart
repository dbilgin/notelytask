import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/service/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.loading()) {
    _initialise();
  }

  StreamSubscription<dynamic>? _authSubscription;
  int _mfaEvaluationId = 0;

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> _initialise() async {
    final client = _client;
    if (client == null) {
      emit(const AuthState.unconfigured());
      return;
    }

    await _safeRefreshMfaState();

    _authSubscription = client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;
      if (data.event == AuthChangeEvent.passwordRecovery && user != null) {
        emit(AuthState.passwordRecovery(user: user));
        return;
      }
      if (user == null) {
        emit(const AuthState.unauthenticated());
        return;
      }
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.userUpdated ||
          data.event == AuthChangeEvent.mfaChallengeVerified) {
        await _safeRefreshMfaState(refreshFactors: true);
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      await _requireClient().auth.signUp(
            email: email,
            password: password,
            emailRedirectTo: SupabaseConfig.authCallbackUrl,
          );
      emit(
        const AuthState.unauthenticated(
          message: 'Check your email to confirm your account.',
        ),
      );
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      await _requireClient().auth.signInWithPassword(
            email: email,
            password: password,
          );
      await refreshMfaState(refreshFactors: true);
    });
  }

  Future<void> signOut() async {
    await _runAuthAction(() async {
      await _requireClient().auth.signOut();
      emit(const AuthState.unauthenticated());
    });
  }

  Future<void> clearDeletedAccountSession() async {
    try {
      await _requireClient().auth.signOut();
    } catch (_) {
      // The auth user has already been removed server-side.
    }
    emit(const AuthState.unauthenticated(message: 'Account deleted.'));
  }

  Future<void> sendPasswordReset(String email) async {
    await _runAuthAction(() async {
      await _requireClient().auth.resetPasswordForEmail(
            email,
            redirectTo: SupabaseConfig.authCallbackUrl,
          );
      emit(
        const AuthState.unauthenticated(
          message: 'Check your email for the password reset link.',
        ),
      );
    });
  }

  Future<void> updatePassword(String password) async {
    await _runAuthAction(() async {
      final response = await _requireClient().auth.updateUser(
            UserAttributes(password: password),
          );
      final user = response.user ?? _requireClient().auth.currentUser;
      if (user == null) {
        emit(const AuthState.unauthenticated());
        return;
      }
      await refreshMfaState(
        message: 'Password updated.',
        refreshFactors: true,
      );
    });
  }

  Future<void> refreshMfaState({
    String? message,
    bool refreshFactors = false,
  }) async {
    final evaluationId = ++_mfaEvaluationId;
    final client = _requireClient();
    final user = client.auth.currentUser;
    if (user == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    final refreshedFactors =
        refreshFactors ? await client.auth.mfa.listFactors() : null;
    if (evaluationId != _mfaEvaluationId || isClosed) {
      return;
    }

    final currentUser = client.auth.currentUser ?? user;
    final allFactors = refreshedFactors?.all ?? currentUser.factors ?? [];
    final verifiedTotp = refreshedFactors?.totp ?? _verifiedTotp(allFactors);
    if (verifiedTotp.isEmpty) {
      emit(
        AuthState.mfaEnrollmentRequired(
          user: currentUser,
          mfaFactors: allFactors,
          message: message,
        ),
      );
      return;
    }

    final assurance = client.auth.mfa.getAuthenticatorAssuranceLevel();
    if (assurance.currentLevel != AuthenticatorAssuranceLevels.aal2) {
      emit(
        AuthState.mfaVerificationRequired(
          user: currentUser,
          mfaFactors: verifiedTotp,
          message: message,
        ),
      );
      return;
    }

    emit(
      AuthState.authenticated(
        user: currentUser,
        mfaFactors: verifiedTotp,
        message: message,
      ),
    );
  }

  Future<void> _safeRefreshMfaState({
    String? message,
    bool refreshFactors = false,
  }) async {
    try {
      await refreshMfaState(
        message: message,
        refreshFactors: refreshFactors,
      );
    } on AuthException catch (error) {
      emit(AuthState.unauthenticated(error: error.message));
    } catch (error) {
      emit(AuthState.unauthenticated(error: error.toString()));
    }
  }

  List<Factor> _verifiedTotp(List<Factor> factors) {
    return factors
        .where(
          (factor) =>
              factor.factorType == FactorType.totp &&
              factor.status == FactorStatus.verified,
        )
        .toList();
  }

  Future<void> startRequiredTotpEnrollment() async {
    final previous = state;
    if (previous.status != AuthStatus.mfaEnrollmentRequired) {
      return;
    }
    await _runAuthAction(() async {
      final enrollment = await createTotpEnrollment();
      emit(
        AuthState.mfaEnrollmentRequired(
          user: previous.user!,
          mfaFactors: previous.mfaFactors,
          mfaEnrollment: enrollment,
        ),
      );
    }, loadingState: previous);
  }

  Future<AuthMfaEnrollment> createTotpEnrollment() async {
    final response = await _requireClient().auth.mfa.enroll(
          issuer: 'NotelyTask',
          friendlyName: 'Authenticator app',
        );
    final totp = response.totp;
    if (totp == null) {
      throw const AuthException('Authenticator setup did not return a secret.');
    }
    return AuthMfaEnrollment(
      factorId: response.id,
      uri: totp.uri,
      qrCode: totp.qrCode,
      secret: totp.secret,
    );
  }

  Future<void> verifyRequiredTotpEnrollment(String code) async {
    final enrollment = state.mfaEnrollment;
    if (enrollment == null) {
      emit(
        AuthState.mfaEnrollmentRequired(
          user: state.user!,
          mfaFactors: state.mfaFactors,
          error: 'Authenticator setup is not ready yet.',
        ),
      );
      return;
    }
    await _runAuthAction(() async {
      await _requireClient().auth.mfa.challengeAndVerify(
            factorId: enrollment.factorId,
            code: code,
          );
      await refreshMfaState(
        message: 'Two-factor authentication enabled.',
        refreshFactors: true,
      );
    }, loadingState: state);
  }

  Future<void> verifyTotpCode(String code, {String? factorId}) async {
    final selectedFactorId = factorId ??
        state.mfaFactors
            .where((factor) => factor.factorType == FactorType.totp)
            .map((factor) => factor.id)
            .firstOrNull;
    if (selectedFactorId == null) {
      emit(
        AuthState.mfaEnrollmentRequired(
          user: state.user!,
          mfaFactors: state.mfaFactors,
          error: 'Set up an authenticator app before verifying.',
        ),
      );
      return;
    }
    await _runAuthAction(() async {
      await _requireClient().auth.mfa.challengeAndVerify(
            factorId: selectedFactorId,
            code: code,
          );
      await refreshMfaState(refreshFactors: true);
    }, loadingState: state);
  }

  Future<void> verifyAdditionalTotpEnrollment({
    required AuthMfaEnrollment enrollment,
    required String code,
  }) async {
    await _requireClient().auth.mfa.challengeAndVerify(
          factorId: enrollment.factorId,
          code: code,
        );
    await refreshMfaState(
      message: 'Authenticator added.',
      refreshFactors: true,
    );
  }

  Future<void> cancelTotpEnrollment(AuthMfaEnrollment enrollment) async {
    try {
      await _requireClient().auth.mfa.unenroll(enrollment.factorId);
      await refreshMfaState(refreshFactors: true);
    } catch (_) {
      await refreshMfaState(refreshFactors: true);
    }
  }

  Future<void> unenrollFactor(String factorId) async {
    final verifiedTotp = state.mfaFactors
        .where(
          (factor) =>
              factor.factorType == FactorType.totp &&
              factor.status == FactorStatus.verified,
        )
        .toList();
    if (verifiedTotp.length <= 1) {
      emit(
        AuthState.authenticated(
          user: state.user!,
          mfaFactors: state.mfaFactors,
          message: 'Add another authenticator before removing this one.',
        ),
      );
      return;
    }
    await _runAuthAction(() async {
      await _requireClient().auth.mfa.unenroll(factorId);
      await refreshMfaState(
        message: 'Authenticator removed.',
        refreshFactors: true,
      );
    });
  }

  Future<void> _runAuthAction(
    Future<void> Function() action, {
    AuthState? loadingState,
  }) async {
    final previous = loadingState ?? state;
    emit(
      previous.status == AuthStatus.mfaEnrollmentRequired ||
              previous.status == AuthStatus.mfaVerificationRequired
          ? AuthState(
              status: previous.status,
              user: previous.user,
              mfaFactors: previous.mfaFactors,
              mfaEnrollment: previous.mfaEnrollment,
            )
          : const AuthState.loading(),
    );
    try {
      await action();
    } on AuthException catch (error) {
      emit(_stateWithError(previous, error.message));
    } catch (error) {
      emit(_stateWithError(previous, error.toString()));
    }
    if (state.status == AuthStatus.loading) {
      emit(previous);
    }
  }

  AuthState _stateWithError(AuthState previous, String error) {
    switch (previous.status) {
      case AuthStatus.mfaEnrollmentRequired:
        return AuthState.mfaEnrollmentRequired(
          user: previous.user!,
          mfaFactors: previous.mfaFactors,
          mfaEnrollment: previous.mfaEnrollment,
          error: error,
        );
      case AuthStatus.mfaVerificationRequired:
        return AuthState.mfaVerificationRequired(
          user: previous.user!,
          mfaFactors: previous.mfaFactors,
          error: error,
        );
      case AuthStatus.authenticated:
        return AuthState.authenticated(
          user: previous.user!,
          mfaFactors: previous.mfaFactors,
          message: error,
        );
      default:
        return AuthState.unauthenticated(error: error);
    }
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw const AuthException('Cloud sync is not configured.');
    }
    return client;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
