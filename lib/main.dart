import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:notelytask/cubit/selected_note_cubit.dart';
import 'package:notelytask/repository/github_repository.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  runApp(App());
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GithubRepository>(
          create: (context) => GithubRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SelectedNoteCubit()),
          BlocProvider(create: (context) => NavigatorCubit(_navigatorKey)),
          BlocProvider(create: (context) => NotesCubit()),
        ],
        child: BlocProvider(
          create: (context) => GithubCubit(
            notesCubit: context.read<NotesCubit>(),
            githubRepository: context.read<GithubRepository>(),
          ),
          child: MaterialApp(
            title: 'NotelyTask',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              colorScheme: ColorScheme.light(
                primary: Color(0xff17181c),
                secondary: Color(0xff2e8fff),
              ),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.white,
                selectionColor: Color(0xff2e8fff),
                selectionHandleColor: Color(0xff2e8fff),
              ),
              hintColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              scaffoldBackgroundColor: const Color(0xff1f1f24),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                headline4: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                subtitle1: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                bodyText1: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                caption: TextStyle(color: Colors.white),
              ),
            ),
            home: HomePage(),
            navigatorKey: _navigatorKey,
          ),
        ),
      ),
    );
  }
}
