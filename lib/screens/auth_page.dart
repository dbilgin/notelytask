import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/auth_cubit.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/screens/mfa_page.dart';

enum AuthFormMode { signIn, signUp, resetRequest, updatePassword }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AuthFormMode _mode = AuthFormMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.passwordRecovery) {
          setState(() => _mode = AuthFormMode.updatePassword);
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.unconfigured) {
          return const _CloudConfigMissing();
        }
        if (state.status == AuthStatus.mfaEnrollmentRequired ||
            state.status == AuthStatus.mfaVerificationRequired) {
          return const MfaPage();
        }

        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('NotelyTask')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subtitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (_mode != AuthFormMode.updatePassword) ...[
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_mode != AuthFormMode.resetRequest) ...[
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: _mode == AuthFormMode.updatePassword
                                ? 'New password'
                                : 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_mode == AuthFormMode.signUp ||
                          _mode == AuthFormMode.updatePassword) ...[
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                          obscureText: true,
                          validator: _validateConfirmation,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (state.error != null) ...[
                        Text(
                          state.error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (state.message != null) ...[
                        Text(
                          state.message!,
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton.icon(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : () => _submit(context),
                        icon: state.status == AuthStatus.loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_submitIcon),
                        label: Text(_submitLabel),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          if (_mode != AuthFormMode.signIn)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _mode = AuthFormMode.signIn),
                              child: const Text('Sign in'),
                            ),
                          if (_mode != AuthFormMode.signUp)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _mode = AuthFormMode.signUp),
                              child: const Text('Create account'),
                            ),
                          if (_mode != AuthFormMode.resetRequest &&
                              _mode != AuthFormMode.updatePassword)
                            TextButton(
                              onPressed: () => setState(
                                () => _mode = AuthFormMode.resetRequest,
                              ),
                              child: const Text('Reset password'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String get _title {
    switch (_mode) {
      case AuthFormMode.signIn:
        return 'Sign in';
      case AuthFormMode.signUp:
        return 'Create account';
      case AuthFormMode.resetRequest:
        return 'Reset password';
      case AuthFormMode.updatePassword:
        return 'Choose a new password';
    }
  }

  String get _subtitle {
    switch (_mode) {
      case AuthFormMode.signIn:
        return 'Use your email and password to sync notes to the cloud.';
      case AuthFormMode.signUp:
        return 'Email confirmation is required before your first sign-in.';
      case AuthFormMode.resetRequest:
        return 'We will send a password reset link to your email.';
      case AuthFormMode.updatePassword:
        return 'Enter a new password for your account.';
    }
  }

  String get _submitLabel {
    switch (_mode) {
      case AuthFormMode.signIn:
        return 'Sign in';
      case AuthFormMode.signUp:
        return 'Create account';
      case AuthFormMode.resetRequest:
        return 'Send reset link';
      case AuthFormMode.updatePassword:
        return 'Update password';
    }
  }

  IconData get _submitIcon {
    switch (_mode) {
      case AuthFormMode.signIn:
        return Icons.login_rounded;
      case AuthFormMode.signUp:
        return Icons.person_add_alt_rounded;
      case AuthFormMode.resetRequest:
        return Icons.mark_email_read_outlined;
      case AuthFormMode.updatePassword:
        return Icons.lock_reset_rounded;
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authCubit = context.read<AuthCubit>();
    switch (_mode) {
      case AuthFormMode.signIn:
        await authCubit.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        break;
      case AuthFormMode.signUp:
        await authCubit.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        break;
      case AuthFormMode.resetRequest:
        await authCubit.sendPasswordReset(_emailController.text.trim());
        break;
      case AuthFormMode.updatePassword:
        await authCubit.updatePassword(_passwordController.text);
        break;
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      return 'Enter a valid email.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }
}

class _CloudConfigMissing extends StatelessWidget {
  const _CloudConfigMissing();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NotelyTask')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Cloud sync is not configured. Check the app configuration and try again.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
