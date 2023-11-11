import 'package:flutter/material.dart';
import 'custom_number_input.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'data_model.dart';
import 'data_service.dart';

/// TODO: Database storing each patient and pump along with their connection info (IP/port), medication, patient name, pump edit history, etc.
///
const String controllerIP =
    '192.168.224.182'; // will prob be dynamically obtained/updated
const int controllerPort = 80; // will always be 80?
const int connectionTimeout =
    5000; // 5 seconds until app gives up connecting to microcontroller

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

// TODO: Exception handling for unopened connections (for example, the micro-
// controller is off)
// ! The main page should be *always* listening to changes in dosage, VTBI, and/or drug (since these can be done from multiple devices); when a change happens, the microcontroller will *broadcast* the updated pump settings to all connected devices, and the mainpagestate widget should update the database entry for the pump accordingly
// TODO: Put the "functional" parts of the main page (connecting to the database, connecting to the currently-selected IP address via sockets) in their own class/widget (like some sort of separate controller?), and make the main page its own widget into which all the data from the database/socket connection is passed???
// ? Refactor some code parts to use FutureBuilder instead of async/await?
class _HomePageState extends State<HomePage> {
  TcpSocketConnection socket =
      TcpSocketConnection(controllerIP, controllerPort);

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataService>(
        future: DataService.connectToDatabase(),
        builder: (context, AsyncSnapshot<DataService> snapshot) {
          if (snapshot.data == null) {
            return const HomePageLoading();
          }
          DataService database = snapshot.data!;
          // database.insertPump(const Pump(id: 1, ipAddress: 'Mettu Street'));
          return FutureBuilder<Iterable<Pump>>(
              future: database.getAllPumps(),
              builder: (context, AsyncSnapshot<Iterable<Pump>> snapshot) {
                if (snapshot.data == null) {
                  return const HomePageLoading();
                }
                List<Widget> allPumpsInfo = [
                  for (Pump e in snapshot.data!) Text(e.toString())
                ];
                allPumpsInfo.add(CustomNumberInput(
          senderCallback: ((value) => socket.sendMessage(value.toString()))));
                return Scaffold(body: Column(children: allPumpsInfo));
              });
        });
  }

  // Scaffold(
  //       body: Column(children: [
  //     CustomNumberInput(
  //         senderCallback: ((value) => socket.sendMessage(value.toString())))
  //   ]));
}

class HomePageLoading extends StatelessWidget {
  const HomePageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Loading...'));
  }
}
