import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NativeService {
  static MethodChannel widgetChannel =
      const MethodChannel('com.omedacore.notelytask/widget');

  static void initialiseWidgetListener(BuildContext context) {
    if (!Platform.isAndroid) {
      return;
    }

    widgetChannel.setMethodCallHandler((MethodCall call) async {
      try {
        if (call.method == 'widgetClicked' &&
            call.arguments['note_id'] != null) {
          var noteId = call.arguments['note_id'].toString();
          context.read<GithubCubit>().getAndUpdateNotes(
                context: context,
                redirectNoteId: noteId,
              );
        }
      } catch (e) {}
    });
  }

  static void getNativeArgs(BuildContext context) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      dynamic arguments = await widgetChannel.invokeMethod('getIntentArgs');
      if (arguments['note_id'] != null) {
        var noteId = arguments['note_id'].toString();
        context.read<GithubCubit>().getAndUpdateNotes(
              context: context,
              redirectNoteId: noteId,
            );
      }
    } catch (e) {}
  }
}
