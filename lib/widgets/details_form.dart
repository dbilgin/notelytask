import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsForm extends StatefulWidget {
  final Note? note;
  final bool isDeletedList;
  const DetailsForm({
    Key? key,
    this.note,
    required this.isDeletedList,
  }) : super(key: key);

  @override
  State<DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  Timer? _debounce;
  String? _id;
  bool _isDeleted = false;

  @override
  void initState() {
    _titleController.text = widget.note?.title ?? '';
    _textController.text = widget.note?.text ?? '';
    _id = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _isDeleted = widget.note?.isDeleted ?? false;

    var note = Note(
      id: _id!,
      title: _titleController.text,
      text: _textController.text,
      date: DateTime.now(),
      isDeleted: _isDeleted,
    );

    context.read<NotesCubit>().setNote(note);
    context.read<SelectedNoteCubit>().setNote(note);

    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedSubmit(Note note) {
    context.read<NotesCubit>().setNote(note);
    context.read<SelectedNoteCubit>().setNote(note);
    context.read<GithubCubit>().createOrUpdateRemoteNotes();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    var note = Note(
      id: _id!,
      title: _titleController.text,
      text: _textController.text,
      date: DateTime.now(),
      isDeleted: _isDeleted,
    );
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () => _debouncedSubmit(note),
    );
  }

  @override
  Widget build(BuildContext context) {
    var shouldHideForm = widget.isDeletedList &&
        _titleController.text.isEmpty &&
        _textController.text.isEmpty;

    return BlocListener<GithubCubit, GithubState>(
      listener: (context, state) {
        if (state.error) {
          const snackBar = SnackBar(
            content: Text('Error with Github integration.'),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: shouldHideForm
                ? [Container()]
                : [
                    TextFormField(
                      onChanged: (text) => _submit(),
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onChanged: (text) => _submit(),
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        controller: _textController,
                        // expands: true,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
