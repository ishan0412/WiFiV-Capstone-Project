import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'data/data_model.dart';
import 'widgets/custom_number_input.dart';
import 'pump_navbar.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
// import 'dart:math' show min;
import 'constants/constants.dart';

const int controllerPort = 80; // will always be 80?
const int connectionTimeout =
    3000; // 5 seconds until app gives up connecting to microcontroller

class MainPage extends StatefulWidget {
  Map<int, Pump> database;
  Map<int, List<double>> bloodPressureStorage = {};
  Map<int, TcpSocketConnection> socketsByPumpId = {};
  int currentlyActivePumpId;
  final void Function(int, double) setPumpDripRateCallback;
  final void Function(int, double) setPumpVtbiCallback;
  final void Function(Pump) reloadPumpCallback;
  final void Function(int) selectPumpCallback;
  final void Function(Pump) addPumpCallback;

  MainPage(
      {super.key,
      required this.database,
      required this.currentlyActivePumpId,
      required this.setPumpDripRateCallback,
      required this.setPumpVtbiCallback,
      required this.reloadPumpCallback,
      required this.selectPumpCallback,
      required this.addPumpCallback});

  @override
  MainPageState createState() {
    return (database[currentlyActivePumpId] != null)
        ? MainPageState(
            database[currentlyActivePumpId]!.drugName,
            database[currentlyActivePumpId]!.currentRate,
            database[currentlyActivePumpId]!.currentVtbi)
        : MainPageState('', -1, -1);
  }
}

class MainPageState extends State<MainPage> {
  String currentlyActivePumpDrugName;
  double currentlyActivePumpRate;
  double currentlyActivePumpVtbi;
  double currentSystolicPressure = 0;
  double currentDiastolicPressure = 0;
  double currentMeanArterialPressure = 0;
  bool pageIsInactive = false;
  // OverlayEntry? numpadInput;

  MainPageState(this.currentlyActivePumpDrugName, this.currentlyActivePumpRate,
      this.currentlyActivePumpVtbi);

  @override
  void initState() {
    Timer.periodic(
        const Duration(seconds: 10), (Timer t) => suggestRateChange());
    initSocketConnections();
    super.initState();
  }

  void initSocketConnections() {
    for (Pump connectedPump in widget.database.values) {
      addSocketForPump(
          connectedPump); // TODO: add visual indicator in UI if socket is not connected (e.g., grayed-out tab)
    }
  }

  @override
  void dispose() {
    for (TcpSocketConnection socket in widget.socketsByPumpId.values) {
      socket.disconnect();
    }
    super.dispose();
  }

  void setPumpDripRate(double updatedRate) {
    // ! Probably make this into a function:
    TcpSocketConnection currActvPumpSocket =
        widget.socketsByPumpId[widget.currentlyActivePumpId]!;
    if (currActvPumpSocket.isConnected()) {
      // TODO: Move double to 0-1023 int conversion here?
      // TODO: Actually move double-analog out conversion to the arduino code, because the microcontroller needs to also have the actual dosage/VTBI value it received (so that it can store and broadcast that value)
      // int analogOut =
      //     min((((doseToSet + 28.122) / 12.802) * (1024 / 12)).round(), 1023);
      // print(analogOut);

      // Test inputs between 0 and 1023:
      // int analogOut = min(updatedRate.round(), 1023);
      // currActvPumpSocket.sendMessage(analogOut.toString());
      try {
        currActvPumpSocket.sendMessage('${updatedRate}r');
        setState(() => currentlyActivePumpRate = updatedRate);
        widget.database[widget.currentlyActivePumpId] = widget
            .database[widget.currentlyActivePumpId]!
            .changeRate(updatedRate);
        widget.setPumpDripRateCallback(
            widget.currentlyActivePumpId, updatedRate);
      } catch (e) {
        currActvPumpSocket.disconnect();
        print(
            'Connection to pump of patient ${widget.database[widget.currentlyActivePumpId]!.patientName} timed out.');
      }
    } else {
      print(
          'Pump of patient ${widget.database[widget.currentlyActivePumpId]!.patientName} is not currently connected.');
    }
    //
  }

  void setPumpVtbi(double updatedVtbi) {
    TcpSocketConnection currActvPumpSocket =
        widget.socketsByPumpId[widget.currentlyActivePumpId]!;
    if (currActvPumpSocket.isConnected()) {
      setState(() => currentlyActivePumpVtbi = updatedVtbi);
      currActvPumpSocket.sendMessage('${updatedVtbi}v');
      widget.database[widget.currentlyActivePumpId] = widget
          .database[widget.currentlyActivePumpId]!
          .changeVtbi(updatedVtbi);
      widget.setPumpVtbiCallback(widget.currentlyActivePumpId, updatedVtbi);
    } else {
      print(
          'Pump of patient ${widget.database[widget.currentlyActivePumpId]!.patientName} is not currently connected.');
    }
  }

