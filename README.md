# NotelyTask

## What's this?

NotelyTask is an easy to use note-taking application. Just open it and start taking notes. It supports local folder synchronization to keep your notes backed up and synced across devices. You can get builds from [Releases](https://github.com/dbilgin/notelytask/releases) or build the app yourself.

## How does it work?

NotelyTask uses [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) for immediately preserving user data. Your notes are stored locally and the app has no tracking whatsoever.

### Local Folder Sync

You can select a local folder (or a synced folder like Dropbox, Google Drive, Nextcloud, etc.) to store your notes. The app saves your notes as a `notes.json` file in the selected folder, allowing you to:

- Back up your notes automatically
- Sync across devices using any cloud storage service
- Keep full control of your data

### Encryption

NotelyTask supports optional PIN-based encryption for your notes. When enabled, your notes are encrypted before being saved to the sync folder.

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
