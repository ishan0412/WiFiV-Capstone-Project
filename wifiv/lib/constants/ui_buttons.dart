import 'package:flutter/material.dart';
import 'constants.dart'; // circular import?
// import 'ui_colors.dart';
// import 'ui_sizes.dart';

ButtonStyle ctaButtonStyle = ButtonStyle(
    // TODO: Make sizes adaptive!
    minimumSize: const MaterialStatePropertyAll(
        Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    fixedSize: const MaterialStatePropertyAll(
        Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    maximumSize: const MaterialStatePropertyAll(
        Size(minButtonWidthOnPhone, buttonHeightOnPhone)),
    backgroundColor: const MaterialStatePropertyAll(themeGreen),
    foregroundColor: const MaterialStatePropertyAll(Colors.white),
    textStyle: const MaterialStatePropertyAll(bodyTextStyle),
    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonCornerRadiusOnPhone))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(minButtonPadding)));

const double selectedTabBorderWidth = 1; // should be same thickness as bold font
