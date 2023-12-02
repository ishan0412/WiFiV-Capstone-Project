// import 'dart:io';
// import 'dart:ui';
import 'dart:math' show min;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
        width: numPadButtonSize,
        height: numPadButtonSize,
        margin: const EdgeInsets.all(minMarginBtwnAdjElems),
        child: TextButton(
            onPressed: () => onNumericKeyPress(number),
            child: Text('$number', style: bodyTextStyle)));
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
          width: numPadButtonSize,
          height: numPadButtonSize,
          child:
              TextButton(onPressed: onBackKeyPress, child: const Text('Back', style: bodyTextStyle))),
      NumericButton(number: 0, onNumericKeyPress: onNumericKeyPress),
      Container(
          width: numPadButtonSize,
          height: numPadButtonSize,
          child:
              TextButton(onPressed: onDecimalKeyPress, child: const Text('.', style: bodyTextStyle)))
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
          height: buttonHeightOnPhone,
          child: TextButton(style: ButtonStyle(
    // TODO: Make sizes adaptive!
    // minimumSize: const MaterialStatePropertyAll(
    //     Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    // fixedSize: const MaterialStatePropertyAll(
    //     Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    // maximumSize: const MaterialStatePropertyAll(
    //     Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    backgroundColor: const MaterialStatePropertyAll(themeGreen),
    foregroundColor: const MaterialStatePropertyAll(Colors.white),
    textStyle: const MaterialStatePropertyAll(bodyTextStyle),
    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonCornerRadiusOnPhone))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(minButtonPadding))),
              onPressed: onSubmitKeyPress, child: const Text('Submit')))
    ]);
  }
}

/// TODO: Optimize this widget by assigning it to a final state variable, as
// the docs here describe: https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
///
class CustomNumberInput extends StatefulWidget {
  const CustomNumberInput(
      {super.key, required this.senderCallback, required this.propsPassed, required this.closeNumInputCallback});

  final ValueSetter<double> senderCallback;
  final Map<String, dynamic> propsPassed;
  final void Function() closeNumInputCallback;

  @override
  State<CustomNumberInput> createState() => _CustomNumberInputState();
}

class _CustomNumberInputState extends State<CustomNumberInput> {
  final TextEditingController _controller = TextEditingController();
  bool numPadIsActive = false;

  void onNumericKeyPress(int number) {
    if (_controller.text.length < 6) {
      _controller.text += number.toString();
    }
  }

  void onBackKeyPress() {
    if (_controller.text.isNotEmpty) {
      _controller.text =
          _controller.text.substring(0, _controller.text.length - 1);
    }
  }

  void onDecimalKeyPress() {
    if ((!_controller.text.contains('.')) && (_controller.text.length < 6)) {
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
    // int analogOut = min(double.parse(_controller.text).round(), 1023);
    // print(analogOut);
    widget.senderCallback(double.parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Color.fromARGB(224, 39, 44, 59),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            // color: Color.fromARGB(224, 39, 44, 59),
            margin: const EdgeInsets.fromLTRB(screenLeftRightMargin,
                screenTopMargin, screenLeftRightMargin, 0),
            child: Column(children: [
              // SizedBox(height: 200),
              // Text(
              //     'Enter a ${(widget.propsPassed['settingName']! == 'RATE') ? 'rate' : 'VTBI'} to update ${widget.propsPassed['patientName']}\'s pump with.', style: bodyTextStyle),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                    'Enter a new ${(widget.propsPassed['settingName']! == 'RATE') ? 'rate' : 'VTBI'} value.',
                    style: bodyTextStyle),
                const SizedBox(height: minMarginBtwnAdjElems),
                TextButton(
                    style: grayButtonStyle,
                    onPressed: widget.closeNumInputCallback,
                    child: const Text('Close'))
              ]),
              const SizedBox(height: minMarginBtwnAdjElems),
              Container(
                  // height: 100,
                  decoration: const BoxDecoration(
                      color: themeOverlay,
                      borderRadius: BorderRadius.all(
                          Radius.circular(fieldCornerRadiusOnPhone))),
                  height: numberInputMinSizeOnPhone,
                  padding: const EdgeInsets.all(minOverlayHorizontalPadding),
                  // child: GestureDetector(
                  // onTap: () => setState(() => numPadIsActive = true),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 200,
                            child: TextField(
                                controller: _controller,
                                readOnly: true,
                                decoration: null,
                                style: displayTextStyle,
                                onTap: () =>
                                    setState(() => numPadIsActive = true))),
                        Text(
                            (widget.propsPassed['settingName']! == 'RATE')
                                ? 'mL/hr'
                                : 'mL',
                            style: bodyTextStyle)
                      ])),
              CustomNumPad(
                  onNumericKeyPress: onNumericKeyPress,
                  onBackKeyPress: onBackKeyPress,
                  onSubmitKeyPress: onSubmitKeyPress,
                  onDecimalKeyPress: onDecimalKeyPress)
            ]))));
  }
}
