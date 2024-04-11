import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/google_drive_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/google_drive_state.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/state_loader.dart';

class GoogleDrivePage extends StatefulWidget {
  const GoogleDrivePage({super.key});

  @override
  State<GoogleDrivePage> createState() => _GoogleDrivePageState();
}

class _GoogleDrivePageState extends State<GoogleDrivePage> {
  final fileIdController = TextEditingController();
  String? _fileId;

  void _signInWithGoogle() async {
    await context.read<GoogleDriveCubit>().getTokens();
  }

  void _signOut() async {
    final result = await context.read<GoogleDriveCubit>().signOut();
    if (!mounted) return;

    if (result) {
      context.read<NotesCubit>().reset();
    } else {
      showSnackBar(context, 'Error signing out.');
    }
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
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 0),
          child: StateLoader(),
        ),
      ),
      body: BlocBuilder<GoogleDriveCubit, GoogleDriveState>(
          builder: (context, state) {
        final isLoggedIn = state.isLoggedIn();
        return Padding(
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
                if (!isLoggedIn)
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: const Text('Sign In With Google'),
                  ),
                if (isLoggedIn)
                  SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width - 100,
                    child: TextField(
                      controller: fileIdController,
                      onChanged: (value) => setState(() => _fileId = value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Existing File ID',
                      ),
                    ),
                  ),
                if (isLoggedIn)
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
