import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsForm extends StatefulWidget {
  final Note? note;
  DetailsForm({Key? key, this.note}) : super(key: key);

  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  Timer? _debounce;
  String? _id;

  @override
  void initState() {
    _titleController.text = widget.note?.title ?? '';
    _textController.text = widget.note?.text ?? '';
    _id = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    var note = Note(
      id: _id!,
      title: _titleController.text,
      text: _textController.text,
      date: DateTime.now(),
    );

    context.read<NotesCubit>().setNote(note);
    context.read<SelectedNoteCubit>().setNote(note);

    // _titleController.addListener(_submit);
    // _textController.addListener(_submit);
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // _titleController.dispose();
    // _textController.dispose();
    super.dispose();
  }

  void _debouncedSubmit(Note note) {
    context.read<NotesCubit>().setNote(note);
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
    );
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () => _debouncedSubmit(note),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GithubCubit, GithubState>(
      listener: (context, state) {
        if (state.error) {
          final snackBar = SnackBar(
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
            children: [
              TextFormField(
                onChanged: (text) => _submit(),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.headline4,
                decoration: InputDecoration(
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
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
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
