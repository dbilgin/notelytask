import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/utils.dart';

class FileList extends StatelessWidget {
  const FileList({
    super.key,
    required this.noteId,
  });
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final fileDataList = state.notes
            .firstWhereOrNull((element) => element.id == noteId)
            ?.fileDataList;

        if (fileDataList == null || fileDataList.isEmpty) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${fileDataList.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context) {
            List<PopupMenuEntry<String>> items = [];

            for (int i = 0; i < fileDataList.length; i++) {
              final fileData = fileDataList[i];

              // Add file item
              items.add(
                PopupMenuItem<String>(
                  value: 'open_$i',
                  child: Row(
                    children: [
                      Icon(
                        getFileIcon(fileData.name),
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileData.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          showFileBottomSheet(context, fileData, noteId);
                        },
                        tooltip: 'More',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (i < fileDataList.length - 1) {
                items.add(const PopupMenuDivider());
              }
            }

            return items;
          },
          onSelected: (value) {
            if (value.startsWith('open_')) {
              final index = int.parse(value.substring(5));
              final fileData = fileDataList[index];
              openFile(context, fileData);
            }
          },
          tooltip: 'View attachments',
        );
      },
    );
  }
}
