import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:convert';
import 'package:notelytask/models/github_state.dart';
import 'package:path_provider/path_provider.dart';

class GithubFile {
  GithubFile({this.sha, this.content});
  final String? sha;
  final String? content;
}

class GithubRepository {
  Future<GithubFile?> createNewFile(
    String ownerRepo,
    String accessToken,
    Uint8List content,
    String fileName,
  ) async {
    try {
      final encodedContent = base64.encode(content);

      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/$fileName',
      );
      final body = {
        'message': '$fileName uploaded',
        'content': encodedContent,
      };
      final response = await put(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        final content = jsonResponse['content'];
        final sha = content['sha'];

        return GithubFile(
          sha: sha,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile(
    String ownerRepo,
    String accessToken,
    String sha,
    String fileName,
  ) async {
    try {
      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/$fileName',
      );
      final body = {
        'message': '$fileName deleted',
        'sha': sha,
      };
      final response = await delete(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
        body: jsonEncode(body),
      );

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

  Future<GithubFile?> createOrUpdateNotesFile(
    String ownerRepo,
    String accessToken,
    String stringifiedContent,
    String? sha,
  ) async {
    try {
      final encodedContent = base64.encode(utf8.encode(stringifiedContent));

      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/notes.json',
      );
      final body = sha != null
          ? {
              'message': 'Notes added',
              'sha': sha,
              'content': encodedContent,
            }
          : {
              'message': 'Notes added',
              'content': encodedContent,
            };
      final response = await put(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        final content = jsonResponse['content'];
        final sha = content['sha'];

        return GithubFile(
          sha: sha,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<File?> getFile(
    String ownerRepo,
    String accessToken,
    String fileName,
  ) async {
    try {
      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/$fileName',
      );
      final response = await get(
        url,
        headers: {
          'Authorization': 'bearer $accessToken',
          'accept': 'application/vnd.github.raw+json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Directory dir = kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory();

        final path = '${dir.path}/$fileName';

        final file = File(path);
        await file.writeAsBytes(
          response.bodyBytes,
          mode: FileMode.write,
        );

        return file;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<GithubFile?> getExistingNoteFile(
    String ownerRepo,
    String accessToken,
  ) async {
    try {
      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/notes.json',
      );
      final response = await get(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);

        final sha = jsonResponse['sha'];

        final cleanedJson = jsonResponse['content'].replaceAll('\n', '').trim();
        final base64Decoded = base64.decode(cleanedJson);
        final utfDecoded = utf8.decode(base64Decoded);

        return GithubFile(
          sha: sha,
          content: utfDecoded,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<GithubState?> initialLogin() async {
    try {
      final url = Uri.https(
        'github.com',
        '/login/device/code',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'scope': 'repo',
        },
      );

      final response = await post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        final deviceCode = jsonResponse['device_code'];
        final userCode = jsonResponse['user_code'];
        final verificationUri = jsonResponse['verification_uri'];
        final expiresIn = jsonResponse['expires_in'];

        return GithubState(
          deviceCode: deviceCode,
          userCode: userCode,
          verificationUri: verificationUri,
          expiresIn: expiresIn,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccessToken(String code) async {
    Uri? url;
    if (kIsWeb) {
      final endpoint = dotenv.env['ENDPOINT'];
      if (endpoint == null) {
        return null;
      }
      url = Uri.https(
        endpoint,
        '/notelytask-access-token',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'code': code,
        },
      );
    } else {
      url = Uri.https(
        'github.com',
        '/login/oauth/access_token',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'device_code': code,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );
    }
    try {
      final response = await post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        final accessToken = jsonResponse['access_token'];
        return accessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
