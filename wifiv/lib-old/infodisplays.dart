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
  final int activePumpIdOnStartup;
  // Pass the following to navbar child widget:
  // final DataService database;
  // final KeyValueService keyValueStore;
  // inal List<Pump> pumpListOnStartup; // ! make this an id-Pump map
  // Pass to numpad input child widget:
  // final ValueSetter<int> onSubmitValueCallback;
  // final Map<int, Pump> databaseOnStartup;
  final Map<int, Pump> databaseOnStartup;
  final ValueSetter<int> onPumpSelectCallback;
  final ValueSetter<Pump> onPumpAddCallback;
  final ValueSetter<int> onPumpRemoveCallback;

  const ActivePumpInfo(
      {super.key,
      required this.activePumpIdOnStartup,
      required this.databaseOnStartup,
      required this.onPumpSelectCallback,
      required this.onPumpAddCallback,
      required this.onPumpRemoveCallback});

  @override
  State<StatefulWidget> createState() =>
      ActivePumpInfoState(activePumpIdOnStartup, databaseOnStartup);
}

class ActivePumpInfoState extends State<ActivePumpInfo> {
  int currentlyActivePumpId;
  Map<int, Pump> database;
  bool settingInputIsOpen = false;

  ActivePumpInfoState(this.currentlyActivePumpId, this.database);

  void selectPump(int selectedPumpId) {
    setState(() => currentlyActivePumpId =
        selectedPumpId); // prob doesn't need to be in a setState wrapper
    widget.onPumpSelectCallback(selectedPumpId);
  }

  void addPump(Pump pumpToAdd) {
    database[pumpToAdd.id] = pumpToAdd;
    widget.onPumpAddCallback(pumpToAdd);
  }

  void removePump(int pumpIdToRemove) {
    database.remove(pumpIdToRemove);
    if (currentlyActivePumpId == pumpIdToRemove) {
      selectPump(pumpIdToRemove - ((pumpIdToRemove == database.length) as int));
    }
    widget.onPumpRemoveCallback(pumpIdToRemove);
  }

  @override
  Widget build(BuildContext context) {
    Pump currentlyActivePump = database[currentlyActivePumpId]!;
    print(currentlyActivePump);
    return Scaffold(
        body: Container(
            child: Column(children: [
      PumpNavBar(
          activePumpIdOnStartup: widget.activePumpIdOnStartup,
          allPumpsListOnStartup: widget.databaseOnStartup.values.toList(),
          onPumpSelectCallback: selectPump,
          onPumpAddCallback: addPump,
          onPumpRemoveCallback: removePump),
      Text('DRUG: ${currentlyActivePump.drugName}'),
      ClickablePumpSettingInput(
          inputName: 'RATE',
          valueOnStartup: currentlyActivePump.currentRate,
          onOpenInputCallback: () => setState(() => settingInputIsOpen = true),
          onCloseInputCallback: () {}),
      Text('VTBI: ${currentlyActivePump.currentVtbi}'),
      Text('input\'s supposed to be open: $settingInputIsOpen')
    ])));
  }
}

class ClickablePumpSettingInput extends StatefulWidget {
  final String inputName;
  final double valueOnStartup;
  final VoidCallback onOpenInputCallback;
  final VoidCallback onCloseInputCallback;

  const ClickablePumpSettingInput(
      {super.key,
      required this.inputName,
      required this.valueOnStartup,
      required this.onOpenInputCallback,
      required this.onCloseInputCallback});

  @override
  State<StatefulWidget> createState() =>
      ClickablePumpSettingInputState(valueOnStartup);
}

class ClickablePumpSettingInputState extends State<ClickablePumpSettingInput> {
  bool isOpen = false;
  double value;

  ClickablePumpSettingInputState(this.value);

  @override
  Widget build(BuildContext context) {
    if (isOpen) {
      return const Text('Mettu');
    } else {
      return Container(
          height: 200,
          child: GestureDetector(
              onTap: () {
                widget.onOpenInputCallback();
                setState(() => isOpen = true);
              },
              child: Text('${widget.inputName}: $value')));
    }
  }
}
