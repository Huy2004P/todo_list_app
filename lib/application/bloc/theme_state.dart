import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final double textScaleFactor;

  const ThemeState(this.themeMode, {this.textScaleFactor = 1.0});
}
