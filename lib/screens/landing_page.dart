import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notelytask/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static final Uri _latestReleaseUrl = Uri.parse(
    'https://github.com/dbilgin/notelytask/releases/latest',
  );

  void _openLogin(BuildContext context) =>
      Navigator.of(context).pushNamed('/login');
  void _openSignup(BuildContext context) =>
      Navigator.of(context).pushNamed('/signup');
  void _openPrivacy(BuildContext context) =>
      Navigator.of(context).pushNamed('/privacy_policy');
  Future<void> _openLatestRelease() async {
    await launchUrl(
      _latestReleaseUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isCompact = width < 720;
          final heroHeight = isCompact
              ? math.max(560.0, height * 0.86)
              : math.max(600.0, height * 0.78);

          return SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(
                  height: heroHeight,
                  isCompact: isCompact,
                  onLogin: () => _openLogin(context),
                  onSignup: () => _openSignup(context),
                  onPrivacy: () => _openPrivacy(context),
                  onLatestRelease: _openLatestRelease,
                ),
                _FeatureBand(isCompact: isCompact),
                _SecurityBand(isCompact: isCompact),
                _Footer(
                  theme: theme,
                  onLogin: () => _openLogin(context),
                  onSignup: () => _openSignup(context),
                  onPrivacy: () => _openPrivacy(context),
                  onLatestRelease: _openLatestRelease,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.height,
    required this.isCompact,
    required this.onLogin,
    required this.onSignup,
    required this.onPrivacy,
    required this.onLatestRelease,
  });

  final double height;
  final bool isCompact;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onPrivacy;
  final VoidCallback onLatestRelease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _HeroBitmapBackdrop(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.05),
                  colorScheme.surface.withValues(alpha: 0.42),
                  colorScheme.surface.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 20 : 48,
                18,
                isCompact ? 20 : 48,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LandingNav(
                    isCompact: isCompact,
                    onLogin: onLogin,
                    onSignup: onSignup,
                    onPrivacy: onPrivacy,
                  ),
                  const Spacer(),
                  Align(
                    alignment:
                        isCompact ? Alignment.bottomLeft : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isCompact ? 520 : 720,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NotelyTask',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: isCompact ? 54 : 82,
                              height: 0.95,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Private notes that stay quick offline, sync when you are ready, and protect your account with two-factor sign-in.',
                            style: theme.textTheme.titleLarge?.copyWith(
                              height: 1.35,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.86,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: onSignup,
                                icon: const Icon(Icons.person_add_rounded),
                                label: const Text('Create account'),
                              ),
                              OutlinedButton.icon(
                                onPressed: onLogin,
                                icon: const Icon(Icons.login_rounded),
                                label: const Text('Sign in'),
                              ),
                              TextButton.icon(
                                onPressed: onLatestRelease,
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Latest release'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _HeroStats(isCompact: isCompact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBitmapBackdrop extends StatelessWidget {
  const _HeroBitmapBackdrop();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/foreground.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.18),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Image.asset(
            'assets/icon.png',
            fit: BoxFit.none,
            alignment: const Alignment(0.78, -0.18),
            scale: 0.68,
            opacity: const AlwaysStoppedAnimation(0.2),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const _EditorialOverlay(),
        ],
      ),
    );
  }
}

class _EditorialOverlay extends StatelessWidget {
  const _EditorialOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _EditorialPainter(Theme.of(context)));
  }
}

class _EditorialPainter extends CustomPainter {
  const _EditorialPainter(this.theme);

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final success =
        ThemeHelper.getThemeColors(AppTheme.forestGreen)['primary']!;
    final warning = AppColors.warning;

    final washPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withValues(alpha: 0.34),
          success.withValues(alpha: 0.18),
          warning.withValues(alpha: 0.16),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, washPaint);

    final notePaint = Paint()
      ..color = surface.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()
      ..color = secondary.withValues(alpha: 0.56)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final baseX = size.width * 0.58;
    final baseY = size.height * 0.18;
    for (var i = 0; i < 4; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          baseX + i * 34,
          baseY + i * 76,
          math.min(310, size.width * 0.34),
          145,
        ),
        const Radius.circular(8),
      );
      canvas.save();
      canvas.translate(rect.outerRect.center.dx, rect.outerRect.center.dy);
      canvas.rotate((-5 + i * 2.7) * math.pi / 180);
      canvas.translate(-rect.outerRect.center.dx, -rect.outerRect.center.dy);
      canvas.drawRRect(rect, notePaint);
      canvas.drawRRect(rect, strokePaint);
      final left = rect.outerRect.left + 24;
      final top = rect.outerRect.top + 28;
      canvas.drawLine(Offset(left, top), Offset(left + 128, top), accentPaint);
      canvas.drawLine(
        Offset(left, top + 34),
        Offset(left + 218, top + 34),
        linePaint,
      );
      canvas.drawLine(
        Offset(left, top + 64),
        Offset(left + 170, top + 64),
        linePaint,
      );
      canvas.restore();
    }

    final pathPaint = Paint()
      ..color = primary.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.72)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.42,
        size.width * 0.58,
        size.height * 0.8,
        size.width * 0.96,
        size.height * 0.52,
      );
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _EditorialPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

