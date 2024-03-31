import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';

class GithubLoader extends StatelessWidget {
  const GithubLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubCubit, GithubState>(
      builder: (context, state) => state.loading
          ? const LinearProgressIndicator(
              minHeight: 1,
              color: Color(0xffdce3e8),
            )
          : Container(),
    );
  }
}
