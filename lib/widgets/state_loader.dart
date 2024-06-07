import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';

class StateLoader extends StatelessWidget {
  const StateLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubCubit, GithubState>(
      builder: (context, ghState) => (ghState.loading)
          ? const LinearProgressIndicator(
              minHeight: 1,
              color: Color(0xffdce3e8),
            )
          : Container(),
    );
  }
}
