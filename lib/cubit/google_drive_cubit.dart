import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/cubit/models/remote_connection_result.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/google_drive_state.dart';
import 'package:notelytask/repository/google_drive_repository.dart';
import 'package:notelytask/repository/models/get_notes_result.dart';
import 'package:notelytask/utils.dart';

class GoogleDriveCubit extends HydratedCubit<GoogleDriveState> {
  GoogleDriveCubit({
    required this.googleDriveRepository,
  }) : super(const GoogleDriveState());
  final GoogleDriveRepository googleDriveRepository;

  Future<GetNotesResult> getRemoteNotes({
    required BuildContext context,
    String? encryptionKey,
  }) async {
    final fileId = state.fileId;
    final accessToken = state.accessToken;

    if (accessToken == null || fileId == null) {
      emit(state.copyWith(loading: false));
      return GetNotesResult();
    }
    emit(state.copyWith(loading: true));

    final content = await googleDriveRepository.getExistingNoteFile(
      fileId,
      accessToken,
      getTokens,
    );

    if (content == null || content == '') {
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

    emit(state.copyWith(loading: false));

    return GetNotesResult(notesString: decrypted);
  }

  Future<void> createOrUpdateRemoteNotes({
    required Map<String, dynamic> notesJSONMap,
    bool shouldResetIfError = true,
    String? encryptionKey,
  }) async {
    final fileId = state.fileId;
    final accessToken = state.accessToken;
    if (accessToken == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    emit(state.copyWith(loading: true));

    final stringifiedContent = json.encode(notesJSONMap);
    final finalizedStringContent = encryptionKey == null
        ? stringifiedContent
        : encrypt(stringifiedContent, encryptionKey);

    final newNoteId = await googleDriveRepository.createOrUpdateNotesFile(
      fileId,
      accessToken,
      finalizedStringContent,
      getTokens,
    );

    if (newNoteId != null) {
      emit(state.copyWith(fileId: newNoteId));
    } else if (shouldResetIfError) {
      reset(shouldError: true);
    } else {
      emit(state.copyWith(error: true, fileId: null));
    }

    emit(state.copyWith(loading: false));
  }

  Future<RemoteConnectionResult> setFileId({
    required String? fileId,
    required Future<String?> Function() enterEncryptionKeyDialog,
  }) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      reset(shouldError: true);
      return const RemoteConnectionResult();
    }
    emit(state.copyWith(loading: true, error: false));

    if (fileId == null) {
      return const RemoteConnectionResult(shouldCreateRemote: true);
    }

    final existingContent = await googleDriveRepository.getExistingNoteFile(
      fileId,
      accessToken,
      getTokens,
    );

    if (existingContent == null) {
      return const RemoteConnectionResult(shouldCreateRemote: true);
    }

    emit(
      state.copyWith(
        fileId: fileId,
      ),
    );

    final isEncryptedString = isEncrypted(existingContent);
    if (isEncryptedString) {
      final encryptionKey = await enterEncryptionKeyDialog();
      if (encryptionKey == null) {
        reset(shouldError: true);
        return const RemoteConnectionResult();
      }

      final decrypted = decrypt(existingContent, encryptionKey);
      if (decrypted == null) {
        reset(shouldError: true);
        return const RemoteConnectionResult();
      }

      emit(state.copyWith(loading: false));
      return RemoteConnectionResult(content: decrypted);
    }

    emit(state.copyWith(loading: false));
    return RemoteConnectionResult(content: existingContent);
  }

  Future<String?> getTokens() async {
    reset();
    emit(state.copyWith(loading: true));

    final signInData = await googleDriveRepository.signIn();
    if (signInData == null) {
      reset(shouldError: true);
      return null;
    }

    final accessToken = signInData.accessToken;
    final idToken = signInData.idToken;

    emit(
      state.copyWith(
        accessToken: accessToken,
        idToken: idToken,
      ),
    );

    emit(state.copyWith(loading: false));
    final verified = await _verify();

    if (verified) {
      return signInData.accessToken;
    } else {
      return null;
    }
  }

  Future<FileData?> uploadNewFile(
    String safeFileName,
    Uint8List data,
  ) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      return null;
    }
    emit(state.copyWith(loading: true));

    final newFile = await googleDriveRepository.createNewFile(
      accessToken,
      data,
      safeFileName,
      getTokens,
    );
    final fileId = newFile?.fileId;

    if (newFile == null || fileId == null) {
      emit(state.copyWith(error: true, loading: false));
      return null;
    }

    emit(state.copyWith(loading: false));
    return FileData(name: safeFileName, id: fileId);
  }

  Future<String?> getFileLocalPath(FileData fileData) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      emit(state.copyWith(loading: false));
      return null;
    }

    emit(state.copyWith(loading: true));

    final file = await googleDriveRepository.getFile(
      fileData,
      accessToken,
      getTokens,
    );

    emit(state.copyWith(loading: false));
    return file?.path;
  }

  Future<bool> deleteFile(FileData fileData) async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      return false;
    }
    emit(state.copyWith(loading: true));

    bool isDeleted = await googleDriveRepository.deleteFile(
      accessToken,
      fileData,
      getTokens,
    );

    emit(state.copyWith(loading: false));
    return isDeleted;
  }

  Future<bool> signOut() async {
    emit(state.copyWith(loading: true));
    final signedOut = await googleDriveRepository.signOut();
    if (signedOut) {
      reset();
    }

    emit(state.copyWith(loading: false));
    return signedOut;
  }

  Future<bool> _verify() async {
    final idToken = state.idToken;
    if (idToken == null) {
      reset(shouldError: true);
      return false;
    }
    try {
      final result = await googleDriveRepository.verifyIdToken(idToken);
      if (!result) {
        reset(shouldError: true);
      }

      return result;
    } catch (e) {
      reset(shouldError: true);
      return false;
    }
  }

  void reset({bool shouldError = false}) {
    emit(const GoogleDriveState());
    emit(
      state.copyWith(
        loading: false,
        error: shouldError,
        accessToken: null,
        idToken: null,
        fileId: null,
      ),
    );
  }

  void invalidateError() {
    emit(state.copyWith(error: false));
  }

  @override
  GoogleDriveState fromJson(Map<String, dynamic> json) {
    return GoogleDriveState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GoogleDriveState state) {
    return state.toJson();
  }
}
