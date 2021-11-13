import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/models/note.dart';

class NavigatorCubit extends Cubit<dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;
  NavigatorCubit(this.navigatorKey) : super({});

  void pushNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  void pop() {
    navigatorKey.currentState?.pop();
  }
}

class DetailNavigationParameters {
  final Note? note;
  final bool? withAppBar;
  DetailNavigationParameters({this.note, this.withAppBar});
}
