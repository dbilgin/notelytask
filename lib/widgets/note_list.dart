import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_row_files.dart';

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
  /// Swipe Left index is 2
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
          if (kIsWeb && !widget.isDeletedList)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => navigateToDetails(
                  context: context,
                  isDeletedList: widget.isDeletedList,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                var fileData = widget.notes[index].fileDataList;
                var fileNames = fileData.map((e) => e.name);

                return Dismissible(
                  key: ValueKey<int>(
                      widget.notes[index].date.millisecondsSinceEpoch),
                  onDismissed: (direction) =>
                      _dismissed(direction, widget.notes[index]),
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          widget.isDeletedList ? Icons.restore : Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => navigateToDetails(
                          context: context,
                          note: widget.notes[index],
                          isDeletedList: widget.isDeletedList,
                        ),
                        title: Text(
                          widget.notes[index].title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.notes[index].text,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 5,
                            ),
                            if (fileNames.isNotEmpty)
                              NoteListRowFiles(fileNames: fileNames),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white,
              ),
              itemCount: widget.notes.length,
            ),
          ),
        ],
      ),
    );
  }
}
