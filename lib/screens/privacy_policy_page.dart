import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Privacy Policy',
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
            Card(
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy for NotelyTask',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: ${DateTime.now().year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      'Introduction',
                      'NotelyTask ("we", "our", or "us") is a privacy-first note-taking application. Unlike most apps, we do NOT collect, store, or process your personal data on our servers. This Privacy Policy explains our minimal data practices and your complete control over your information.',
                    ),
                    _buildSection(
                      context,
                      'What We DON\'T Collect',
                      '''NotelyTask is designed with zero data collection:

• **No Server Storage**: We do not store any of your notes, content, or personal data on our servers
• **No Telemetry**: We do not collect usage analytics, crash reports, or behavioral data
• **No Tracking**: We do not track your activity or use cookies for tracking
• **No Personal Information**: We do not collect names, emails, or any identifying information
• **No Device Data**: We do not collect device information or technical specifications

**What Stays Local:**
• All your notes and content remain on your device
• App settings and preferences are stored locally
• GitHub access tokens (when used) are stored securely on your device only''',
                    ),
                    _buildSection(
                      context,
                      'How Your Data Works',
                      '''NotelyTask operates entirely on your device:

• **Local Processing**: All note editing, searching, and organization happens locally
• **No Cloud Dependency**: The app works completely offline
• **Optional GitHub Sync**: You can optionally sync to YOUR GitHub repository (under your control)
• **No Third-Party Services**: We don't use analytics, advertising, or tracking services

**Our Backend Service:**
Our open-source backend (github.com/dbilgin/notelytask-backend) only:
• Facilitates GitHub OAuth login flow
• Has no database or data storage
• Processes no personal information
• Is completely stateless''',
                    ),
                    _buildSection(
                      context,
                      'Data Storage and Security',
                      '''• **100% Local Storage**: Your notes are stored exclusively on your device
• **No Server Storage**: We have no servers storing your personal data
• **GitHub Integration**: Optional sync to YOUR GitHub repository (you maintain full control)
• **Open Source**: Our backend is open source and auditable at github.com/dbilgin/notelytask-backend
• **No Encryption Needed**: Since we don't store your data, there's no server-side data to encrypt
• **Device Security**: Your data security depends on your device's security measures''',
                    ),
                    _buildSection(
                      context,
                      'GitHub Integration',
                      '''When you choose to connect GitHub:

• **Your Repository**: Notes sync to a repository YOU own and control
• **Minimal Permissions**: We request only repository access permissions
• **Local Token Storage**: GitHub access tokens are stored only on your device
• **No Server Processing**: Our backend only facilitates the OAuth flow, no data processing
• **Full Control**: You can revoke access anytime through GitHub settings
• **GitHub's Policies**: GitHub interactions are subject to GitHub's privacy policies
• **Open Source Backend**: Our OAuth service is open source and auditable''',
                    ),
                    _buildSection(
                      context,
                      'Data Retention',
                      '''• **Device Storage**: Notes remain on your device until you delete them
• **No Server Retention**: We retain no data on our servers (because we store none)
• **Deleted Notes**: Deleted notes are moved to local "deleted" state and can be permanently removed
• **GitHub Data**: Any synced data follows your GitHub repository settings
• **Complete Removal**: Uninstalling the app removes all local data
• **No Backup Concerns**: We have no server backups to worry about''',
                    ),
                    _buildSection(
                      context,
                      'Your Rights',
                      '''You have the right to:

• Access all your data stored in the app
• Export your notes at any time
• Delete your notes and app data
• Disconnect GitHub integration
• Request information about data processing
• Contact us with privacy concerns''',
                    ),
                    _buildSection(
                      context,
                      'Third-Party Services',
                      '''NotelyTask has minimal third-party integration:

• **GitHub**: Optional integration for note sync (direct to YOUR repository)
• **Our Backend**: Open-source OAuth service (github.com/dbilgin/notelytask-backend)
• **Flutter Framework**: App development framework by Google
• **No Analytics**: We use no analytics services (Google Analytics, etc.)
• **No Advertising**: We use no advertising networks or tracking
• **No Data Sharing**: We have no data to share with third parties''',
                    ),
                    _buildSection(
                      context,
                      'Children\'s Privacy',
                      'NotelyTask is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us immediately.',
                    ),
                    _buildSection(
                      context,
                      'Changes to This Policy',
                      'We may update this Privacy Policy from time to time. We will notify users of any material changes through the app or other appropriate means. Your continued use of the app after changes constitutes acceptance of the updated policy.',
                    ),
                    _buildSection(
                      context,
                      'Contact Us',
                      '''If you have questions about this Privacy Policy or our data practices:

• **GitHub Issues**: Open an issue on our repository
• **Source Code**: Review our open-source backend at github.com/dbilgin/notelytask-backend
• **Transparency**: All our server code is public and auditable

Since we collect no personal data, most privacy concerns don't apply to NotelyTask.''',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'True Privacy: NotelyTask stores ZERO data on our servers. Your notes stay on your device or in your GitHub repository. No tracking, no telemetry, no data collection.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
