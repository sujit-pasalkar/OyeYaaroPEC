import 'package:flutter/material.dart';

class Themes {

  static ThemeData kIOSTheme = new ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light,
    // canvasColor: Colors.transparent
  );

  static ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.blue[400],
    // canvasColor: Colors.transparent
  );
}