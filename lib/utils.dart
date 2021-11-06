import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelytask/cubit/navigator_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool isSmallScreen(BuildContext context) {
  MediaQueryData queryData = MediaQuery.of(context);
  return queryData.size.width <= 500;
}

void saveToRepoAlert({
  required BuildContext context,
  required Function(bool keepLocal) onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Github Connection"),
        content: Text(
          "Would you like to keep your local data and overwrite your repo?",
        ),
        actions: [
          TextButton(
            child: Text("Yes"),
            onPressed: () {
              context.read<NavigatorCubit>().pop();
              onPressed(true);
            },
          ),
          TextButton(
            child: Text("No"),
            onPressed: () {
              context.read<NavigatorCubit>().pop();
              onPressed(false);
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () => context.read<NavigatorCubit>().pop(),
          ),
        ],
      );
    },
  );
}

String getGithubApiUrl(String ownerRepo) {
  return 'https://api.github.com/repos/$ownerRepo/contents/notes.json';
}
