# NotelyTask

## What's this?

NotelyTask is an easy to use note-taking application with email/password accounts, mandatory authenticator-app two-factor authentication, Supabase sync, attachments, and an offline local cache. Just open it, sign in, and start taking notes.

## How does it work?

NotelyTask uses [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) to keep a local offline cache of your notes. When you are signed in and have completed two-factor authentication, the app syncs your note document to Supabase.

The Supabase backend stores one note blob per user instead of splitting every note into separate relational rows. Attachments are stored separately in private Supabase Storage and referenced from the note blob metadata.

### Supabase Sync

The app ships with public Supabase client config in `assets/env/notelytask.env`, so normal local runs and Xcode launches do not need manual flags:

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

Cloud note and attachment access requires an `aal2` Supabase session. After email/password login, existing users must verify a TOTP code or set up an authenticator app before cloud sync starts.

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
