import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/models/note.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(body: DetailsPage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NotelyTask'),
      ),
      body: BlocBuilder<NotesCubit, List<Note>>(
        builder: (context, state) {
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              title: Text(state[index].title),
              subtitle: Text(state[index].text),
              trailing: Text(state[index].date.toIso8601String()),
            ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: state.length,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToDetails,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), //
    );
  }
}
