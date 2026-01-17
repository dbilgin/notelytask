import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/local_folder_state.dart';
import 'package:notelytask/cubit/models/remote_connection_result.dart';
import 'package:notelytask/repository/local_folder_repository.dart';
import 'package:notelytask/repository/models/get_notes_result.dart';
import 'package:notelytask/utils.dart';

class LocalFolderCubit extends Cubit<LocalFolderState> {
  LocalFolderCubit({
    required this.localFolderRepository,
  }) : super(const LocalFolderState());

  final LocalFolderRepository localFolderRepository;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Secure storage keys
  static const String _folderPathKey = 'local_folder_path';

  /// Load folder path from secure storage on initialization
  Future<void> loadSecureData() async {
    try {
      final folderPath = await _secureStorage.read(key: _folderPathKey);

      if (folderPath != null) {
        // Verify folder still exists
        final exists = await localFolderRepository.folderExists(folderPath);
        if (exists) {
          emit(state.copyWith(folderPath: folderPath));
        } else {
          await _clearSecureData();
        }
      }
    } catch (e) {
      debugPrint('Error loading secure data: $e');
    }
  }

  Future<void> _saveSecureData() async {
    try {
      if (state.folderPath != null) {
        await _secureStorage.write(
            key: _folderPathKey, value: state.folderPath);
      } else {
        await _secureStorage.delete(key: _folderPathKey);
      }
    } catch (e) {
      debugPrint('Error saving secure data: $e');
    }
  }

  /// Clear secure storage data
  Future<void> _clearSecureData() async {
    try {
      await _secureStorage.delete(key: _folderPathKey);
    } catch (e) {
      debugPrint('Error clearing secure data: $e');
    }
  }

  /// Select a folder using file picker
  Future<String?> selectFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      return result;
    } catch (e) {
      debugPrint('Error selecting folder: $e');
      return null;
    }
  }

  /// Set folder path and save to secure storage
  Future<void> setFolderPath(String folderPath) async {
    emit(state.copyWith(folderPath: folderPath, error: false));
    await _saveSecureData();
  }

  Future<String?> getFileLocalPath(String fileName) async {
    final folderPath = state.folderPath;

    if (folderPath != null) {
      emit(state.copyWith(loading: true));

      final file = await localFolderRepository.getFile(
        folderPath,
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
    final folderPath = state.folderPath;

    if (folderPath != null) {
      emit(state.copyWith(loading: true));

      final existingFile = await localFolderRepository.getExistingNoteFile(
        folderPath,
      );

      final content = existingFile?.content;

      if (existingFile == null || content == null || content.isEmpty) {
        emit(state.copyWith(loading: false));
        // No existing file is not an error - it's just a new folder
        return GetNotesResult();
      }

      final isEncryptedString = isEncrypted(content);

      if (isEncryptedString && encryptionKey == null) {
        emit(state.copyWith(loading: false));
        return GetNotesResult(pinNeeded: true);
      }

      final decrypted =
          isEncryptedString ? decrypt(content, encryptionKey!) : content;

      if (decrypted == null) {
        emit(state.copyWith(loading: false));
        return GetNotesResult(decryptionFailed: true);
      }

      emit(state.copyWith(loading: false));
      return GetNotesResult(notesString: decrypted);
    }
    return GetNotesResult();
  }

  Future<RemoteConnectionResult> setFolderUrl(
    String folderPath,
    bool keepLocal,
    Future<String?> Function() enterEncryptionKeyDialog,
  ) async {
    emit(state.copyWith(loading: true, error: false));

    // Verify folder exists
    final exists = await localFolderRepository.folderExists(folderPath);
    if (!exists) {
      reset(shouldError: true);
      return const RemoteConnectionResult();
    }

    emit(state.copyWith(folderPath: folderPath));
    await _saveSecureData();

    final existingFile = await localFolderRepository.getExistingNoteFile(
      folderPath,
    );

    final content = existingFile?.content;

    if (keepLocal || content == null || content.isEmpty) {
      emit(state.copyWith(loading: false));
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
    final folderPath = state.folderPath;
    if (folderPath == null) {
      return null;
    }
    emit(state.copyWith(loading: true));

    final newFile = await localFolderRepository.createNewFile(
      folderPath,
      data,
      safeFileName,
    );

    if (newFile == null) {
      emit(state.copyWith(error: true, loading: false));
      return null;
    }

    emit(state.copyWith(loading: false));
    return FileData(name: safeFileName, id: safeFileName);
  }

  Future<bool> deleteFile(FileData fileData) async {
    final folderPath = state.folderPath;
    if (folderPath == null) {
      return false;
    }
    emit(state.copyWith(loading: true));

    bool isDeleted = await localFolderRepository.deleteFile(
      folderPath,
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
    final folderPath = state.folderPath;
    if (!state.isConnected() || folderPath == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    emit(state.copyWith(loading: true));

    final stringifiedContent = json.encode(notesJSONMap);
    final finalizedStringContent = encryptionKey == null
        ? stringifiedContent
        : encrypt(stringifiedContent, encryptionKey);

    final success = await localFolderRepository.createOrUpdateNotesFile(
      folderPath,
      finalizedStringContent,
    );

    if (!success) {
      if (shouldResetIfError) {
        reset(shouldError: true);
      } else {
        emit(state.copyWith(error: true, loading: false));
      }
      return;
    }

    emit(state.copyWith(loading: false));
  }

  void reset({bool shouldError = false}) {
    emit(
      const LocalFolderState().copyWith(
        loading: false,
        folderPath: null,
        error: shouldError,
      ),
    );
    _clearSecureData();
  }

  void invalidateError() {
    emit(state.copyWith(error: false));
  }
}
