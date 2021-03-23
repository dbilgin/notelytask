import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubits/navigator_cubit.dart';
import 'package:notelytask/cubits/selected_note_cubit.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list.dart';
import 'package:notelytask/widgets/uploader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToDetails({note}) {
    if (isSmallScreen(context)) {
      context
          .read<NavigatorCubit>()
          .push(Scaffold(body: DetailsPage(note: note)));
    } else {
      context.read<SelectedNoteCubit>().setNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NotelyTask'),
        actions: [
          Uploader(),
        ],
      ),
      body: NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToDetails,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), //
    );
  }
}
