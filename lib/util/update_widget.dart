import 'dart:io';
import 'package:home_widget/home_widget.dart';

Future<void> updateWidget(String notes) async {
  if (!Platform.isAndroid) {
    return;
  }
  await HomeWidget.saveWidgetData<String>('_notes', notes);
  await HomeWidget.updateWidget(
      name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
}
