import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/notes_state.dart';
import 'package:notelytask/utils.dart';

class FileList extends StatelessWidget {
  const FileList({
    super.key,
    required this.noteId,
  });
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final fileDataList = state.notes
            .firstWhereOrNull((element) => element.id == noteId)
            ?.fileDataList;

        return Container(
          color: Theme.of(context).colorScheme.primary,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 100.0,
            ),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              thickness: 8.0,
              radius: const Radius.circular(8.0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    if (fileDataList != null)
                      for (var fileData in fileDataList)
                        TextButton(
                          onPressed: () => openFile(context, fileData),
                          onLongPress: () =>
                              showFileBottomSheet(context, fileData, noteId),
                          child: Row(
                            children: [
                              Icon(
                                getFileIcon(fileData.name),
                                color: Colors.white,
                                size: 40.0,
                              ),
                              Text(
                                fileData.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
