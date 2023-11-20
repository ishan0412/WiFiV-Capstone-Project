import 'package:flutter/material.dart';
import 'data_model.dart';
import 'custom_number_input.dart';

class HomePageLoading extends StatelessWidget {
  const HomePageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Loading...'));
  }
}

class HomePage extends StatelessWidget {
  final List<Pump> allPumpsInfo;
  final int currentlyActivePumpId;
  final ValueSetter<int> senderCallback;

  const HomePage(
      {super.key,
      required this.allPumpsInfo,
      required this.currentlyActivePumpId,
      required this.senderCallback});

  @override
  Widget build(BuildContext context) {
    // List<Widget> childWidgets = [
    //   for (Pump e in allPumpsInfo) Text(e.toString())
    // ];
    // childWidgets.add(Text('$currentlyActivePumpId'));
    // childWidgets.add(CustomNumberInput(senderCallback: senderCallback));
    // return Scaffold(body: Column(children: childWidgets));
    return Scaffold(
        body: Column(children: [
      Container(
          height: 100,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (Pump e in allPumpsInfo)
              TextButton(onPressed: () => {}, child: Text(e.patientName))
          ])),
      Text('$currentlyActivePumpId'),
      CustomNumberInput(senderCallback: senderCallback)
    ]));
  }
}
