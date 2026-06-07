import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/auth_cubit.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/screens/auth_page.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/screens/mfa_page.dart';

class AuthCallbackPage extends StatelessWidget {
  const AuthCallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          return const HomePage();
        }

        if (state.status == AuthStatus.passwordRecovery) {
          return const AuthPage();
        }

        if (state.status == AuthStatus.mfaEnrollmentRequired ||
            state.status == AuthStatus.mfaVerificationRequired) {
          return const MfaPage();
        }

        if (state.status == AuthStatus.unauthenticated ||
            state.status == AuthStatus.unconfigured) {
          return const AuthPage();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('NotelyTask')),
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Finishing sign-in...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
