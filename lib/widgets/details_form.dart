import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
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
    final currentDelta =
        jsonEncode(_quillController.document.toDelta().toJson());
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
    final shouldHideForm = widget.isDeletedList &&
        _titleController.text.isEmpty &&
        isDocumentEmpty;

    return Column(
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
                        color: colorScheme.onSurface.withValues(alpha: 0.12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field — borderless, large
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          controller: _titleController,
                          onChanged: (_) => _submit(),
                          textInputAction: TextInputAction.next,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Untitled',
                            hintStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.2),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Subtle divider
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 20,
                        endIndent: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                      ),

                      // Toolbar (hidden for deleted notes)
                      if (!widget.isDeletedList) ...[
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.06),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: QuillSimpleToolbar(
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
                        ),
                      ],

                      // Quill editor
                      Expanded(
                        child: IgnorePointer(
                          ignoring: widget.isDeletedList,
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _editorFocusNode,
                            config: QuillEditorConfig(
                              expands: true,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 16),
                              autoFocus: false,
                              placeholder: 'Start writing…',
                              customStyles: DefaultStyles(
                                paragraph: DefaultTextBlockStyle(
                                  (theme.textTheme.bodyLarge?.copyWith(
                                        height: 1.7,
                                      )) ??
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

        // Bottom action bar
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
                    color: colorScheme.onSurface.withValues(alpha: 0.07),
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Attach file',
                    onPressed: () => uploadFile(context, widget.note),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const Spacer(),
                  FileList(noteId: widget.note.id),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
