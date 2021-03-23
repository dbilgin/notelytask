import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
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
    _id = widget.note?.id;

    _titleController.addListener(_submit);
    _textController.addListener(_submit);
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    void _debouncedSubmit() {
      if (_id == null) {
        _id = DateTime.now().millisecondsSinceEpoch.toString();
      }
      var note = Note(
        id: _id!,
        title: _titleController.text,
        text: _textController.text,
        date: DateTime.now(),
      );
      context.read<NotesCubit>().setNote(note);
    }

    _debounce = Timer(const Duration(milliseconds: 500), _debouncedSubmit);
  }

  String? _validate(value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              validator: _validate,
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'description',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              minLines: 10,
              keyboardType: TextInputType.multiline,
              controller: _textController,
              validator: _validate,
            ),
          ],
        ),
      ),
    );
  }
}
