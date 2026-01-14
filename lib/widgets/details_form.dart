import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late CodeController _codeController;
  Timer? _debounce;

  Map<String, TextStyle> _buildCustomTheme(bool isDark) {
    final baseTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;
    return {
      ...baseTheme,
      'section': TextStyle(
        color: baseTheme['section']?.color ??
            (isDark ? const Color(0xFFE06C75) : const Color(0xFFE45649)),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      'strong': TextStyle(
        color: baseTheme['strong']?.color,
        fontWeight: FontWeight.bold,
      ),
      'emphasis': TextStyle(
        color: baseTheme['emphasis']?.color,
        fontStyle: FontStyle.italic,
      ),
    };
  }

  @override
  void initState() {
    _titleController.text = widget.note.title;
    _codeController = CodeController(
      text: widget.note.text,
      language: markdown,
    );
    _codeController.addListener(_onCodeChanged);
    super.initState();
  }

  void _onCodeChanged() {
    _submit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) {
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
      text: _codeController.text,
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
    final isDark = theme.brightness == Brightness.dark;

    var shouldHideForm = widget.isDeletedList &&
        _titleController.text.isEmpty &&
        _codeController.text.isEmpty;

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

                          // Content Field with live markdown syntax highlighting
                          Expanded(
                            child: CodeTheme(
                              data: CodeThemeData(
                                styles: _buildCustomTheme(isDark),
                              ),
                              child: CodeField(
                                controller: _codeController,
                                textStyle: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'sans',
                                  height: 1.5,
                                ),
                                gutterStyle: GutterStyle.none,
                                background: colorScheme.surface,
                                expands: true,
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
  }
}
