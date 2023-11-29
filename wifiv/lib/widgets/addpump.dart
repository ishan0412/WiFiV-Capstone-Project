import 'dart:async';
import 'dart:io';
// import 'dart:js_util';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:network_info_plus/network_info_plus.dart';
// import 'package:lan_scanner/lan_scanner.dart';
// import 'package:network_discovery/network_discovery.dart';
import 'package:network_tools/network_tools.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/data_model.dart';

const int controllerPort = 80; // will always be 80?
const int connectionTimeout =
    3000; // 5 seconds until app gives up connecting to microcontroller

class AddPumpWidget extends StatefulWidget {
  // final NetworkInfo networkInfo = NetworkInfo();
  final void Function(Pump) addPumpCallback;

  const AddPumpWidget({super.key, required this.addPumpCallback});

  @override
  AddPumpWidgetState createState() => AddPumpWidgetState();
}

class AddPumpWidgetState extends State<AddPumpWidget> {
  Map<String, TcpSocketConnection> availablePumps =
      {}; // set a timeout of 5 seconds; if this list is empty, move on from the loading screen and just say there aren't any pumps available

  @override
  void initState() {
    scanNetworkForPumps();
    super.initState();
  }

  void scanNetworkForPumps() async {
    // final appDocDirectory = await getApplicationDocumentsDirectory();
    // await configureNetworkTools(appDocDirectory.path, enableDebugging: true);
    // TODO: Handling changes to a different wifi network while the app is still running/active
    String thisDeviceIp = (await NetworkInfo().getWifiIP())!;
    print('this device\'s IP: $thisDeviceIp');
    String subnet = thisDeviceIp.substring(0, thisDeviceIp.lastIndexOf('.'));
    Stream<ActiveHost> stream =
        HostScanner.scanDevicesForSinglePort(subnet, controllerPort);
    stream.listen((ActiveHost host) {
      String currentPumpIp = host.internetAddress.address;
      // print(currentPumpIp);
      setState(() => availablePumps[currentPumpIp] =
          TcpSocketConnection(currentPumpIp, controllerPort));
    }, onDone: () {
      print('Scan complete.');
    });
    // List<String> pumpIpsInNetwork = [];
    // stream.listen((ActiveHost host) async {
    //   String currIpAddress = host.internetAddress.toString();
    //   // print(host.internetAddress);
    //   // addressesInNetwork.add(host.internetAddress);
    //   TcpSocketConnection currentsocket =
    //       TcpSocketConnection(currIpAddress, controllerPort);
    //   if (await currentsocket.canConnect(3000)) {
    //     setState(() => availablePumps[currIpAddress] = currentsocket);
    //     print('Mettu');
    //   }
    // }).onDone(() {
    //   print("Scan complete.");
    // });
    // print(addressesInNetwork);
    // final StreamController<ActiveHost> streamController =
    //     StreamController<ActiveHost>();
    // StreamSubscription<ActiveHost> subscription = streamController.stream.listen((host) async {
    //   print(host.internetAddress);
    //   // addressesInNetwork.add(host.ip);
    // }, onDone: () {
    //   print("Scan complete.");
    // });
    // TcpSocketConnection testSocket =
    //     TcpSocketConnection('192.168.26.183', controllerPort);
    // print(await testSocket.canConnect(3000));
    // LanScanner scanner = LanScanner();
    // final stream = scanner.icmpScan(subnet);
    // List<InternetAddress> addressesInNetwork = [];
    // stream.listen((HostModel host) {
    //   print(host.ip);
    //   // addressesInNetwork.add(host.ip);
    // }).onDone(() {
    //   print("Scan complete.");
    // });
  }

  void parseReceivedPumpInfo(
      String pumpInfo, TcpSocketConnection socketToPump) {
    Map<String, dynamic> addedPumpAsJson = jsonDecode(pumpInfo);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PatientNamePopup(onSubmitCallback: (String inputPatientName) {
              addedPumpAsJson['patientName'] = inputPatientName;
              // print(Pump.fromMap(addedPumpAsJson));
              widget.addPumpCallback(Pump.fromMap(addedPumpAsJson));
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // ? close add pump widget too?
              socketToPump.disconnect();
            })));
  }

  void connectToPump(String pumpIp) async {
    // TODO: Handling for if the pump is already connected to the app:
    TcpSocketConnection? socket = availablePumps[pumpIp];
    if (socket == null) {
      print('Pump IP $pumpIp does not exist.');
    } else if (!(await socket.canConnect(connectionTimeout))) {
      print('Can\'t connect to pump at IP $pumpIp.');
    } else {
      print('Pump at IP $pumpIp is open for connection!');
      socket.enableConsolePrint(true);
      await socket.connect(connectionTimeout, (String message) => parseReceivedPumpInfo(message, socket));
      // parseReceivedPumpInfo('');
      // ! remember to disconnect sockets when we're done with them
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(scrollDirection: Axis.vertical, children: [
      for (String e in availablePumps.keys)
        AvailablePumpButton(pumpIp: e, connectToPumpCallback: connectToPump)
    ]));
  }
}

class AvailablePumpButton extends StatelessWidget {
  final String pumpIp;
  final void Function(String) connectToPumpCallback;

  const AvailablePumpButton(
      {super.key, required this.pumpIp, required this.connectToPumpCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        child: TextButton(
            onPressed: () => connectToPumpCallback(pumpIp),
            child: Text(pumpIp)));
  }
}

class PatientNamePopup extends StatelessWidget {
  final void Function(String) onSubmitCallback;

  const PatientNamePopup({super.key, required this.onSubmitCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: 100, child: TextField(onSubmitted: onSubmitCallback)));
  }
}
