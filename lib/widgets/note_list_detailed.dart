import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/widgets/note_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteListDetailed extends StatefulWidget {
  final List<Note> notes;
  NoteListDetailed({required this.notes});

  @override
  _NoteListDetailedState createState() => _NoteListDetailedState();
}

class _NoteListDetailedState extends State<NoteListDetailed> {
  _tap({Note? note}) {
    context.read<SelectedNoteCubit>().setNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NoteList(notes: widget.notes, onTap: _tap),
          flex: 1,
        ),
        BlocBuilder<SelectedNoteCubit, Note?>(
          builder: (context, Note? state) => Expanded(
            child: DetailsPage(note: state),
            flex: 3,
          ),
        ),
      ],
    );
  }
}
