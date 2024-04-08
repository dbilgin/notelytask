import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notelytask/cubit/models/google_sign_in_result.dart';

class GoogleDriveRepository {
  Future<GoogleSignInResult?> signIn() async {
    try {
      const List<String> scopes = [
        'https://www.googleapis.com/auth/drive.appdata',
        'https://www.googleapis.com/auth/drive.file',
      ];

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
}
