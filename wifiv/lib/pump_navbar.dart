import 'package:flutter/material.dart';
import 'data/data_model.dart';
import 'widgets/addpump.dart';

class PumpNavBar extends StatefulWidget {
  final List<Pump> pumpListOnStartup;
  final int currentlyActivePumpIdOnStartup;
  final void Function(int) selectPumpCallback;
  final void Function(Pump) addPumpCallback;

  PumpNavBar(
      {super.key,
      required this.pumpListOnStartup,
      required this.currentlyActivePumpIdOnStartup,
      required this.selectPumpCallback,
      required this.addPumpCallback});

  @override
  PumpNavBarState createState() =>
      PumpNavBarState(pumpListOnStartup, currentlyActivePumpIdOnStartup);
}

class PumpNavBarState extends State<PumpNavBar> {
  List<Pump> pumpList;
  int currentlyActivePumpId;

  PumpNavBarState(this.pumpList, this.currentlyActivePumpId);

  void addPump(Pump addedPump) {
    setState(() {
      pumpList.add(addedPump);
      currentlyActivePumpId = addedPump.id;
    });
    widget.addPumpCallback(addedPump);
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          height: 50,
          width: 300,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (Pump e in pumpList)
              PumpSelectTab(
                  thisPump: e,
                  isActivePump: e.id == currentlyActivePumpId,
                  onPumpSelectCallback: (id) {
                    setState(() => currentlyActivePumpId = id);
                    widget.selectPumpCallback(id);
                  },
                  onPumpRemoveCallback: (pump) {})
          ])),
      TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddPumpWidget(addPumpCallback: addPump))),
          child: const Text('+'))
    ]);
  }
}

class PumpSelectTab extends StatelessWidget {
  final Pump thisPump;
  final bool isActivePump;
  final ValueSetter<int> onPumpSelectCallback;
  final ValueSetter<Pump> onPumpRemoveCallback;

  const PumpSelectTab(
      {super.key,
      required this.thisPump,
      required this.isActivePump,
      required this.onPumpSelectCallback,
      required this.onPumpRemoveCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 20,
        child: TextButton(
            onPressed: () => onPumpSelectCallback(thisPump.id),
            child: Text('${thisPump.patientName} $isActivePump')));
  }
}
