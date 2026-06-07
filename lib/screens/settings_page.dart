import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/auth_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/cubit/supabase_sync_cubit.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/models/sync_state.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/screens/mfa_page.dart';
import 'package:notelytask/theme.dart';
import 'package:notelytask/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String version = '';
  bool _mfaBusy = false;

  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}${packageInfo.buildNumber.isNotEmpty ? '+' : ''}${packageInfo.buildNumber}';
  }

  @override
  void initState() {
    super.initState();
    getVersion().then((value) {
      if (mounted) {
        setState(() => version = value);
      }
    });
  }

  Future<void> _onSubmitEncryption(String key) async {
    final notesCubit = context.read<NotesCubit>();
    await notesCubit.setEncryptionKey(key);
    await notesCubit.createOrUpdateRemoteNotes();

    if (!mounted) return;
    await notesCubit.getAndUpdateLocalNotes(context: context);
    if (!mounted) return;
    showSnackBar(context, 'Encryption successful.');
  }

  Future<void> _onSubmitDecryption(String key) async {
    final existingKey = context.read<NotesCubit>().state.encryptionKey;
    if (key != existingKey) {
      showSnackBar(context, 'Wrong pin, decryption failed.');
      return;
    }

    final notesCubit = context.read<NotesCubit>();
    await notesCubit.setEncryptionKey(null);
    await notesCubit.createOrUpdateRemoteNotes();

    if (!mounted) return;
    await notesCubit.getAndUpdateLocalNotes(context: context);
    if (!mounted) return;
    showSnackBar(context, 'Decryption successful.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Cloud Sync'),
            const SizedBox(height: 12),
            _buildSyncCard(colorScheme: colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Security'),
            const SizedBox(height: 12),
            _buildSecurityCard(colorScheme: colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            _ThemeCard(colorScheme: colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Privacy & Legal'),
            const SizedBox(height: 12),
            _PrivacyCard(colorScheme: colorScheme, version: version),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _addAuthenticator() async {
    final authCubit = context.read<AuthCubit>();
    setState(() => _mfaBusy = true);
    AuthMfaEnrollment? enrollment;
    try {
      enrollment = await authCubit.createTotpEnrollment();
      if (!mounted) return;
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => MfaEnrollmentDialog(enrollment: enrollment!),
      );
      if (verified != true) {
        await authCubit.cancelTotpEnrollment(enrollment);
      }
      if (!mounted) return;
      if (verified == true) {
        showSnackBar(context, 'Authenticator added.');
      }
    } catch (error) {
      if (!mounted) return;
      showSnackBar(context, error.toString());
      if (enrollment != null) {
        await authCubit.cancelTotpEnrollment(enrollment);
      }
    } finally {
      if (mounted) {
        setState(() => _mfaBusy = false);
      }
    }
  }

  Future<void> _removeAuthenticator(String factorId) async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.mfaFactors.length <= 1) {
      showSnackBar(
        context,
        'Add another authenticator before removing this one.',
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove authenticator?'),
        content: const Text(
          'This authenticator will no longer work for sign-in codes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    setState(() => _mfaBusy = true);
    try {
      await authCubit.unenrollFactor(factorId);
      if (!mounted) return;
      showSnackBar(context, 'Authenticator removed.');
    } catch (error) {
      if (!mounted) return;
      showSnackBar(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => _mfaBusy = false);
      }
    }
  }

  Widget _buildSyncCard({required ColorScheme colorScheme}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.email ?? 'Signed in',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          BlocBuilder<SupabaseSyncCubit, SyncState>(
                            builder: (context, syncState) {
                              return Text(
                                syncState.dirty
                                    ? 'Local changes waiting to sync'
                                    : 'Notes sync to the cloud',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<NotesCubit, NotesState>(
              builder: (context, notesState) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context
                            .read<NotesCubit>()
                            .getAndUpdateLocalNotes(context: context),
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Sync Now'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (notesState.encryptionKey == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => encryptionKeyDialog(
                            context: context,
                            isPinRequired: false,
                            title: 'Enter Your Encryption Pin',
                            text:
                                'Do not lose this. It encrypts your synced notes.',
                            onSubmit: _onSubmitEncryption,
                          ),
                          icon: const Icon(Icons.lock_rounded),
                          label: const Text('Encrypt Notes'),
                        ),
                      ),
                    if (notesState.encryptionKey != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => encryptionKeyDialog(
                            context: context,
                            isPinRequired: false,
                            title: 'Enter Your Encryption Pin',
                            text:
                                'Decryption will fail if the wrong key is entered.',
                            onSubmit: _onSubmitDecryption,
                          ),
                          icon: const Icon(Icons.lock_open_rounded),
                          label: const Text('Decrypt Notes'),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthCubit>().signOut();
                  if (context.mounted) {
                    getIt<NavigationService>().pushNamed('/');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard({required ColorScheme colorScheme}) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final factors = authState.mfaFactors;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.secondary,
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two-factor authentication',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Required for cloud notes and attachments',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (factors.isEmpty)
                  const Text('No verified authenticator is available.')
                else
                  ...factors.map(
                    (factor) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.password_rounded),
                      title: Text(
                        factor.friendlyName?.isNotEmpty == true
                            ? factor.friendlyName!
                            : 'Authenticator app',
                      ),
                      subtitle: Text(
                        'Added ${factor.createdAt.toLocal().toString().split(".").first}',
                      ),
                      trailing: IconButton(
                        tooltip: factors.length <= 1
                            ? 'Add another authenticator before removing this one'
                            : 'Remove authenticator',
                        onPressed: _mfaBusy || factors.length <= 1
                            ? null
                            : () => _removeAuthenticator(factor.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _mfaBusy ? null : _addAuthenticator,
                    icon: _mfaBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_moderator_outlined),
                    label: const Text('Add Authenticator'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: AppTheme.values.length,
              itemBuilder: (context, index) {
                final themeOption = AppTheme.values[index];
                final isSelected = settingsState.selectedTheme == themeOption;
                final colors = ThemeHelper.getThemeColors(themeOption);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.read<SettingsCubit>().setTheme(themeOption);
                      showSnackBar(
                        context,
                        'Theme changed to ${ThemeHelper.getThemeName(themeOption)}',
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors['surface'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors['primary']!
                              : colorScheme.onSurface.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    colors['primary']!,
                                    colors['secondary']!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: isSelected
                                  ? const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Text(
                              ThemeHelper.getThemeName(themeOption),
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.colorScheme,
    required this.version,
  });

  final ColorScheme colorScheme;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorScheme.surface,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.privacy_tip_rounded,
              color: colorScheme.onSurface,
            ),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Learn how your data is handled'),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
            onTap: () {
              getIt<NavigationService>().pushNamed('/privacy_policy');
            },
          ),
          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.info_rounded,
              color: colorScheme.onSurface,
            ),
            title: const Text('About NotelyTask'),
            subtitle: Text('Version $version'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About NotelyTask'),
                  content: const Text(
                    'NotelyTask is a note-taking app with cloud sync, email/password accounts, and an offline local cache.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
