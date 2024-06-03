import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/google_drive_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/google_drive_state.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/state_loader.dart';

class GoogleDrivePage extends StatefulWidget {
  const GoogleDrivePage({super.key});

  @override
  State<GoogleDrivePage> createState() => _GoogleDrivePageState();
}

class _GoogleDrivePageState extends State<GoogleDrivePage> {
  void _signInWithGoogle() async {
    final result = await context.read<GoogleDriveCubit>().getTokens();
    if (!mounted) {
      return;
    }

    if (result == null) {
      showSnackBar(context, 'Error signing in.');
      return;
    }

    _setFileId();
  }

  Future<void> _setFileId() async {
    final fileIdResult = await googleFileIdDialog(context);
    if (!mounted) {
      return;
    }

    final result = await context.read<NotesCubit>().setRemoteConnection(
          fileId: fileIdResult,
          keepLocal: fileIdResult == null,
          enterEncryptionKeyDialog: () => encryptionKeyDialog(
            context: context,
            title: 'Enter Your Encryption Pin',
            text:
                'This will be used to decrypt your notes.\nLeave blank if you do not have a key.',
            isPinRequired: true,
          ),
        );

    if (!result && mounted) {
      showSnackBar(context, 'An error occurred.');
    }
  }

  void _signOut() async {
    final result = await context.read<GoogleDriveCubit>().signOut();
    if (!mounted) return;

    context.read<NotesCubit>().reset(shouldError: result);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Drive',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 0),
          child: StateLoader(),
        ),
      ),
      body: BlocBuilder<GoogleDriveCubit, GoogleDriveState>(
          builder: (context, state) {
        final isLoggedIn = state.isLoggedIn();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: isLoggedIn
                ? Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    direction: Axis.vertical,
                    runSpacing: 24.0,
                    spacing: 12.0,
                    children: [
                      Text('File ID: ${state.fileId}'),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text('Sign Out'),
                      ),
                      BlocBuilder<NotesCubit, NotesState>(builder: (
                        notesContext,
                        notesState,
                      ) {
                        return Wrap(
                          children: [
                            if (notesState.encryptionKey == null)
                              ElevatedButton(
                                onPressed: () => encryptionKeyDialog(
                                  context: context,
                                  isPinRequired: false,
                                  title: 'Enter Your Encryption Pin',
                                  text:
                                      'Do not lose this!\nThis will encrypt your notes.',
                                  onSubmit: _onSubmitEncryption,
                                ),
                                child: const Text('Encrypt Notes'),
                              ),
                            if (notesState.encryptionKey != null)
                              ElevatedButton(
                                onPressed: () => encryptionKeyDialog(
                                  context: context,
                                  isPinRequired: false,
                                  title: 'Enter Your Encryption Pin',
                                  text:
                                      'Decryption will fail if wrong key is entered.',
                                  onSubmit: _onSubmitDecryption,
                                ),
                                child: const Text('Decrypt Notes'),
                              ),
                          ],
                        );
                      }),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: const Text('Sign In With Google'),
                  ),
          ),
        );
      }),
    );
  }
}
