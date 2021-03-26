import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SelectedNoteCubit()),
        BlocProvider(create: (context) => NavigatorCubit(_navigatorKey)),
        BlocProvider(create: (context) => NotesCubit()),
      ],
      child: MaterialApp(
        title: 'NotelyTask',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
        navigatorKey: _navigatorKey,
      ),
    );
  }
}
