# NotelyTask

## What's this?

NotelyTask is an easy to use note-taking application with email/password accounts, mandatory authenticator-app two-factor authentication, Supabase sync, attachments, and an offline local cache. Just open it, sign in, and start taking notes.

## How does it work?

NotelyTask uses [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) to keep a local offline cache of your notes. When you are signed in and have completed two-factor authentication, the app syncs your note document to Supabase.

The Supabase backend stores one note blob per user instead of splitting every note into separate relational rows. Attachments are stored separately in private Supabase Storage and referenced from the note blob metadata.

Attachments are limited to 10 MB per file and 250 MB total per user.

### Supabase Sync

Create a local env file for normal local runs and Xcode launches:

```bash
cp assets/env/notelytask.env.example assets/env/notelytask.env
```

Then run:

```bash
flutter run
```

Dart defines can still override those values for CI or alternate environments:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://lccgvjrcsklmvyhvdkde.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

The production web app is hosted with Firebase Hosting at `https://notelytask.dbilgin.com`. The web auth callback route is `/auth-callback`, and native auth callbacks use `com.omedacore.notelytask://auth-callback`.

The remote backend schema lives in `supabase/migrations` and is pushed to the hosted Supabase project with the Supabase CLI. Do not use a local Supabase stack for this project unless that workflow is explicitly reintroduced.

### Authentication

The auth flow supports:

- Email/password signup
- Email confirmation
- Email/password login
- Required authenticator-app two-factor authentication
- Password reset by email
- Sign out
- Account deletion from Settings

Cloud note and attachment access requires an `aal2` Supabase session. After email/password login, existing users must verify a TOTP code or set up an authenticator app before cloud sync starts.

Deleting an account removes the user's synced note document, private attachment files, auth account, local note cache, and remembered local encryption PIN on that device.

### Encryption

NotelyTask supports optional PIN-based encryption for your synced note blob. When enabled, the note document is encrypted before it is saved to Supabase. Attachments are stored in private user-scoped Supabase Storage.

## Building for Linux (Ubuntu/Debian)

You can build a .deb package for Ubuntu/Debian systems:

```bash
# Install flutter_to_debian
dart pub global activate flutter_to_debian

# Build the app
flutter build linux --release

# Create .deb package
flutter_to_debian

# Install the package
sudo dpkg -i notelytask_*_amd64.deb
```

## How does it look?

<div>
  <img width="300" src="https://github.com/user-attachments/assets/7498131f-9d42-456d-bf73-a759444711f7" />
  <img width="300" src="https://github.com/user-attachments/assets/e412d497-5caf-41a9-a8e7-4c926ea0eefe" />
</div>
# Dokploy Release Deployment

Native releases are also copied through SFTPGo's HTTPS API at
`https://download.dbilgin.com`, using Actions secret `SFTPGO_API_KEY`
bound to user `ci-builds`. API-key authentication must be enabled for that
user. No SSH key, known-hosts setting, or published SFTP port is needed.
After all packages are built and the GitHub release is published, CI clears
only `/notelytask` in that user's namespace and uploads the latest APK, DEB,
and RPM. Old downloads are deleted first to respect storage limits; an
interrupted upload may leave partial downloads, so rerun the upload job.
GitHub releases contain generated release notes only, with no uploaded packages
or package links. Packages are distributed through SFTPGo; Actions artifacts
remain the intermediate handoff between build and upload jobs.
`ci-builds` needs list, delete,
create-directory, and upload access. CI verifies uploaded filenames and sizes.

Version tags also build the Flutter website in GitHub Actions, publish
`ghcr.io/dbilgin/notelytask-web`, and deploy its immutable image digest after
the native GitHub release succeeds. Dokploy needs no GitHub repository connection.
The container serves port 8080 and supports `/auth-callback` and other SPA routes.

Repository Actions secrets:
- `ENV_FILE`: existing public Flutter/Supabase client configuration. Dokploy's
  runtime environment cannot change the compiled web app.
- `DOKPLOY_API_KEY`: API access to `https://app.omedacore.com`.
- `GHCR_READ_TOKEN`: optional persistent token with `read:packages` for the
  repository owner's private GHCR package. Alternatively make the web package
  public after its first build, before rollout. A public repository does not
  automatically make its container packages public.

The workflow targets the existing NotelyTask web application and checks
`https://notelytask.dbilgin.com/release.txt` for the released commit before
reporting success. Failed rollouts fail the deployment job; a previous image
digest can be restored through Dokploy. Firebase deployment remains manual.
