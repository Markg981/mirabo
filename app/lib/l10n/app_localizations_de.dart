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
  String goodbyeTitle(Object name) {
    return 'Für heute ist Schluss, $name!';
  }

  @override
  String get goodbyeBody =>
      'Das war schön. Hol einen Erwachsenen: bis zum nächsten Mal!';

  @override
  String closingTitle(Object name) {
    return 'Gut gemacht, $name!';
  }

  @override
  String get closingBody =>
      'Du bist ein gutes Stück weitergekommen. Du kannst das Tablet jetzt weglegen: alles bleibt, wie es ist, und wartet auf dich.';

  @override
  String get closingBack => 'Zurück nach Hause';

  @override
  String get closingA11y => 'Ich bin fertig';

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
  String get catEmpty => 'Heute gibt es hier nichts.';

  @override
  String capacityLabel(String capacity) {
    String _temp0 = intl.Intl.selectLogic(capacity, {
      'insieme': 'Ich und die anderen',
      'mani': 'Die Hände',
      'sensi': 'Die Sinne',
      'parole': 'Die Wörter',
      'pensare': 'Zählen und denken',
      'mondo': 'Die Welt',
      'other': '$capacity',
    });
    return '$_temp0';
  }

  @override
  String get badgeAtHome => 'Zu Hause';

  @override
  String get badgeTogether => 'Zusammen';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(area, {
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
    });
    return '$_temp0';
  }

  @override
  String worldShort(String world) {
    String _temp0 = intl.Intl.selectLogic(world, {
      'emozioni': 'Gefühle',
      'inclusione': 'Zusammen',
      'ambiente': 'Der Wald',
      'sicurezza': 'Mein Körper',
      'other': '$world',
    });
    return '$_temp0';
  }

  @override
  String worldLong(String world) {
    String _temp0 = intl.Intl.selectLogic(world, {
      'emozioni': 'Gefühle und Konflikte',
      'inclusione': 'Vielfalt und Inklusion',
      'ambiente': 'Natur und Lebewesen',
      'sicurezza': 'Sicherheit und Körper',
      'other': '$world',
    });
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'Der Satz zum Merken';

  @override
  String get activityTryAgain => 'Versuch\'s nochmal.';

  @override
  String get activityHelp => 'Schau genau hin. Ich helfe dir.';

  @override
  String get activityHelpButton => 'Hilfe';

  @override
  String get activityHelpPoint =>
      'Schau das farbige an: Es könnte das sein. Probier du.';

  @override
  String get activityHelpDemo =>
      'Ich zeige es dir: Schau das leuchtende an und tippe es sanft an. Jetzt probierst du.';

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
    return 'Tippe und entdecke $scene';
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
    return 'Fahr mit dem Finger nach: $label';
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
    String _temp0 = intl.Intl.selectLogic(animal, {
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
    });
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
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'roten',
      'blue': 'blauen',
      'green': 'grünen',
      'yellow': 'gelben',
      'purple': 'lila',
      'other': '$color',
    });
    return 'Lass nur die $_temp0 Ballons platzen.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'roten',
      'blue': 'blauen',
      'green': 'grünen',
      'yellow': 'gelben',
      'purple': 'lila',
      'other': '$color',
    });
    return 'Jetzt die $_temp0 Ballons.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'roten',
      'blue': 'blauen',
      'green': 'grünen',
      'yellow': 'gelben',
      'purple': 'lila',
      'other': '$color',
    });
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
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'Roter',
      'blue': 'Blauer',
      'green': 'Grüner',
      'yellow': 'Gelber',
      'purple': 'Lila',
      'other': '$color',
    });
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
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'der Kreis',
      'square': 'das Quadrat',
      'triangle': 'das Dreieck',
      'star': 'der Stern',
      'heart': 'das Herz',
      'hexagon': 'das Sechseck',
      'circleSmall': 'der kleine Kreis',
      'squareSmall': 'das kleine Quadrat',
      'other': '$shape',
    });
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
  String get parentTabShelf => 'Regal';

  @override
  String get parentHowUse => 'Wie nutzt ihr die App gerade?';

  @override
  String get parentHowUseHint =>
      'Im Modus „zusammen“ erscheinen Gesprächspausen für euch beide. Im Modus „allein“ antwortet das Kind durch Tippen, und Geschichten über Sicherheit und Körper bleiben verborgen.';

  @override
  String get parentPlace => 'Wo ihr wohnt';

  @override
  String get parentPlaceHint =>
      'Für den Naturkalender: Die Tipps folgen den Jahreszeiten bei euch zu Hause.';

  @override
  String hemisphere(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'north': 'Nordhalbkugel',
      'south': 'Südhalbkugel',
      'equator': 'In der Nähe des Äquators',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String get parentData => 'Wo die Daten liegen';

  @override
  String get parentDataHint =>
      'Profile, Tagebuch und Fortschritte bleiben verschlüsselt auf diesem Gerät. Die Google-Drive-Sicherung unten ist freiwillig.';

  @override
  String get parentWipe => 'Alle Daten löschen';

  @override
  String get parentWipeConfirmTitle => 'Alles löschen?';

  @override
  String get parentWipeConfirm =>
      'Profile und Tagebuch werden von diesem Gerät gelöscht. Das lässt sich nicht rückgängig machen. Eine Google-Drive-Sicherung bleibt, wo sie ist.';

  @override
  String get parentWipeYes => 'Löschen';

  @override
  String get backupTitle => 'Sicherung auf Google Drive';

  @override
  String get backupHint =>
      'Freiwillig. Die Sicherung landet in einem versteckten Ordner deines Drive, den die App für nichts anderes nutzen kann, und ist mit einem Passwort verschlüsselt, das nur du kennst. So kannst du auf ein neues Tablet wechseln oder die App neu installieren, ohne etwas zu verlieren.';

  @override
  String get backupOff => 'Aus: Die Daten sind nur auf diesem Tablet.';

  @override
  String backupOnAccount(String account) {
    return 'An, mit $account';
  }

  @override
  String backupLast(String date) {
    return 'Letzte Sicherung: $date';
  }

  @override
  String get backupNever => 'Noch keine Sicherung.';

  @override
  String get backupAutoFailed =>
      'Die letzte automatische Sicherung hat nicht geklappt. Versuch es mit „Jetzt sichern“.';

  @override
  String get backupEnable => 'Sicherung einschalten';

  @override
  String get backupNow => 'Jetzt sichern';

  @override
  String get backupRestore => 'Von Drive wiederherstellen';

  @override
  String get backupDisable => 'Ausschalten';

  @override
  String get backupPasswordTitle => 'Passwort für die Sicherung wählen';

  @override
  String get backupPasswordHint =>
      'Die Sicherung wird mit diesem Passwort verschlüsselt, bevor sie das Tablet verlässt. Du brauchst es, um sie auf einem anderen Gerät wiederherzustellen: Wenn du es vergisst, ist die Sicherung verloren, auch für uns.';

  @override
  String get backupPassword => 'Passwort';

  @override
  String get backupPasswordRepeat => 'Passwort wiederholen';

  @override
  String backupPasswordShort(int n) {
    return 'Mindestens $n Zeichen.';
  }

  @override
  String get backupPasswordMismatch =>
      'Die beiden Passwörter stimmen nicht überein.';

  @override
  String get backupRestorePasswordTitle => 'Passwort der Sicherung';

  @override
  String get backupRestorePasswordHint =>
      'Das Passwort, das du beim Einschalten der Sicherung gewählt hast.';

  @override
  String get backupWrongPassword => 'Falsches Passwort.';

  @override
  String get backupNone =>
      'Auf diesem Google-Konto gibt es noch keine Mirabò-Sicherung.';

  @override
  String get backupExistsTitle => 'Es gibt schon eine Sicherung';

  @override
  String get backupExists =>
      'Auf diesem Google-Konto gibt es schon eine Mirabò-Sicherung. Möchtest du sie auf diesem Tablet wiederherstellen oder durch die Daten dieses Tablets ersetzen?';

  @override
  String get backupExistsRestore => 'Wiederherstellen';

  @override
  String get backupExistsReplace => 'Ersetzen';

  @override
  String get backupRestoreConfirmTitle => 'Sicherung wiederherstellen?';

  @override
  String get backupRestoreConfirm =>
      'Profile, Tagebuch und Fortschritte auf diesem Tablet werden durch die der Sicherung ersetzt.';

  @override
  String get backupDisableTitle => 'Sicherung ausschalten?';

  @override
  String get backupDisableConfirm =>
      'Das Tablet sichert nicht mehr und vergisst das Konto. Die Kopie auf Drive kannst du behalten, um sie später wiederherzustellen, oder löschen.';

  @override
  String get backupDisableKeep => 'Ausschalten, Kopie behalten';

  @override
  String get backupDisableDelete => 'Ausschalten, Kopie löschen';

  @override
  String get backupDone => 'Sicherung abgeschlossen.';

  @override
  String get backupRestored => 'Sicherung wiederhergestellt.';

  @override
  String get backupError =>
      'Das hat nicht geklappt. Prüfe die Verbindung und versuch es noch einmal.';

  @override
  String get backupContinue => 'Weiter';

  @override
  String get profileRestoreLink =>
      'Schon einmal Mirabò benutzt? Von Google Drive wiederherstellen';

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
  String get gesturesTitle => 'Gesten im echten Leben';

  @override
  String gesturesIntro(String companion, String name) {
    return '$companion wächst nur, wenn $name die Geste aus einer Geschichte wirklich macht, nicht durch Zeit in der App. Wenn ihr sie gemacht habt, trag es hier ein.';
  }

  @override
  String gesturesNext(int count, String companion) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gesten',
      one: '1 Geste',
    );
    return 'Noch $_temp0 bis zum nächsten Schritt von $companion.';
  }

  @override
  String gesturesAllGrown(String companion) {
    return '$companion hat den letzten Schritt erreicht: Die Gesten lohnen sich trotzdem.';
  }

  @override
  String gesturesEmpty(String name) {
    return 'Hier erscheinen die Gesten aus den Geschichten, die $name beendet hat.';
  }

  @override
  String get gestureMark => 'Heute gemacht';

  @override
  String get gestureMarked => 'Heute eingetragen';

  @override
  String gestureTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal gemacht',
      one: '1-mal gemacht',
      zero: 'noch nicht gemacht',
    );
    return '$_temp0';
  }

  @override
  String get ideaTitle => 'Eine Idee für heute';

  @override
  String ideaIntro(String name) {
    return 'Etwas Kleines, das Sie mit $name tun können, weg vom Bildschirm. Jeden Tag eine neue.';
  }

  @override
  String ideaFromStory(String story) {
    return 'Aus der Geschichte „$story“';
  }

  @override
  String ideaHome(String title, String area) {
    return 'Mit den Händen: $title ($area)';
  }

  @override
  String get ideaHomeHint =>
      'Die Darbietung Schritt für Schritt finden Sie bei den Montessori-Aktivitäten.';

  @override
  String ideaReasonRepeat(String name) {
    return '$name wollte es noch einmal machen';
  }

  @override
  String ideaReasonStory(String name, String story) {
    return '$name hat „$story“ gehört';
  }

  @override
  String get ideaReasonTryAlone =>
      'Ihr habt es zusammen gemacht: Nächstes Mal kann es das Kind selbstständig versuchen';

  @override
  String ideaReasonCapacity(String name, String capacity) {
    String _temp0 = intl.Intl.selectLogic(capacity, {
      'insieme': '$name ist gern mit anderen zusammen',
      'mani': '$name arbeitet gern mit den Händen',
      'sensi': '$name entdeckt gern mit allen Sinnen',
      'parole': '$name spielt gern mit Wörtern',
      'pensare': '$name zählt und denkt gern',
      'mondo': '$name entdeckt gern die Welt',
      'other': '$name wählt das oft',
    });
    return '$_temp0';
  }

  @override
  String get ideaAnother => 'Eine andere Idee';

  @override
  String ideaEmpty(String name) {
    return 'Sobald $name eine Geschichte beendet hat, finden Sie hier eine Idee für gemeinsam.';
  }

  @override
  String weekTitle(String name) {
    return 'Die Woche von $name';
  }

  @override
  String get weekIntro =>
      'Die letzten 7 Tage, erzählt. Keine Noten: nur, was passiert ist.';

  @override
  String weekStories(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hat $count Geschichten gehört: $titles.',
      one: 'Hat eine Geschichte gehört: $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekAllTogether => 'Sie haben immer gemeinsam zugehört.';

  @override
  String get weekAllAlone =>
      'Allein gehört: die nächste können Sie gemeinsam hören.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together-mal von $total wart ihr zusammen.',
      one: 'Einmal von $total wart ihr zusammen.',
    );
    return '$_temp0';
  }

  @override
  String weekChoice(String story, String answer) {
    return 'In „$story“ wurde bei der Pause gewählt: „$answer“.';
  }

  @override
  String weekKeyPhrase(String phrase) {
    return 'Ein Satz zum gemeinsamen Wiederholen: „$phrase“';
  }

  @override
  String weekGestures(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Im echten Leben wurden $count Gesten gemacht, aus $titles.',
      one: 'Im echten Leben wurde die Geste aus $titles gemacht.',
    );
    return '$_temp0';
  }

  @override
  String get weekNoGestures =>
      'Keine Geste eingetragen: Wenn ihr sie gemacht habt, tragen Sie sie unten ein.';

  @override
  String weekHome(String titles) {
    return 'Mit den Händen, weg vom Bildschirm: $titles.';
  }

  @override
  String get weekEmpty =>
      'Diese Woche keine Geschichten und keine Gesten. Das ist in Ordnung: Wochen ohne Bildschirm zählen auch.';

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
    String _temp0 = intl.Intl.selectLogic(stage, {
      'starting': 'fängt an',
      'working': 'arbeitet daran',
      'canDo': 'schafft es',
      'alone': 'macht es allein',
      'other': '$stage',
    });
    return '$_temp0';
  }

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(skill, {
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
    });
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
    String _temp0 = intl.Intl.selectLogic(band, {
      'small': 'Die Kleinen',
      'mid': 'Erste Schritte',
      'big': 'Die Großen',
      'other': '$band',
    });
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

  @override
  String get lessonNaming => 'Das ist';

  @override
  String get lessonShow => 'Wo ist es?';

  @override
  String get lessonTell => 'Wie heißt das?';

  @override
  String shelfTitle(Object name) {
    return '${name}s Regal';
  }

  @override
  String shelfHint(String name, int max, int per) {
    return 'Wenige Materialien auf einmal, wie in den Regalen einer Montessori-Umgebung: $name wählt frei unter denen, die du hier hinstellst. Höchstens $max insgesamt und $per pro Fähigkeit; tausche sie aus, wenn sie erkundet sind.';
  }

  @override
  String shelfCount(int count, int max) {
    return '$count von $max';
  }

  @override
  String get shelfAuto => 'Automatische Auswahl';

  @override
  String get shelfAutoOn =>
      'Das Regal füllt sich jetzt von selbst und wechselt einmal pro Woche.';

  @override
  String get shelfAutoHint =>
      'Das Regal füllt sich von selbst und wechselt einmal pro Woche: Woran das Kind arbeitet, bleibt, der Rest macht Platz für anderes. Tippe auf ein Material, um selbst auszuwählen.';

  @override
  String shelfFull(int max) {
    return 'Im Regal stehen schon $max Materialien: nimm eins weg, um ein anderes hinzustellen.';
  }

  @override
  String shelfCapacityFull(int max) {
    return 'Für diese Fähigkeit stehen schon $max Materialien da: nimm eins weg, um ein anderes hinzustellen.';
  }

  @override
  String shelfTotal(int count, int max) {
    return 'Im Regal: $count von $max';
  }

  @override
  String get shelfRotateNow => 'Jetzt wechseln';

  @override
  String get shelfRotated => 'Das Regal hat gewechselt.';

  @override
  String get shelfKindStory => 'Geschichte';

  @override
  String get shelfKindGame => 'Spiel';

  @override
  String get shelfKindActivity => 'Aktivität';

  @override
  String get gesturePause => 'Pause: Wir machen die Geste';

  @override
  String get gestureStart => 'Bereit? Los!';

  @override
  String get huntFound => 'Ich hab\'s gefunden!';

  @override
  String get huntNotFound => 'Ich finde es nicht';

  @override
  String get huntRest => 'Bildschirm ruhen lassen';

  @override
  String get huntRestHint =>
      'Tippe auf den Bildschirm, wenn du zurück bist. Wenn du nicht magst, ist das auch in Ordnung.';

  @override
  String get huntTellMe => 'Was hast du gefunden? Sag es laut.';

  @override
  String get huntRules =>
      'Das Kind sucht immer nur eine Sache, im Haus oder draußen mit euch. Nur Dinge in Reichweite: nicht klettern, nichts Spitzes oder Zerbrechliches, keine Medikamente oder Putzmittel. Draußen nur, was schon auf dem Boden liegt. Am Ende kommt alles wieder an seinen Platz.';

  @override
  String get catMake => 'Erfinden & entdecken';

  @override
  String get factoryTitle => 'Geschichtenfabrik';

  @override
  String get natureTitle => 'Naturkalender';

  @override
  String factoryAsk(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'who': 'Wer ist die Hauptfigur?',
      'place': 'Wo lebt sie?',
      'problem': 'Eines Tages: Was passiert?',
      'feeling': 'Wie fühlt sie sich?',
      'helper': 'Wer kommt zu Hilfe?',
      'ending': 'Wie geht es aus?',
      'other': '$step',
    });
    return '$_temp0';
  }

  @override
  String get factoryNameIt => 'Wie soll die Geschichte heißen?';

  @override
  String get factoryRead => 'Lesen wir die Geschichte!';

  @override
  String get factoryMine => 'Meine Geschichten';

  @override
  String get factoryNew => 'Erfinde eine';

  @override
  String factoryBy(Object name) {
    return 'Eine Geschichte von $name';
  }

  @override
  String get factoryEnd => 'Ende';

  @override
  String get factoryOtherEnding => 'Probier ein anderes Ende';

  @override
  String factoryDone(Object name) {
    return 'Was für eine schöne Geschichte, $name! Ich lege sie zu deinen Geschichten.';
  }

  @override
  String get factoryMineEmpty =>
      'Hier findest du die Geschichten, die du erfindest.';

  @override
  String factoryWhoA(String who) {
    String _temp0 = intl.Intl.selectLogic(who, {
      'dragon': 'ein kleiner Drache',
      'bunny': 'ein Häschen',
      'robot': 'ein freundlicher Roboter',
      'penguin': 'ein Pinguin',
      'unicorn': 'ein Einhorn',
      'kitten': 'ein Kätzchen',
      'other': '$who',
    });
    return '$_temp0';
  }

  @override
  String factoryWhoThe(String who) {
    String _temp0 = intl.Intl.selectLogic(who, {
      'dragon': 'der kleine Drache',
      'bunny': 'das Häschen',
      'robot': 'der freundliche Roboter',
      'penguin': 'der Pinguin',
      'unicorn': 'das Einhorn',
      'kitten': 'das Kätzchen',
      'other': '$who',
    });
    return '$_temp0';
  }

  @override
  String factoryPlaceName(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'forest': 'der Wald',
      'room': 'das Kinderzimmer',
      'stream': 'der Bach',
      'sky': 'die Wolken',
      'snow': 'der Schnee',
      'night': 'die Nacht',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String factoryPlaceIn(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'forest': 'in einem Wald voller Bäume',
      'room': 'in einem Kinderzimmer voller Spielsachen',
      'stream': 'an einem kleinen Bach',
      'sky': 'auf einer weichen Wolke',
      'snow': 'auf einer Wiese voller Schnee',
      'night': 'auf einer Wiese unter den Sternen',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String factoryProblemName(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'das Gewitter',
      'star': 'der heruntergefallene Stern',
      'sadFriend': 'ein trauriger Freund',
      'litter': 'der Müll',
      'lost': 'der verlorene Weg',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factoryProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'kam ein starkes Gewitter',
      'star': 'fiel ein kleiner Stern vom Himmel und fand den Weg nach Hause nicht mehr',
      'sadFriend': 'kam ein Freund, ganz traurig, und wollte nicht reden',
      'litter': 'ließ jemand viel Müll auf dem Boden liegen',
      'lost': 'versteckte der Nebel den Weg nach Hause',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factorySolution(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'fanden sie einen trockenen Unterschlupf und warteten, bis das Gewitter vorbei war',
      'star': 'bauten sie eine riesige Leiter und brachten den kleinen Stern zurück an den Himmel',
      'sadFriend': 'setzten sie sich zu dem Freund und hörten ihm zu, bis er wieder lächelte',
      'litter': 'sammelten sie den Müll mit Handschuhen auf und warfen ihn in die richtigen Tonnen',
      'lost': 'folgten sie den Spuren auf dem Weg und fanden nach Hause zurück',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factoryFeelingName(String feeling) {
    String _temp0 = intl.Intl.selectLogic(feeling, {
      'fear': 'die Angst',
      'sadness': 'die Traurigkeit',
      'anger': 'die Wut',
      'curiosity': 'die Neugier',
      'courage': 'der Mut',
      'other': '$feeling',
    });
    return '$_temp0';
  }

  @override
  String factoryFeeling(String feeling) {
    String _temp0 = intl.Intl.selectLogic(feeling, {
      'fear': 'ein bisschen Angst',
      'sadness': 'ein bisschen Traurigkeit',
      'anger': 'ein bisschen Wut',
      'curiosity': 'große Neugier',
      'courage': 'großen Mut',
      'other': '$feeling',
    });
    return '$_temp0';
  }

  @override
  String factoryHelperA(String helper) {
    String _temp0 = intl.Intl.selectLogic(helper, {
      'turtle': 'eine weise Schildkröte',
      'owl': 'eine Eule, die viele Dinge weiß',
      'bear': 'ein freundlicher Bär',
      'bee': 'eine flinke Biene',
      'other': '$helper',
    });
    return '$_temp0';
  }

  @override
  String factoryEndingName(String ending) {
    String _temp0 = intl.Intl.selectLogic(ending, {
      'party': 'ein Fest',
      'sleep': 'schlafen gehen',
      'hug': 'eine Umarmung',
      'snack': 'ein Picknick',
      'other': '$ending',
    });
    return '$_temp0';
  }

  @override
  String factoryPageStart(Object who, Object place) {
    return 'Es war einmal $who $place.';
  }

  @override
  String factoryPageProblem(Object problem) {
    return 'Eines Tages $problem.';
  }

  @override
  String factoryPageFeeling(Object who, Object feeling) {
    return '$who spürte $feeling und atmete tief durch.';
  }

  @override
  String factoryPageHelp(Object helper, Object solution) {
    return 'Zum Glück kam $helper. Gemeinsam $solution.';
  }

  @override
  String factoryEnding(String ending, Object who) {
    String _temp0 = intl.Intl.selectLogic(ending, {
      'party': 'Und am Abend feierte $who ein großes Fest mit allen Freunden.',
      'sleep':
          'Und am Abend schlief $who glücklich unter einer warmen Decke ein.',
      'hug': 'Und am Ende umarmte $who den neuen Freund ganz fest.',
      'snack': 'Und am Ende machte $who mit allen ein Picknick in der Sonne.',
      'other': '$ending',
    });
    return '$_temp0';
  }

  @override
  String get natureAskWeather => 'Wie ist das Wetter?';

  @override
  String get natureAskSeen => 'Was hast du draußen gesehen?';

  @override
  String get natureUpTo => 'Du kannst bis zu drei auswählen.';

  @override
  String natureWeather(String weather) {
    String _temp0 = intl.Intl.selectLogic(weather, {
      'sun': 'Sonne',
      'clouds': 'Wolken',
      'rain': 'Regen',
      'snow': 'Schnee',
      'wind': 'Wind',
      'fog': 'Nebel',
      'other': '$weather',
    });
    return '$_temp0';
  }

  @override
  String natureThing(String thing) {
    String _temp0 = intl.Intl.selectLogic(thing, {
      'leaf': 'Blätter',
      'flower': 'Blumen',
      'bird': 'Vögel',
      'bug': 'Marienkäfer und Insekten',
      'snail': 'Schnecken',
      'fruit': 'Früchte',
      'mushroom': 'Pilze',
      'rainbow': 'Ein Regenbogen',
      'moon': 'Der Mond',
      'other': '$thing',
    });
    return '$_temp0';
  }

  @override
  String natureMonthTip(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Es ist kalt und viele Bäume sind kahl. Siehst du Nester in den Zweigen?',
      'm2': 'Die Tage werden ein kleines bisschen länger. Such die ersten Knospen an den Zweigen.',
      'm3': 'Der Frühling kommt: Die ersten Blumen sprießen. Welche Farbe haben sie?',
      'm4': 'Die Vögel bauen ihre Nester. Hör mal: Wie viele verschiedene Lieder hörst du?',
      'm5': 'Die Wiese ist voller Blumen und Bienen. Schau ihnen aus der Ferne zu: Sie arbeiten so fleißig!',
      'm6': 'Das sind die längsten Tage des Jahres. Was siehst du abends, wenn es noch hell ist?',
      'm7': 'Es ist heiß: Such den Schatten der Bäume. Hörst du die Zikaden?',
      'm8': 'Nachts, wenn der Himmel klar ist, fällt manchmal eine Sternschnuppe. Wünsch dir was!',
      'm9': 'Viele Früchte werden reif: Trauben, Äpfel, Feigen. Welche kennst du?',
      'm10': 'Die Blätter wechseln die Farbe und fallen. Wie viele verschiedene Farben findest du?',
      'm11': 'Im Wald wachsen Pilze. Wir schauen sie an, aber wir fassen sie nicht an!',
      'm12': 'Das sind die kürzesten Tage des Jahres. Der Wald ruht sich aus, wie in Emmas Geschichte.',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String natureEquatorTip(String tip) {
    String _temp0 = intl.Intl.selectLogic(tip, {
      'e1': 'Wenn Regen kommt, riecht die Luft anders. Riechst du es?',
      'e2': 'Nach einem Regenguss bleiben Pfützen. Was siehst du darin gespiegelt?',
      'e3': 'An trockenen Tagen wird die Erde hart und staubig. Fass sie an: Wie fühlt sie sich heute an?',
      'e4': 'Mit dem Regen wachsen die Pflanzen schnell. Findest du ein neues Blatt, noch ganz hell?',
      'e5':
          'Such ein riesiges Blatt und ein winziges. Wie verschieden sind sie?',
      'e6': 'Gibt es einen Baum mit Blüten oder Früchten? Welche Farbe haben sie?',
      'e7': 'Ameisen laufen in einer Reihe. Folge ihnen mit den Augen: Wohin gehen sie?',
      'e8': 'Nach dem Regen erscheint manchmal ein Regenbogen. Wie viele Farben kannst du zählen?',
      'other': '$tip',
    });
    return '$_temp0';
  }

  @override
  String get natureThisMonth => 'Diesen Monat';

  @override
  String natureDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get natureEmptyMonth => 'Diesen Monat ist der Kalender noch leer.';

  @override
  String get natureToday => 'Heute';

  @override
  String get readWord => 'Tippe auf ein Wort, um es noch einmal zu hören';

  @override
  String get profileReadAlong => 'Mitlesen (Karaoke)';

  @override
  String get profileReadAlongHint =>
      'Während die Stimme liest, leuchtet das Wort auf; antippen spielt es noch einmal ab.';

  @override
  String get parentTabPrint => 'Zum Ausdrucken';

  @override
  String printIntro(Object name) {
    return 'Blätter zum Ausdrucken, für die Zeit ohne Bildschirm, in der Sprache von $name.';
  }

  @override
  String get printEveryday => 'Für jeden Tag';

  @override
  String get printNameTrace => 'Ich schreibe meinen Namen';

  @override
  String printNameTraceHint(Object name) {
    return 'Der Name von $name zum Nachspuren mit dem Bleistift.';
  }

  @override
  String get printNature => 'Naturkalender des Monats';

  @override
  String printNatureHint(Object name) {
    return 'Das Monatsraster zum Ausfüllen von Hand, mit dem, was $name schon eingetragen hat.';
  }

  @override
  String get printGestures => 'Gesten aus den Geschichten';

  @override
  String get printGestureHint =>
      'Die Geste, zwei Wochen Kreise zum Ausmalen und Platz zum Zeichnen.';

  @override
  String printGesturesEmpty(Object name) {
    return 'Hier erscheinen die Gesten aus den Geschichten, die $name beendet hat.';
  }

  @override
  String get printMade => 'Erfundene Geschichten';

  @override
  String get printMadeHint =>
      'Die Geschichte als kleines Heft, mit Platz für Bilder.';

  @override
  String printMadeEmpty(Object name) {
    return 'Hier erscheinen die Geschichten, die $name in der Fabrik erfindet.';
  }

  @override
  String get printButton => 'Drucken';

  @override
  String get pdfDrawHere => 'Hier malen';

  @override
  String get pdfGestureTimes =>
      'Jedes Mal, wenn du es machst, malst du einen Kreis aus.';

  @override
  String get pdfTraceName => 'Spure deinen Namen nach';

  @override
  String get pdfWeather => 'Wetter';

  @override
  String get pdfSeen => 'Ich habe gesehen';

  @override
  String get exitAsk => 'Möchtest du raus?';

  @override
  String get exitStay => 'Bleiben';

  @override
  String get exitLeave => 'Raus';

  @override
  String get profileInteraction => 'Wie es die App nutzt';

  @override
  String profileInteractionHint(Object name) {
    return 'Startwerte nach Alter: verschieben Sie sie, wenn $name mehr oder weniger kann. Die App ändert sie nie von selbst.';
  }

  @override
  String get profileHands => 'Hände';

  @override
  String get profileHandsHint =>
      'Größere Knöpfe und breitere Spuren für Anfänger.';

  @override
  String get hands1 => 'Nur tippen';

  @override
  String get hands2 => 'Ziehen';

  @override
  String get hands3 => 'Genau';

  @override
  String get profileReading => 'Lesen';

  @override
  String get profileReadingHint =>
      'Kein Text (nur Stimme), nur der Kernsatz, Text mit Mitlesen oder ganzer Text.';

  @override
  String get readingNone => 'Liest noch nicht';

  @override
  String get readingLetters => 'Buchstaben';

  @override
  String get readingWords => 'Wörter';

  @override
  String get readingFluent => 'Liest gut';

  @override
  String get profileAutonomy => 'Selbstständigkeit';

  @override
  String get profileAutonomyHint =>
      'Wie viele Auswahlmöglichkeiten, wiederholte Anweisung, Bestätigung vor dem Verlassen.';

  @override
  String get autonomy1 => 'Mit Hilfe';

  @override
  String get autonomy2 => 'Etwas allein';

  @override
  String get autonomy3 => 'Allein';

  @override
  String adviceHands(Object name) {
    return 'In den letzten Tagen spurt $name Buchstaben beim ersten Versuch nach: feinere Spuren ausprobieren?';
  }

  @override
  String adviceReading(Object name) {
    return 'In den letzten Tagen legt $name Wörter beim ersten Versuch: mehr Text zeigen?';
  }

  @override
  String adviceAutonomy(Object name) {
    return 'In den letzten Tagen antwortet $name beim ersten Versuch richtig: mehr Auswahl auf einmal ausprobieren?';
  }

  @override
  String get adviceYes => 'Ja, probieren wir';

  @override
  String get adviceNo => 'Nicht jetzt';

  @override
  String get sharedPromptGuide => 'Sag du mir, was zu tun ist';

  @override
  String get sharedPromptHelp => 'Wie könnten wir helfen?';
}
