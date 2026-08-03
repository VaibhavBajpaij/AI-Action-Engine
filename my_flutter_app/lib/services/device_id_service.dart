import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  final SharedPreferences _prefs;
  static const String _key = 'deviceId';
  static const _uuid = Uuid();

  DeviceIdService(this._prefs);

  /// Gets the device ID. Generates and stores a new UUID v4 on first launch.
  String get deviceId {
    String? id = _prefs.getString(_key);
    if (id == null) {
      id = _uuid.v4();
      _prefs.setString(_key, id);
    }
    return id;
  }
}
