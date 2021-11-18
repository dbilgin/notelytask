import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/github_loader.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class DeletedListPage extends StatefulWidget {
  @override
  _DeletedListPageState createState() => _DeletedListPageState();
}

class _DeletedListPageState extends State<DeletedListPage> {
  bool? smallScreen;

  @override
  Widget build(BuildContext context) {
    var smallScreenCheck = isSmallScreen(context);
    if (smallScreen == null || smallScreenCheck != smallScreen) {
      setState(() => smallScreen = smallScreenCheck);
      context.read<GithubCubit>().getAndUpdateNotes();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Deleted List'),
        bottom: PreferredSize(
          child: GithubLoader(),
          preferredSize: Size(double.infinity, 0),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          context.read<SelectedNoteCubit>().setNote(null);
          return true;
        },
        child: NoteListLayout(isDeletedList: true),
      ),
    );
  }
}
