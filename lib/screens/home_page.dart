import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/github_loader.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? smallScreen;

  void _navigateToLogin() {
    context.read<NavigatorCubit>().pushNamed('/github');
  }

  void _navigateToDeletedList() {
    context.read<SelectedNoteCubit>().setNote(null);
    context.read<NavigatorCubit>().pushNamed('/deleted_list');
  }

  @override
  Widget build(BuildContext context) {
    var smallScreenCheck = isSmallScreen(context);
    if (smallScreen == null || smallScreenCheck != smallScreen) {
      setState(() => smallScreen = smallScreenCheck);
      context.read<SelectedNoteCubit>().setNote(null);
      context.read<GithubCubit>().getAndUpdateNotes();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('NotelyTask'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_rounded),
            tooltip: 'Deleted Notes',
            onPressed: _navigateToDeletedList,
          ),
          IconButton(
            icon: Image.asset('assets/github.png'),
            tooltip: 'Github Integration',
            onPressed: _navigateToLogin,
          ),
        ],
        bottom: PreferredSize(
          child: GithubLoader(),
          preferredSize: Size(double.infinity, 0),
        ),
      ),
      body: NoteListLayout(),
      floatingActionButton: !kIsWeb
          ? FloatingActionButton(
              onPressed: () => navigateToDetails(
                context: context,
                isDeletedList: false,
              ),
              tooltip: 'Add New Note',
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
