import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/file_list.dart';

class DetailsForm extends StatefulWidget {
  final Note note;
  final bool isDeletedList;
  final Function(Note note) submit;
  const DetailsForm({
    super.key,
    required this.note,
    required this.isDeletedList,
    required this.submit,
  });

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
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Get the current note from state to ensure we have the latest file list
    final currentNote = context
        .read<NotesCubit>()
        .state
        .notes
        .where((n) => n.id == widget.note.id)
        .firstOrNull;

    var note = Note(
      id: widget.note.id,
      title: _titleController.text,
      text: _textController.text,
      date: DateTime.now(),
      isDeleted: widget.note.isDeleted,
      fileDataList: currentNote?.fileDataList ?? widget.note.fileDataList,
    );
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () => widget.submit(note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    var shouldHideForm = widget.isDeletedList &&
        _titleController.text.isEmpty &&
        _textController.text.isEmpty;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return BlocListener<LocalFolderCubit, LocalFolderState>(
          listener: (context, state) {
            if (state.error) {
              showSnackBar(context, 'Error with local folder.');
              context.read<NotesCubit>().invalidateError();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: shouldHideForm
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Note is empty',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Field
                              TextFormField(
                                controller: _titleController,
                                onChanged: (text) => _submit(),
                                textInputAction: TextInputAction.next,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Note title...',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Content Field
                              if (!settingsState.markdownEnabled)
                                Expanded(
                                  child: TextFormField(
                                    controller: _textController,
                                    onChanged: (text) => _submit(),
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: theme.textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Start writing your note...',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface,
                                      contentPadding: const EdgeInsets.all(16),
                                      alignLabelWithHint: true,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ),

                              // Markdown Preview
                              if (settingsState.markdownEnabled)
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: _textController.text.isEmpty
                                        ? Text(
                                            'Nothing to preview...',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          )
                                        : SingleChildScrollView(
                                            child: Markdown(
                                              data: _textController.text,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              selectable: true,
                                              styleSheet: MarkdownStyleSheet(
                                                p: theme.textTheme.bodyLarge,
                                              ),
                                            ),
                                          ),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded),
                            tooltip: 'Upload File',
                            onPressed: () => uploadFile(context, widget.note),
                            color: colorScheme.onSurface,
                          ),
                          IconButton(
                            icon: Icon(
                              settingsState.markdownEnabled
                                  ? Icons.edit_rounded
                                  : Icons.preview_rounded,
                            ),
                            tooltip: settingsState.markdownEnabled
                                ? 'Edit Mode'
                                : 'Preview Mode',
                            onPressed: () =>
                                context.read<SettingsCubit>().toggleMarkdown(),
                            color: settingsState.markdownEnabled
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                          const Spacer(),
                          FileList(noteId: widget.note.id),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
