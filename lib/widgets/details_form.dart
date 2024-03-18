import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/file_list.dart';

class DetailsForm extends StatefulWidget {
  final Note note;
  final bool isDeletedList;
  final Function(Note note) submit;
  const DetailsForm({
    Key? key,
    required this.note,
    required this.isDeletedList,
    required this.submit,
  }) : super(key: key);

  @override
  State<DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    _titleController.text = widget.note.title;
    _textController.text = widget.note.text;

    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    var note = Note(
      id: widget.note.id,
      title: _titleController.text,
      text: _textController.text,
      date: DateTime.now(),
      isDeleted: widget.note.isDeleted,
      fileDataList: widget.note.fileDataList,
    );
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () => widget.submit(note),
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
          showSnackBar(context, 'Error with Github integration.');
        }
      },
      child: Column(
        children: [
          Expanded(
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
          ),
          KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              return Visibility(
                visible: !isKeyboardVisible,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.file_upload),
                      tooltip: 'Upload File',
                      onPressed: () => uploadFile(context, widget.note.id),
                      color: Colors.white,
                    ),
                    FileList(
                      noteId: widget.note.id,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
