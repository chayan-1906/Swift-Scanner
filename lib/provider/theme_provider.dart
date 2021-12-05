import 'package:flutter/cupertino.dart';
import 'package:swift_scanner/models/theme_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemePreferences themePreferences = ThemePreferences();

  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool theme) {
    _darkTheme = theme;
    themePreferences.setDarkTheme(theme);
    print(_darkTheme);
    notifyListeners();
  }
}
