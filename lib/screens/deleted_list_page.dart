import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/widgets/note_list_layout.dart';
import 'package:notelytask/widgets/state_loader.dart';

class DeletedListPage extends StatefulWidget {
  const DeletedListPage({super.key});

  @override
  State<DeletedListPage> createState() => _DeletedListPageState();
}

class _DeletedListPageState extends State<DeletedListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().setSelectedNoteId(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: colorScheme.onSurface,
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_rounded,
              color: colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Deleted Notes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<NotesCubit, dynamic>(
            builder: (context, state) {
              final deletedNotes =
                  state.notes.where((note) => note.isDeleted == true).toList();

              if (deletedNotes.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () => _showClearAllDialog(context),
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 4),
          child: StateLoader(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: NoteListLayout(isDeletedList: true),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('Clear All Deleted Notes'),
            ],
          ),
          content: const Text(
            'This will permanently delete all notes in trash. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearAllDeletedNotes(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _clearAllDeletedNotes(BuildContext context) async {
    final notesCubit = context.read<NotesCubit>();
    final deletedNotes =
        notesCubit.state.notes.where((note) => note.isDeleted == true).toList();

    for (final note in deletedNotes) {
      for (final fileData in note.fileDataList) {
        await notesCubit.deleteFile(fileData);
      }
      notesCubit.deleteNotePermanently(note.id);
    }

    if (!context.mounted) {
      return;
    }
    await notesCubit.createOrUpdateRemoteNotes();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedNotes.length} notes permanently deleted'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
