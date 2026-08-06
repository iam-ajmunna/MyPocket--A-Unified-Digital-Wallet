import 'package:flutter/material.dart';

class AppElevation {
  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
