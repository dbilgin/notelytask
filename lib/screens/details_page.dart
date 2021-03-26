import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/widgets/details_form.dart';

class DetailsPage extends StatefulWidget {
  final Note? note;
  DetailsPage({this.note});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DetailsForm(key: Key(widget.note?.id ?? 'new'), note: widget.note),
    );
  }
}
