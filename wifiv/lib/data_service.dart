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
          'CREATE TABLE pumps(id INTEGER PRIMARY KEY, ipAddress TEXT, drugName TEXT, patientName TEXT, currentRate REAL, currentVtbi REAL, pumpChangeLog TEXT)');
    }, onUpgrade: ((db, oldVersion, newVersion) {
      // db.execute('ALTER TABLE pumps ADD drugName TEXT');
      // db.execute('ALTER TABLE pumps ADD patientName TEXT');
      // db.execute('ALTER TABLE pumps ADD currentRate REAL');
      // db.execute('ALTER TABLE pumps ADD currentVtbi REAL');
      // return db.execute('ALTER TABLE pumps ADD pumpChangeLog TEXT');
      // return db.execute('ALTER TABLE pumps ADD patientName TEXT');
    }), version: 5);
    return DataService._create(database);
  }

  Future<void> insertPump(Pump pump) async {
    await database.insert('pumps', pump.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Pump> getPumpById(int id) async {
    return Pump.fromMap(
        (await database.query('pumps', distinct: true, where: 'id = $id'))[0]);
  }

  Future<Iterable<Pump>> getAllPumps() async {
    final List<Map<String, dynamic>> pumpsAsMaps =
        await database.query('pumps');
    return pumpsAsMaps.map(Pump.fromMap);
  }

  Future<Map<int, String>> getAllPumpIpAddresses() async {
    List<Map<String, dynamic>> pumpsAsMaps =
        await database.query('pumps', columns: ['id', 'ipAddress']);
    return {
      for (Map<String, dynamic> e in pumpsAsMaps) e['id']: e['ipAddress']
    };
  }

  Future<void> clearDatabase() async {
    await database.delete('pumps');
  }
}
