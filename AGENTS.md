# AGENTS.md

Guidance for AI coding agents working in this repository. Keep this file concise, current, and oriented toward future agents.

## Always Keep This Updated

Whenever you make or discover a relevant app change, update this file in the same change. Relevant changes include architecture, data flow, setup or verification commands, storage and sync behavior, generated files, platform behavior, testing expectations, or any rule that would help the next agent avoid a wrong assumption.

## Project Shape

NotelyTask is a Flutter/Dart notes app with Supabase-backed email/password accounts, Supabase sync, attachments, and a HydratedBloc offline cache.

The app does not use the old local-folder sync backend anymore. Notes sync to Supabase as one per-user note document/blob, not as one row per note. Attachments are stored separately in private Supabase Storage.

## Architecture Map

- `lib/main.dart` initializes Flutter, optional Supabase config, HydratedBloc, app cubits, routes, and theme.
- `AuthCubit` owns Supabase Auth session state, signup, login, logout, reset email, and password update.
- `NotesCubit` owns local note mutations, HydratedBloc serialization, conflict prompts, encryption decisions, and requests to sync the note blob.
- `SupabaseSyncCubit` owns sync loading/error/dirty state and calls the Supabase repository.
- `SupabaseSyncRepository` is the low-level Supabase database and Storage access layer.
- `lib/screens` and `lib/widgets` are UI surfaces. They should delegate durable state changes to cubits.
- `lib/service/supabase_service.dart` centralizes `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and platform-specific auth callback handling.

## Data, Persistence, and Sync

- HydratedBloc is the immediate offline cache for notes and settings.
- Supabase stores one row per user in `note_documents`; `payload` is either plain JSON text or an encrypted base64 blob.
- Do not split notes into relational rows unless the product direction explicitly changes.
- Supabase Storage bucket `note-attachments` stores attachment bytes under the signed-in user's id prefix.
- Attachment metadata remains inside the note blob.
- Local text edits should update immediately and mark remote sync dirty if Supabase write fails.
- First login/sync must preserve the local-versus-cloud conflict prompt instead of silently overwriting either side.
- The missing-PIN decrypt prompt in `NotesCubit` must remain single-flight. Auth, home mount, settings, and native/widget paths can overlap sync requests, and only one decrypt dialog should appear.

## Encryption Rules

- PIN encryption is still supported for the synced note blob.
- The device PIN is remembered per Supabase user in secure storage; do not rely only on the synced note payload or HydratedBloc for the local PIN.
- Encryption and decryption helpers live in shared utilities.
- If the remote blob is encrypted and no PIN is available, prompt before replacing local cache.
- Wrong or missing PIN handling must not overwrite or clear valid local notes.
- Attachments are private through Supabase Storage policies, but they are not currently client-side encrypted.

## Supabase Backend

- Supabase migrations live in `supabase/migrations`.
- The hosted project is `notelytask` in `eu-central-1` Frankfurt, project ref `lccgvjrcsklmvyhvdkde`.
- Use the hosted Supabase project for backend work. Do not start or rely on a local Supabase stack unless the user explicitly changes this preference.
- The Supabase CLI uses `SUPABASE_ACCESS_TOKEN` in the user's shell for remote operations.
- Apply migrations only after linking the intended project; never commit service-role keys.
- Email confirmation and password reset require Supabase Auth redirect URLs for `https://notelytask.dbilgin.com/auth-callback` and `com.omedacore.notelytask://auth-callback`.
- Firebase Hosting uses project `deniz-bilgin`, hosting target `notelytask`, and site `notelytask-edd7f`.

## Platform Notes

- Android home widget updates are triggered from note-state changes and use the local cached note state.
- Android native widget navigation goes through the native service method channel.
- Android/iOS/macOS declare the `com.omedacore.notelytask` URL scheme for Supabase auth callbacks.
- Linux deep links require `app_links` as a direct dependency, `Exec=notelytask %u`, and `MimeType=x-scheme-handler/com.omedacore.notelytask;` in the desktop entry.
- Firebase Hosting must rewrite all web routes, including `/auth-callback`, to `/index.html`.
- Web and non-web behavior are split through conditional imports in the app configuration utilities.
- File opening, sharing, temporary files, and native channels are platform-sensitive. Check `kIsWeb`, desktop, and Android behavior before broad changes.

## Generated Files and Tooling

- Do not hand-edit generated JSON serialization files. Regenerate them with build runner after changing annotated models.
- Common setup command: `flutter pub get`.
- Public Supabase client config lives in `assets/env/notelytask.env` so normal local runs and Xcode launches work without manual flags. Dart defines may override those values for CI or alternate environments.
- Web builds may override `SUPABASE_WEB_AUTH_CALLBACK_URL`, defaulting to `https://notelytask.dbilgin.com/auth-callback`.
- After model serialization changes, use `dart run build_runner build --delete-conflicting-outputs`.
- Use `flutter analyze` for static checks and focused `flutter test` for behavior.
- Some Flutter commands may try to update the Flutter SDK cache outside this repository. In restricted sandboxes, that can fail because the SDK path is not writable.

## Repo Hygiene

- Preserve unrelated dirty work. This repository may contain user changes in platform files or lockfiles.
- Keep backend-adjacent changes scoped to cubits, repositories, models, utilities, migrations, and tests unless UI or platform behavior truly needs to change.
- Avoid moving business rules into screens or widgets.
- When changing sync, encryption, or persistence behavior, document migration expectations and test the failure path as well as the happy path.
- Keep this file practical for AI agents: summarize responsibilities and invariants instead of pasting code snippets.
