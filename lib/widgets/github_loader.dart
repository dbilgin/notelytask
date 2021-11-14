import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';

class GithubLoader extends StatelessWidget {
  const GithubLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubCubit, GithubState>(
      builder: (context, state) =>
          state.loading ? LinearProgressIndicator(minHeight: 1) : Container(),
    );
  }
}
