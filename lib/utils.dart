import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/selected_note_cubit.dart';
import 'models/note.dart';

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
    context.read<NavigatorCubit>().pushNamed(
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
              context.read<NavigatorCubit>().pop();
              onPressed(true);
            },
          ),
          TextButton(
            child: Text(
              'No',
              style: Theme.of(context).textTheme.caption,
            ),
            onPressed: () {
              context.read<NavigatorCubit>().pop();
              onPressed(false);
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.caption,
            ),
            onPressed: () => context.read<NavigatorCubit>().pop(),
          ),
        ],
      );
    },
  );
}
