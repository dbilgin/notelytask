import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/service/navigation_service.dart';
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
  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  @override
  void initState() {
    super.initState();
    getVersion().then((value) => setState(() => version = value));
  }

  Future<void> _onSubmitEncryption(String key) async {
    context.read<NotesCubit>().setEncryptionKey(key);
    await context.read<NotesCubit>().createOrUpdateRemoteNotes();

    if (!mounted) return;
    await context.read<NotesCubit>().getAndUpdateLocalNotes(context: context);
    if (!mounted) return;
    showSnackBar(context, 'Encryption successful.');
  }

  Future<void> _onSubmitDecryption(String key) async {
    final existingKey = context.read<NotesCubit>().state.encryptionKey;
    if (key != existingKey) {
      showSnackBar(context, 'Wrong pin, decryption failed.');
      return;
    }

    context.read<NotesCubit>().setEncryptionKey(null);
    await context.read<NotesCubit>().createOrUpdateRemoteNotes();

    if (!mounted) return;
    await context.read<NotesCubit>().getAndUpdateLocalNotes(context: context);
    if (!mounted) return;
    showSnackBar(context, 'Decryption successful.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Local Storage Section
            _buildSectionHeader(context, 'Local Storage'),
            const SizedBox(height: 12),
            BlocBuilder<LocalFolderCubit, LocalFolderState>(
              builder: (context, folderState) {
                return Card(
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_rounded,
                              size: 24,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Storage Folder',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (folderState.isConnected()) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: colorScheme.primary,
                                child: Icon(
                                  Icons.folder_rounded,
                                  color: colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connected',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (folderState.folderPath != null)
                                      Text(
                                        folderState.folderPath!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<LocalFolderCubit>().reset();
                                showSnackBar(
                                    context, 'Disconnected from folder');
                              },
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Disconnect'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(color: colorScheme.error),
                              ),
                            ),
                          ),
                          BlocBuilder<NotesCubit, NotesState>(
                            builder: (notesContext, notesState) {
                              if (folderState.isConnected()) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    if (notesState.encryptionKey == null)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => encryptionKeyDialog(
                                            context: context,
                                            isPinRequired: false,
                                            title: 'Enter Your Encryption Pin',
                                            text:
                                                'Do not lose this!\nThis will encrypt your notes.',
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
                                                'Decryption will fail if wrong key is entered.',
                                            onSubmit: _onSubmitDecryption,
                                          ),
                                          icon: const Icon(
                                              Icons.lock_open_rounded),
                                          label: const Text('Decrypt Notes'),
                                        ),
                                      ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ] else ...[
                          Text(
                            'Select a folder to store your notes locally.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                getIt<NavigationService>()
                                    .pushNamed('/folder_selection');
                              },
                              icon: const Icon(Icons.folder_open_rounded),
                              label: const Text('Select Folder'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Theme Selection Section
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return Card(
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_rounded,
                              color: colorScheme.onSurface,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Theme',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: AppTheme.values.length,
                          itemBuilder: (context, index) {
                            final themeOption = AppTheme.values[index];
                            final isSelected =
                                settingsState.selectedTheme == themeOption;
                            final colors =
                                ThemeHelper.getThemeColors(themeOption);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context
                                      .read<SettingsCubit>()
                                      .setTheme(themeOption);
                                  showSnackBar(context,
                                      'Theme changed to ${ThemeHelper.getThemeName(themeOption)}');
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colors['surface'],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? colors['primary']!
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Color preview
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                      // Theme name
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 8),
                                        child: Text(
                                          ThemeHelper.getThemeName(themeOption),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colors['primary']
                                                : colorScheme.onSurface,
                                          ),
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
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Privacy & Legal Section
            _buildSectionHeader(context, 'Privacy & Legal'),
            const SizedBox(height: 12),
            Card(
              color: colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_rounded,
                      color: colorScheme.onSurface,
                    ),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Learn how we protect your data'),
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
                            'NotelyTask is a modern note-taking app that helps you capture and organize your thoughts across all your devices.\n\nBuilt with Flutter for a seamless experience on web, mobile, and desktop.',
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
            ),

            const SizedBox(height: 24),

            // Editor Settings Section
            _buildSectionHeader(context, 'Editor'),
            const SizedBox(height: 12),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return Card(
                  color: colorScheme.surface,
                  child: SwitchListTile(
                    secondary: Icon(
                      Icons.preview_rounded,
                      color: colorScheme.onSurface,
                    ),
                    title: const Text('Markdown Preview'),
                    subtitle: const Text('Enable markdown preview mode'),
                    value: settingsState.markdownEnabled,
                    onChanged: (value) {
                      context.read<SettingsCubit>().toggleMarkdown();
                    },
                    activeThumbColor: colorScheme.primary,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}
