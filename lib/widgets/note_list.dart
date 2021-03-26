import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_detailed_layout.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class NoteList extends StatelessWidget {
  final bool deletedList;
  NoteList({this.deletedList = false});

  @override
  Widget build(BuildContext context) {
    void _navigateToDetails({note}) {
      context
          .read<NavigatorCubit>()
          .push(Scaffold(body: DetailsPage(note: note)));
    }

    return BlocBuilder<NotesCubit, List<Note>>(
      builder: (context, List<Note> state) {
        var filteredNotes =
            state.where((element) => element.isDeleted == deletedList).toList();

        if (isSmallScreen(context)) {
          return NoteListLayout(
            notes: filteredNotes,
            onTap: _navigateToDetails,
          );
        } else {
          return NoteListDetailedLayout(notes: filteredNotes);
        }
      },
    );
  }
}
