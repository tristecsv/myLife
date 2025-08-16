import 'package:flutter/material.dart';

class ColorConstants {
  static const Color green = Color(0xFF2ECC71);
  static const Color blue = Color(0xFF3B82F6);
  static const Color red = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);

  static const List<Color> colorOptions = [
    green,
    blue,
    red,
    purple,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
  ];

  // Hive box + keys
  static const String settingsBox = 'settings_box';
  static const String keyIsDark = 'is_dark';
  static const String keyPrimaryColor = 'primary_color';
}
