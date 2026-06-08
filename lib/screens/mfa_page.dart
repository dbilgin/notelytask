import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notelytask/cubit/auth_cubit.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:pinput/pinput.dart';

class MfaPage extends StatefulWidget {
  const MfaPage({super.key});

  @override
  State<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends State<MfaPage> {
  bool _requestedEnrollment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AuthCubit>().state;
    if (!_requestedEnrollment &&
        state.status == AuthStatus.mfaEnrollmentRequired &&
        state.mfaEnrollment == null) {
      _requestedEnrollment = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AuthCubit>().startRequiredTotpEnrollment();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isEnrollment = state.status == AuthStatus.mfaEnrollmentRequired;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Two-factor authentication'),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEnrollment ? 'Secure your account' : 'Enter your code',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnrollment
                          ? 'Two-factor authentication is required before your notes can sync.'
                          : 'Open your authenticator app and enter the 6-digit code.',
                    ),
                    const SizedBox(height: 24),
                    if (state.error != null) ...[
                      Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (state.message != null) ...[
                      Text(
                        state.message!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isEnrollment)
                      state.mfaEnrollment == null
                          ? _EnrollmentLoading(
                              onRetry: () => context
                                  .read<AuthCubit>()
                                  .startRequiredTotpEnrollment(),
                            )
                          : MfaEnrollmentForm(
                              enrollment: state.mfaEnrollment!,
                              submitLabel: 'Enable and continue',
                              onSubmit: (code) => context
                                  .read<AuthCubit>()
                                  .verifyRequiredTotpEnrollment(code),
                            )
                    else
                      MfaChallengeForm(
                        onSubmit: (code) =>
                            context.read<AuthCubit>().verifyTotpCode(code),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MfaEnrollmentDialog extends StatelessWidget {
  const MfaEnrollmentDialog({
    super.key,
    required this.enrollment,
  });

  final AuthMfaEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add authenticator'),
      content: SizedBox(
        width: 420,
        child: MfaEnrollmentForm(
          enrollment: enrollment,
          submitLabel: 'Verify authenticator',
          onSubmit: (code) async {
            await context.read<AuthCubit>().verifyAdditionalTotpEnrollment(
                  enrollment: enrollment,
                  code: code,
                );
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class MfaEnrollmentForm extends StatefulWidget {
  const MfaEnrollmentForm({
    super.key,
    required this.enrollment,
    required this.submitLabel,
    required this.onSubmit,
  });

  final AuthMfaEnrollment enrollment;
  final String submitLabel;
  final Future<void> Function(String code) onSubmit;

  @override
  State<MfaEnrollmentForm> createState() => _MfaEnrollmentFormState();
}

class _MfaEnrollmentFormState extends State<MfaEnrollmentForm> {
  final _codeController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.string(
                Uri.decodeFull(
                  widget.enrollment.qrCode.replaceFirst(
                    'data:image/svg+xml;utf-8,',
                    '',
                  ),
                ),
                width: 220,
                height: 220,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Scan the QR code in your authenticator app.'),
        const SizedBox(height: 8),
        const Text('Manual setup key'),
        const SizedBox(height: 4),
        SelectableText(
          widget.enrollment.secret,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        const SizedBox(height: 16),
        _MfaCodeInput(controller: _codeController),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.verified_user_outlined),
          label: Text(widget.submitLabel),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(code);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class MfaChallengeForm extends StatefulWidget {
  const MfaChallengeForm({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function(String code) onSubmit;

  @override
  State<MfaChallengeForm> createState() => _MfaChallengeFormState();
}

class _MfaChallengeFormState extends State<MfaChallengeForm> {
  final _codeController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MfaCodeInput(controller: _codeController),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.lock_open_rounded),
          label: const Text('Verify and continue'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(code);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _MfaCodeInput extends StatelessWidget {
  const _MfaCodeInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pinput(
        controller: controller,
        length: 6,
        keyboardType: TextInputType.number,
        autofocus: true,
        closeKeyboardWhenCompleted: true,
      ),
    );
  }
}

class _EnrollmentLoading extends StatelessWidget {
  const _EnrollmentLoading({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = context.watch<AuthCubit>().state.error != null;
    if (hasError) {
      return OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try setup again'),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
