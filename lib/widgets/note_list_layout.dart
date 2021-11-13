import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_detailed.dart';
import 'package:notelytask/widgets/note_list.dart';

class NoteListLayout extends StatelessWidget {
  final bool deletedList;
  NoteListLayout({this.deletedList = false});

  @override
  Widget build(BuildContext context) {
    void _navigateToDetails({note}) {
      context.read<NavigatorCubit>().pushNamed(
            '/details',
            arguments: DetailNavigationParameters(
              note: note,
              withAppBar: true,
            ),
          );
    }

    return BlocBuilder<NotesCubit, List<Note>>(
      builder: (context, List<Note> state) {
        var filteredNotes =
            state.where((element) => element.isDeleted == deletedList).toList();

        if (isSmallScreen(context)) {
          return NoteList(
            notes: filteredNotes,
            onTap: _navigateToDetails,
          );
        } else {
          return NoteListDetailed(notes: filteredNotes);
        }
      },
    );
  }
}
