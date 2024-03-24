import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/notes_state.dart';
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

  Future<String?> getFileLocalPath(String fileName) async {
    final accessToken = state.accessToken;
    final ownerRepo = state.ownerRepo;

    if (accessToken != null && ownerRepo != null) {
      emit(state.copyWith(loading: true));

      final file = await githubRepository.getFile(
        ownerRepo,
        accessToken,
        fileName,
      );

      emit(state.copyWith(loading: false));
      return file?.path;
    }
    emit(state.copyWith(loading: false));
    return null;
  }

  Future<void> getAndUpdateNotes({
    required BuildContext context,
    String? redirectNoteId,
  }) async {
    final encryptionKey = notesCubit.state.encryptionKey;
    final accessToken = state.accessToken;
    final ownerRepo = state.ownerRepo;

    if (accessToken != null && ownerRepo != null) {
      emit(state.copyWith(loading: true));

      final existingFile = await githubRepository.getExistingNoteFile(
        ownerRepo,
        accessToken,
        encryptionKey,
      );

      final finalContent = existingFile?.content;
      if (existingFile == null || finalContent == null) {
        reset();
        notesCubit.emit(const NotesState());
      } else {
        final list = notesCubit.fromJson(finalContent);
        notesCubit.emit(list);
        emit(state.copyWith(loading: false, sha: existingFile.sha));
      }
    }

    if (redirectNoteId != null) {
      final note = notesCubit.state.notes
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

  Future<void> setRepoUrl(String ownerRepo, bool keepLocal, String? pin) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      reset();
      return;
    }
    emit(state.copyWith(loading: true, error: false));
    notesCubit.emit(notesCubit.state.copyWith(encryptionKey: pin));

    final existingFile = await githubRepository.getExistingNoteFile(
      ownerRepo,
      accessToken,
      pin,
    );

    emit(
      state.copyWith(
        ownerRepo: ownerRepo,
        sha: existingFile?.sha,
      ),
    );

    if (keepLocal || existingFile?.sha == null) {
      await createOrUpdateRemoteNotes(shouldResetIfError: false);
    } else {
      final finalContent = existingFile?.content;
      notesCubit.emit(finalContent != null
          ? notesCubit.fromJson(finalContent)
          : const NotesState());
    }

    emit(state.copyWith(loading: false));
  }

  bool isLoggedIn() {
    final ownerRepo = state.ownerRepo;
    final accessToken = state.accessToken;
    return ownerRepo != null && accessToken != null;
  }

  Future<FileData?> uploadNewFile(
    String fileName,
    Uint8List data,
  ) async {
    final ownerRepo = state.ownerRepo;
    final accessToken = state.accessToken;
    if (ownerRepo == null || accessToken == null) {
      return null;
    }
    emit(state.copyWith(loading: true));

    final safeFileName = notesCubit.nonExistentFileName(fileName: fileName);

    var newFile = await githubRepository.createNewFile(
      ownerRepo,
      accessToken,
      data,
      safeFileName,
    );
    final sha = newFile?.sha;

    if (newFile == null || sha == null) {
      emit(state.copyWith(error: true, loading: false));
      return null;
    }

    emit(state.copyWith(loading: false));
    return FileData(name: safeFileName, sha: sha);
  }

  Future<bool> deleteFile(FileData fileData) async {
    final ownerRepo = state.ownerRepo;
    final accessToken = state.accessToken;
    if (ownerRepo == null || accessToken == null) {
      return false;
    }
    emit(state.copyWith(loading: true));

    bool isDeleted = await githubRepository.deleteFile(
      ownerRepo,
      accessToken,
      fileData.sha,
      fileData.name,
    );

    emit(state.copyWith(loading: false));
    return isDeleted;
  }

  Future<void> createOrUpdateRemoteNotes({
    bool shouldResetIfError = true,
  }) async {
    final encryptionKey = notesCubit.state.encryptionKey;

    final ownerRepo = state.ownerRepo;
    final sha = state.sha;
    final accessToken = state.accessToken;
    if (!isLoggedIn() || ownerRepo == null || accessToken == null) {
      return;
    }
    emit(state.copyWith(loading: true));

    final jsonMap = notesCubit.state.toJson();
    final stringifiedContent = json.encode(jsonMap);
    final finalizedStringContent = encryptionKey == null
        ? stringifiedContent
        : encrypt(stringifiedContent, encryptionKey);

    var newNote = await githubRepository.createOrUpdateNotesFile(
      ownerRepo,
      accessToken,
      finalizedStringContent,
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
    emit(
      state.copyWith(accessToken: await githubRepository.getAccessToken(code)),
    );
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