  void selectPump(int selectedPumpId) {
    setState(() {
      currentlyActivePumpDrugName = widget.database[selectedPumpId]!.drugName;
      currentlyActivePumpRate = widget.database[selectedPumpId]!.currentRate;
      currentlyActivePumpVtbi = widget.database[selectedPumpId]!.currentVtbi;
      if (widget.bloodPressureStorage[selectedPumpId] == null) {
        currentSystolicPressure = 0;
        currentDiastolicPressure = 0;
        currentMeanArterialPressure = 0;
      } else {
        currentSystolicPressure =
            widget.bloodPressureStorage[selectedPumpId]![0];
        currentDiastolicPressure =
            widget.bloodPressureStorage[selectedPumpId]![1];
        currentMeanArterialPressure =
            widget.bloodPressureStorage[selectedPumpId]![2];
      }
    });
    widget.currentlyActivePumpId = selectedPumpId;
    widget.selectPumpCallback(selectedPumpId);
  }

  void addPump(Pump addedPump) {
    widget.database[addedPump.id] = addedPump;
    addSocketForPump(addedPump);
    // add pump callback
    widget.addPumpCallback(addedPump);
    selectPump(addedPump.id);
  }

  void addSocketForPump(Pump addedPump) async {
    TcpSocketConnection socketToAdd =
        TcpSocketConnection(addedPump.ipAddress, controllerPort);
    socketToAdd.enableConsolePrint(true);
    // TODO: modify/delete pump sync procedure in addpump.dart, since the pump's getting synced here anyways?
    if (await socketToAdd.canConnect(connectionTimeout)) {
      await socketToAdd.connect(connectionTimeout, recvPumpUpdate);
    }
    widget.socketsByPumpId[addedPump.id] = socketToAdd;
  }

  // void reloadPumpOnStartup(Pump targetPump) async {
  //   widget.database[targetPump.id] = targetPump;
  // }

  void recvPumpUpdate(String updateMessage) {
    switch (updateMessage[updateMessage.length - 1]) {
      case '}':
        // Reload/sync pump data between microcontroller and app
        List<String> parsedMessageData = updateMessage.split('#');
        Pump updatedPump = Pump.fromMap(jsonDecode(parsedMessageData[0]));
        print('Pump ${updatedPump.id} reload');
        updatedPump.patientName = widget.database[updatedPump.id]!.patientName;
        widget.database[updatedPump.id] = updatedPump;
        widget.bloodPressureStorage[updatedPump.id] = parsedMessageData[1]
            .substring(0, parsedMessageData[1].length - 1)
            .split(' ')
            .map((e) => double.parse(e))
            .toList();
        if (updatedPump.id == widget.currentlyActivePumpId) {
          setState(() {
            currentlyActivePumpDrugName =
                widget.database[updatedPump.id]!.drugName;
            currentlyActivePumpRate =
                widget.database[updatedPump.id]!.currentRate;
            currentlyActivePumpVtbi =
                widget.database[updatedPump.id]!.currentVtbi;
            currentSystolicPressure =
                widget.bloodPressureStorage[updatedPump.id]![0];
            currentDiastolicPressure =
                widget.bloodPressureStorage[updatedPump.id]![1];
            currentMeanArterialPressure =
                widget.bloodPressureStorage[updatedPump.id]![2];
          });
        }
        widget.reloadPumpCallback(updatedPump);
      case 'r':
        // Update rate for the target pump (the id of which is given in the updateMessage string)
        recvPumpValueUpdateBroadcast(updateMessage, 'r');
      case 'v':
        // Update vtbi for the target pump
        recvPumpValueUpdateBroadcast(updateMessage, 'v');
      default:
        throw StateError(
            'The app received an unexpected message from the microcontroller: $updateMessage');
    }
  }

