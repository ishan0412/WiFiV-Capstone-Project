import 'package:flutter/material.dart';
import 'data/data_model.dart';
import 'widgets/addpump.dart';
import 'constants/constants.dart';

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
    // TODO: MediaQuery.sizeOf() for size-responsive UI
    List<Widget> base = [];
    for (Pump e in pumpList) {
      base.add(PumpSelectTab(
          thisPump: e,
          isActivePump: e.id == currentlyActivePumpId,
          onPumpSelectCallback: (id) {
            setState(() => currentlyActivePumpId = id);
            widget.selectPumpCallback(id);
          },
          onPumpRemoveCallback: (pump) {}));
      base.add(const SizedBox(width: minMarginBtwnAdjElems));
    }
    base.add(SizedBox(width: buttonHeightOnPhone, child: TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddPumpWidget(addPumpCallback: addPump))),
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(themeGreen),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            textStyle: MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold, fontSize: buttonHeightOnPhone - 2 * minButtonPadding)),
            shape: MaterialStatePropertyAll(CircleBorder()),
            fixedSize: MaterialStatePropertyAll(
                    Size(buttonHeightOnPhone, buttonHeightOnPhone))),
        child: Center(child: Text('+')))));
    return Row(children: base);
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
    return FittedBox(
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(themeGray),
                textStyle: const MaterialStatePropertyAll(buttonTextStyle),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
                // TODO: change this and actually set min, max, and fixed sizes correctly
                minimumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                fixedSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                maximumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        buttonHeightOnPhone * buttonCornerRadiusScale)))),
            onPressed: () => onPumpSelectCallback(thisPump.id),
            child: Center(child: Text(thisPump.patientName))));
  }
}
