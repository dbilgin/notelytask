import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

Future<void> updateWidget(String notes) async {
  if (kIsWeb || !Platform.isAndroid) {
    return;
  }
  await HomeWidget.saveWidgetData<String>('_notes', notes);
  await HomeWidget.updateWidget(
      name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
}
