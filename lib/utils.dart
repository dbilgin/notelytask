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
  required Function() onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Overwrite"),
        content: Text(
          "If you have existing notes on this repo, they will be replaced.",
        ),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              context.read<NavigatorCubit>().pop();
              onPressed();
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
