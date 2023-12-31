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
  OverlayEntry? overlayEntry;

  PumpNavBarState(this.pumpList, this.currentlyActivePumpId);

  void addPump(Pump addedPump) {
    setState(() {
      pumpList.add(addedPump);
      currentlyActivePumpId = addedPump.id;
    });
    widget.addPumpCallback(addedPump);
  }

  void openAddPumpWidget(BuildContext context) {
    OverlayState? overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            child: AddPumpWidget(
                addPumpCallback: addPump,
                currentlyConnectedPumpAddresses: {
                  for (Pump e in pumpList) e.ipAddress
                },
                onPumpSelectForConnection: () => overlayEntry!.remove(),
                // propsPassed: propsToPass,
                onClose: () => overlayEntry!.remove())));
    overlayState.insert(overlayEntry!);
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
    base.add(SizedBox(
        width: buttonHeightOnPhone,
        child: Container(
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: themeGreen),
            child: IconButton(
                onPressed: () => openAddPumpWidget(context),
                alignment: Alignment.center,
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(themeGreen),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    // textStyle: MaterialStatePropertyAll(TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: buttonHeightOnPhone - 2 * minButtonPadding)),
                    shape: MaterialStatePropertyAll(CircleBorder()),
                    fixedSize: MaterialStatePropertyAll(
                        Size(buttonHeightOnPhone, buttonHeightOnPhone))),
                color: themeGreen,
                icon: const Icon(Icons.add, color: Colors.white, size: 18)))));
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
                backgroundColor: MaterialStatePropertyAll(
                    isActivePump ? Colors.transparent : themeGray),
                textStyle: const MaterialStatePropertyAll(bodyTextStyle),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
                // TODO: change this and actually set min, max, and fixed sizes correctly
                minimumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                fixedSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                maximumSize: const MaterialStatePropertyAll(
                    Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    side: isActivePump
                        ? const BorderSide(
                            color: Colors.white, width: selectedTabBorderWidth)
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(
                        buttonHeightOnPhone * buttonCornerRadiusScale)))),
            onPressed: () => onPumpSelectCallback(thisPump.id),
            child: Center(child: Text((thisPump.patientName.length <= 9) ? thisPump.patientName : '${thisPump.patientName.substring(0, 6)}...'))));
  }
}
