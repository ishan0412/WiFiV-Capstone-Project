import 'package:flutter/material.dart';
import 'package:wifiv/homepage_controller.dart';
// import 'keyvalue_service.dart';
// import 'custom_number_input.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:wifiv/keyvalue_service.dart';
import 'data_service.dart';
import 'data_model.dart';
import 'infodisplays.dart';
// import 'dart:convert';

// /// TODO: Database storing each patient and pump along with their connection info (IP/port), medication, patient name, pump edit history, etc.
// ///
const String controllerIP =
    '192.168.224.40'; // will prob be dynamically obtained/updated
const int controllerPort = 80; // will always be 80?
const int connectionTimeout =
    5000; // 5 seconds until app gives up connecting to microcontroller

void main() {
  // KeyValueService keyValueStore = await KeyValueService.openKeyValueStore();
  // keyValueStore.setCurrentlyActivePumpId(0);
  // DataService database = await DataService.connectToDatabase();
  // database.clearDatabase();
  // print(await database.getAllPumpIpAddresses());
  // Pump testPump = Pump(
  //     id: 2,
  //     ipAddress: '192.168.224.196',
  //     drugName: 'Adrenaline',
  //     patientName: 'Pauleh');
  // database.insertPump(testPump);
  // print(testPump);
  // testPump = testPump.changeRate(300);
  // testPump = testPump.changeVtbi(1000);
  // print(testPump);
  // database.updatePump(testPump);
  // print(Pump.fromMap(testPump.toMap()));
  // print(jsonDecode(jsonEncode(testPump.pumpChangeLog.map((e) => e.toJson()).toList())));
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(home: HomePageController());
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<DataService> database = DataService.connectToDatabase();
  Future<KeyValueService> keyValueStore = KeyValueService.openKeyValueStore();
  Map<int, TcpSocketConnection> connectedSockets = {};
  bool loadOnTimeout = true;
  // // bool loadOnTimeout = true;

  @override
  void initState() {
    super.initState();
    initConnections();
  }

  @override
  void dispose() {
    for (int key in connectedSockets.keys) {
      connectedSockets[key]!.disconnect();
    }
    super.dispose();
  }

  void connectToPump(int pumpId, String pumpIpAddress) async {
    TcpSocketConnection socket =
        TcpSocketConnection(pumpIpAddress, controllerPort);
    connectedSockets[pumpId] = socket;
    if (await socket.canConnect(connectionTimeout)) {
      socket.connect(connectionTimeout,
          () => print('Connected to pump $pumpId at IP $pumpIpAddress!'));
    } else {
      print(
          'Connection to $pumpId at IP $pumpIpAddress currently unavailable.');
    }
  }

  // void disconnectFromPump(int pumpId) {
  //   connectedSockets[pumpId]!.disconnect();
  //   connectedSockets.remove(pumpId);
  // }

  void initConnections() async {
    Map<int, String> connectedIpAddresses =
        await database.then((value) => value.getAllPumpIpAddresses());
    Future.delayed(const Duration(seconds: connectionTimeout),
        () => setState(() => loadOnTimeout = true));
    for (int key in connectedIpAddresses.keys) {
      connectToPump(key, connectedIpAddresses[key]!);
    }
    print(connectedSockets);
  }

  void sendValueToPump(int targetPumpId, int value) {
    print('Attempting to send value $value to pump $targetPumpId...');
    TcpSocketConnection socket = connectedSockets[targetPumpId]!;
    if (socket.isConnected()) {
      print('Successfully sent message!');
      socket.sendMessage(value.toString());
    } else {
      print('The app is currently not connected to pump $targetPumpId.');
    }
  }

  void addPump(Pump pumpToAdd) async {
    (await database).insertPump(pumpToAdd);
  }

  void selectPump(int selectedPumpId) async {
    (await keyValueStore).setCurrentlyActivePumpId(selectedPumpId);
  }

  void removePump(int pumpToRemoveId) async {
    // (await database).
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder(
            future: Future.wait([database, keyValueStore]),
            builder: (context, snapshot) {
              if (!(snapshot.hasData && loadOnTimeout)) {
                return const StartupLoadingPage();
              }
              DataService awaitedDatabase = snapshot.data![0] as DataService;
              KeyValueService awaitedKeyValueStore =
                  snapshot.data![1] as KeyValueService;
              print('Opened database and key-value store.');
              return FutureBuilder(
                  future: Future.wait([
                    // awaitedDatabase.getAllPumps(),
                    awaitedDatabase.getDatabaseAsDict(),
                    awaitedKeyValueStore.getCurrentlyActivePumpId()
                  ]),
                  builder: (context, snapshot) {
                    if (!(snapshot.hasData && loadOnTimeout)) {
                      return StartupLoadingPage();
                    }
                    // List<Pump> allPumpsList =
                    //     (snapshot.data![0] as Iterable<Pump>).toList();
                    Map<int, Pump> databaseAsDict =
                        snapshot.data![0] as Map<int, Pump>;
                    int currentlyActivePumpId = snapshot.data![1] as int;
                    print(
                        'Queried list of pumps and currently active pump\'s ID.');
                    // return FutureBuilder(
                    //     future:
                    //         awaitedDatabase.getPumpById(currentlyActivePumpId),
                    //     builder: (context, snapshot) {
                    //       if (!(snapshot.hasData && loadOnTimeout)) {
                    //         return const MaterialApp(
                    //             home: StartupLoadingPage());
                    //       }
                    //       print(
                    //           'Got the currently active pump\'s info: ${snapshot.data!}');
                    //       return ActivePumpInfo(
                    //           activePumpOnStartup: snapshot.data!,
                    //           allPumpsListOnStartup: allPumpsList,
                    //           onPumpSelectCallback: selectPump,
                    //           onPumpAddCallback: addPump,
                    //           onPumpRemoveCallback: removePump);
                    //     });
                    return ActivePumpInfo(
                        activePumpIdOnStartup: currentlyActivePumpId,
                        databaseOnStartup: databaseAsDict,
                        onPumpSelectCallback: selectPump,
                        onPumpAddCallback: addPump,
                        onPumpRemoveCallback: removePump);
                  });
            }));
  }
}

// TODO: Package all of the FutureBuilders' logic into this class:
class StartupLoadingPage extends StatelessWidget {
  const StartupLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Mettu'));
  }
}
