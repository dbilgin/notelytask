import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:notelytask/service/navigation_service.dart';

import 'cubit/selected_note_cubit.dart';
import 'models/note.dart';

GetIt getIt = GetIt.instance;

bool isSmallScreen(BuildContext context) {
  MediaQueryData queryData = MediaQuery.of(context);
  return queryData.size.width <= 500;
}

void navigateToDetails({
  required BuildContext context,
  required bool isDeletedList,
  Note? note,
}) {
  if (isSmallScreen(context)) {
    getIt<NavigationService>().pushNamed(
      '/details',
      arguments: DetailNavigationParameters(
        note: note,
        withAppBar: true,
        isDeletedList: isDeletedList,
      ),
    );
  }
  context.read<SelectedNoteCubit>().setNote(note);
}

void saveToRepoAlert({
  required BuildContext context,
  required Function(bool keepLocal) onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xff2a2a31),
        title: Text('Github Connection'),
        content: Text(
          'Would you like to keep your local data and overwrite your repo?',
        ),
        actions: [
          TextButton(
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.caption,
            ),
            onPressed: () {
              getIt<NavigationService>().pop();
              onPressed(true);
            },
          ),
          TextButton(
            child: Text(
              'No',
              style: Theme.of(context).textTheme.caption,
            ),
            onPressed: () {
              getIt<NavigationService>().pop();
              onPressed(false);
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.caption,
            ),
            onPressed: () => getIt<NavigationService>().pop(),
          ),
        ],
      );
    },
  );
}
