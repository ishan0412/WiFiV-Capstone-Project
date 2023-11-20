import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

class KeyValueService {
  final SharedPreferences keyValueStore;

  KeyValueService._create(this.keyValueStore);

  static Future<KeyValueService> openKeyValueStore() async {
    WidgetsFlutterBinding.ensureInitialized();
    return KeyValueService._create(await SharedPreferences.getInstance());
  }

  Future<void> setCurrentlyActivePumpId(int pumpId) async {
    keyValueStore.setInt('currentlyActivePumpId', pumpId);
  }

  Future<int> getCurrentlyActivePumpId() async {
    return keyValueStore.getInt('currentlyActivePumpId') ?? -1;
  }
}
