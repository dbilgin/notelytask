import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteListLayout extends StatelessWidget {
  final List<Note> notes;
  final Function({Note note}) onTap;
  NoteListLayout({required this.notes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    void _dismissed(DismissDirection direction, Note note) {
      context.read<NotesCubit>().deleteNote(note);

      if (context.read<SelectedNoteCubit>().state?.id == note.id) {
        context.read<SelectedNoteCubit>().setNote(null);
      }
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey<int>(notes[index].date.millisecondsSinceEpoch),
          child: ListTile(
            onTap: () => onTap(note: notes[index]),
            title: Text(notes[index].title),
            subtitle: Text(
              notes[index].text,
              overflow: TextOverflow.fade,
              maxLines: 5,
            ),
            isThreeLine: true,
          ),
          onDismissed: (direction) => _dismissed(direction, notes[index]),
          background: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.delete,
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
      separatorBuilder: (context, index) => const Divider(),
      itemCount: notes.length,
    );
  }
}
