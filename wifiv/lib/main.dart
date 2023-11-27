import 'package:flutter/material.dart';
import 'data/keyvalue_service.dart';
import 'data/data_service.dart';
import 'data/data_model.dart';
import 'titrationsettings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // KeyValueService keyValueStore = await KeyValueService.openKeyValueStore();
  // keyValueStore.setCurrentlyActivePumpId(0);
  // DataService database = await DataService.connectToDatabase();
  // database.clearDatabase();
  // Pump testPump = Pump(
  //     id: 0,
  //     ipAddress: '192.168.224.196',
  //     drugName: 'Adrenaline',
  //     patientName: 'Pauleh');
  // database.insertPump(testPump);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Future<DataService> database = DataService.connectToDatabase();
  Future<KeyValueService> keyValueStore = KeyValueService.openKeyValueStore();

  void setPumpDripRate(int pumpId, double updatedRate) async {
    DataService awaitedDatabase = await database;
    awaitedDatabase.updatePump(
        (await awaitedDatabase.getPumpById(pumpId)).changeRate(updatedRate));
  }

  void setPumpVtbi(int pumpId, double updatedVtbi) async {
    DataService awaitedDatabase = await database;
    awaitedDatabase.updatePump(
        (await awaitedDatabase.getPumpById(pumpId)).changeVtbi(updatedVtbi));
  }

  // void updatePumpOnlyRateAndVtbi(Pump updatedPump) async {
  //   // ! NOTE: probably clears pump update log
  //   (await database).updatePumpOnlyRateAndVtbi(updatedPump);
  // }

  void updatePumpOnlyRateAndVtbi(Pump updatedPump) async {
    // ! NOTE: probably clears pump update log
    (await database).updatePump(updatedPump);
  }

  void addPump(Pump addedPump) async {
    (await database).insertPump(addedPump);
    // (await keyValueStore).setCurrentlyActivePumpId(addedPump.id);
  }

  void selectPump(int selectedPumpId) async {
    (await keyValueStore).setCurrentlyActivePumpId(selectedPumpId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: FutureBuilder(
      future: Future.wait([database, keyValueStore]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const StartupLoadingScreen();
        }
        DataService awaitedDatabase = snapshot.data![0] as DataService;
        KeyValueService keyValueStore = snapshot.data![1] as KeyValueService;
        return FutureBuilder(
          future: Future.wait([
            awaitedDatabase.getDatabaseAsDict(),
            keyValueStore.getCurrentlyActivePumpId()
          ]),
          builder: (context, snapshot) {
            return (snapshot.hasData)
                ? MainPage(
                    database: snapshot.data![0] as Map<int, Pump>,
                    currentlyActivePumpId: snapshot.data![1] as int,
                    setPumpDripRateCallback: setPumpDripRate,
                    setPumpVtbiCallback: setPumpVtbi,
                    reloadPumpCallback: updatePumpOnlyRateAndVtbi,
                    selectPumpCallback: selectPump,
                    addPumpCallback: addPump)
                : const StartupLoadingScreen();
          },
        );
      },
    )));
  }
}

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Loading...');
  }
}
