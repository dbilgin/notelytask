import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:notelytask/main.dart';
import 'package:notelytask/service/navigation_service.dart';

void main() {
  setUp(() {
    HydratedBloc.storage = _MemoryStorage();
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<NavigationService>()) {
      getIt.registerLazySingleton(() => NavigationService());
    }
  });

  testWidgets('shows cloud sync configuration message when not configured',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('NotelyTask'), findsOneWidget);
    expect(
      find.textContaining('Cloud sync is not configured'),
      findsOneWidget,
    );
  });
}

class _MemoryStorage implements Storage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  dynamic read(String key) => _storage[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _storage[key] = value;
  }
}
