import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteNoteDocument {
  final String payload;
  final bool isEncrypted;
  final DateTime clientUpdatedAt;
  final DateTime? serverUpdatedAt;

  const RemoteNoteDocument({
    required this.payload,
    required this.isEncrypted,
    required this.clientUpdatedAt,
    this.serverUpdatedAt,
  });
}

class SupabaseSyncRepository {
  SupabaseSyncRepository(this.client);

  static const attachmentBucket = 'note-attachments';
  final SupabaseClient client;

  User? get currentUser => client.auth.currentUser;

  String get _userId {
    final id = currentUser?.id;
    if (id == null) {
      throw const AuthException('You must be signed in to sync notes.');
    }
    return id;
  }

  Future<RemoteNoteDocument?> getNoteDocument() async {
    final data = await client
        .from('note_documents')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return RemoteNoteDocument(
      payload: data['payload'] as String,
      isEncrypted: data['is_encrypted'] as bool? ?? false,
      clientUpdatedAt: DateTime.parse(data['client_updated_at'] as String),
      serverUpdatedAt: data['server_updated_at'] == null
          ? null
          : DateTime.parse(data['server_updated_at'] as String),
    );
  }

  Future<void> upsertNoteDocument({
    required String payload,
    required bool isEncrypted,
    required DateTime clientUpdatedAt,
  }) async {
    await client.from('note_documents').upsert({
      'user_id': _userId,
      'payload': payload,
      'is_encrypted': isEncrypted,
      'schema_version': 1,
      'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
    });
  }

  Future<String> uploadAttachment({
    required String fileName,
    required Uint8List data,
  }) async {
    final path = '$_userId/$fileName';
    await client.storage.from(attachmentBucket).uploadBinary(
          path,
          data,
          fileOptions: const FileOptions(upsert: false),
        );
    return path;
  }

  Future<Uint8List> downloadAttachment(String path) async {
    return await client.storage.from(attachmentBucket).download(path);
  }

  Future<void> deleteAttachment(String path) async {
    await client.storage.from(attachmentBucket).remove([path]);
  }
}
