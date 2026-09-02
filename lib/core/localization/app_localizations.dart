import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('zh', 'TW'));
  }

  static const List<Locale> supportedLocales = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
    Locale('ja', 'JP'),
    Locale('zh', 'CN'),
  ];

  String translate(String key, {Map<String, String>? args}) {
    String langCode = locale.languageCode;
    String? countryCode = locale.countryCode;
    String fullKey = countryCode != null && countryCode.isNotEmpty
        ? '${langCode}_$countryCode'
        : langCode;

    Map<String, String>? langMap = Translations.values[fullKey] ??
        Translations.values[langCode] ??
        Translations.values['zh_TW'];

    String text = langMap?[key] ?? Translations.values['zh_TW']?[key] ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }

    return text;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, String>? args}) {
    return AppLocalizations.of(this).translate(key, args: args);
  }
}
