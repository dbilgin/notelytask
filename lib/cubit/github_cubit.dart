import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class GithubCubit extends HydratedCubit<GithubState> {
  GithubCubit() : super(GithubState());

  void setRepoUrl(String repoUrl) {
    emit(state.copyWith(repoUrl: repoUrl));
  }

  void reset() {
    emit(GithubState());
  }

  void setAccessToken(String? accessToken) {
    emit(state.copyWith(accessToken: accessToken));
  }

  void setSha(String sha) {
    emit(state.copyWith(sha: sha));
  }

  Future<void> launchLogin() async {
    try {
      final url = Uri.https('github.com', '/login/device/code', {
        'client_id': dotenv.env['GITHUB_CLIENT_ID'],
        'scope': 'repo',
      });

      var response =
          await http.post(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;

        emit(state.copyWith(
          deviceCode: jsonResponse['device_code'],
          userCode: jsonResponse['user_code'],
          verificationUri: jsonResponse['verification_uri'],
          expiresIn: jsonResponse['expires_in'],
        ));
      } else {
        emit(state.copyWith(
          deviceCode: null,
          userCode: null,
          verificationUri: null,
          expiresIn: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        deviceCode: null,
        userCode: null,
        verificationUri: null,
        expiresIn: null,
      ));
    }
  }

  Future<void> getAccessToken(String deviceCode) async {
    final url = Uri.https('github.com', '/login/oauth/access_token', {
      'client_id': dotenv.env['GITHUB_CLIENT_ID'],
      'device_code': deviceCode,
      'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
    });

    var response =
        await http.post(url, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;

      var accessToken = jsonResponse['access_token'];
      setAccessToken(accessToken);
    } else {
      setAccessToken(null);
    }
  }

  @override
  GithubState fromJson(Map<String, dynamic> json) {
    return GithubState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GithubState state) {
    return state.toJson();
  }
}
