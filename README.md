# NotelyTask

## What's this?
NotelyTask is a very easy to use note-taking application, you can just open it and start taking your notes. It also supports Github integration if you want to syncronize between your devices. Currently it can support all platforms that Flutter supports. Even so, the GH Actions builds currently build for **Mac**, **Android** and **Web**. You can reach the projects from these links:


| Web | Mac | Android |
| --- | --- | --- |
| https://www.notelytask.com/ | https://github.com/dbilgin/notelytask/releases | <a href="https://play.google.com/store/apps/details?id=com.omedacore.notelytask" target="_blank"><img src="https://user-images.githubusercontent.com/15243788/144152573-56ecee58-8f9d-4227-bf65-5ece270ce376.png" height="65" /></a> |


:radioactive: &nbsp;**If you want to use the Mac application**, there may be permission issues with the new MacOS releases. If you want to use it, don't forget to unzip and then run `sudo chmod -R 755 NotelyTask.app/` on the terminal after downloading the zip.

## How does it work?
NotelyTask uses [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) for immediately starting to preserve user data. This data is not saved anywhere on any servers when the user starts using it initially, everything stays in the hydrated bloc (the project has no tracking whatsoever). This allows the note data to be displayed to the user again when they come back to the application unless the data is manually removed.

### Github Integration
The Github integration is implemented for syncronization between different devices through a Github repo. The application connects to the Github API through NotelyTask's Github oauth application and is able to reach a repository that the user can commit to. At this point comes the only requirement for a backend service. The web application requires a backend to be able to sign in to Github and for this [notelytask-backend](https://github.com/dbilgin/notelytask-backend) is used. Apart from this there is no data transfer at any point with any other backend services.

Once the user logs in with their Github account and enters a repository, NotelyTask will remember this repository and start committing users notes into a `.json` file. If the user logs in on another device and chooses to get the data from the selected repository, the new device will sync with the uploaded `.json` file. If the Github connection is not reset, this syncronization will happen every time the application is opened.

## How does it look?
<div>
  <img src="https://user-images.githubusercontent.com/15243788/144157310-82e89cae-a18d-422c-8432-6d58a2830c4f.png" width="300" />
  <img src="https://user-images.githubusercontent.com/15243788/144157320-3546d9cd-86f1-463b-a051-8dedc457cf40.png" width="300" />
  <img src="https://user-images.githubusercontent.com/15243788/144157324-36481f03-9ab3-4223-ae93-319645de3f9b.png" width="300" />
  <img src="https://user-images.githubusercontent.com/15243788/144157716-bfcf05b1-aef9-48cd-be3c-1b08d327c763.png" width="300" />
</div>
