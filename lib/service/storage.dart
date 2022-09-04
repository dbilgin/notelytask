import 'package:get_storage/get_storage.dart';

enum StorageKeys { googleAuthHeaders, driveUploadEnabled }

class Storage {
  final box = GetStorage();

  Future<void> write(StorageKeys key, dynamic data) async {
    await box.write(key.toString(), data);
  }

  dynamic read(StorageKeys key) {
    return box.read(key.toString());
  }

  dynamic readMap(StorageKeys key) {
    var value = box.read(key.toString());

    if (value == null) return null;
    return Map<String, String>.from(value);
  }

  Future<void> remove(StorageKeys key) async {
    return await box.remove(key.toString());
  }

  void listen(StorageKeys key, Function(dynamic value) callback) {
    box.listenKey(key.toString(), callback);
  }
}
