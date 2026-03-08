import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/util/quill_utils.dart';
import 'package:notelytask/utils.dart';

class NoteList extends StatefulWidget {
  final List<Note> notes;
  final bool isDeletedList;
  final String? selectedNoteId;
  const NoteList({
    super.key,
    required this.notes,
    required this.isDeletedList,
    this.selectedNoteId,
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
                      Icons.restore_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text('Restore'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_permanent',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
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
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
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
    return BlocListener<LocalFolderCubit, LocalFolderState>(
      listener: (context, state) {
        if (state.error) {
          showSnackBar(context, 'Error with local folder.');
          context.read<NotesCubit>().invalidateError();
        }
      },
      child: Column(
        children: [
          if ((kIsWeb || isDesktop) && !widget.isDeletedList)
            _NewNoteButton(
              onTap: () => navigateToDetails(
                context: context,
                isDeletedList: widget.isDeletedList,
              ),
            ),
          Expanded(
            child: widget.notes.isEmpty
                ? _EmptyState(isDeletedList: widget.isDeletedList)
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (listContext, index) {
                      final note = widget.notes[index];
                      return _NoteCard(
                        note: note,
                        isDeletedList: widget.isDeletedList,
                        isSelected: note.id == widget.selectedNoteId,
                        onTap: () => navigateToDetails(
                          context: listContext,
                          note: note,
                          isDeletedList: widget.isDeletedList,
                        ),
                        onDismissed: (direction) =>
                            _dismissed(direction, note),
                        onContextMenu: (position) =>
                            _showContextMenu(listContext, position, note),
                        onLongPress: () =>
                            _showContextMenu(listContext, null, note),
                      );
                    },
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemCount: widget.notes.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewNoteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewNoteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: colorScheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              'New note',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDeletedList;
  const _EmptyState({required this.isDeletedList});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDeletedList
                  ? Icons.delete_outline_rounded
                  : Icons.edit_note_rounded,
              size: 72,
              color: colorScheme.onSurface.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 20),
            Text(
              isDeletedList ? 'No deleted notes' : 'No notes yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDeletedList
                  ? 'Deleted notes will appear here'
                  : 'Tap + to create your first note',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isDeletedList;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(DismissDirection) onDismissed;
  final void Function(Offset?) onContextMenu;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.note,
    required this.isDeletedList,
    required this.isSelected,
    required this.onTap,
    required this.onDismissed,
    required this.onContextMenu,
    required this.onLongPress,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays >= 365) {
      return '${(diff.inDays / 365).floor()}y';
    } else if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).floor()}mo';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final preview = extractPlainTextFromDelta(note.text);
    final hasContent = preview.isNotEmpty;
    final fileCount = note.fileDataList.length;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: ValueKey<int>(note.date.millisecondsSinceEpoch),
          onDismissed: onDismissed,
          background: _SwipeBackground(
            color: isDeletedList
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            icon: isDeletedList ? Icons.restore_rounded : Icons.delete_rounded,
            label: isDeletedList ? 'Restore' : 'Delete',
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _SwipeBackground(
            color: const Color(0xFFEF4444),
            icon: Icons.delete_forever_rounded,
            label: 'Delete',
            alignment: Alignment.centerRight,
          ),
          child: GestureDetector(
            onSecondaryTapDown: (d) => onContextMenu(d.globalPosition),
            onLongPress: onLongPress,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left accent bar
                      Container(
                        width: 3,
                        color: hasContent
                            ? colorScheme.primary.withValues(alpha: 0.7)
                            : colorScheme.onSurface.withValues(alpha: 0.08),
                      ),
                      // Card content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title + date row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title.isEmpty
                                          ? 'Untitled'
                                          : note.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: note.title.isEmpty
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(note.date),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              // Preview
                              if (hasContent) ...[
                                const SizedBox(height: 6),
                                Text(
                                  preview,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              // File badge
                              if (fileCount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_file_rounded,
                                            size: 11,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '$fileCount',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final AlignmentGeometry alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]
            : [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(width: 6),
                Icon(icon, color: Colors.white, size: 20),
              ],
      ),
    );
  }
}
