# NotelyTask

## What's this?
NotelyTask is a very easy to use note-taking application, you can just open it and start taking your notes. It also supports Github integration if you want to syncronize between your devices. You can get your builds from [Releases](https://github.com/dbilgin/notelytask/releases) or build the app yourself by setting your own environment variables.

☢️ **This app requires full access to your GitHub repositories, use with caution** ☢️

## How does it work?
NotelyTask uses [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) for immediately starting to preserve user data. This data is not saved anywhere on any servers when the user starts using it initially, everything stays in the hydrated bloc (the project has no tracking whatsoever). This allows the note data to be displayed to the user again when they come back to the application unless the data is manually removed.

### Github Integration
The Github integration is implemented for syncronization between different devices through a Github repo. The application connects to the Github API through NotelyTask's Github oauth application and is able to reach a repository that the user can commit to. At this point comes the only requirement for a backend service.

<hr>

⚠️ The web application is no longer available directly
> The web application requires a backend to be able to sign in to Github and for this [notelytask-backend](https://github.com/dbilgin/notelytask-backend) is used. Apart from this there is no data transfer at any point with any other backend services.

<hr>

Once the user logs in with their Github account and enters a repository, NotelyTask will remember this repository and start committing users notes into a `.json` file. If the user logs in on another device and chooses to get the data from the selected repository, the new device will sync with the uploaded `.json` file. If the Github connection is not reset, this syncronization will happen every time the application is opened.

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
sudo dpkg -i debian/packages/*.deb
```

## How does it look?
<div>
  <img src="https://github.com/user-attachments/assets/805b4752-c2d4-4505-8d6c-1ee377831051" width="300" />
  <img src="https://github.com/user-attachments/assets/8b19d248-8596-49d9-ac3c-35d4b3701e43" width="300" />
  <img src="https://github.com/user-attachments/assets/854ea8bd-ad51-40ac-b1c3-340e507f122a" width="300" />
  <img src="https://github.com/user-attachments/assets/f596fe36-26b7-4f57-ab7b-8e684c58a6b6" width="300" />
</div>
