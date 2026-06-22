import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends InheritedNotifier<AppStateController> {
  const AppController({
    super.key,
    required AppStateController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppStateController of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppController>();

    assert(
      result != null,
      'AppController not found in context',
    );

    return result!.notifier!;
  }
}

class AppStateController extends ChangeNotifier {
  static const String _languageStorageKey = 'app_language';

  ThemeMode _themeMode = ThemeMode.light;

  /*
    العربية هي اللغة الافتراضية لأول تشغيل.
  */
  Locale _locale = const Locale('ar');

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isArabic => _locale.languageCode == 'ar';

  void toggleTheme(bool value) {
    _themeMode = value
        ? ThemeMode.dark
        : ThemeMode.light;

    notifyListeners();
  }

  /*
    قراءة اللغة المحفوظة من التخزين المحلي.

    إذا لم تكن هناك لغة محفوظة، سيتم استخدام العربية.
  */
  Future<void> loadSavedLanguage() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedLanguage =
          preferences.getString(_languageStorageKey);

      debugPrint(
        '🌐 SAVED LANGUAGE: $savedLanguage',
      );

      if (savedLanguage == 'en') {
        _locale = const Locale('en');
      } else {
        /*
          يشمل:
          - savedLanguage == ar
          - savedLanguage == null
          - أي قيمة غير صالحة
        */
        _locale = const Locale('ar');
      }

      debugPrint(
        '✅ ACTIVE LANGUAGE: ${_locale.languageCode}',
      );
    } catch (error, stackTrace) {
      /*
        في حالة حدوث خطأ نستخدم العربية.
      */
      _locale = const Locale('ar');

      debugPrint(
        '❌ LOAD LANGUAGE ERROR: $error',
      );

      debugPrint(
        '❌ LOAD LANGUAGE STACK: $stackTrace',
      );
    }
  }

  /*
    التبديل بين العربية والإنجليزية
    ثم حفظ الاختيار على الجهاز.
  */
  Future<void> toggleLanguage() async {
    final newLocale = isArabic
        ? const Locale('en')
        : const Locale('ar');

    await setLocale(newLocale);
  }

  /*
    تعيين لغة محددة وحفظها.
  */
  Future<void> setLocale(Locale locale) async {
    final languageCode =
        locale.languageCode.toLowerCase();

    /*
      نسمح فقط بالعربية والإنجليزية.
    */
    final safeLanguageCode =
        languageCode == 'en' ? 'en' : 'ar';

    _locale = Locale(safeLanguageCode);

    /*
      نعيد بناء التطبيق مباشرة.
    */
    notifyListeners();

    try {
      final preferences =
          await SharedPreferences.getInstance();

      final saved = await preferences.setString(
        _languageStorageKey,
        safeLanguageCode,
      );

      debugPrint(
        '💾 LANGUAGE SAVED: '
        '$safeLanguageCode, success: $saved',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ SAVE LANGUAGE ERROR: $error',
      );

      debugPrint(
        '❌ SAVE LANGUAGE STACK: $stackTrace',
      );
    }
  }

  /*
    اختيار العربية مباشرة.
  */
  Future<void> setArabic() async {
    await setLocale(
      const Locale('ar'),
    );
  }

  /*
    اختيار الإنجليزية مباشرة.
  */
  Future<void> setEnglish() async {
    await setLocale(
      const Locale('en'),
    );
  }
}