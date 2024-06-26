import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_detailed.dart';
import 'package:notelytask/widgets/note_list.dart';

class NoteListLayout extends StatelessWidget {
  final bool isDeletedList;
  const NoteListLayout({
    super.key,
    this.isDeletedList = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, NotesState state) {
        final filteredNotes = state.notes
            .where((element) => element.isDeleted == isDeletedList)
            .toList();

        if (isDeletedList && filteredNotes.isEmpty) {
          return Center(
            child: Text(
              'Nothing to see here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        } else if (isSmallScreen(context)) {
          return NoteList(
            notes: filteredNotes,
            isDeletedList: isDeletedList,
          );
        } else {
          return NoteListDetailed(
            notes: filteredNotes,
            isDeletedList: isDeletedList,
          );
        }
      },
    );
  }
}
