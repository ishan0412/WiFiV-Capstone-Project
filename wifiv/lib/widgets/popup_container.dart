import 'dart:ui';
import '../constants/constants.dart';
import 'package:flutter/material.dart';

class PopupContainer extends StatelessWidget {
  final Widget child;

  const PopupContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(182, 39, 44, 59),
        body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
                padding: const EdgeInsets.fromLTRB(
                    screenLeftRightMargin, 0, screenLeftRightMargin, 0),
                alignment: Alignment.center,
                child: IntrinsicHeight(
                    child: IntrinsicWidth(
                        child: Container(
                  // margin: const EdgeInsets.fromLTRB(screenLeftRightMargin,
                  //     screenTopMargin, screenLeftRightMargin, 0),
                  padding: const EdgeInsets.all(minOverlayHorizontalPadding),
                  decoration: const BoxDecoration(
                      color: themeOverlay,
                      borderRadius: BorderRadius.all(
                          Radius.circular(fieldCornerRadiusOnPhone))),
                  child: child,
                ))))));
  }
}
