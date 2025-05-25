import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/widgets/details_form.dart';
import 'package:notelytask/widgets/state_loader.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
            color: colorScheme.onSurface,
          ),
          title: Row(
            children: [
              Icon(
                widget.isDeletedList
                    ? Icons.visibility_rounded
                    : Icons.edit_note_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.isDeletedList ? 'View Note' : 'Edit Note',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size(double.infinity, 4),
            child: StateLoader(),
          ),
        ),
        body: layout,
      );
    } else {
      return layout;
    }
  }
}
