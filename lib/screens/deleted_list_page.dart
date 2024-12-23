import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/widgets/note_list_layout.dart';
import 'package:notelytask/widgets/state_loader.dart';

class DeletedListPage extends StatefulWidget {
  const DeletedListPage({super.key});

  @override
  State<DeletedListPage> createState() => _DeletedListPageState();
}

class _DeletedListPageState extends State<DeletedListPage> {
  @override
  void initState() {
    context.read<NotesCubit>().getAndUpdateLocalNotes(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Deleted List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 0),
          child: StateLoader(),
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          context.read<SettingsCubit>().setSelectedNoteId(null);
        },
        child: const NoteListLayout(isDeletedList: true),
      ),
    );
  }
}
