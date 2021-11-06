import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:notelytask/models/github_state.dart';

class GithubNote {
  GithubNote({this.sha, this.content});
  final String? sha;
  final String? content;
}

class GithubRepository {
  Future<GithubNote?> getExistingNoteFile(
    String ownerRepo,
    String? accessToken,
  ) async {
    try {
      if (accessToken == null) return null;

      final url = Uri.https(
        'api.github.com',
        '/repos/$ownerRepo/contents/notes.json',
      );
      var response = await post(url, headers: {'Authorization': accessToken});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        var sha = jsonResponse['sha'];
        var content = jsonResponse['content'];

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

      if (response.statusCode == 200) {
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

  Future<String?> getAccessToken(String deviceCode) async {
    try {
      final url = Uri.https(
        'github.com',
        '/login/oauth/access_token',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );

      var response = await post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
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