class _LandingNav extends StatelessWidget {
  const _LandingNav({
    required this.isCompact,
    required this.onLogin,
    required this.onSignup,
    required this.onPrivacy,
  });

  final bool isCompact;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Image.asset(
          'assets/icon.png',
          width: 34,
          height: 34,
          errorBuilder: (_, __, ___) => const Icon(Icons.note_alt_rounded),
        ),
        const SizedBox(width: 10),
        Text(
          'NotelyTask',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (!isCompact)
          TextButton(
            onPressed: onPrivacy,
            child: const Text('Privacy'),
          ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onLogin,
          child: const Text('Sign in'),
        ),
        if (!isCompact) ...[
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onSignup,
            child: const Text('Create account'),
          ),
        ],
      ],
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Offline first', Icons.offline_bolt_outlined),
      ('Private cloud sync', Icons.cloud_done_outlined),
      ('PIN encryption', Icons.enhanced_encryption_outlined),
      ('Two-factor sign-in', Icons.verified_user_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => _SignalPill(
              label: item.$1,
              icon: item.$2,
              dense: isCompact,
            ),
          )
          .toList(),
    );
  }
}

class _SignalPill extends StatelessWidget {
  const _SignalPill({
    required this.label,
    required this.icon,
    required this.dense,
  });

  final String label;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 14,
          vertical: dense ? 8 : 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: dense ? 16 : 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FeatureBand extends StatelessWidget {
  const _FeatureBand({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 720
        ? 1
        : width < 1060
            ? 2
            : 4;
    final features = [
      _FeatureCopy(
        icon: Icons.edit_note_rounded,
        title: 'Write offline, sync later',
        body:
            'Keep writing when the connection drops. Your local cache stays fast, then sync catches up when the cloud is reachable.',
      ),
      _FeatureCopy(
        icon: Icons.cloud_queue_rounded,
        title: 'One private cloud note document',
        body:
            'Your notes move as a single private document for your account, with attachments stored separately in private storage.',
      ),
      _FeatureCopy(
        icon: Icons.attach_file_rounded,
        title: 'Attachments without folder setup',
        body:
            'Add images and files to notes without choosing device folders or managing sync directories by hand.',
      ),
      _FeatureCopy(
        icon: Icons.lock_person_rounded,
        title: 'PIN encryption and 2FA',
        body:
            'Encrypt your synced notes with a local PIN and protect account access with an authenticator app.',
      ),
    ];

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 20 : 48,
              isCompact ? 42 : 70,
              isCompact ? 20 : 48,
              isCompact ? 26 : 50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A notes app with a longer memory.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Quiet, practical tools for notes that need to travel with you without giving up privacy.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: isCompact ? 222 : 246,
                  ),
                  itemBuilder: (context, index) =>
                      _FeatureTile(feature: features[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityBand extends StatelessWidget {
  const _SecurityBand({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 48,
              vertical: isCompact ? 40 : 64,
            ),
            child: isCompact
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SecurityCopy(),
                      SizedBox(height: 24),
                      _SecurityList(),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _SecurityCopy()),
                      SizedBox(width: 36),
                      Expanded(flex: 2, child: _SecurityList()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecurityCopy extends StatelessWidget {
  const _SecurityCopy();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secure by habit, not by ceremony.',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Account access requires two-factor authentication, while optional PIN encryption protects the synced note document before it leaves the device.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SecurityList extends StatelessWidget {
  const _SecurityList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SecurityRow(
          icon: Icons.verified_user_rounded,
          title: 'Authenticator-app sign-in',
        ),
        _SecurityRow(
          icon: Icons.lock_rounded,
          title: 'Optional PIN-encrypted sync',
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.theme,
    required this.onLogin,
    required this.onSignup,
    required this.onPrivacy,
    required this.onLatestRelease,
  });

  final ThemeData theme;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onPrivacy;
  final VoidCallback onLatestRelease;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              'NotelyTask',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(onPressed: onPrivacy, child: const Text('Privacy')),
            TextButton(
              onPressed: onLatestRelease,
              child: const Text('Latest release'),
            ),
            TextButton(onPressed: onLogin, child: const Text('Sign in')),
            FilledButton(
              onPressed: onSignup,
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCopy {
  const _FeatureCopy({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _FeatureCopy feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(feature.icon, size: 28, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                feature.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
