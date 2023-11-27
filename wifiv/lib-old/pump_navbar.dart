// import 'package:flutter/material.dart';
// import 'data_model.dart';
// import 'data_service.dart';
// import 'keyvalue_service.dart';

// // class PumpSelectTab extends StatelessWidget {
// //   final String patientName;
// //   final int pumpId;
// //   // final bool isCurrentlySelected;
// //   final ValueSetter<int> onPumpSelectCallback;

// //   const PumpSelectTab(
// //       {super.key,
// //       required this.patientName,
// //       required this.pumpId,
// //       required this.onPumpSelectCallback});

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //         height: 100,
// //         child: TextButton(
// //             onPressed: () => onPumpSelectCallback(pumpId),
// //             child: Text(patientName)));
// //   }
// // }

// class PumpSelectTab extends StatelessWidget {
//   final Pump thisPump;
//   final bool isActivePump;
//   final ValueSetter<int> onPumpSelectCallback;
//   final ValueSetter<Pump> onPumpRemoveCallback;

//   const PumpSelectTab(
//       {super.key,
//       required this.thisPump,
//       required this.isActivePump,
//       required this.onPumpSelectCallback,
//       required this.onPumpRemoveCallback});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 20,
//         child: TextButton(
//             onPressed: () => onPumpSelectCallback(thisPump.id),
//             child: Text('${thisPump.patientName} $isActivePump')));
//   }
// }

// class PumpNavBar extends StatefulWidget {
//   // final KeyValueService keyValueStore;
//   // final DataService database;
//   final int activePumpIdOnStartup;
//   final List<Pump> allPumpsListOnStartup;
//   final ValueSetter<int> onPumpSelectCallback;
//   final ValueSetter<Pump> onPumpAddCallback;
//   final ValueSetter<int> onPumpRemoveCallback;
//   // To pass to child widget:
//   // final double currentlyActivePumpRate;
//   // final double currentlyActivePumpVtbi;

//   const PumpNavBar(
//       {super.key,
//       // required this.keyValueStore,
//       // required this.database,
//       required this.activePumpIdOnStartup,
//       required this.allPumpsListOnStartup,
//       required this.onPumpSelectCallback,
//       required this.onPumpAddCallback,
//       required this.onPumpRemoveCallback});

//   @override
//   State<StatefulWidget> createState() =>
//       PumpNavBarState(activePumpIdOnStartup, allPumpsListOnStartup);
// }

// class PumpNavBarState extends State<PumpNavBar> {
//   int currentlyActivePumpId;
//   List<Pump> allPumpsList;

//   PumpNavBarState(this.currentlyActivePumpId, this.allPumpsList);

//   void selectPump(int selectedPumpId) {
//     setState(() => currentlyActivePumpId = selectedPumpId);
//     widget.onPumpSelectCallback(selectedPumpId);
//   }

//   void removePump(Pump pumpToRemove) {
//     int indexToRemove = allPumpsList.indexOf(pumpToRemove);
//     setState(() => allPumpsList.removeAt(indexToRemove));
//     if (currentlyActivePumpId == pumpToRemove.id) {
//       selectPump(
//           indexToRemove - ((indexToRemove == allPumpsList.length) as int));
//     }
//     widget.onPumpRemoveCallback(pumpToRemove.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(
//     //     body: ListView(
//     //   scrollDirection: Axis.horizontal,
//     //   children: [
//     //     for (Pump e in allPumpsList)
//     //       PumpSelectTab(
//     //         patientName: e.patientName,
//     //         pumpId: e.id,
//     //         onPumpSelectCallback: (value) => {
//     //           setState(
//     //             () => _setCurrentlyActivePumpId(value),
//     //           )
//     //         },
//     //       )
//     //   ],
//     // ));
//     // return const Text('Donald Pump');
//     return Container(
//         height: 100,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: [
//             for (Pump e in allPumpsList)
//               PumpSelectTab(
//                   thisPump: e,
//                   isActivePump: e.id == currentlyActivePumpId,
//                   onPumpSelectCallback: selectPump,
//                   onPumpRemoveCallback: (pump) => removePump(pump))
//           ],
//         ));
//   }
// }
