// import 'package:flutter/material.dart';
// import 'package:wifiv/homepage_views.dart';
// import 'package:wifiv/keyvalue_service.dart';
// import 'package:tcp_socket_connection/tcp_socket_connection.dart';
// import 'pump_navbar.dart';
// import 'data_model.dart';
// import 'data_service.dart';

// /// TODO: Database storing each patient and pump along with their connection info (IP/port), medication, patient name, pump edit history, etc.
// ///
// const String controllerIP =
//     '192.168.224.40'; // will prob be dynamically obtained/updated
// const int controllerPort = 80; // will always be 80?
// const int connectionTimeout =
//     5000; // 5 seconds until app gives up connecting to microcontroller

// class HomePageController extends StatefulWidget {
//   const HomePageController({super.key});

//   @override
//   _HomePageControllerState createState() => _HomePageControllerState();
// }

// // TODO: Exception handling for unopened connections (for example, the micro-
// // controller is off)
// // ! The main page should be *always* listening to changes in dosage, VTBI, and/or drug (since these can be done from multiple devices); when a change happens, the microcontroller will *broadcast* the updated pump settings to all connected devices, and the mainpagestate widget should update the database entry for the pump accordingly
// // TODO: Put the "functional" parts of the main page (connecting to the database, connecting to the currently-selected IP address via sockets) in their own class/widget (like some sort of separate controller?), and make the main page its own widget into which all the data from the database/socket connection is passed???
// // ? Refactor some code parts to use FutureBuilder instead of async/await?
// class _HomePageControllerState extends State<HomePageController> {
//   TcpSocketConnection socket =
//       TcpSocketConnection(controllerIP, controllerPort);
//   // Future<DataService> database = DataService.connectToDatabase();
//   // Future<KeyValueService> keyValueStore = KeyValueService.openKeyValueStore();

//   @override
//   void initState() {
//     super.initState();
//     initConnection();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     socket.disconnect();
//   }

//   void initConnection() async {
//     socket.enableConsolePrint(true);
//     if (await socket.canConnect(connectionTimeout)) {
//       await socket.connect(connectionTimeout, () => {});
//     } else {
//       print('Failed to connect to $controllerIP.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: Future.wait([
//           DataService.connectToDatabase(),
//           KeyValueService.openKeyValueStore()
//         ]),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const HomePageLoading();
//           }
//           DataService database = snapshot.data![0] as DataService;
//           KeyValueService keyValueStore = snapshot.data![1] as KeyValueService;
//           return FutureBuilder(
//               future: Future.wait([
//                 database.getAllPumps(),
//                 keyValueStore.getCurrentlyActivePumpId(),
//               ]),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const HomePageLoading();
//                 }
//                 // return HomePage(
//                 //     allPumpsInfo:
//                 //         (snapshot.data![0] as Iterable<Pump>).toList(),
//                 //     currentlyActivePumpId: snapshot.data![1] as int,
//                 //     senderCallback: ((value) =>
//                 //         socket.sendMessage(value.toString())));
//                 List<Pump> allPumpsListOnStartup =
//                     (snapshot.data![0] as Iterable<Pump>).toList();
//                 int currentlyActivePumpOnStartup = snapshot.data![1] as int;
//                 return PumpNavBar(
//                     keyValueStore: keyValueStore,
//                     database: database,
//                     currentlyActivePumpOnStartup: snapshot.data![1] as int,
//                     allPumpsListOnStartup:
//                         (snapshot.data![0] as Iterable<Pump>).toList());
//               });
//         });
//   }
// }
