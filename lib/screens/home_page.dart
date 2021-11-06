import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/screens/github_page.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToDetails({note}) {
    if (isSmallScreen(context)) {
      context.read<NavigatorCubit>().push(
            Scaffold(
              body: DetailsPage(
                note: note,
                withAppBar: true,
              ),
            ),
          );
    } else {
      context.read<SelectedNoteCubit>().setNote(note);
    }
  }

  void _navigateToLogin() {
    context.read<NavigatorCubit>().push(GithubPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NotelyTask'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Settings',
            onPressed: _navigateToLogin,
          ),
        ],
      ),
      body: NoteListLayout(),
      floatingActionButton: !kIsWeb
          ? FloatingActionButton(
              onPressed: _navigateToDetails,
              tooltip: 'Add New Note',
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
