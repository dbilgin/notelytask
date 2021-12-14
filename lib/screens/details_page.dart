import 'package:flutter/material.dart';
import 'package:notelytask/models/note.dart';
import 'package:notelytask/widgets/details_form.dart';
import 'package:notelytask/widgets/github_loader.dart';

class DetailsPage extends StatefulWidget {
  final Note? note;
  final bool withAppBar;
  final bool isDeletedList;
  DetailsPage({
    this.note,
    required this.withAppBar,
    required this.isDeletedList,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    var layout = SafeArea(
      child: DetailsForm(
        key: Key((widget.note?.id ?? 'new')),
        note: widget.note,
        isDeletedList: widget.isDeletedList,
      ),
    );

    if (widget.withAppBar) {
      return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            child: GithubLoader(),
            preferredSize: Size(double.infinity, 0),
          ),
        ),
        body: layout,
      );
    } else {
      return layout;
    }
  }
}
