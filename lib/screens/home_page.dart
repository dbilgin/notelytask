import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/service/native_service.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/github_loader.dart';
import 'package:notelytask/widgets/note_list_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? smallScreen;

  @override
  void initState() {
    NativeService.initialiseWidgetListener(context);
    super.initState();
  }

  Future<void> setAndUpdate() async {
    final args = await NativeService.getNativeArgs(context);
    if (!mounted || args == null) return;
    NativeService.updateNotes(context, args);
  }

  void _navigateToLogin() {
    getIt<NavigationService>().pushNamed('/github');
  }

  void _navigateToDeletedList() {
    context.read<SelectedNoteCubit>().setNote(null);
    getIt<NavigationService>().pushNamed('/deleted_list');
  }

  @override
  Widget build(BuildContext context) {
    var smallScreenCheck = isSmallScreen(context);
    if (smallScreen == null || smallScreenCheck != smallScreen) {
      setState(() => smallScreen = smallScreenCheck);
      context.read<SelectedNoteCubit>().setNote(null);
      context.read<GithubCubit>().getAndUpdateNotes(context: context);
    }

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
            onPressed: _navigateToLogin,
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
