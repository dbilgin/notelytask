import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_detailed.dart';
import 'package:notelytask/widgets/note_list.dart';

class NoteListLayout extends StatelessWidget {
  final bool isDeletedList;
  const NoteListLayout({
    Key? key,
    this.isDeletedList = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, List<Note>>(
      builder: (context, List<Note> state) {
        var filteredNotes = state
            .where((element) => element.isDeleted == isDeletedList)
            .toList();

        if (isDeletedList && filteredNotes.isEmpty) {
          return Center(
            child: Text(
              'Nothing to see here',
              style: Theme.of(context).textTheme.headline6,
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
