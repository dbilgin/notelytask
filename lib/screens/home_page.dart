import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/local_folder_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/service/native_service.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/utils.dart';
import 'package:notelytask/widgets/note_list_layout.dart';
import 'package:notelytask/widgets/state_loader.dart';

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
    context.read<LocalFolderCubit>().loadSecureData().then((_) {
      final localContext = context;
      if (!localContext.mounted) {
        return;
      }
      localContext.read<SettingsCubit>().setSelectedNoteId(null);
      localContext
          .read<NotesCubit>()
          .getAndUpdateLocalNotes(context: localContext);
    });
  }

  Future<void> setAndUpdate() async {
    final args = await NativeService.getNativeArgs(context);
    if (!mounted || args == null) return;
    NativeService.updateNotes(context, args);
  }

  void _navigateToDeletedList() {
    context.read<SettingsCubit>().setSelectedNoteId(null);
    getIt<NavigationService>().pushNamed('/deleted_list');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NotelyTask'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Deleted Notes',
            onPressed: _navigateToDeletedList,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => getIt<NavigationService>().pushNamed('/settings'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 2),
          child: StateLoader(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: NoteListLayout(),
      ),
      floatingActionButton: !kIsWeb && !isDesktop
          ? FloatingActionButton(
              onPressed: () => navigateToDetails(
                context: context,
                isDeletedList: false,
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
