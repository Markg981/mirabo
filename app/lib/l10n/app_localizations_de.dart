// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mirabò';

  @override
  String get appTagline => 'Geschichten und kleine Schritte zum Großwerden.';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get finish => 'Ende';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get listenAgain => 'Nochmal hören';

  @override
  String get readAgain => 'Nochmal vorlesen';

  @override
  String get seeYouTomorrow => 'Bis morgen!';

  @override
  String get go => 'Los geht\'s!';

  @override
  String get home => 'Zuhause';

  @override
  String get parentArea => 'Elternbereich';

  @override
  String get modeTogether => 'Zusammen';

  @override
  String get modeAlone => 'Allein';

  @override
  String stepOf(Object current, Object total) {
    return 'Schritt $current von $total';
  }

  @override
  String homeHello(Object name) {
    return 'Hallo $name!';
  }

  @override
  String get homeQuestion => 'Was machen wir heute?';

  @override
  String get homeOneStory => 'Eine Geschichte';

  @override
  String get homeLetsPlay => 'Spielen';

  @override
  String switchChildA11y(Object name) {
    return 'Kind wechseln. Jetzt spielt $name';
  }

  @override
  String get chooseWhoPlays => 'Wer spielt heute?';

  @override
  String chooseWith(Object companion) {
    return 'mit $companion';
  }

  @override
  String get chooseAdd => 'Hinzufügen';

  @override
  String get chooseAddHint => 'für Erwachsene';

  @override
  String get chooseAddA11y => 'Ein Kind hinzufügen';

  @override
  String get catStories => 'Geschichten';

  @override
  String get catGames => 'Spiele';

  @override
  String get catEmpty => 'Heute gibt es hier nichts.';

  @override
  String get badgeAtHome => 'Zu Hause';

  @override
  String get badgeTogether => 'Zusammen';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(
      area,
      {
        'cognitivo': 'Vorbereitung',
        'autonomia': 'Selbstständigkeit',
        'sociale': 'In der Klasse',
        'paure': 'Erster Schultag',
        'vitaPratica': 'Praktisches Leben',
        'sensoriale': 'Sinne',
        'linguaggio': 'Sprache und Schreiben',
        'matematica': 'Mathematik',
        'cultura': 'Kultur',
        'other': '$area',
      },
    );
    return '$_temp0';
  }

  @override
  String worldShort(String world) {
    String _temp0 = intl.Intl.selectLogic(
      world,
      {
        'emozioni': 'Gefühle',
        'inclusione': 'Zusammen',
        'ambiente': 'Der Wald',
        'sicurezza': 'Mein Körper',
        'other': '$world',
      },
    );
    return '$_temp0';
  }

  @override
  String worldLong(String world) {
    String _temp0 = intl.Intl.selectLogic(
      world,
      {
        'emozioni': 'Gefühle und Konflikte',
        'inclusione': 'Vielfalt und Inklusion',
        'ambiente': 'Natur und Lebewesen',
        'sicurezza': 'Sicherheit und Körper',
        'other': '$world',
      },
    );
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'Der Satz zum Merken';

  @override
  String get activityTryAgain => 'Versuch\'s nochmal.';

  @override
  String get activityHelp => 'Schau genau hin. Ich helfe dir.';

  @override
  String get checklistPrompt => 'Was ist schon fertig?';

  @override
  String get checklistSay => 'Was ist für morgen schon fertig?';

  @override
  String get checklistAlone => 'allein';

  @override
  String get checklistAllDone => 'Alles fertig, gute Nacht';

  @override
  String get enoughForToday => 'Für heute reicht\'s';

  @override
  String get countdownPick => 'Datum wählen';

  @override
  String get countdownToday => 'Es ist heute!';

  @override
  String get countdownTodaySay => 'Heute ist der Tag!';

  @override
  String countdownDaysTo(int count, String event) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tage bis: $event',
      one: 'Noch 1 Tag bis: $event',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysSay(int count, String task) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tage. $task',
      one: 'Noch 1 Tag. $task',
    );
    return '$_temp0';
  }

  @override
  String exploreTap(Object scene) {
    return '$scene: tippen und entdecken';
  }

  @override
  String exploreSay(Object scene) {
    return 'Das ist $scene. Tippe und entdecke.';
  }

  @override
  String get exploreAllSeen => 'Ich habe alles gesehen!';

  @override
  String get exploreEnough => 'Für heute reicht\'s';

  @override
  String get patternPrompt => 'Was kommt als Nächstes?';

  @override
  String get presentationWhatYouNeed => 'Was du brauchst';

  @override
  String presentationWhatYouNeedSay(Object items) {
    return 'Was du brauchst: $items';
  }

  @override
  String get presentationReady => 'Alles bereit';

  @override
  String get presentationPrepare =>
      'Leg alles auf ein Tablett, bevor du das Kind rufst. Zeig die Schritte einmal, langsam und ohne zu sprechen; dann lass es selbst machen.';

  @override
  String presentationStep(Object current, Object total) {
    return 'Schritt $current von $total';
  }

  @override
  String get presentationWorkAlone => 'Jetzt allein';

  @override
  String presentationYourTurnSay(Object name) {
    return 'Jetzt bist du dran, $name. Wir legen das Tablet weg.';
  }

  @override
  String get presentationHowDidItGo => 'Für Erwachsene: Wie ist es gelaufen?';

  @override
  String get presentationControl => 'Fehlerkontrolle';

  @override
  String get presentationObserve => 'Worauf achten';

  @override
  String get presentationMarkLater =>
      'Trag es ein, wenn das Kind fertig ist, auch etwas später. Nicht korrigieren, während es arbeitet.';

  @override
  String get presentationWatched => 'Hat zugeschaut';

  @override
  String get presentationDid => 'Hat es gemacht';

  @override
  String get presentationAlone => 'Allein';

  @override
  String get presentationRepeat => 'Will es nochmal';

  @override
  String get forTheAdult => 'Für Erwachsene';

  @override
  String turnYou(Object name) {
    return 'Du bist dran, $name';
  }

  @override
  String get turnAdult => 'Die Großen sind dran';

  @override
  String spellSay(Object word) {
    return 'Lege: $word';
  }

  @override
  String get spellSentence => 'Lege den Satz';

  @override
  String get spellWord => 'Lege das Wort';

  @override
  String tracePrompt(Object label) {
    return 'Fahr das $label mit dem Finger nach';
  }

  @override
  String get traceRestart => 'Nochmal von vorn';

  @override
  String gameWellDone(Object name) {
    return 'Super, $name!';
  }

  @override
  String get gameNiceGame => 'Was für ein schönes Spiel.';

  @override
  String gameWellDoneSay(Object name) {
    return 'Super, $name! Was für ein schönes Spiel.';
  }

  @override
  String get gameAgain => 'Nochmal';

  @override
  String get gameEnough => 'Genug für jetzt';

  @override
  String get gameMemoryTitle => 'Tier-Memory';

  @override
  String gameMemoryDesc(int count) {
    return 'Finde die Paare: $count Paare.';
  }

  @override
  String get memoryIntro => 'Finde die Paare mit gleichen Tieren.';

  @override
  String get memoryCovered => 'Verdeckte Karte';

  @override
  String animalName(String animal) {
    String _temp0 = intl.Intl.selectLogic(
      animal,
      {
        'dog': 'der Hund',
        'cat': 'die Katze',
        'rabbit': 'das Kaninchen',
        'fox': 'der Fuchs',
        'bear': 'der Bär',
        'panda': 'der Panda',
        'frog': 'der Frosch',
        'monkey': 'der Affe',
        'lion': 'der Löwe',
        'tiger': 'der Tiger',
        'cow': 'die Kuh',
        'pig': 'das Schwein',
        'other': '$animal',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameBalloonsTitle => 'Die Luftballons';

  @override
  String get gameBalloonsDescSmall => 'Lass die Ballons platzen.';

  @override
  String get gameBalloonsDescMid =>
      'Lass nur die in der Farbe platzen, die der Begleiter sagt.';

  @override
  String get gameBalloonsDescBig =>
      'Lass die Zahlen der Reihe nach platzen, von 1 bis 10.';

  @override
  String get balloonsPopAll => 'Lass die Ballons platzen!';

  @override
  String balloonsPopColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'roten',
        'blue': 'blauen',
        'green': 'grünen',
        'yellow': 'gelben',
        'purple': 'lila',
        'other': '$color',
      },
    );
    return 'Lass nur die $_temp0 Ballons platzen.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'roten',
        'blue': 'blauen',
        'green': 'grünen',
        'yellow': 'gelben',
        'purple': 'lila',
        'other': '$color',
      },
    );
    return 'Jetzt die $_temp0 Ballons.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'roten',
        'blue': 'blauen',
        'green': 'grünen',
        'yellow': 'gelben',
        'purple': 'lila',
        'other': '$color',
      },
    );
    return 'Nur die $_temp0';
  }

  @override
  String get balloonsNumbersStart =>
      'Lass die Zahlen der Reihe nach platzen. Fang mit der Eins an.';

  @override
  String balloonsNow(Object n) {
    return 'Jetzt die $n.';
  }

  @override
  String balloonsFind(Object n) {
    return 'Finde die $n';
  }

  @override
  String balloonsWrongNumber(Object got, Object want) {
    return 'Das ist die $got. Such die $want.';
  }

  @override
  String get balloonsDone => 'Geschafft!';

  @override
  String balloonA11yNumber(Object n) {
    return 'Ballon $n';
  }

  @override
  String balloonA11yColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'Roter',
        'blue': 'Blauer',
        'green': 'Grüner',
        'yellow': 'Gelber',
        'purple': 'Lila',
        'other': '$color',
      },
    );
    return '$_temp0 Ballon';
  }

  @override
  String get gameShapesTitle => 'Jede Form an ihren Platz';

  @override
  String get gameShapesDescSmall => 'Drei Formen ins richtige Loch ziehen.';

  @override
  String get gameShapesDescMid => 'Fünf Formen ins richtige Loch ziehen.';

  @override
  String get gameShapesDescBig =>
      'Sechs Formen, groß und klein: Achte auf die Größe.';

  @override
  String get shapesIntro => 'Leg jede Form in ihr Loch.';

  @override
  String get shapesIntroBig =>
      'Leg jede Form in ihr Loch. Achte auf die Größe: groß und klein.';

  @override
  String shapesWrong(Object shape) {
    return 'Das ist $shape. Probier ein anderes Loch.';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(
      shape,
      {
        'circle': 'der Kreis',
        'square': 'das Quadrat',
        'triangle': 'das Dreieck',
        'star': 'der Stern',
        'heart': 'das Herz',
        'hexagon': 'das Sechseck',
        'circleSmall': 'der kleine Kreis',
        'squareSmall': 'das kleine Quadrat',
        'other': '$shape',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameDrawingTitle => 'Malen und Ausmalen';

  @override
  String get gameDrawingDesc => 'Ein weißes Blatt, Farben und Stempel.';

  @override
  String get drawingIntro => 'Such dir eine Farbe aus und mal mit dem Finger.';

  @override
  String get drawingSheet => 'Malblatt';

  @override
  String get drawingEraser => 'Radiergummi';

  @override
  String get drawingUndo => 'Rückgängig';

  @override
  String get drawingNewSheet => 'Neues Blatt';

  @override
  String get gameXyloTitle => 'Das Xylofon';

  @override
  String get gameXyloDescSmall => 'Frei spielen.';

  @override
  String gameXyloDescBig(Object song) {
    return 'Frei spielen oder „$song“ lernen.';
  }

  @override
  String get xyloNotes => 'C D E F G A H C';

  @override
  String get xyloSong => 'Bruder Jakob';

  @override
  String get xyloIntro => 'Tippe auf die Stäbe und spiel.';

  @override
  String xyloIntroSong(Object song) {
    return 'Spiel, was du willst, oder lern $song.';
  }

  @override
  String get xyloFree => 'Frei spielen';

  @override
  String get xyloFreeSay => 'Spiel, was du willst.';

  @override
  String get xyloSongSay => 'Spiel den Stab, der leuchtet.';

  @override
  String xyloNoteA11y(Object note) {
    return 'Ton $note';
  }

  @override
  String get gamePuzzleTitle => 'Das Schiebepuzzle';

  @override
  String get gamePuzzleDesc =>
      'Bring die Zahlen von 1 bis 8 wieder in Ordnung, indem du die Plättchen schiebst.';

  @override
  String get puzzleIntro =>
      'Schieb die Plättchen, bis sie in der richtigen Reihenfolge sind, von eins bis acht.';

  @override
  String puzzleTileA11y(Object n) {
    return 'Plättchen $n';
  }

  @override
  String get gateTitle => 'Bereich für Erwachsene';

  @override
  String gateQuestion(Object a, Object b) {
    return 'Wie viel ist $a × $b?';
  }

  @override
  String get gateWrong => 'Nochmal versuchen';

  @override
  String get gateEnter => 'Öffnen';

  @override
  String get parentTabSession => 'Sitzung';

  @override
  String get parentTabProfiles => 'Profile';

  @override
  String get parentTabCards => 'Darüber sprechen';

  @override
  String get parentTabDiary => 'Tagebuch';

  @override
  String get parentTabGrowth => 'Entwicklung';

  @override
  String get parentHowUse => 'Wie nutzt ihr die App gerade?';

  @override
  String get parentHowUseHint =>
      'Im Modus „zusammen“ erscheinen Gesprächspausen für euch beide. Im Modus „allein“ antwortet das Kind durch Tippen, und Geschichten über Sicherheit und Körper bleiben verborgen.';

  @override
  String get parentData => 'Wo die Daten liegen';

  @override
  String get parentDataHint =>
      'Nur auf diesem Gerät. Drive-Sicherung und Cloud-Konto kommen in späteren Versionen.';

  @override
  String get parentWipe => 'Alle Daten löschen';

  @override
  String get parentWipeConfirmTitle => 'Alles löschen?';

  @override
  String get parentWipeConfirm =>
      'Profile und Tagebuch werden von diesem Gerät gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get parentWipeYes => 'Löschen';

  @override
  String get parentNewProfile => 'Neues Profil';

  @override
  String parentProfileLine(String age, String companion, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geschichten',
      one: '1 Geschichte',
    );
    return '$age · Begleiter $companion · $_temp0';
  }

  @override
  String get diaryEmpty => 'Keine Geschichten in den letzten 30 Tagen.';

  @override
  String get diaryTogether => 'zusammen';

  @override
  String get diaryAlone => 'allein';

  @override
  String diaryChose(Object answer) {
    return 'in der Pause gewählt: „$answer“';
  }

  @override
  String growthTitle(Object name) {
    return 'Wie $name wächst';
  }

  @override
  String get growthIntro =>
      'Verglichen wird nur mit sich selbst, vor einem Monat. Die App sieht nur einen kleinen Teil des Tages: Bei Fragen zur Entwicklung sind Kinderarzt oder Lehrkraft die Ansprechpartner.';

  @override
  String get growthEmpty =>
      'Keine Aktivitäten in den letzten 30 Tagen. Sobald das Kind welche macht, siehst du hier die Etappen.';

  @override
  String get growthOffscreen =>
      'Wo es keinen Fortschritt gibt, probier die Aktivität ohne Bildschirm aus der Karte: nicht mehr Zeit in der App.';

  @override
  String growthNew(Object count) {
    return 'In den letzten 30 Tagen: $count Runden. Vor einem Monat hatte es das noch nicht ausprobiert.';
  }

  @override
  String growthCompare(Object before, Object now) {
    return 'Heute: $now · vor einem Monat: $before (grauer Rand).';
  }

  @override
  String stageLabel(String stage) {
    String _temp0 = intl.Intl.selectLogic(
      stage,
      {
        'starting': 'fängt an',
        'working': 'arbeitet daran',
        'canDo': 'schafft es',
        'alone': 'macht es allein',
        'other': '$stage',
      },
    );
    return '$_temp0';
  }

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(
      skill,
      {
        'suoni_iniziali': 'Laute und Buchstaben',
        'pregrafismo': 'Buchstaben nachspuren',
        'numeri': 'Zahlen und Mengen',
        'logica': 'Logik und Reihen',
        'routine_sera': 'Sachen für morgen vorbereiten',
        'routine_mattino': 'Die Morgenroutine',
        'vestirsi': 'Sich allein anziehen',
        'mensa': 'Beim Mittagessen',
        'turno_e_condivisione': 'Warten und Teilen',
        'chiedere_aiuto': 'Um Hilfe bitten',
        'distacco': 'Der Abschied am Morgen',
        'conoscere_la_scuola': 'Die Schule kennenlernen',
        'primo_giorno': 'Der erste Tag',
        'travasi': 'Umfüllen und Gießen',
        'motricita_fine': 'Feinmotorik',
        'cura_ambiente': 'Sorge für die Umgebung',
        'dimensioni': 'Größen und Reihenbildung',
        'colori': 'Farben',
        'forme': 'Formen',
        'tatto': 'Tasten',
        'udito': 'Hören',
        'scrittura': 'Schreiben',
        'vocabolario': 'Wortschatz',
        'decine': 'Zehner und Einer',
        'geografia': 'Geografie',
        'botanica': 'Botanik',
        'other': '$skill',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileWelcome => 'Willkommen bei Mirabò';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileNew => 'Neues Profil';

  @override
  String get profileChild => 'Das Kind';

  @override
  String get profileFirstRunHint =>
      'Diesen Teil füllt ein Erwachsener aus. Es dauert eine Minute, dann geht das Tablet an das Kind.';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameHint => 'So wird der Begleiter es nennen';

  @override
  String get profileAge => 'Alter';

  @override
  String profileYears(Object range) {
    return '$range Jahre';
  }

  @override
  String ageBandLabel(String band) {
    String _temp0 = intl.Intl.selectLogic(
      band,
      {
        'small': 'Die Kleinen',
        'mid': 'Erste Schritte',
        'big': 'Die Großen',
        'other': '$band',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get profileLanguageHint =>
      'Geschichten, Aktivitäten, Spiele und die Stimme des Begleiters sind in dieser Sprache.';

  @override
  String get profileCompanion => 'Der Begleiter';

  @override
  String get profileCompanionEditHint =>
      'Der Begleiter wird nur einmal gewählt: Er ist der beste Freund des Kindes.';

  @override
  String get profileCompanionNewHint =>
      'Lasst das Kind wählen. Er wird nur einmal gewählt und nicht gewechselt.';

  @override
  String get profileWorlds => 'Welten der Geschichten';

  @override
  String get profileWorldsHint =>
      'Wählt die Themen, die das Kind in seiner Bibliothek findet.';

  @override
  String get profileSafetyTogether => '„Mein Körper“ nur im Modus zusammen';

  @override
  String get profileSafetyTogetherHint =>
      'Empfohlen: Geschichten über Sicherheit und Körper liest man mit einem Erwachsenen.';

  @override
  String get profileAccess => 'Barrierefreiheit und Zeit';

  @override
  String get profileDyslexia => 'Leicht lesbarer Text';

  @override
  String get profileDyslexiaHint =>
      'Schrift Lexend, mehr Abstand zwischen Buchstaben und Zeilen.';

  @override
  String get profileLowStim => 'Wenig Reize';

  @override
  String get profileLowStimHint => 'Sanfte Farben, keine Animationen.';

  @override
  String get profileAloneSession => 'Sitzung „allein“';

  @override
  String profileMinutes(Object count) {
    return '$count Minuten';
  }

  @override
  String profileMinutesShort(Object count) {
    return '$count Min.';
  }

  @override
  String get profileDelete => 'Dieses Profil löschen';

  @override
  String get profileMissingName => 'Name fehlt';

  @override
  String get profileMissingCompanion => 'Begleiter fehlt';

  @override
  String get profileStart => 'Los geht\'s';

  @override
  String get translationDraft => 'Übersetzung wird geprüft';
}
