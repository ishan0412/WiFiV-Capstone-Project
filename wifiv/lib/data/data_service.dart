import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data_model.dart';
import 'dart:io' show Platform;

class DataService {
  final Database database;

  DataService._create(this.database);

  static Future<DataService> connectToDatabase() async {
    if (!(Platform.isIOS)) {
      WidgetsFlutterBinding.ensureInitialized();
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    var databasePath = join(await getDatabasesPath(), 'pump_settings_database.db');
    Database database = await openDatabase(
        databasePath,
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE pumps(id INTEGER PRIMARY KEY, ipAddress TEXT, drugName TEXT, patientName TEXT, currentRate REAL, currentVtbi REAL, pumpChangeLog TEXT)');
    }, onUpgrade: ((db, oldVersion, newVersion) {
      print('Mettu');
      // db.execute('ALTER TABLE pumps ADD drugName TEXT');
      // db.execute('ALTER TABLE pumps ADD patientName TEXT');
      // db.execute('ALTER TABLE pumps ADD currentRate REAL');
      // db.execute('ALTER TABLE pumps ADD currentVtbi REAL');
      // db.execute('ALTER TABLE pumps ADD pumpChangeLog TEXT');
      // return db.execute('ALTER TABLE pumps ADD patientName TEXT');
    }), version: 2);
    return DataService._create(database);
  }

  Future<void> insertPump(Pump pump) async {
    await database.insert('pumps', pump.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePump(Pump pump) async {
    await database.update('pumps', pump.toMap(), where: 'id = ${pump.id}');
  }

  // Future<void> updatePumpOnlyRateAndVtbi(Pump pump) async {
  //   await database.update('pumps',
  //       {'currentRate': pump.currentRate, 'currentVtbi': pump.currentVtbi},
  //       where: 'id = ${pump.id}');
  // }

  Future<Pump> getPumpById(int id) async {
    return Pump.fromMap(
        (await database.query('pumps', distinct: true, where: 'id = $id'))[0]);
  }

  Future<Iterable<Pump>> getAllPumps() async {
    final List<Map<String, dynamic>> pumpsAsMaps =
        await database.query('pumps');
    return pumpsAsMaps.map(Pump.fromMap);
  }

  Future<Map<int, Pump>> getDatabaseAsDict() async {
    return {for (Pump e in (await getAllPumps())) e.id: e};
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
