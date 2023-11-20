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
  // DataService database = await DataService.connectToDatabase();
  // print(await database.getAllPumpIpAddresses());
  // Pump testPump = Pump(
  //     id: 1,
  //     ipAddress: '192.168.224.40',
  //     drugName: 'Norepinephrine',
  //     patientName: 'Bonscii');
  // database.insertPump(testPump);
  // print(testPump);
  // testPump = testPump.changeRate(100);
  // testPump = testPump.changeVtbi(100);
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

  @override
  void initState() {
    super.initState();
    initConnection();
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();
  }

  void initConnection() async {
    socket.enableConsolePrint(true);
    if (await socket.canConnect(connectionTimeout)) {
      await socket.connect(connectionTimeout, () => {});
    } else {
      print('Failed to connect to $controllerIP.');
    }
  }
  // // Future<TcpSocketConnection socket =
  // //     TcpSocketConnection(controllerIP, controllerPort);
  // Map<int, TcpSocketConnection>? connectedSockets;
  // Future<DataService> database = DataService.connectToDatabase();
  // Future<KeyValueService> keyValueStore = KeyValueService.openKeyValueStore();
  bool loadOnTimeout = true;
  // // bool loadOnTimeout = true;

  // @override
  // void initState() {
  //   super.initState();
  //   initConnections();
  // }

  // @override
  // void dispose() {
  //   for (int key in connectedSockets!.keys) {
  //     connectedSockets![key]!.disconnect();
  //   }
  //   super.dispose();
  // }

  // void connectToPump(int pumpId, String pumpIpAddress) {
  //   TcpSocketConnection socket =
  //       TcpSocketConnection(pumpIpAddress, controllerPort);
  //   // socket.connect(connectionTimeout, () => connectedSockets![pumpId] = socket);
  // }

  // void disconnectFromPump(int pumpId) {
  //   connectedSockets![pumpId]!.disconnect();
  //   connectedSockets!.remove(pumpId);
  // }

  // void initConnections() async {
  //   // Map<int, String> connectedIpAddresses =
  //   //     await database.then((value) => value.getAllPumpIpAddresses());
  //   // Future.delayed(
  //   //     const Duration(seconds: 1), () => setState(() => loadOnTimeout = true));
  //   // for (int key in connectedIpAddresses.keys) {
  //   //   TcpSocketConnection socket =
  //   //       TcpSocketConnection(connectedIpAddresses[key]!, controllerPort);
  //   //   socket.enableConsolePrint(true);
  //   //   if (await socket.canConnect(connectionTimeout)) {
  //   //     await socket.connect(
  //   //         connectionTimeout, () => {connectedSockets![key] = socket});
  //   //     print(connectedSockets);
  //   //   } else {
  //   //     print('Failed to connect to ${connectedIpAddresses[key]}.');
  //   //   }
  //   // }

  //   connectedSockets = connectedSockets ?? {};

  TcpSocketConnection socket =
      TcpSocketConnection(controllerIP, controllerPort);
  // Future<DataService> database = DataService.connectToDatabase();
  // Future<KeyValueService> keyValueStore = KeyValueService.openKeyValueStore();

  void sendValueToPump(int targetPumpId, int value) {
    print('Attempting to send value $value to pump $targetPumpId...');
    // if (connectedSockets != null) {
    //   TcpSocketConnection? socket = connectedSockets![targetPumpId];
    //   if (socket == null) {
    //     print('The app is currently not connected to pump $targetPumpId.');
    //   } else {
    //     print('Successfully sent message!');
    //     socket.sendMessage(value.toString());
    //   }
    // }
    socket.sendMessage(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder(
            future: Future.wait([database, keyValueStore]),
            builder: (context, snapshot) {
              if (!(snapshot.hasData && loadOnTimeout)) {
                return const MaterialApp(home: StartupLoadingPage());
              }
              DataService awaitedDatabase = snapshot.data![0] as DataService;
              KeyValueService awaitedKeyValueStore =
                  snapshot.data![1] as KeyValueService;
              print('Opened database and key-value store.');
              return FutureBuilder(
                  future: Future.wait([
                    awaitedDatabase.getAllPumps(),
                    awaitedKeyValueStore.getCurrentlyActivePumpId()
                  ]),
                  builder: (context, snapshot) {
                    if (!(snapshot.hasData && loadOnTimeout)) {
                      return const MaterialApp(home: StartupLoadingPage());
                    }
                    List<Pump> allPumpsList =
                        (snapshot.data![0] as Iterable<Pump>).toList();
                    int currentlyActivePumpId = snapshot.data![1] as int;
                    print(
                        'Queried list of pumps and currently active pump\'s ID.');
                    return FutureBuilder(
                        future:
                            awaitedDatabase.getPumpById(currentlyActivePumpId),
                        builder: (context, snapshot) {
                          if (!(snapshot.hasData && loadOnTimeout)) {
                            return const MaterialApp(
                                home: StartupLoadingPage());
                          }
                          print(
                              'Got the currently active pump\'s info: ${snapshot.data!}');
                          return ActivePumpInfo(
                              activePumpOnStartup: snapshot.data!,
                              database: awaitedDatabase,
                              keyValueStore: awaitedKeyValueStore,
                              pumpListOnStartup: allPumpsList,
                              onSubmitValueCallback: (value) => sendValueToPump(
                                  currentlyActivePumpId, value));
                        });
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
