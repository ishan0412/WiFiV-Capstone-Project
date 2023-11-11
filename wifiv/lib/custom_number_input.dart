// import 'dart:io';
// import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

const double buttonSize =
    72; // ! eventually put button stylings in their own class and/or file
const double spacingBetweenButtons = 12;

class NumericButton extends StatelessWidget {
  const NumericButton({
    super.key,
    required this.number,
    required this.onNumericKeyPress,
  });

  final int number;
  final ValueSetter<int> onNumericKeyPress;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.all(spacingBetweenButtons),
        child: TextButton(
            onPressed: () => onNumericKeyPress(number),
            child: Text('$number')));
  }
}

class CustomNumPad extends StatelessWidget {
  const CustomNumPad(
      {super.key,
      required this.onNumericKeyPress,
      required this.onBackKeyPress,
      required this.onSubmitKeyPress,
      required this.onDecimalKeyPress});

  final ValueSetter<int> onNumericKeyPress;
  final VoidCallback onBackKeyPress;
  final VoidCallback onSubmitKeyPress;
  final VoidCallback onDecimalKeyPress;

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    List<TableRow> buttonsInPad = [
      for (int rowNumber = 1; rowNumber < 9; rowNumber += 3)
        TableRow(children: [
          for (int colNumber = 0; colNumber < 3; colNumber++)
            NumericButton(
                number: rowNumber + colNumber,
                onNumericKeyPress: onNumericKeyPress)
        ])
    ];
    buttonsInPad.add(TableRow(children: [
      Container(
          width: buttonSize,
          height: buttonSize,
          child:
              TextButton(onPressed: onBackKeyPress, child: const Text('Back'))),
      NumericButton(number: 0, onNumericKeyPress: onNumericKeyPress),
      Container(
          width: buttonSize,
          height: buttonSize,
          child:
              TextButton(onPressed: onDecimalKeyPress, child: const Text('.')))
    ]));

    return Column(children: [
      Table(
        defaultColumnWidth:
            const FixedColumnWidth(buttonSize + spacingBetweenButtons),
        children: buttonsInPad,
      ),
      // const SizedBox(height: spacingBetweenButtons),
      Container(
          width: 3 * buttonSize + 2 * spacingBetweenButtons,
          height: buttonSize,
          child: TextButton(
              onPressed: onSubmitKeyPress, child: const Text('Submit')))
    ]);
  }
}

/// TODO: Optimize this widget by assigning it to a final state variable, as
// the docs here describe: https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
///
class CustomNumberInput extends StatefulWidget {
  const CustomNumberInput({super.key, required this.senderCallback});

  final ValueSetter<int> senderCallback;

  @override
  State<CustomNumberInput> createState() => _CustomNumberInputState();
}

class _CustomNumberInputState extends State<CustomNumberInput> {
  final TextEditingController _controller = TextEditingController();

  void onNumericKeyPress(int number) {
    _controller.text += number.toString();
  }

  void onBackKeyPress() {
    if (_controller.text.isNotEmpty) {
      _controller.text =
          _controller.text.substring(0, _controller.text.length - 1);
    }
  }

  void onDecimalKeyPress() {
    if (!_controller.text.contains('.')) {
      _controller.text += '.';
    }
  }

  void onSubmitKeyPress() {
    // Actual dosage input:
    // // Conversion from mL/hr to mL/min:
    // double doseToSet = double.parse(_controller.text) / 60;
    // print(doseToSet);
    // // Translate mL/min dosage into a voltage for the microcontroller to output:
    // int analogOut =
    //     min((((doseToSet + 28.122) / 12.802) * (1024 / 12)).round(), 1023);
    // print(analogOut);

    // Test inputs between 0 and 1023:
    int analogOut = min(double.parse(_controller.text).round(), 1023);
    widget.senderCallback(analogOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 100, child: TextField(controller: _controller)),
      CustomNumPad(
          onNumericKeyPress: onNumericKeyPress,
          onBackKeyPress: onBackKeyPress,
          onSubmitKeyPress: onSubmitKeyPress,
          onDecimalKeyPress: onDecimalKeyPress)
    ]);
  }
}
