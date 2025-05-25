import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';

class StateLoader extends StatelessWidget {
  const StateLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<GithubCubit, GithubState>(
      builder: (context, state) {
        if (!state.loading) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
