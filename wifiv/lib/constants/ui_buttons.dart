import 'package:flutter/material.dart';
import 'constants.dart'; // circular import?
// import 'ui_colors.dart';
// import 'ui_sizes.dart';

ButtonStyle ctaButtonStyle = ButtonStyle(
    // TODO: Make sizes adaptive!
    minimumSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    fixedSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    maximumSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    backgroundColor: const MaterialStatePropertyAll(themeGreen),
    foregroundColor: const MaterialStatePropertyAll(Colors.white),
    textStyle: const MaterialStatePropertyAll(bodyTextStyle),
    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonCornerRadiusOnPhone))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(minButtonPadding)));

ButtonStyle grayButtonStyle = ButtonStyle(
    // TODO: Make sizes adaptive!
    minimumSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    fixedSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    maximumSize: const MaterialStatePropertyAll(
        Size(reducedButtonWidthOnPhone, buttonHeightOnPhone)),
    backgroundColor: const MaterialStatePropertyAll(themeGray),
    foregroundColor: const MaterialStatePropertyAll(Colors.white),
    textStyle: const MaterialStatePropertyAll(bodyTextStyle),
    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonCornerRadiusOnPhone))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(minButtonPadding)));

const double selectedTabBorderWidth = 1; // should be same thickness as bold font
