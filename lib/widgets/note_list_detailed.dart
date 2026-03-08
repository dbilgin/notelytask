import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/widgets/note_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

class NoteListDetailed extends StatefulWidget {
  final List<Note> notes;
  final bool isDeletedList;
  const NoteListDetailed({
    super.key,
    required this.notes,
    required this.isDeletedList,
  });

  @override
  State<NoteListDetailed> createState() => _NoteListDetailedState();
}

class _NoteListDetailedState extends State<NoteListDetailed> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, SettingsState state) {
        final selectedNoteId = state.selectedNoteId;
        Note? existingNote = selectedNoteId != null
            ? context
                .read<NotesCubit>()
                .state
                .notes
                .firstWhereOrNull((n) => n.id == selectedNoteId)
            : null;

        return Row(
          children: [
            Expanded(
              flex: 1,
              child: NoteList(
                notes: widget.notes,
                isDeletedList: widget.isDeletedList,
                selectedNoteId: selectedNoteId,
              ),
            ),
            Expanded(
              key: Key(existingNote?.id ?? ''),
              flex: 3,
              child: DetailsPage(
                note: existingNote,
                withAppBar: false,
                isDeletedList: widget.isDeletedList,
              ),
            ),
          ],
        );
      },
    );
  }
}
