import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale? _locale;

  Locale? get locale => _locale;

  LanguageService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    // If null, use system locale
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return languageCode;
    }
  }

  List<Locale> get supportedLocales => const [
    Locale('de'),
    Locale('en'),
  ];
}