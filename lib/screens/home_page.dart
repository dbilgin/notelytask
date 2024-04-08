import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/service/native_service.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/github_loader.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? smallScreen;

  @override
  void initState() {
    super.initState();
    NativeService.initialiseWidgetListener(context);
    context.read<SettingsCubit>().setSelectedNoteId(null);
    context.read<NotesCubit>().getAndUpdateLocalNotes(context: context);
  }

  Future<void> setAndUpdate() async {
    final args = await NativeService.getNativeArgs(context);
    if (!mounted || args == null) return;
    NativeService.updateNotes(context, args);
  }

  void _navigateToGithubLogin() {
    getIt<NavigationService>().pushNamed('/github');
  }

  void _navigateToGDriveLogin() {
    getIt<NavigationService>().pushNamed('/google_drive');
  }

  void _navigateToDeletedList() {
    context.read<SettingsCubit>().setSelectedNoteId(null);
    getIt<NavigationService>().pushNamed('/deleted_list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NotelyTask',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Deleted Notes',
            onPressed: _navigateToDeletedList,
            color: Colors.white,
          ),
          IconButton(
            icon: Image.asset('assets/github.png'),
            tooltip: 'Github Integration',
            onPressed: _navigateToGithubLogin,
          ),
          IconButton(
            icon: Image.asset('assets/google_drive.png'),
            tooltip: 'Google Drive Integration',
            onPressed: _navigateToGDriveLogin,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 0),
          child: GithubLoader(),
        ),
      ),
      body: const NoteListLayout(),
      floatingActionButton: !kIsWeb
          ? FloatingActionButton(
              onPressed: () => navigateToDetails(
                context: context,
                isDeletedList: false,
              ),
              tooltip: 'Add New Note',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
