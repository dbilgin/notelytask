import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/github_loader.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class DeletedListPage extends StatefulWidget {
  const DeletedListPage({Key? key}) : super(key: key);

  @override
  State<DeletedListPage> createState() => _DeletedListPageState();
}

class _DeletedListPageState extends State<DeletedListPage> {
  bool? smallScreen;

  @override
  Widget build(BuildContext context) {
    var smallScreenCheck = isSmallScreen(context);
    if (smallScreen == null || smallScreenCheck != smallScreen) {
      setState(() => smallScreen = smallScreenCheck);
      context.read<GithubCubit>().getAndUpdateNotes(context: context);
    }

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
          child: GithubLoader(),
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          context.read<SelectedNoteCubit>().setNote(null);
        },
        child: const NoteListLayout(isDeletedList: true),
      ),
    );
  }
}
