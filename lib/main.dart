import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubits/drive_cubit.dart';
import 'package:notelytask/cubits/navigator_cubit.dart';
import 'package:notelytask/cubits/selected_note_cubit.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/cubits/notes_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  runApp(App());
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriveCubit(),
      child: BlocProvider(
        create: (_) => SelectedNoteCubit(),
        child: BlocProvider(
          create: (_) => NavigatorCubit(_navigatorKey),
          child: BlocProvider(
            create: (_) => NotesCubit(),
            child: MaterialApp(
              title: 'NotelyTask',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: HomePage(),
              navigatorKey: _navigatorKey,
            ),
          ),
        ),
      ),
    );
  }
}
