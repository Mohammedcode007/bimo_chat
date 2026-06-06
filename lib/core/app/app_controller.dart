import 'package:flutter/material.dart';

class AppController extends InheritedNotifier<AppStateController> {
  const AppController({
    super.key,
    required AppStateController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppStateController of(BuildContext context) {
    final AppController? result = context
        .dependOnInheritedWidgetOfExactType<AppController>();

    assert(result != null, 'AppController not found in context');

    return result!.notifier!;
  }
}

class AppStateController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isArabic => _locale.languageCode == 'ar';

  void toggleTheme(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
