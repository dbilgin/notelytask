import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/utils.dart';

class NoteList extends StatefulWidget {
  final List<Note> notes;
  final bool isDeletedList;
  const NoteList({
    super.key,
    required this.notes,
    required this.isDeletedList,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  void _dismissed(DismissDirection direction, Note note) async {
    if (!widget.isDeletedList) {
      context.read<NotesCubit>().deleteNote(note);
    } else {
      if (direction.index == 2) {
        for (var fileData in note.fileDataList) {
          await context.read<NotesCubit>().deleteFile(fileData);
        }
        if (mounted) {
          context.read<NotesCubit>().deleteNotePermanently(note.id);
        }
      } else {
        context.read<NotesCubit>().restoreNote(note);
      }
    }

    if (!mounted) return;

    if (context.read<SettingsCubit>().state.selectedNoteId == note.id) {
      context.read<SettingsCubit>().setSelectedNoteId(null);
    }
    context.read<NotesCubit>().createOrUpdateRemoteNotes();
  }

  void _showContextMenu(BuildContext context, Offset? position, Note note) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // For long press (mobile), show at center of screen
    final Offset menuPosition = position ??
        Offset(MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        menuPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: widget.isDeletedList
          ? [
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(
                      Icons.restore,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Restore'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_permanent',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Delete Permanently'),
                  ],
                ),
              ),
            ]
          : [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
    ).then((value) {
      if (value != null) {
        _handleContextMenuAction(value, note);
      }
    });
  }

  void _handleContextMenuAction(String action, Note note) async {
    switch (action) {
      case 'delete':
        context.read<NotesCubit>().deleteNote(note);
        break;
      case 'restore':
        context.read<NotesCubit>().restoreNote(note);
        break;
      case 'delete_permanent':
        for (var fileData in note.fileDataList) {
          await context.read<NotesCubit>().deleteFile(fileData);
        }
        if (mounted) {
          context.read<NotesCubit>().deleteNotePermanently(note.id);
        }
        break;
    }

    if (!mounted) return;

    if (context.read<SettingsCubit>().state.selectedNoteId == note.id) {
      context.read<SettingsCubit>().setSelectedNoteId(null);
    }
    context.read<NotesCubit>().createOrUpdateRemoteNotes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GithubCubit, GithubState>(
      listener: (context, state) {
        if (state.error) {
          showSnackBar(context, 'Error with Github integration.');
          context.read<NotesCubit>().invalidateError();
        }
      },
      child: Column(
        children: [
          if ((kIsWeb || isDesktop) && !widget.isDeletedList)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () => navigateToDetails(
                  context: context,
                  isDeletedList: widget.isDeletedList,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Note'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          Expanded(
            child: widget.notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isDeletedList
                              ? Icons.delete_outline
                              : Icons.note_add_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isDeletedList
                              ? 'No deleted notes'
                              : 'No notes yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isDeletedList
                              ? 'Deleted notes will appear here'
                              : 'Tap the + button to create your first note',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final note = widget.notes[index];
                      final fileData = note.fileDataList;
                      final fileNames = fileData.map((e) => e.name);

                      return Dismissible(
                        key: ValueKey<int>(note.date.millisecondsSinceEpoch),
                        onDismissed: (direction) => _dismissed(direction, note),
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: widget.isDeletedList
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                widget.isDeletedList
                                    ? Icons.restore
                                    : Icons.delete,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isDeletedList ? 'Restore' : 'Delete',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onSecondaryTapDown: (details) => _showContextMenu(
                              context,
                              details.globalPosition,
                              note,
                            ),
                            onLongPress: () => _showContextMenu(
                              context,
                              null,
                              note,
                            ),
                            child: ListTile(
                              onTap: () => navigateToDetails(
                                context: context,
                                note: note,
                                isDeletedList: widget.isDeletedList,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                note.title.isEmpty
                                    ? 'Untitled Note'
                                    : note.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: note.title.isEmpty
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (note.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      note.text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (fileNames.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${fileNames.length} file${fileNames.length > 1 ? 's' : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: _buildDateChip(context, note.date),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: widget.notes.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    String timeText;
    if (difference.inDays > 0) {
      timeText = '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes}m';
    } else {
      timeText = 'now';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        timeText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
