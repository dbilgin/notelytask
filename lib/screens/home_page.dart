import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool smallScreen = false;

  @override
  void initState() {
    smallScreen = isSmallScreen(context);
    context.read<GithubCubit>().getAndUpdateNotes();
    super.initState();
  }

  void _navigateToDetails({note}) {
    if (isSmallScreen(context)) {
      context.read<NavigatorCubit>().pushNamed(
            '/details',
            arguments: DetailNavigationParameters(
              note: note,
              withAppBar: true,
            ),
          );
    } else {
      context.read<SelectedNoteCubit>().setNote(note);
    }
  }

  void _navigateToLogin() {
    context.read<NavigatorCubit>().pushNamed('/github');
  }

  @override
  Widget build(BuildContext context) {
    var smallScreenCheck = isSmallScreen(context);
    if (smallScreenCheck != smallScreen) {
      setState(() => smallScreen = smallScreenCheck);
      context.read<GithubCubit>().getAndUpdateNotes();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('NotelyTask'),
        actions: [
          IconButton(
            icon: Image.asset('assets/github.png'),
            tooltip: 'Github Integration',
            onPressed: _navigateToLogin,
          ),
        ],
        bottom: PreferredSize(
          child: BlocBuilder<GithubCubit, GithubState>(
            builder: (context, state) => state.loading
                ? LinearProgressIndicator(minHeight: 1)
                : Container(),
          ),
          preferredSize: Size(double.infinity, 0),
        ),
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
