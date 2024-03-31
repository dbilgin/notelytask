import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/models/remote_connection_result.dart';
import 'package:notelytask/repository/github_repository.dart';
import 'package:notelytask/utils.dart';

class GithubCubit extends HydratedCubit<GithubState> {
  GithubCubit({
    required this.githubRepository,
  }) : super(const GithubState());
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

  Future<String?> getAndUpdateNotes({
    required BuildContext context,
    String? encryptionKey,
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

      final content = existingFile?.content;

      if (existingFile == null || content == null || content == '') {
        reset(shouldError: true);
        return null;
      }

      final isEncryptedString = isEncrypted(content);

      if (isEncryptedString && encryptionKey == null) {
        reset(shouldError: true);
        return null;
      }

      final decrypted =
          isEncryptedString ? decrypt(content, encryptionKey!) : content;

      if (decrypted == null) {
        reset(shouldError: true);
        return null;
      }

      emit(state.copyWith(loading: false, sha: existingFile.sha));
      return decrypted;
    }
    return null;
  }

  Future<RemoteConnectionResult> setRepoUrl(
    String ownerRepo,
    bool keepLocal,
    Future<String?> Function() enterEncryptionKeyDialog,
  ) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      reset(shouldError: true);
      return RemoteConnectionResult();
    }
    emit(state.copyWith(loading: true, error: false));

    final existingFile = await githubRepository.getExistingNoteFile(
      ownerRepo,
      accessToken,
    );

    emit(
      state.copyWith(
        ownerRepo: ownerRepo,
        sha: existingFile?.sha,
      ),
    );
    final content = existingFile?.content;

    if (keepLocal || existingFile?.sha == null || content == null) {
      return RemoteConnectionResult(shouldCreateRemote: true);
    }

    final isEncryptedString = isEncrypted(content);
    if (isEncryptedString) {
      final encryptionKey = await enterEncryptionKeyDialog();
      if (encryptionKey == null) {
        reset(shouldError: true);
        return RemoteConnectionResult();
      }

      final decrypted = decrypt(content, encryptionKey);
      if (decrypted == null) {
        reset(shouldError: true);
        return RemoteConnectionResult();
      }

      emit(state.copyWith(loading: false));
      return RemoteConnectionResult(content: decrypted);
    }

    emit(state.copyWith(loading: false));
    return RemoteConnectionResult(content: content);
  }

  bool isLoggedIn() {
    final ownerRepo = state.ownerRepo;
    final accessToken = state.accessToken;
    return ownerRepo != null && accessToken != null;
  }

  Future<FileData?> uploadNewFile(
    String safeFileName,
    Uint8List data,
  ) async {
    final ownerRepo = state.ownerRepo;
    final accessToken = state.accessToken;
    if (ownerRepo == null || accessToken == null) {
      return null;
    }
    emit(state.copyWith(loading: true));

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
    required Map<String, dynamic> notesJSONMap,
    bool shouldResetIfError = true,
    String? encryptionKey,
  }) async {
    final ownerRepo = state.ownerRepo;
    final sha = state.sha;
    final accessToken = state.accessToken;
    if (!isLoggedIn() || ownerRepo == null || accessToken == null) {
      return;
    }
    emit(state.copyWith(loading: true));

    final stringifiedContent = json.encode(notesJSONMap);
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
      reset(shouldError: true);
    } else {
      emit(state.copyWith(error: true, ownerRepo: ''));
    }

    emit(state.copyWith(loading: false));
  }

  void reset({bool shouldError = false}) {
    emit(const GithubState());
    emit(state.copyWith(loading: false, ownerRepo: '', error: shouldError));
  }

  void invalidateError() {
    emit(state.copyWith(error: false));
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
