import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  static const _storage = FlutterSecureStorage();

  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _photoUrlKey = 'photo_url';

  Future<void> saveSession({
    required String userId,
    required String username,
    required String photoUrl,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _photoUrlKey, value: photoUrl);
  }

  Future<String?> getUserId() {
    return _storage.read(key: _userIdKey);
  }

  Future<String?> getUsername() {
    return _storage.read(key: _usernameKey);
  }

  Future<String?> getPhotoUrl() {
    return _storage.read(key: _photoUrlKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _photoUrlKey);
  }
}
