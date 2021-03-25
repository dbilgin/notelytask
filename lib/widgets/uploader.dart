import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:notelytask/services/googleDrive.dart';

class Uploader extends StatefulWidget {
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  GoogleDrive? drive;

  @override
  void initState() {
    drive = GoogleDrive(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.shopping_cart),
      tooltip: 'Open shopping cart',
      onPressed: () async {
        var jsonData = {'who': 'who are you?', 'who2': 'who are you?'};

        var list = await drive?.listFiles();
        if (list != null &&
            list.files != null &&
            (list.files?.length ?? 0) > 0) {
          var id = list.files![0].id!;

          await drive?.updateFile(id, jsonData);

          // Read
          gd.Media? f = await drive?.readFile(id);

          String bar = await utf8.decodeStream(f!.stream);
          drive?.removeFile(id);
        } else {
          await drive?.uploadFile(jsonData);
        }
      },
    );
  }
}
