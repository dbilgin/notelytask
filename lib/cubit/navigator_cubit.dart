import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigatorCubit extends Cubit<dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;
  NavigatorCubit(this.navigatorKey) : super({});

  void push(Widget route) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => route,
      ),
    );
  }

  void pop() {
    navigatorKey.currentState?.pop();
  }
}
