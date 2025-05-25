import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/cubit/models/remote_connection_result.dart';
import 'package:notelytask/repository/github_repository.dart';
import 'package:notelytask/repository/models/get_notes_result.dart';
import 'package:notelytask/utils.dart';

class GithubCubit extends Cubit<GithubState> {
  GithubCubit({
    required this.githubRepository,
  }) : super(const GithubState());

  final GithubRepository githubRepository;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Secure storage keys
  static const String _accessTokenKey = 'github_access_token';
  static const String _ownerRepoKey = 'github_owner_repo';
  static const String _shaKey = 'github_sha';

  /// Load sensitive data from secure storage on initialization
  Future<void> loadSecureData() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final ownerRepo = await _secureStorage.read(key: _ownerRepoKey);
      final sha = await _secureStorage.read(key: _shaKey);

      if (accessToken != null || ownerRepo != null || sha != null) {
        emit(state.copyWith(
          accessToken: accessToken,
          ownerRepo: ownerRepo,
          sha: sha,
        ));
      }
    } catch (e) {
      // If there's an error reading from secure storage, continue with empty state
      debugPrint('Error loading secure data: $e');
    }
  }

  /// Save sensitive data to secure storage
  Future<void> _saveSecureData() async {
    try {
      if (state.accessToken != null) {
        await _secureStorage.write(
            key: _accessTokenKey, value: state.accessToken);
      } else {
        await _secureStorage.delete(key: _accessTokenKey);
      }

      if (state.ownerRepo != null) {
        await _secureStorage.write(key: _ownerRepoKey, value: state.ownerRepo);
      } else {
        await _secureStorage.delete(key: _ownerRepoKey);
      }

      if (state.sha != null) {
        await _secureStorage.write(key: _shaKey, value: state.sha);
      } else {
        await _secureStorage.delete(key: _shaKey);
      }
    } catch (e) {
      debugPrint('Error saving secure data: $e');
    }
  }

  /// Clear all secure storage data
  Future<void> _clearSecureData() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _ownerRepoKey);
      await _secureStorage.delete(key: _shaKey);
    } catch (e) {
      debugPrint('Error clearing secure data: $e');
    }
  }

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

  Future<GetNotesResult> getRemoteNotes({
    required BuildContext context,
    String? encryptionKey,
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
        return GetNotesResult();
      }

      final isEncryptedString = isEncrypted(content);

      if (isEncryptedString && encryptionKey == null) {
        return GetNotesResult(pinNeeded: true);
      }

      final decrypted =
          isEncryptedString ? decrypt(content, encryptionKey!) : content;

      if (decrypted == null) {
        reset(shouldError: true);
        return GetNotesResult();
      }

      emit(state.copyWith(loading: false, sha: existingFile.sha));
      await _saveSecureData();

      return GetNotesResult(notesString: decrypted);
    }
    return GetNotesResult();
  }

  Future<RemoteConnectionResult> setRepoUrl(
    String ownerRepo,
    bool keepLocal,
    Future<String?> Function() enterEncryptionKeyDialog,
  ) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      reset(shouldError: true);
      return const RemoteConnectionResult();
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
    await _saveSecureData();

    final content = existingFile?.content;

    if (keepLocal || existingFile?.sha == null || content == null) {
      return const RemoteConnectionResult(shouldCreateRemote: true);
    }

    final isEncryptedString = isEncrypted(content);
    if (isEncryptedString) {
      final encryptionKey = await enterEncryptionKeyDialog();
      if (encryptionKey == null) {
        reset(shouldError: true);
        return const RemoteConnectionResult();
      }

      final decrypted = decrypt(content, encryptionKey);
      if (decrypted == null) {
        reset(shouldError: true);
        return const RemoteConnectionResult();
      }

      emit(state.copyWith(loading: false));
      return RemoteConnectionResult(content: decrypted);
    }

    emit(state.copyWith(loading: false));
    return RemoteConnectionResult(content: content);
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

    final newFile = await githubRepository.createNewFile(
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
    return FileData(name: safeFileName, id: sha);
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
      fileData.id,
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
    if (!state.isLoggedIn() || ownerRepo == null || accessToken == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    emit(state.copyWith(loading: true));

    final stringifiedContent = json.encode(notesJSONMap);
    final finalizedStringContent = encryptionKey == null
        ? stringifiedContent
        : encrypt(stringifiedContent, encryptionKey);

    final newNote = await githubRepository.createOrUpdateNotesFile(
      ownerRepo,
      accessToken,
      finalizedStringContent,
      sha,
    );

    if (newNote != null && newNote.sha != null) {
      emit(state.copyWith(sha: newNote.sha));
      await _saveSecureData();
    } else if (shouldResetIfError) {
      reset(shouldError: true);
    } else {
      emit(state.copyWith(error: true, ownerRepo: ''));
    }

    emit(state.copyWith(loading: false));
  }

  void reset({bool shouldError = false}) {
    emit(
      const GithubState().copyWith(
        loading: false,
        ownerRepo: null,
        error: shouldError,
        accessToken: null,
      ),
    );
    _clearSecureData();
  }

  void invalidateError() {
    emit(state.copyWith(error: false));
  }

  Future<void> launchLogin() async {
    reset();
    final loginResult = await githubRepository.initialLogin();
    if (loginResult == null) {
      reset(shouldError: true);
      return;
    }

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
    await _saveSecureData();
  }
}
