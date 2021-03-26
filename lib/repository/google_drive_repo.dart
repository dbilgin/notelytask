import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:notelytask/service/google_auth_client.dart';
import 'package:notelytask/service/storage.dart';

const _scopes = [gd.DriveApi.driveAppdataScope];

class GoogleDriveRepo {
  final storage = Storage();
  final googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<Map<String, String>?> login() async {
    Map<String, String>? authHeaders = storage.readMap(
      StorageKeys.GoogleAuthHeaders,
    );
    try {
      if (await googleSignIn.isSignedIn() && authHeaders != null) {
        return authHeaders;
      }

      var account = await googleSignIn.signInSilently(suppressErrors: false);
      authHeaders = await account?.authHeaders;
      _setStorageData(authHeaders);

      return authHeaders;
    } catch (e) {
      var account = await googleSignIn.signIn();
      authHeaders = await account?.authHeaders;
      _setStorageData(authHeaders);

      return authHeaders;
    }
  }

  Future<void> _setStorageData(Map<String, String>? authHeaders) async {
    storage.write(StorageKeys.GoogleAuthHeaders, authHeaders);
    if (!await googleSignIn.isSignedIn()) {
      storage.write(StorageKeys.DriveUploadEnabled, false);
    }
  }

  Future<bool> logout() async {
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<gd.DriveApi?> createClient() async {
    var authHeaders = await login();
    if (authHeaders == null) return null;

    final authenticateClient = GoogleAuthClient(authHeaders);
    return gd.DriveApi(authenticateClient);
  }

  Future<gd.FileList?> listFiles() async {
    var driveApi = await createClient();
    if (driveApi == null) return null;

    try {
      var fileList = await driveApi.files.list(spaces: 'appDataFolder');
      return fileList;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _readFile(String fileId) async {
    var driveApi = await createClient();
    if (driveApi == null) return null;

    var media = await driveApi.files
        .get(fileId, downloadOptions: gd.DownloadOptions.fullMedia) as gd.Media;

    String data = await utf8.decodeStream(media.stream);
    return json.decode(data);
  }

  Future<Map<String, dynamic>?> readNoteFile() async {
    var list = await listFiles();
    if (list != null && list.files != null && (list.files?.length ?? 0) > 0) {
      var id = list.files![0].id!;
      return await _readFile(id);
    }

    return null;
  }

  Future<void> removeFile(String fileId) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    await driveApi.files.delete(fileId);
  }

  Future<void> _updateFile(String fileId, String jsonStr) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    await driveApi.files.update(
      _getFile(jsonStr),
      fileId,
      addParents: 'appDataFolder',
    );
  }

  Future<void> _uploadFile(String jsonStr) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    await driveApi.files.create(
      _getFile(jsonStr, parents: ['appDataFolder']),
      uploadMedia: _getMedia(jsonStr),
    );
  }

  gd.File _getFile(String jsonStr, {List<String>? parents}) {
    var driveFile = gd.File.fromJson(json.decode(jsonStr));
    driveFile.name = 'notes.json';
    driveFile.parents = parents;

    return driveFile;
  }

  gd.Media _getMedia(String jsonStr) {
    var bytes = jsonStr.codeUnits;

    final Stream<List<int>> mediaStream =
        Future.value(bytes).asStream().asBroadcastStream();
    var media = new gd.Media(mediaStream, bytes.length);

    return media;
  }

  sendToDrive(String jsonStr) async {
    var list = await listFiles();
    if (list != null && list.files != null && (list.files?.length ?? 0) > 0) {
      var id = list.files![0].id!;

      await _updateFile(id, jsonStr);
    } else {
      await _uploadFile(jsonStr);
    }
  }

  removeAll() async {
    if (!await googleSignIn.isSignedIn()) return;

    var list = await listFiles();
    if (list != null && list.files != null && (list.files?.length ?? 0) > 0) {
      for (var item in list.files!) {
        if (item.id == null) continue;
        await removeFile(item.id!);
      }
    }

    await logout();
  }

  Future<void> setDriveUpload(bool isEnabled) async {
    await storage.write(StorageKeys.DriveUploadEnabled, isEnabled);
  }

  bool isDriveUploadEnabled() {
    return storage.read(StorageKeys.DriveUploadEnabled) ?? false;
  }

  void listenDriveEnabled(Function(bool value) callback) {
    storage.listen(
        StorageKeys.DriveUploadEnabled, (value) => callback(value as bool));
  }
}
