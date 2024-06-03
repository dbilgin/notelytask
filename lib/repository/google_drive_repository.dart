import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/cubit/models/google_sign_in_result.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:path_provider/path_provider.dart';

class GoogleFile {
  GoogleFile({this.fileId, this.content});
  final String? fileId;
  final String? content;
}

class GoogleDriveRepository {
  final List<String> scopes = [
    'https://www.googleapis.com/auth/drive.appdata',
    'https://www.googleapis.com/auth/drive.file', // write
    'https://www.googleapis.com/auth/drive.readonly', // read
  ];
  Future<GoogleSignInResult?> signIn() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_CLIENT_ID'],
        scopes: scopes,
      );
      final account = (await googleSignIn.signInSilently()) ??
          (await googleSignIn.signIn());

      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await googleSignIn.canAccessScopes(scopes);
      }

      if (!isAuthorized) {
        return null;
      }

      final auth = await account?.authentication;
      final accessToken = auth?.accessToken;
      final idToken = auth?.idToken;

      return accessToken != null && idToken != null
          ? GoogleSignInResult(accessToken: accessToken, idToken: idToken)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> signOut() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_CLIENT_ID'],
        scopes: scopes,
      );
      await googleSignIn.disconnect();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyIdToken(
    String idToken,
  ) async {
    try {
      final url = Uri.https(
        'api.notelytask.com',
        '/google_verify',
        {
          'id_token': idToken,
        },
      );
      final response = await post(url, headers: {'Accept': 'application/json'});

      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 404) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<File?> getFile(
    FileData fileData,
    String accessToken,
    Future<String?> Function() getTokens,
  ) async {
    try {
      final url = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/${fileData.id}',
        {'alt': 'media'},
      );
      final response = await get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Directory dir = kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory();

        final path = '${dir.path}/${fileData.name}';

        final file = File(path);
        await file.writeAsBytes(
          response.bodyBytes,
          mode: FileMode.write,
        );

        return file;
      } else if (response.statusCode == 401) {
        final newAccessToken = await getTokens();
        if (newAccessToken == null) {
          return null;
        }
        return getFile(fileData, newAccessToken, getTokens);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile(
    String accessToken,
    FileData fileData,
    Future<String?> Function() getTokens,
  ) async {
    try {
      final url = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/${fileData.id}',
      );
      final response = await delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 404) {
        return true;
      } else if (response.statusCode == 401) {
        final newAccessToken = await getTokens();
        if (newAccessToken == null) {
          return false;
        }
        return deleteFile(newAccessToken, fileData, getTokens);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getExistingNoteFile(
    String fileId,
    String accessToken,
    Future<String?> Function() getTokens,
  ) async {
    try {
      final url = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/$fileId',
        {
          'alt': 'media',
        },
      );
      final response = await get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final cleanedJson = response.body.replaceAll('\n', '').trim();
        return cleanedJson;
      } else if (response.statusCode == 401) {
        final newAccessToken = await getTokens();
        if (newAccessToken == null) {
          return null;
        }
        return getExistingNoteFile(fileId, newAccessToken, getTokens);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<GoogleFile?> createNewFile(
    String accessToken,
    Uint8List content,
    String fileName,
    Future<String?> Function() getTokens,
  ) async {
    try {
      final url = Uri.https(
        'www.googleapis.com',
        '/upload/drive/v3/files',
        {
          'uploadType': 'multipart',
        },
      );

      final params = {
        'name': fileName,
        'title': fileName,
        'parents': [],
        // 'mimeType': 'text/plain',
      };
      final request = MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['Content-Type'] = 'multipart/related'
        ..files.add(MultipartFile.fromString(
          'metadata',
          json.encode(params),
          contentType: MediaType('application', 'json', {'charset': 'UTF-8'}),
          filename: fileName,
        ))
        ..files.add(MultipartFile.fromBytes(
          'file',
          content,
          // contentType: MediaType('text', 'plain'),
          filename: fileName,
        ));

      final response = await request.send().then((result) async {
        return Response.fromStream(result);
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        return GoogleFile(
          fileId: jsonResponse['id'],
        );
      } else if (response.statusCode == 401) {
        final newAccessToken = await getTokens();
        if (newAccessToken == null) {
          return null;
        }
        return createNewFile(
          newAccessToken,
          content,
          fileName,
          getTokens,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> createOrUpdateNotesFile(
    String? fileId,
    String accessToken,
    String stringifiedContent,
    Future<String?> Function() getTokens,
  ) async {
    try {
      final url = fileId != null
          ? Uri.https(
              'www.googleapis.com',
              '/upload/drive/v3/files/$fileId',
              {
                'uploadType': 'multipart',
              },
            )
          : Uri.https(
              'www.googleapis.com',
              '/upload/drive/v3/files',
              {
                'uploadType': 'multipart',
              },
            );

      final params = {
        'name': 'notes.json',
        'title': 'notes.json',
        'parents': [],
        'mimeType': 'text/plain',
      };
      final requestMethod = fileId != null ? 'PATCH' : 'POST';

      final request = MultipartRequest(requestMethod, url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['Content-Type'] = 'multipart/related'
        ..files.add(MultipartFile.fromString(
          'metadata',
          json.encode(params),
          contentType: MediaType('application', 'json', {'charset': 'UTF-8'}),
          filename: 'notes.json',
        ))
        ..files.add(MultipartFile.fromString(
          'file',
          stringifiedContent,
          contentType: MediaType('text', 'plain'),
          filename: 'notes.json',
        ));

      final response = await request.send().then((result) async {
        return Response.fromStream(result);
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final id = jsonResponse['id'];
        return id;
      } else if (response.statusCode == 401) {
        final newAccessToken = await getTokens();
        if (newAccessToken == null) {
          return null;
        }
        return createOrUpdateNotesFile(
          fileId,
          newAccessToken,
          stringifiedContent,
          getTokens,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
