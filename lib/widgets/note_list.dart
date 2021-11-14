import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/utils.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  NoteList({required this.notes});

  @override
  Widget build(BuildContext context) {
    void _dismissed(DismissDirection direction, Note note) {
      context.read<NotesCubit>().deleteNote(note);

      if (context.read<SelectedNoteCubit>().state?.id == note.id) {
        context.read<SelectedNoteCubit>().setNote(null);
      }
      context.read<GithubCubit>().createOrUpdateRemoteNotes();
    }

    void _navigateToDetails({note}) {
      if (isSmallScreen(context)) {
        context.read<NavigatorCubit>().pushNamed(
              '/details',
              arguments: DetailNavigationParameters(
                note: note,
                withAppBar: true,
              ),
            );
      }

      context.read<SelectedNoteCubit>().setNote(note);
    }

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
                onPressed: _navigateToDetails,
                child: Icon(Icons.add),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey<int>(notes[index].date.millisecondsSinceEpoch),
                  child: ListTile(
                    onTap: () => _navigateToDetails(note: notes[index]),
                    title: Text(notes[index].title),
                    subtitle: Text(
                      notes[index].text,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                    ),
                    isThreeLine: true,
                  ),
                  onDismissed: (direction) =>
                      _dismissed(direction, notes[index]),
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
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white,
              ),
              itemCount: notes.length,
            ),
          ),
        ],
      ),
    );
  }
}
