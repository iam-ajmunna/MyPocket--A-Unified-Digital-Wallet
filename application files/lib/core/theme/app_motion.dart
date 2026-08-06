import 'package:flutter/material.dart';

class AppMotion {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration screen = Duration(milliseconds: 350);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.fastOutSlowIn;
}
