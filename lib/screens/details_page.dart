import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/widgets/details_form.dart';

class DetailsPage extends StatefulWidget {
  final Note? note;
  final bool withAppBar;
  DetailsPage({this.note, required this.withAppBar});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    var layout = SafeArea(
      child: DetailsForm(key: Key(widget.note?.id ?? 'new'), note: widget.note),
    );

    if (widget.withAppBar) {
      return Scaffold(
        appBar: AppBar(),
        body: layout,
      );
    } else {
      return layout;
    }
  }
}
