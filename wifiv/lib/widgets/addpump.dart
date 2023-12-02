import 'dart:async';
// import 'dart:io';
// import 'dart:js_util';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_discovery/network_discovery.dart';
import '../constants/constants.dart';
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
  final Set<String> currentlyConnectedPumpAddresses;
  final void Function() onPumpSelectForConnection;

  const AddPumpWidget(
      {super.key,
      required this.addPumpCallback,
      required this.currentlyConnectedPumpAddresses,
      required this.onPumpSelectForConnection});

  @override
  AddPumpWidgetState createState() => AddPumpWidgetState();
}

class AddPumpWidgetState extends State<AddPumpWidget> {
  Map<String, TcpSocketConnection> availablePumps =
      {}; // set a timeout of 5 seconds; if this list is empty, move on from the loading screen and just say there aren't any pumps available
  OverlayEntry? overlayEntry;

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
      if (!widget.currentlyConnectedPumpAddresses.contains(currentPumpIp)) {
        setState(() => availablePumps[currentPumpIp] =
            TcpSocketConnection(currentPumpIp, controllerPort));
      }
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
    OverlayState? overlayState = Overlay.of(context);
    List<String> parsedMessageData = pumpInfo.split('#');
    Map<String, dynamic> addedPumpAsJson = jsonDecode(parsedMessageData[0]);
    overlayEntry = OverlayEntry(
        builder: (context) =>
            PatientNamePopup(onSubmitCallback: (String inputPatientName) {
              addedPumpAsJson['patientName'] = inputPatientName;
              // print(Pump.fromMap(addedPumpAsJson));
              widget.addPumpCallback(Pump.fromMap(addedPumpAsJson));
              widget.onPumpSelectForConnection();
              overlayEntry!.remove();
              socketToPump.disconnect();
            }));
    overlayState.insert(overlayEntry!);
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
      await socket.connect(connectionTimeout,
          (String message) => parseReceivedPumpInfo(message, socket));
      // parseReceivedPumpInfo('');
      // ! remember to disconnect sockets when we're done with them
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: const Color.fromARGB(200, 39, 44, 59),
        child: Container(
            padding: const EdgeInsets.all(minButtonPadding),
            decoration: const BoxDecoration(
                color: themeOverlay,
                borderRadius: BorderRadius.all(
                    Radius.circular(fieldCornerRadiusOnPhone))),
            child: Column(
                // scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                children: [
                  for (String e in availablePumps.keys)
                    AvailablePumpButton(
                        pumpIp: e, connectToPumpCallback: connectToPump)
                ])));
  }
}

class AvailablePumpButton extends StatelessWidget {
  final String pumpIp;
  final void Function(String) connectToPumpCallback;

  const AvailablePumpButton(
      {super.key, required this.pumpIp, required this.connectToPumpCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: minButtonWidthOnPhone,
        height: buttonHeightOnPhone,
        child: TextButton(
            onPressed: () => connectToPumpCallback(pumpIp),
            style: ButtonStyle(
                minimumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                fixedSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                maximumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
                textStyle: const MaterialStatePropertyAll(bodyTextStyle),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(buttonCornerRadiusOnPhone))),
                padding: const MaterialStatePropertyAll(
                    EdgeInsets.all(minButtonPadding))),
            child: Text(pumpIp.substring(pumpIp.lastIndexOf('.') + 1))));
  }
}

class PatientNamePopup extends StatelessWidget {
  final void Function(String) onSubmitCallback;

  const PatientNamePopup({super.key, required this.onSubmitCallback});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: [
      SizedBox(height: 200),
      Container(height: 100, child: TextField(onSubmitted: onSubmitCallback))
    ]));
  }
}
