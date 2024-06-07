import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/google_drive_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/google_drive_state.dart';

class StateLoader extends StatelessWidget {
  const StateLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleDriveCubit, GoogleDriveState>(
      builder: (context, driveState) => BlocBuilder<GithubCubit, GithubState>(
        builder: (context, ghState) => (driveState.loading || ghState.loading)
            ? const LinearProgressIndicator(
                minHeight: 1,
                color: Color(0xffdce3e8),
              )
            : Container(),
      ),
    );
  }
}
