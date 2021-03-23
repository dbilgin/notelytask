import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/services/googleDrive.dart';

class Uploader extends StatefulWidget {
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final drive = GoogleDrive();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.shopping_cart),
      tooltip: 'Open shopping cart',
      onPressed: () async {
        var list = await drive.listFiles();
        if (list.files != null && list.files!.length > 0) {
          var f = await drive.readFile(list.files![0].id!);
        }
      },
    );
  }
}
