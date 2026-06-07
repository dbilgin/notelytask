import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/auth_cubit.dart';
import 'package:notelytask/cubit/settings_cubit.dart';
import 'package:notelytask/cubit/supabase_sync_cubit.dart';
import 'package:notelytask/models/auth_state.dart';
import 'package:notelytask/models/settings_state.dart';
import 'package:notelytask/repository/supabase_sync_repository.dart';
import 'package:notelytask/screens/auth_callback_page.dart';
import 'package:notelytask/screens/auth_page.dart';
import 'package:notelytask/screens/details_page.dart';
import 'package:notelytask/screens/home_page.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/screens/privacy_policy_page.dart';
import 'package:notelytask/screens/settings_page.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/service/supabase_service.dart';
import 'package:notelytask/theme.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'screens/deleted_list_page.dart';
import 'util/configure_nonweb.dart'
    if (dart.library.html) 'util/configure_web.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await SupabaseConfig.loadEnv();

  configureApp();
  getIt.registerLazySingleton(() => NavigationService());

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) => SupabaseSyncCubit(
            syncRepository: SupabaseConfig.client == null
                ? null
                : SupabaseSyncRepository(SupabaseConfig.client!),
          ),
        ),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(
          create: (context) => NotesCubit(
            supabaseSyncCubit: context.read<SupabaseSyncCubit>(),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'NotelyTask',
            theme: getThemeData(settingsState.selectedTheme),
            localizationsDelegates: const [
              FlutterQuillLocalizations.delegate,
            ],
            navigatorKey: getIt<NavigationService>().navigatorKey,
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              final settingsUri = Uri.parse(settings.name ?? '/');

              var routes = <String, WidgetBuilder>{
                '/': (context) => const AuthGate(),
                '/auth-callback': (context) => const AuthCallbackPage(),
                '/deleted_list': (context) => const DeletedListPage(),
                '/details': (context) => Scaffold(
                      body: DetailsPage(
                        note:
                            (settings.arguments as DetailNavigationParameters?)
                                ?.note,
                        withAppBar:
                            (settings.arguments as DetailNavigationParameters?)
                                    ?.withAppBar ??
                                true,
                        isDeletedList:
                            (settings.arguments as DetailNavigationParameters?)
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
                  builder: (context) => const AuthGate(),
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
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.passwordRecovery) {
          context.read<NotesCubit>().getAndUpdateLocalNotes(context: context);
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.authenticated) {
          return const HomePage();
        }

        return const AuthPage();
      },
    );
  }
}
