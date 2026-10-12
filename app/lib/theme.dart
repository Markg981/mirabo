import 'package:flutter/material.dart';

import 'ui/design/palette.dart';

/// Tema: carta crema, inchiostro prugna, Nunito arrotondato, target touch grandi.
/// Con dyslexiaFont passa a Lexend con spaziatura e interlinea maggiori.
/// Con lowStimulation i colori si spengono e le transizioni spariscono.
ThemeData miraboTheme({required bool dyslexiaFont, required bool lowStimulation}) {
  final tokens = MiraboTokens(lowStimulation: lowStimulation);
  final primary = tokens.tint(MiraboColors.sky);
  final secondary = tokens.tint(MiraboColors.teal);

  final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light).copyWith(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: MiraboColors.pale(primary),
    onPrimaryContainer: MiraboColors.deep(primary, 0.3),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: MiraboColors.pale(secondary, 0.85),
    onSecondaryContainer: MiraboColors.deep(secondary, 0.25),
    surface: MiraboColors.paper,
    onSurface: MiraboColors.ink,
    onSurfaceVariant: MiraboColors.inkSoft,
    outline: const Color(0xFFB9CBDB),
    outlineVariant: MiraboColors.line,
    surfaceContainerHighest: const Color(0xFFEAF2F8),
    error: const Color(0xFFC6384C),
  );

  final family = dyslexiaFont ? 'Lexend' : 'Nunito';
  TextStyle t(double size, FontWeight w, {double? height}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: w,
        height: height ?? (dyslexiaFont ? 1.6 : 1.35),
        letterSpacing: dyslexiaFont ? 0.6 : 0.1,
        wordSpacing: dyslexiaFont ? 2.5 : 0,
        color: MiraboColors.ink,
      );
  // Titoli in Fredoka (geometrico e tondo); con l'alta leggibilità tutto in Lexend.
  TextStyle h(double size, FontWeight w, {double height = 1.15}) =>
      dyslexiaFont ? t(size, FontWeight.w700, height: height) : t(size, w, height: height).copyWith(fontFamily: 'Fredoka', letterSpacing: 0.2);
  final bold = dyslexiaFont ? FontWeight.w700 : FontWeight.w800;

  final textTheme = TextTheme(
    displaySmall: h(44, FontWeight.w700, height: 1.05),
    headlineMedium: h(36, FontWeight.w700, height: 1.1),
    headlineSmall: h(29, FontWeight.w600),
    titleLarge: h(25, FontWeight.w600, height: 1.2),
    titleMedium: t(20, FontWeight.w700, height: 1.3),
    titleSmall: t(17, FontWeight.w700),
    bodyLarge: t(22, FontWeight.w600),
    bodyMedium: t(18, FontWeight.w600),
    bodySmall: t(15, FontWeight.w600).copyWith(color: MiraboColors.inkSoft),
    labelLarge: t(18, bold, height: 1.2),
    labelMedium: t(15, FontWeight.w700, height: 1.2),
    labelSmall: t(13, FontWeight.w700, height: 1.2),
  );

  final radius16 = BorderRadius.circular(16);
  final radius20 = BorderRadius.circular(20);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: family,
    textTheme: textTheme,
    scaffoldBackgroundColor: lowStimulation ? const Color(0xFFF2F5F7) : MiraboColors.cream,
    extensions: [tokens],
    splashFactory: lowStimulation ? NoSplash.splashFactory : InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: MiraboColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 72,
      titleTextStyle: h(28, FontWeight.w600, height: 1.2),
    ),
    cardTheme: CardThemeData(
      color: MiraboColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: MiraboColors.line),
      ),
    ),
    dividerTheme: const DividerThemeData(color: MiraboColors.line, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(120, 60),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius20),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 20),
        disabledBackgroundColor: MiraboColors.disabled,
        disabledForegroundColor: MiraboColors.inkSoft,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(120, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: radius20),
        side: const BorderSide(color: Color(0xFFB9CBDB), width: 1.5),
        foregroundColor: MiraboColors.ink,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: radius16),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(56, 56), foregroundColor: MiraboColors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MiraboColors.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: textTheme.bodyMedium?.copyWith(color: MiraboColors.inkSoft),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w800),
      hintStyle: textTheme.bodyMedium?.copyWith(color: MiraboColors.inkSoft),
      helperStyle: textTheme.bodySmall,
      border: OutlineInputBorder(borderRadius: radius16, borderSide: const BorderSide(color: MiraboColors.line, width: 1.5)),
      enabledBorder:
          OutlineInputBorder(borderRadius: radius16, borderSide: const BorderSide(color: MiraboColors.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: primary, width: 2.5)),
      errorBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: scheme.error, width: 1.5)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(0, 56),
        textStyle: textTheme.labelLarge,
        backgroundColor: MiraboColors.paper,
        selectedBackgroundColor: MiraboColors.pale(primary, 0.78),
        selectedForegroundColor: MiraboColors.deep(primary, 0.3),
        side: const BorderSide(color: MiraboColors.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? secondary : null),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? secondary : null),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFFB9CBDB), width: 2),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: MiraboColors.inkSoft,
      shape: RoundedRectangleBorder(borderRadius: radius16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MiraboColors.paper,
      side: const BorderSide(color: MiraboColors.line, width: 1.5),
      shape: const StadiumBorder(),
      labelStyle: textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: secondary,
      inactiveTrackColor: MiraboColors.pale(secondary, 0.8),
      thumbColor: secondary,
      trackHeight: 8,
      valueIndicatorColor: MiraboColors.ink,
      valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(color: Colors.white),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: MiraboColors.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: h(28, FontWeight.w600, height: 1.2),
      contentTextStyle: textTheme.bodyMedium,
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelColor: MiraboColors.ink,
      unselectedLabelColor: MiraboColors.inkSoft,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(color: MiraboColors.paper, borderRadius: BorderRadius.circular(14)),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: MiraboColors.ink, borderRadius: BorderRadius.circular(10)),
      textStyle: textTheme.labelMedium?.copyWith(color: Colors.white),
    ),
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
