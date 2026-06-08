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
                      'NotelyTask ("we", "our", or "us") is a note-taking application that syncs your notes to your cloud account when you sign in. This Privacy Policy explains what data is processed for account access, note sync, and attachments.',
                    ),
                    _buildSection(
                      context,
                      'What We Collect',
                      '''NotelyTask keeps data collection limited to the app experience:

• **Account Information**: Your account service stores your email address and password credentials for login
• **Two-Factor Authentication**: Your account service stores authenticator-app factor metadata for required sign-in verification
• **Synced Notes**: Your notes are stored as one per-user note document in cloud storage
• **Attachments**: Files you attach to notes are stored in private cloud storage
• **Local Cache**: Notes are also cached locally on your device for offline use
• **No Telemetry**: We do not collect usage analytics, crash reports, or behavioral data
• **No Tracking**: We do not track your activity or use cookies for tracking
• **No Advertising**: We do not use advertising networks''',
                    ),
                    _buildSection(
                      context,
                      'How Your Data Works',
                      '''NotelyTask uses a cloud sync service for account-based sync:

• **Email Login**: You create and access your account with email and password
• **Email Confirmation**: New accounts require email confirmation
• **Two-Factor Authentication**: Cloud notes and attachments require an authenticator-app code after login
• **Password Reset**: Password reset links are sent by email
• **Offline Editing**: Text notes are cached locally and can be edited while offline
• **Cloud Sync**: Local note changes sync to your cloud account when the app can connect''',
                    ),
                    _buildSection(
                      context,
                      'Data Storage and Security',
                      '''• **Account Security**: Passwords are handled by the account service, not stored directly by the app
• **Access Controls**: Cloud database policies restrict each user to their own note document and require completed two-factor authentication
• **Private Storage**: Attachment storage is scoped to the signed-in user and requires completed two-factor authentication
• **PIN Encryption**: When enabled, your note document is encrypted before it is synced
• **Local Cache**: Your device keeps an offline copy of notes for app functionality
• **Device Security**: Local cache security also depends on your device security''',
                    ),
                    _buildSection(
                      context,
                      'Cloud Services',
                      '''NotelyTask uses a cloud provider for authentication, two-factor authentication, database storage, file storage, and email delivery for account flows. The provider processes the information required to provide these services, including account email, authentication metadata, note document storage, and attachment storage.''',
                    ),
                    _buildSection(
                      context,
                      'Data Retention',
                      '''• **Account Data**: Account data remains in the cloud service while your account exists
• **Synced Notes**: Synced notes remain until you delete them or your account data is removed
• **Deleted Notes**: Deleted notes are moved to the app's deleted state and can be permanently removed
• **Attachments**: Attachments remain in private storage until deleted
• **Local Cache**: Uninstalling the app removes local device data, but not cloud data already synced to your account''',
                    ),
                    _buildSection(
                      context,
                      'Your Rights',
                      '''You have the right to:

• Access all your data stored in the app
• Export your notes at any time
• Delete your notes and app data
• Sign out of your cloud account
• Request information about data processing
• Contact us with privacy concerns''',
                    ),
                    _buildSection(
                      context,
                      'Third-Party Services',
                      '''NotelyTask uses a small set of third-party services:

• **Cloud Sync Provider**: Authentication, database, storage, and account emails
• **Flutter Framework**: App development framework by Google
• **No Analytics**: We use no analytics services (Google Analytics, etc.)
• **No Advertising**: We use no advertising networks or tracking
• **No Advertising Data Sharing**: We do not sell or share data for advertising''',
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
                      '''If you have questions about this Privacy Policy or our data practices: support@omedacore.com''',
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
                              'NotelyTask syncs through your cloud account, keeps an offline local cache, supports PIN-encrypted note blobs, and does not use analytics, tracking, or advertising.',
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
