import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/widgets/details_form.dart';
import 'package:notelytask/widgets/github_loader.dart';

class DetailsPage extends StatefulWidget {
  final Note? note;
  final bool withAppBar;
  final bool isDeletedList;
  const DetailsPage({
    super.key,
    this.note,
    required this.withAppBar,
    required this.isDeletedList,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Note note;

  @override
  void initState() {
    note = Note.generateNew(note: widget.note);

    context.read<NotesCubit>().setNote(note);
    context.read<SettingsCubit>().setSelectedNoteId(note.id);

    super.initState();
  }

  void _submit(Note note) {
    context.read<NotesCubit>().setNote(note);
    context.read<NotesCubit>().createOrUpdateRemoteNotes();
  }

  @override
  Widget build(BuildContext context) {
    var layout = SafeArea(
      child: DetailsForm(
        key: Key((note.id)),
        note: note,
        isDeletedList: widget.isDeletedList,
        submit: _submit,
      ),
    );

    if (widget.withAppBar) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          bottom: const PreferredSize(
            preferredSize: Size(double.infinity, 0),
            child: GithubLoader(),
          ),
        ),
        body: layout,
      );
    } else {
      return layout;
    }
  }
}
