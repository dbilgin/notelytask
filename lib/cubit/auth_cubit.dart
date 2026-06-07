import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/service/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.loading()) {
    _initialise();
  }

  StreamSubscription<AuthState>? _authSubscription;

  SupabaseClient? get _client => SupabaseConfig.client;

  void _initialise() {
    final client = _client;
    if (client == null) {
      emit(const AuthState.unconfigured());
      return;
    }

    final currentUser = client.auth.currentUser;
    emit(
      currentUser == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user: currentUser),
    );

    _authSubscription = client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (data.event == AuthChangeEvent.passwordRecovery && user != null) {
        return AuthState.passwordRecovery(user: user);
      }
      if (user == null) {
        return const AuthState.unauthenticated();
      }
      return AuthState.authenticated(user: user);
    }).listen(emit);
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
    });
  }

  Future<void> signOut() async {
    await _runAuthAction(() async {
      await _requireClient().auth.signOut();
      emit(const AuthState.unauthenticated());
    });
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
      emit(
        AuthState.authenticated(
          user: user,
          message: 'Password updated.',
        ),
      );
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    final previous = state;
    emit(const AuthState.loading());
    try {
      await action();
    } on AuthException catch (error) {
      emit(AuthState.unauthenticated(error: error.message));
    } catch (error) {
      emit(AuthState.unauthenticated(error: error.toString()));
    }
    if (state.status == AuthStatus.loading) {
      emit(previous);
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
