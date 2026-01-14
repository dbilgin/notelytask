import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/state_loader.dart';

class FolderSelectionPage extends StatefulWidget {
  const FolderSelectionPage({super.key});

  @override
  State<FolderSelectionPage> createState() => _FolderSelectionPageState();
}

class _FolderSelectionPageState extends State<FolderSelectionPage> {
  String? localFolderPath;

  @override
  void initState() {
    localFolderPath = context.read<LocalFolderCubit>().state.folderPath;
    super.initState();
  }

  Future<void> _selectFolder() async {
    final selectedPath = await context.read<LocalFolderCubit>().selectFolder();
    if (selectedPath != null && mounted) {
      setState(() {
        localFolderPath = selectedPath;
      });
    }
  }

  void saveFolderPath(String folderPath) {
    saveToFolderAlert(
      context: context,
      onPressed: (bool keepLocal) async {
        final result = await context.read<NotesCubit>().setRemoteConnection(
              folderPath: folderPath,
              keepLocal: keepLocal,
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
      },
    );
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
          'Local Storage',
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
      body: BlocBuilder<LocalFolderCubit, LocalFolderState>(
        builder: (context, state) {
          List<Widget> children = [];

          if (state.folderPath == null) {
            // Not connected - show folder selection
            children = [
              const Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a folder to store your notes',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (localFolderPath != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    localFolderPath!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _selectFolder,
                icon: const Icon(Icons.folder_rounded),
                label: Text(localFolderPath == null
                    ? 'Select Folder'
                    : 'Change Folder'),
              ),
              if (localFolderPath != null &&
                  localFolderPath != state.folderPath)
                ElevatedButton(
                  onPressed: () => saveFolderPath(localFolderPath!),
                  child: const Text('Save Folder'),
                ),
            ];
          } else {
            // Connected - show folder info and encryption options
            children = [
              const Icon(
                Icons.folder_rounded,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Connected to Local Folder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.folderPath!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectFolder,
                icon: const Icon(Icons.folder_rounded),
                label: const Text('Change Folder'),
              ),
              if (localFolderPath != null &&
                  localFolderPath != state.folderPath)
                ElevatedButton(
                  onPressed: () => saveFolderPath(localFolderPath!),
                  child: const Text('Save New Folder'),
                ),
              BlocBuilder<NotesCubit, NotesState>(builder: (
                notesContext,
                notesState,
              ) {
                return Wrap(
                  children: [
                    if (state.isConnected() && notesState.encryptionKey == null)
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
                    if (state.isConnected() && notesState.encryptionKey != null)
                      ElevatedButton(
                        onPressed: () => encryptionKeyDialog(
                          context: context,
                          isPinRequired: false,
                          title: 'Enter Your Encryption Pin',
                          text: 'Decryption will fail if wrong key is entered.',
                          onSubmit: _onSubmitDecryption,
                        ),
                        child: const Text('Decrypt Notes'),
                      ),
                  ],
                );
              }),
            ];
          }

          return BlocListener<LocalFolderCubit, LocalFolderState>(
            listener: (context, state) {
              if (state.error) {
                showSnackBar(context, 'Error accessing folder.');
                context.read<NotesCubit>().invalidateError();
                setState(() {
                  localFolderPath = null;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  direction: Axis.vertical,
                  runSpacing: 24.0,
                  spacing: 12.0,
                  children: [
                    ...children,
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesCubit>().reset();
                        setState(() {
                          localFolderPath = null;
                        });
                      },
                      child: const Text('Reset Connection'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
