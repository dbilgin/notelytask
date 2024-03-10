import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/repository/github_repository.dart';
import 'package:notelytask/utils.dart';

import 'notes_cubit.dart';

class GithubCubit extends HydratedCubit<GithubState> {
  GithubCubit({
    required this.notesCubit,
    required this.githubRepository,
  }) : super(const GithubState());
  final NotesCubit notesCubit;
  final GithubRepository githubRepository;

  Future<void> getAndUpdateNotes({
    required BuildContext context,
    String? redirectNoteId,
  }) async {
    final accessToken = state.accessToken;
    final ownerRepo = state.ownerRepo;

    if (accessToken != null && ownerRepo != null) {
      emit(state.copyWith(loading: true));

      final existingFile = await githubRepository.getExistingNoteFile(
        ownerRepo,
        accessToken,
      );

      final finalContent = existingFile?.content;
      if (existingFile == null) {
        reset();
        notesCubit.emit([]);
      } else {
        notesCubit.emit(
            finalContent != null ? notesCubit.fromJson(finalContent) : []);
        emit(state.copyWith(loading: false, sha: existingFile.sha));
      }
    }

    if (redirectNoteId != null) {
      var note = notesCubit.state
          .where((n) => n.id == redirectNoteId && !n.isDeleted)
          .toList();
      if (note.isNotEmpty) {
        if (!context.mounted) return;
        navigateToDetails(
          context: context,
          isDeletedList: false,
          note: note[0],
        );
      }
    }
  }

  Future<void> setRepoUrl(String ownerRepo, bool keepLocal) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      reset();
      return;
    }
    emit(state.copyWith(loading: true, error: false));

    final existingFile = await githubRepository.getExistingNoteFile(
      ownerRepo,
      accessToken,
    );

    emit(state.copyWith(
      ownerRepo: ownerRepo,
      sha: existingFile?.sha,
    ));

    if (keepLocal || existingFile?.sha == null) {
      await createOrUpdateRemoteNotes(shouldResetIfError: false);
    } else {
      final finalContent = existingFile?.content;
      notesCubit
          .emit(finalContent != null ? notesCubit.fromJson(finalContent) : []);
    }

    emit(state.copyWith(loading: false));
  }

  Future<void> createOrUpdateRemoteNotes({
    bool shouldResetIfError = true,
  }) async {
    final ownerRepo = state.ownerRepo;
    final sha = state.sha;
    final accessToken = state.accessToken;
    if (ownerRepo == null || accessToken == null) {
      return;
    }
    emit(state.copyWith(loading: true));

    var newNote = await githubRepository.createOrUpdateFile(
      ownerRepo,
      accessToken,
      notesCubit.toJson(notesCubit.state),
      sha,
    );

    if (newNote != null && newNote.sha != null) {
      emit(state.copyWith(sha: newNote.sha));
    } else if (shouldResetIfError) {
      reset();
      emit(state.copyWith(error: true, ownerRepo: ''));
    } else {
      emit(state.copyWith(error: true, ownerRepo: ''));
    }

    emit(state.copyWith(loading: false));
  }

  void reset() {
    emit(const GithubState());
  }

  Future<void> launchLogin() async {
    var loginResult = await githubRepository.initialLogin();
    emit(
      state.copyWith(
        deviceCode: loginResult.deviceCode,
        userCode: loginResult.userCode,
        verificationUri: loginResult.verificationUri,
        expiresIn: loginResult.expiresIn,
      ),
    );
  }

  Future<void> getAccessToken(String code) async {
    emit(state.copyWith(
        accessToken: await githubRepository.getAccessToken(code)));
  }

  @override
  GithubState fromJson(Map<String, dynamic> json) {
    return GithubState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GithubState state) {
    return state.toJson();
  }
}
