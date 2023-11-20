import 'package:flutter/material.dart';
import 'data_model.dart';
import 'data_service.dart';
import 'keyvalue_service.dart';

class PumpSelectTab extends StatelessWidget {
  final String patientName;
  final int pumpId;
  // final bool isCurrentlySelected;
  final ValueSetter<int> onPumpSelectCallback;

  const PumpSelectTab(
      {super.key,
      required this.patientName,
      required this.pumpId,
      required this.onPumpSelectCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: TextButton(
            onPressed: () => onPumpSelectCallback(pumpId),
            child: Text(patientName)));
  }
}

class PumpNavBar extends StatefulWidget {
  final KeyValueService keyValueStore;
  final DataService database;
  final Pump currentlyActivePumpOnStartup;
  final List<Pump> allPumpsListOnStartup;
  final ValueSetter<Pump> onPumpSelectCallback;
  // To pass to child widget:
  // final double currentlyActivePumpRate;
  // final double currentlyActivePumpVtbi;

  const PumpNavBar(
      {super.key,
      required this.keyValueStore,
      required this.database,
      required this.currentlyActivePumpOnStartup,
      required this.allPumpsListOnStartup,
      required this.onPumpSelectCallback});

  @override
  State<StatefulWidget> createState() =>
      _PumpNavBarState(currentlyActivePumpOnStartup, allPumpsListOnStartup);
}

class _PumpNavBarState extends State<PumpNavBar> {
  Future<Pump>? currentlyActivePump;
  Future<List<Pump>>? allPumpsList;

  _PumpNavBarState(Pump activePumpOnStartup, List<Pump> allPumpsListOnStartup) {
    currentlyActivePump = Future.value(activePumpOnStartup);
    allPumpsList = Future.value(allPumpsListOnStartup);
  }

  // void selectActivePump(Pump activePump) {
  //   widget.onPumpSelectCallback()
  // }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     body: ListView(
    //   scrollDirection: Axis.horizontal,
    //   children: [
    //     for (Pump e in allPumpsList)
    //       PumpSelectTab(
    //         patientName: e.patientName,
    //         pumpId: e.id,
    //         onPumpSelectCallback: (value) => {
    //           setState(
    //             () => _setCurrentlyActivePumpId(value),
    //           )
    //         },
    //       )
    //   ],
    // ));
    return const Text('Donald Pump');
  }
}