  void recvPumpValueUpdateBroadcast(
      String updateMessage, String targetSetting) {
    List<String> parsedUpdateInfo = updateMessage.split(' ');
    int targetPumpId = int.parse(parsedUpdateInfo[0]);
    if (widget.database.containsKey(targetPumpId)) {
      widget.bloodPressureStorage[targetPumpId] =
          parsedUpdateInfo.sublist(2, 5).map((e) => double.parse(e)).toList();
      double updatedValue = double.parse(
          parsedUpdateInfo[1].substring(0, parsedUpdateInfo[1].length - 1));
      if (targetSetting == 'r') {
        print('Pump $targetPumpId rate update to $updatedValue');
        if (targetPumpId == widget.currentlyActivePumpId) {
          setState(() => currentlyActivePumpRate = updatedValue);
          setState(() {
            currentSystolicPressure =
                widget.bloodPressureStorage[targetPumpId]![0];
            currentDiastolicPressure =
                widget.bloodPressureStorage[targetPumpId]![1];
            currentMeanArterialPressure =
                widget.bloodPressureStorage[targetPumpId]![2];
          });
        }
        widget.database[targetPumpId] =
            widget.database[targetPumpId]!.changeRate(updatedValue);
        widget.setPumpDripRateCallback(targetPumpId, updatedValue);
      } else {
        print('Pump $targetPumpId VTBI update to $updatedValue');
        if (targetPumpId == widget.currentlyActivePumpId) {
          setState(() => currentlyActivePumpVtbi = updatedValue);
        }
        widget.database[targetPumpId] =
            widget.database[targetPumpId]!.changeVtbi(updatedValue);
        widget.setPumpVtbiCallback(targetPumpId, updatedValue);
      }
    }
  }

  void suggestRateChange() {
    if (currentMeanArterialPressure > 0) {
      if (currentMeanArterialPressure < 65) {
        print(currentlyActivePumpRate + 2);
      } else {
        print(0);
      }
    }
  }

  // void onNumpadOpen(TitrationSettingField openedNumpadInput) {
  //   // setState(() => numpadIsOpen = true);
  //   numpadInput = OverlayEntry(builder: (context) {
  //     return openedNumpadInput;
  //   });
  //   Overlay.of(context).insert(numpadInput!);
  // }

  @override
  Widget build(BuildContext context) {
    TitrationSettingField setDripRateField = TitrationSettingField(
        settingName: 'RATE',
        onNumpadOpen: () => pageIsInactive = true,
        onNumpadClose: () => pageIsInactive = false,
        onValueSubmitCallback: setPumpDripRate,
        value: currentlyActivePumpRate);
    TitrationSettingField setVtbiField = TitrationSettingField(
        settingName: 'VTBI',
        onNumpadOpen: () => pageIsInactive = true,
        onNumpadClose: () => pageIsInactive = false,
        onValueSubmitCallback: setPumpVtbi,
        value: currentlyActivePumpVtbi);
    List<Widget> allChildWidgets = [
      // const SizedBox(height: 40),
      PumpNavBar(
          pumpListOnStartup: widget.database.values.toList(),
          currentlyActivePumpIdOnStartup: widget.currentlyActivePumpId,
          selectPumpCallback: selectPump,
          addPumpCallback: addPump),
      const SizedBox(height: minMarginBelowNavBar),
    ];

    if (currentlyActivePumpDrugName.isEmpty) {
      allChildWidgets.add(const NoPumpsAddedMainPage());
    } else {
      allChildWidgets.addAll([
        Row(children: [
          Text(currentlyActivePumpDrugName.toUpperCase(),
              style: headingTextStyle),
          const Expanded(child: SizedBox()),
          CtaButton(onPressed: () {}, buttonText: 'Log'),
          const SizedBox(width: minMarginBtwnAdjElems),
          CtaButton(onPressed: () => suggestRateChange(), buttonText: 'Suggest')
        ]),
        const SizedBox(height: minMarginBtwnAdjElems),
        setDripRateField,
        const SizedBox(height: minMarginBtwnAdjElems),
        setVtbiField,
        // Text('${currentSystolicPressure.round()}'),
        // Text('${currentDiastolicPressure.round()}'),
        // Text('${currentMeanArterialPressure.round()}'),
        const SizedBox(height: minMarginBelowFields),
        Row(children: [
          const Text('BLOOD PRESSURE', style: headingTextStyle),
          const Expanded(child: SizedBox()),
          CtaButton(onPressed: () {}, buttonText: 'Log'),
        ]),
        const SizedBox(height: minMarginBtwnAdjElems),
        Row(
          children: [
            BloodPressureInfoWidget(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('MAP', style: bodyTextStyle),
                        Text('${currentMeanArterialPressure.round()}',
                            style: headingTextStyle)
                      ],
                    ))),
            const SizedBox(width: minMarginBtwnAdjElems),
            BloodPressureInfoWidget(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('SYS', style: bodyTextStyle),
                Text('${currentSystolicPressure.round()}',
                    style: headingTextStyle)
              ]),
              const SizedBox(height: minMarginBtwnAdjElems),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                const Text('DIA', style: bodyTextStyle),
                Text('${currentDiastolicPressure.round()}',
                    style: headingTextStyle)
              ]),
              Expanded(child: Image.asset('assets/output-onlinegiftools.gif'))
            ])),
          ],
        )
      ]);
    }

    Widget base = Container(
        margin: const EdgeInsets.fromLTRB(
            screenLeftRightMargin, screenTopMargin, screenLeftRightMargin, 0),
        child: Column(
          children: allChildWidgets,
        ));
    // if (numpadIsOpen) {
    //   onNumpadOpen(setDripRateField);
    // }
    return base;

    // return (numpadIsOpen
    //     ? Stack(children: [base, Container(color: Colors.white70)])
    //     : base);
  }
}

