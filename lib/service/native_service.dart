import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/utils.dart';

class NativeService {
  static MethodChannel widgetChannel =
      const MethodChannel('com.omedacore.notelytask/widget');

  static void initialiseWidgetListener(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    widgetChannel.setMethodCallHandler((MethodCall call) async {
      try {
        if (call.method == 'widgetClicked' &&
            call.arguments['note_id'] != null) {
          var noteId = call.arguments['note_id'].toString();
          context.read<NotesCubit>().getAndUpdateLocalNotes(
                context: context,
              );
          final redirectNote =
              await context.read<NotesCubit>().getNoteById(noteId);

          if (redirectNote != null) {
            if (!context.mounted) return;
            navigateToDetails(
              context: context,
              isDeletedList: false,
              note: redirectNote,
            );
          }
        }
      } catch (e) {
        return;
      }
    });
  }

  static Future<String?> getNativeArgs(BuildContext context) async {
    if (kIsWeb || !Platform.isAndroid) {
      return null;
    }

    try {
      dynamic arguments = await widgetChannel.invokeMethod('getIntentArgs');
      if (arguments['note_id'] != null) {
        var noteId = arguments['note_id'].toString();
        return noteId;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<void> updateNotes(BuildContext context, String noteId) async {
    await context.read<NotesCubit>().getAndUpdateLocalNotes(
          context: context,
        );

    if (!context.mounted) return;
    final redirectNote = await context.read<NotesCubit>().getNoteById(noteId);

    if (redirectNote != null) {
      if (!context.mounted) return;
      navigateToDetails(
        context: context,
        isDeletedList: false,
        note: redirectNote,
      );
    }
  }
}
