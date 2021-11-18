import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/utils.dart';

class NoteList extends StatefulWidget {
  final List<Note> notes;
  final bool isDeletedList;
  NoteList({
    required this.notes,
    required this.isDeletedList,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  /// Swipe Left index is 2
  void _dismissed(DismissDirection direction, Note note) {
    if (!widget.isDeletedList) {
      context.read<NotesCubit>().deleteNote(note);
    } else {
      if (direction.index == 2) {
        context.read<NotesCubit>().deleteNotePermanently(note);
      } else {
        context.read<NotesCubit>().restoreNote(note);
      }
    }

    if (context.read<SelectedNoteCubit>().state?.id == note.id) {
      context.read<SelectedNoteCubit>().setNote(null);
    }
    context.read<GithubCubit>().createOrUpdateRemoteNotes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GithubCubit, GithubState>(
      listener: (context, state) {
        if (state.error) {
          final snackBar = SnackBar(
            content: Text('Error with Github integration.'),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Column(
        children: [
          if (kIsWeb)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => navigateToDetails(
                  context: context,
                  isDeletedList: widget.isDeletedList,
                ),
                child: Icon(Icons.add),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey<int>(
                      widget.notes[index].date.millisecondsSinceEpoch),
                  child: ListTile(
                    onTap: () => navigateToDetails(
                      context: context,
                      note: widget.notes[index],
                      isDeletedList: widget.isDeletedList,
                    ),
                    title: Text(widget.notes[index].title),
                    subtitle: Text(
                      widget.notes[index].text,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                    ),
                    isThreeLine: true,
                  ),
                  onDismissed: (direction) =>
                      _dismissed(direction, widget.notes[index]),
                  background: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          widget.isDeletedList ? Icons.restore : Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ],
                    ),
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
