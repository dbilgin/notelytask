import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/google_drive_cubit.dart';

class GoogleDrivePage extends StatefulWidget {
  const GoogleDrivePage({super.key});

  @override
  State<GoogleDrivePage> createState() => _GoogleDrivePageState();
}

class _GoogleDrivePageState extends State<GoogleDrivePage> {
  void _connectGoogleDrive() async {
    await context.read<GoogleDriveCubit>().getTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Drive',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.vertical,
            runSpacing: 24.0,
            spacing: 12.0,
            children: [
              ElevatedButton(
                onPressed: _connectGoogleDrive,
                child: const Text('Connect to Google Drive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
