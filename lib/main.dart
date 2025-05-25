import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/repository/github_repository.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/screens/github_page.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/screens/privacy_policy_page.dart';
import 'package:notelytask/screens/settings_page.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'screens/deleted_list_page.dart';
import 'util/configure_nonweb.dart'
    if (dart.library.html) 'util/configure_web.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  await GetStorage.init();

  configureApp();
  getIt.registerLazySingleton(() => NavigationService());

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
          BlocProvider(
            create: (context) => GithubCubit(
              githubRepository: context.read<GithubRepository>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SettingsCubit()),
            BlocProvider(
              create: (context) => NotesCubit(
                githubCubit: context.read<GithubCubit>(),
              ),
            ),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp(
                title: 'NotelyTask',
                theme: getThemeData(settingsState.selectedTheme),
                navigatorKey: getIt<NavigationService>().navigatorKey,
                initialRoute: '/',
                onGenerateRoute: (RouteSettings settings) {
                  final settingsUri = Uri.parse(settings.name ?? '/');
                  final ghUserCode = settingsUri.queryParameters['code'];

                  var routes = <String, WidgetBuilder>{
                    '/': (context) => const HomePage(),
                    '/deleted_list': (context) => const DeletedListPage(),
                    '/github': (context) => GithubPage(code: ghUserCode),
                    '/details': (context) => Scaffold(
                          body: DetailsPage(
                            note: (settings.arguments
                                    as DetailNavigationParameters?)
                                ?.note,
                            withAppBar: (settings.arguments
                                        as DetailNavigationParameters?)
                                    ?.withAppBar ??
                                true,
                            isDeletedList: (settings.arguments
                                        as DetailNavigationParameters?)
                                    ?.isDeletedList ??
                                true,
                          ),
                        ),
                    '/settings': (context) => const SettingsPage(),
                    '/privacy_policy': (context) => const PrivacyPolicyPage(),
                  };

                  if (routes[settingsUri.path] == null) {
                    return MaterialPageRoute(
                      settings: const RouteSettings(name: '/'),
                      builder: (context) => const HomePage(),
                    );
                  } else {
                    WidgetBuilder builder = routes[settingsUri.path]!;
                    return MaterialPageRoute(
                      settings: RouteSettings(name: settingsUri.toString()),
                      builder: (ctx) => builder(ctx),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
