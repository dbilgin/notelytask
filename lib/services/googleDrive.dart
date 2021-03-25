import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:http/http.dart' as http;
import 'package:notelytask/cubits/drive_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _scopes = [gd.DriveApi.driveAppdataScope];

class GoogleDrive {
  final BuildContext context;
  GoogleDrive(this.context);

  final googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<Map<String, String>?> login() async {
    Map<String, String>? authHeaders;
    try {
      authHeaders = context.read<DriveCubit>().state;
      if (await googleSignIn.isSignedIn() && authHeaders != null) {
        return authHeaders;
      }

      var account = await googleSignIn.signInSilently(suppressErrors: false);
      authHeaders = await account?.authHeaders;
      return authHeaders;
    } catch (e) {
      var account = await googleSignIn.signIn();
      authHeaders = await account?.authHeaders;
      return authHeaders;
    } finally {
      context.read<DriveCubit>().setAuthHeaders(authHeaders);
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

    var fileList = await driveApi.files.list(spaces: 'appDataFolder');
    return fileList;
  }

  Future<gd.Media?> readFile(String fileId) async {
    var driveApi = await createClient();
    if (driveApi == null) return null;

    var media = await driveApi.files
        .get(fileId, downloadOptions: gd.DownloadOptions.fullMedia) as gd.Media;
    return media;
  }

  Future<void> removeFile(String fileId) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    await driveApi.files.delete(fileId);
  }

  Future<void> updateFile(String fileId, Map<String, String> json) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    await driveApi.files.update(
      _getFile(json),
      fileId,
      addParents: 'appDataFolder',
    );
  }

  Future<void> uploadFile(Map<String, String> jsonData) async {
    var driveApi = await createClient();
    if (driveApi == null) return;

    final result = await driveApi.files.create(
      _getFile(jsonData, parents: ['appDataFolder']),
      uploadMedia: _getMedia(jsonData),
    );
    print('Upload result: $result');
  }

  _getFile(Map<String, String> jsonData, {List<String>? parents}) {
    var driveFile = gd.File.fromJson(jsonData);
    driveFile.name = 'notes.json';
    driveFile.parents = parents;

    return driveFile;
  }

  _getMedia(Map<String, String> jsonData) {
    var jsonString = json.encode(jsonData);
    var bytes = jsonString.codeUnits;

    final Stream<List<int>> mediaStream =
        Future.value(bytes).asStream().asBroadcastStream();
    var media = new gd.Media(mediaStream, bytes.length);

    return media;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
