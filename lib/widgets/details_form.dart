import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/models/note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/util/quill_utils.dart';
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
  static KeyboardState keyboardState = KeyboardState.hidden;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late QuillController _quillController;
  late FocusNode _editorFocusNode;
  Timer? _debounce;
  String _lastDelta = '';

  @override
  void initState() {
    _titleController.text = widget.note.title;
    final deltaJson = ensureQuillDelta(widget.note.text);
    _lastDelta = deltaJson;
    final doc = Document.fromJson(
      List<Map<String, dynamic>>.from(jsonDecode(deltaJson)),
    );
    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _editorFocusNode = FocusNode();
    _quillController.addListener(_onQuillChanged);
    super.initState();
  }

  void _onQuillChanged() {
    final currentDelta = jsonEncode(_quillController.document.toDelta().toJson());
    if (currentDelta == _lastDelta) return;
    _lastDelta = currentDelta;
    _submit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _quillController.removeListener(_onQuillChanged);
    _quillController.dispose();
    _editorFocusNode.dispose();
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
      text: jsonEncode(_quillController.document.toDelta().toJson()),
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

    final isDocumentEmpty =
        _quillController.document.toPlainText().trim().isEmpty;
    var shouldHideForm = widget.isDeletedList &&
        _titleController.text.isEmpty &&
        isDocumentEmpty;

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

                          const SizedBox(height: 8),

                          // Quill toolbar (hidden for deleted notes)
                          if (!widget.isDeletedList)
                            QuillSimpleToolbar(
                              controller: _quillController,
                              config: const QuillSimpleToolbarConfig(
                                showFontFamily: false,
                                showFontSize: false,
                                showInlineCode: false,
                                showSubscript: false,
                                showSuperscript: false,
                                showSearchButton: false,
                                showColorButton: false,
                                showBackgroundColorButton: false,
                              ),
                            ),

                          const SizedBox(height: 8),

                          // Quill editor
                          Expanded(
                            child: IgnorePointer(
                              ignoring: widget.isDeletedList,
                              child: QuillEditor.basic(
                                controller: _quillController,
                                focusNode: _editorFocusNode,
                                config: QuillEditorConfig(
                                  expands: true,
                                  padding: EdgeInsets.zero,
                                  autoFocus: false,
                                  placeholder: 'Start writing...',
                                  customStyles: DefaultStyles(
                                    paragraph: DefaultTextBlockStyle(
                                      theme.textTheme.bodyLarge?.copyWith(
                                            height: 1.5,
                                          ) ??
                                          const TextStyle(),
                                      const HorizontalSpacing(0, 0),
                                      const VerticalSpacing(0, 0),
                                      const VerticalSpacing(0, 0),
                                      null,
                                    ),
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
          KeyboardDetection(
            controller: KeyboardDetectionController(
                onChanged: (value) => setState(() => keyboardState = value)),
            child: Visibility(
              visible: keyboardState == KeyboardState.hidden,
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
            ),
          ),
        ],
      ),
    );
  }
}
