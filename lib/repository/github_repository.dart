import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:notelytask/models/github_state.dart';

class GithubNote {
  GithubNote({this.sha, this.content});
  final String? sha;
  final Map<String, dynamic>? content;
}

class GithubRepository {
  Future<GithubNote?> createOrUpdateFile(
    String ownerRepo,
    String accessToken,
    Map<String, dynamic> content,
    String? sha,
  ) async {
    try {
      final stringifiedContent = json.encode(content);
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
      var response = await put(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        var content = jsonResponse['content'];
        var sha = content['sha'];

        return GithubNote(
          sha: sha,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<GithubNote?> getExistingNoteFile(
    String ownerRepo,
    String accessToken,
  ) async {
    try {
      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/notes.json',
      );
      var response = await get(
        url,
        headers: {'Authorization': 'bearer $accessToken'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = json.decode(response.body);

        final sha = jsonResponse['sha'];

        final cleanedJson = jsonResponse['content'].replaceAll('\n', '').trim();
        final base64Decoded = base64.decode(cleanedJson);
        final utfDecoded = utf8.decode(base64Decoded);
        final content = json.decode(utfDecoded);

        return GithubNote(
          sha: sha,
          content: content,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<GithubState> initialLogin() async {
    try {
      final url = Uri.https(
        'github.com',
        '/login/device/code',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'scope': 'repo',
        },
      );

      var response = await post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        var deviceCode = jsonResponse['device_code'];
        var userCode = jsonResponse['user_code'];
        var verificationUri = jsonResponse['verification_uri'];
        var expiresIn = jsonResponse['expires_in'];

        return GithubState(
          deviceCode: deviceCode,
          userCode: userCode,
          verificationUri: verificationUri,
          expiresIn: expiresIn,
        );
      } else {
        return GithubState(
          deviceCode: null,
          userCode: null,
          verificationUri: null,
          expiresIn: null,
        );
      }
    } catch (e) {
      return GithubState(
        deviceCode: null,
        userCode: null,
        verificationUri: null,
        expiresIn: null,
      );
    }
  }

  Future<String?> getAccessToken(String code) async {
    Uri? url;
    if (kIsWeb) {
      url = Uri.https(
        'api.notelytask.com',
        '/accessToken',
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
      var response = await post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        var accessToken = jsonResponse['access_token'];
        return accessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
