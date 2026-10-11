import 'package:flutter/material.dart';

/// Tema: colori caldi, target touch grandi, testo leggibile.
/// Con dyslexiaFont si userà un font ad alta leggibilità (da aggiungere agli asset:
/// Lexend o OpenDyslexic); finché non c'è, aumentiamo spaziatura e interlinea.
ThemeData miraboTheme({required bool dyslexiaFont, required bool lowStimulation}) {
  final seed = lowStimulation ? const Color(0xFF7A8B8B) : const Color(0xFFE8A04C);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  final body = TextStyle(
    fontSize: 22,
    height: dyslexiaFont ? 1.7 : 1.4,
    letterSpacing: dyslexiaFont ? 0.8 : 0.2,
    wordSpacing: dyslexiaFont ? 3 : 0,
    color: const Color(0xFF2B2622),
  );

  return base.copyWith(
    scaffoldBackgroundColor: lowStimulation ? const Color(0xFFF4F1EC) : const Color(0xFFFFF7EA),
    textTheme: base.textTheme.copyWith(
      bodyLarge: body,
      bodyMedium: body.copyWith(fontSize: 18),
      titleLarge: body.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: body.copyWith(fontSize: 34, fontWeight: FontWeight.w800),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(96, 64), textStyle: const TextStyle(fontSize: 20)),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(64, 64))),
    pageTransitionsTheme: lowStimulation
        ? const PageTransitionsTheme(builders: {
            TargetPlatform.android: _NoTransition(),
            TargetPlatform.iOS: _NoTransition(),
          })
        : null,
  );
}

class _NoTransition extends PageTransitionsBuilder {
  const _NoTransition();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      child;
}

/// Dimensione minima dei target touch per fascia: 64 px per i più piccoli.
double minTouch(bool youngest) => youngest ? 64 : 48;
