import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/widgets/note_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteListDetailed extends StatefulWidget {
  final List<Note> notes;
  final bool isDeletedList;
  const NoteListDetailed({
    Key? key,
    required this.notes,
    required this.isDeletedList,
  }) : super(key: key);

  @override
  State<NoteListDetailed> createState() => _NoteListDetailedState();
}

class _NoteListDetailedState extends State<NoteListDetailed> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: NoteList(
            notes: widget.notes,
            isDeletedList: widget.isDeletedList,
          ),
        ),
        BlocBuilder<SelectedNoteCubit, Note?>(
          builder: (context, Note? state) {
            return Expanded(
              flex: 3,
              child: DetailsPage(
                note: state,
                withAppBar: false,
                isDeletedList: widget.isDeletedList,
              ),
            );
          },
        ),
      ],
    );
  }
}
