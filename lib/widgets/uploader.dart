import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/google_drive_enabled_cubit.dart';

class Uploader extends StatefulWidget {
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleDriveEnabledCubit, bool>(
      builder: (context, state) => IconButton(
        icon: Icon(state ? Icons.cloud_done : Icons.cloud_off),
        tooltip: 'Open shopping cart',
        onPressed: () =>
            context.read<GoogleDriveEnabledCubit>().toggleriveStatus(),
      ),
    );
  }
}
