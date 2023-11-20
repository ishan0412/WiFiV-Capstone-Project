import 'package:flutter/material.dart';
import 'data_model.dart';
import 'data_service.dart';
import 'keyvalue_service.dart';
import 'pump_navbar.dart';
import 'custom_number_input.dart';

// class PumpInfo extends StatefulWidget {
//   // final double value;
//   final bool isRateInfo;
//   final ValueGetter<double> setValueCallback;

//   const PumpInfo(this.isRateInfo, {required this.setValueCallback, super.key});

//   State<PumpInfo> createState() => _PumpInfoState();
// }

// class _PumpInfoState extends State<PumpInfo> {
//   double _value = widget.setValueCallback;
// }

class ActivePumpInfo extends StatefulWidget {
  final Pump activePumpOnStartup;
  // Pass the following to navbar child widget:
  final DataService database;
  final KeyValueService keyValueStore;
  final List<Pump> pumpListOnStartup; // ! make this an id-Pump map
  // Pass to numpad input child widget:
  final ValueSetter<int> onSubmitValueCallback;

  const ActivePumpInfo(
      {super.key,
      required this.activePumpOnStartup,
      required this.database,
      required this.keyValueStore,
      required this.pumpListOnStartup,
      required this.onSubmitValueCallback});

  @override
  State<StatefulWidget> createState() =>
      _ActivePumpInfoState(activePumpOnStartup);
}

class _ActivePumpInfoState extends State<ActivePumpInfo> {
  Future<Pump>? currentlyActivePump;

  _ActivePumpInfoState(Pump activePumpOnStartup) {
    // print('ActivePumpInfo widget initialization');
    // if (widget.activePumpOnStartup != null) {
    //   currentlyActivePump = Future.value(widget.activePumpOnStartup);
    // }
    currentlyActivePump = Future.value(activePumpOnStartup);
  }

  Future<void> selectActivePump(Future<Pump> selectedPump) async {
    setState(() => currentlyActivePump = selectedPump);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currentlyActivePump,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
                body: Text(
                    'Mettu')); // temporary fade ("clouding" filter) on whole screen
          }
          Pump awaitedCurrActvPump = snapshot.data!;
          return Scaffold(
              body: Column(children: [
            const SizedBox(height: 50),
            PumpNavBar(
                keyValueStore: widget.keyValueStore,
                database: widget.database,
                currentlyActivePumpOnStartup: awaitedCurrActvPump,
                allPumpsListOnStartup: widget.pumpListOnStartup,
                onPumpSelectCallback: (pump) => selectActivePump),
            const SizedBox(height: 200),
            // Text('Drug: ${awaitedCurrActvPump.drugName}'),
            // Text('Current rate: ${awaitedCurrActvPump.currentRate}'),
            // Text('Current VTBI: ${awaitedCurrActvPump.currentVtbi}'),
            CustomNumberInput(senderCallback: widget.onSubmitValueCallback)
          ]));
        });
  }
}