// class TitrationSettingField extends StatefulWidget {
//   final String settingName;
//   final double value;
//   final Function(TitrationSettingField) onNumpadOpen;
//   final Function() onNumpadClose;
//   final void Function(double) onValueSubmitCallback;

//   const TitrationSettingField(
//       {super.key,
//       required this.settingName,
//       required this.value,
//       required this.onNumpadOpen,
//       required this.onNumpadClose,
//       required this.onValueSubmitCallback});

//   @override
//   TitrationSettingFieldState createState() => TitrationSettingFieldState();
// }

// class TitrationSettingFieldState extends State<TitrationSettingField> {
//   bool numpadIsOpen = false;

//   TitrationSettingFieldState();

//   void openNumpad() {
//     setState(() => numpadIsOpen = true);
//     widget.onNumpadOpen(widget);
//   }

//   void closeNumpad() {
//     setState(() => numpadIsOpen = false);
//     widget.onNumpadClose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return numpadIsOpen
//         ? (Container(
//             height: 500,
//             child: CustomNumberInput(senderCallback: (value) {
//               closeNumpad();
//               widget.onValueSubmitCallback(value.toDouble());
//             })))
//         : Container(
//             height: 100,
//             child: GestureDetector(
//                 onTap: openNumpad,
//                 child: Text('${widget.settingName}: ${widget.value}')));
//   }
// }
class CtaButton extends StatelessWidget {
  final void Function() onPressed;
  final String buttonText;

  const CtaButton(
      {super.key, required this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ctaButtonStyle, onPressed: onPressed, child: Text(buttonText));
  }
}

class TitrationSettingField extends StatelessWidget {
  final String settingName;
  final double value;
  final Function() onNumpadOpen;
  final Function() onNumpadClose;
  final void Function(double) onValueSubmitCallback;

  const TitrationSettingField(
      {super.key,
      required this.settingName,
      required this.value,
      required this.onNumpadOpen,
      required this.onNumpadClose,
      required this.onValueSubmitCallback});

  void openNumpadInput(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CustomNumberInput(senderCallback: (double value) {
              onValueSubmitCallback(value);
              Navigator.pop(context);
            })));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: numberInputMinSizeOnPhone,
        child: GestureDetector(
            onTap: () => openNumpadInput(context),
            child: Container(
                padding: const EdgeInsets.all(minOverlayHorizontalPadding),
                height:
                    numberInputMinSizeOnPhone, // Text('$settingName: $value')
                decoration: const BoxDecoration(
                    color: themeOverlay,
                    borderRadius: BorderRadius.all(
                        Radius.circular(fieldCornerRadiusOnPhone))),
                child: Center(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.ideographic,
                        children: [
                      Text(settingName, style: bodyTextStyle),
                      const Expanded(child: SizedBox()),
                      Text('$value', style: displayTextStyle),
                      const SizedBox(width: minMarginBtwnAdjElems),
                      Text((settingName == 'RATE') ? 'mL/hr' : 'mL',
                          style: bodyTextStyle)
                    ])))));
    // return Container(
    //     height: 100,
    //     child: GestureDetector(
    //         onTap: onNumpadOpen, child: Text('$settingName: $value')));
  }
}

class BloodPressureInfoWidget extends StatefulWidget {
  final Widget child;

  const BloodPressureInfoWidget({super.key, required this.child});

  @override
  BloodPressureInfoWidgetState createState() => BloodPressureInfoWidgetState();
}

class BloodPressureInfoWidgetState extends State<BloodPressureInfoWidget> {
  bool isExpanded = false;

  BloodPressureInfoWidgetState();

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: numberInputMinSizeOnPhone,
            padding: const EdgeInsets.all(minOverlayHorizontalPadding),
            decoration: const BoxDecoration(
                color: themeOverlay,
                borderRadius: BorderRadius.all(
                    Radius.circular(fieldCornerRadiusOnPhone))),
            child: widget.child));
  }
}

class NoPumpsAddedMainPage extends StatelessWidget {
  const NoPumpsAddedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Click the + button to add a pump to monitor!');
  }
}
