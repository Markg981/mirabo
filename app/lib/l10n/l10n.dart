import 'package:flutter/material.dart';

import '../theme.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// L'area dei grandi resta nella lingua del tablet, anche se il bambino
/// usa l'app in un'altra lingua, e non eredita il profilo di interazione del
/// bambino (bottoni enormi, testo nascosto).
class AdultLocale extends StatelessWidget {
  const AdultLocale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
        data: adultTheme(Theme.of(context)),
        child: Localizations.override(context: context, locale: AppLanguage.ofDevice().locale, child: child),
      );
}

/// Pagina per i grandi, nella lingua del tablet.
Route<T> adultRoute<T>(WidgetBuilder builder) =>
    MaterialPageRoute<T>(builder: (context) => AdultLocale(child: Builder(builder: builder)));

/// Lingue dell'app. L'italiano è la lingua originale dei contenuti; le altre
/// arrivano dai file in i18n/<lingua>/ dei pacchetti.
enum AppLanguage {
  it('Italiano', 'it-IT'),
  en('English', 'en-GB'),
  es('Español', 'es-ES'),
  fr('Français', 'fr-FR'),
  de('Deutsch', 'de-DE');

  const AppLanguage(this.nativeName, this.ttsCode);

  /// Il nome nella lingua stessa: chi non parla italiano la riconosce.
  final String nativeName;

  /// Voce del sintetizzatore per questa lingua.
  final String ttsCode;

  String get code => name;
  Locale get locale => Locale(name);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.name == code, orElse: () => AppLanguage.it);

  /// La lingua del dispositivo, se l'app la supporta; altrimenti italiano.
  static AppLanguage ofDevice() =>
      fromCode(WidgetsBinding.instance.platformDispatcher.locale.languageCode);
}
