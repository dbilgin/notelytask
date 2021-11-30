import 'package:flutter/widgets.dart';
import 'package:notelytask/models/note.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed(routeName, arguments: arguments);
  }

  void pop([Object? result]) {
    navigatorKey.currentState?.pop(result);
  }
}

class DetailNavigationParameters {
  final Note? note;
  final bool? withAppBar;
  final bool? isDeletedList;
  DetailNavigationParameters({this.note, this.withAppBar, this.isDeletedList});
}
