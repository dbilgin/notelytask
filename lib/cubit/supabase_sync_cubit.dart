import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/constants/attachment_limits.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/models/sync_state.dart';
import 'package:notelytask/repository/models/get_notes_result.dart';
import 'package:notelytask/repository/supabase_sync_repository.dart';
import 'package:notelytask/utils.dart';

class SupabaseSyncCubit extends Cubit<SyncState> {
  SupabaseSyncCubit({
    required this.syncRepository,
  }) : super(const SyncState());

  final SupabaseSyncRepository? syncRepository;

  bool isConnected() => syncRepository?.currentUser != null;

  String? get currentUserId => syncRepository?.currentUser?.id;

  Future<GetNotesResult> getRemoteNotes({
    String? encryptionKey,
  }) async {
    if (!isConnected()) {
      return GetNotesResult();
    }

    emit(state.copyWith(loading: true, error: false, clearMessage: true));
    try {
      final document = await syncRepository!.getNoteDocument();
      if (document == null || document.payload.isEmpty) {
        emit(state.copyWith(loading: false, error: false));
        return GetNotesResult();
      }

      if (document.isEncrypted && encryptionKey == null) {
        emit(state.copyWith(loading: false, error: false));
        return GetNotesResult(pinNeeded: true);
      }

      final notesString = document.isEncrypted
          ? decrypt(document.payload, encryptionKey!)
          : document.payload;

      if (notesString == null) {
        emit(state.copyWith(loading: false, error: false));
        return GetNotesResult(decryptionFailed: true);
      }

      emit(state.copyWith(loading: false, error: false, dirty: false));
      return GetNotesResult(notesString: notesString);
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          dirty: true,
          message: error.toString(),
        ),
      );
      return GetNotesResult();
    }
  }

  Future<void> createOrUpdateRemoteNotes({
    required Map<String, dynamic> notesJSONMap,
    required String stringifiedContent,
    String? encryptionKey,
    bool shouldResetIfError = false,
  }) async {
    if (!isConnected()) {
      emit(state.copyWith(loading: false, dirty: true));
      return;
    }

    emit(state.copyWith(loading: true, error: false, dirty: true));
    try {
      final payload = encryptionKey == null
          ? stringifiedContent
          : encrypt(stringifiedContent, encryptionKey);
      await syncRepository!.upsertNoteDocument(
        payload: payload,
        isEncrypted: encryptionKey != null,
        clientUpdatedAt: DateTime.now(),
      );
      emit(state.copyWith(loading: false, error: false, dirty: false));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          dirty: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<FileData?> uploadNewFile(
    String safeFileName,
    Uint8List data,
  ) async {
    if (!isConnected()) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: 'Sign in before uploading attachments.',
        ),
      );
      return null;
    }

    if (data.lengthInBytes > attachmentMaxFileSizeBytes) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message:
              'Files must be ${formatAttachmentLimit(attachmentMaxFileSizeBytes)} or smaller.',
        ),
      );
      return null;
    }

    emit(state.copyWith(loading: true, error: false, clearMessage: true));
    try {
      final path = await syncRepository!.uploadAttachment(
        fileName: safeFileName,
        data: data,
      );
      emit(state.copyWith(loading: false, error: false));
      return FileData(name: safeFileName, id: path);
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: _attachmentUploadErrorMessage(error),
        ),
      );
      return null;
    }
  }

  Future<bool> deleteFile(FileData fileData) async {
    if (!isConnected()) {
      return false;
    }

    emit(state.copyWith(loading: true, error: false, clearMessage: true));
    try {
      await syncRepository!.deleteAttachment(_filePath(fileData));
      emit(state.copyWith(loading: false, error: false));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<Uint8List?> downloadFile(FileData fileData) async {
    if (!isConnected()) {
      return null;
    }

    emit(state.copyWith(loading: true, error: false, clearMessage: true));
    try {
      final bytes =
          await syncRepository!.downloadAttachment(_filePath(fileData));
      emit(state.copyWith(loading: false, error: false));
      return bytes;
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: error.toString(),
        ),
      );
      return null;
    }
  }

  Future<bool> deleteAccountData() async {
    if (!isConnected()) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: 'Sign in before deleting your account.',
        ),
      );
      return false;
    }

    emit(state.copyWith(loading: true, error: false, clearMessage: true));
    try {
      await syncRepository!.deleteAllAttachments();
      await syncRepository!.deleteAccountData();
      emit(state.copyWith(loading: false, error: false, dirty: false));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          message: error.toString(),
        ),
      );
      return false;
    }
  }

  void markDirty() {
    emit(state.copyWith(dirty: true));
  }

  void invalidateError() {
    emit(state.copyWith(error: false, clearMessage: true));
  }

  String _filePath(FileData fileData) {
    return fileData.id.isEmpty ? fileData.name : fileData.id;
  }

  String _attachmentUploadErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Attachment storage limit exceeded')) {
      return 'Attachment storage is full. Delete files to upload more.';
    }
    if (message.contains('exceeded the maximum allowed size') ||
        message.contains('maximum allowed size') ||
        message.contains('file_size_limit')) {
      return 'Files must be ${formatAttachmentLimit(attachmentMaxFileSizeBytes)} or smaller.';
    }
    return message;
  }
}
