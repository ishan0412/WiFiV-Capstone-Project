import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'data_model.dart';

class DataService {
  final Database database;

  DataService._create(this.database);

  static Future<DataService> connectToDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    Database database = await openDatabase(
        join(await getDatabasesPath(), 'pump_settings_database.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE pumps(id INTEGER PRIMARY KEY, ipAddress TEXT)');
    }, version: 1);
    return DataService._create(database);
  }

  Future<void> insertPump(Pump pump) async {
    await database.insert('pumps', pump.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Iterable<Pump>> getAllPumps() async {
    final List<Map<String, dynamic>> pumpsAsMaps =
        await database.query('pumps');
    return pumpsAsMaps.map(Pump.fromMap);
  }
}
