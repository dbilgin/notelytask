import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:http/http.dart' as http;

const _scopes = [gd.DriveApi.driveAppdataScope];

class GoogleDrive {
  final googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<GoogleSignInAccount?> login() async {
    try {
      final GoogleSignInAccount? account =
          await googleSignIn.signInSilently(suppressErrors: false);
      return account;
    } catch (e) {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      return account;
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

  Future<gd.DriveApi> createClient() async {
    var account = await login();

    final authHeaders = await account!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return gd.DriveApi(authenticateClient);
  }

  Future<gd.FileList> listFiles() async {
    var driveApi = await createClient();
    var fileList = await driveApi.files.list(spaces: 'appDataFolder');
    return fileList;
  }

  Future<Object> readFile(String fileId) async {
    var driveApi = await createClient();
    var file = await driveApi.files.get(fileId);
    return file;
  }

  Future<void> uploadFile() async {
    var driveApi = await createClient();

    final Stream<List<int>> mediaStream =
        Future.value([104, 105]).asStream().asBroadcastStream();
    var media = new gd.Media(mediaStream, 2);
    var driveFile = new gd.File();
    driveFile.name = "hello_world.txt";
    driveFile.parents = ['appDataFolder'];

    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");
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
