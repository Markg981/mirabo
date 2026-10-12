// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Mirabò';

  @override
  String get appTagline => 'Storie e piccoli passi per crescere.';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Avanti';

  @override
  String get done => 'Fatto';

  @override
  String get finish => 'Fine';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get listenAgain => 'Riascolta';

  @override
  String get readAgain => 'Rileggi';

  @override
  String get seeYouTomorrow => 'A domani!';

  @override
  String get go => 'Via!';

  @override
  String get home => 'Casa';

  @override
  String get parentArea => 'Area genitori';

  @override
  String get modeTogether => 'Insieme';

  @override
  String get modeAlone => 'Da solo';

  @override
  String stepOf(Object current, Object total) {
    return 'Passo $current di $total';
  }

  @override
  String homeHello(Object name) {
    return 'Ciao $name!';
  }

  @override
  String get homeQuestion => 'Cosa facciamo oggi?';

  @override
  String get homeOneStory => 'Una storia';

  @override
  String get homeLetsPlay => 'Giochiamo';

  @override
  String switchChildA11y(Object name) {
    return 'Cambia bambino. Ora gioca $name';
  }

  @override
  String get chooseWhoPlays => 'Chi gioca oggi?';

  @override
  String chooseWith(Object companion) {
    return 'con $companion';
  }

  @override
  String get chooseAdd => 'Aggiungi';

  @override
  String get chooseAddHint => 'per i grandi';

  @override
  String get chooseAddA11y => 'Aggiungi un bambino';

  @override
  String get catStories => 'Le storie';

  @override
  String get catGames => 'Giochi';

  @override
  String get catEmpty => 'Qui non c\'è niente per oggi.';

  @override
  String get badgeAtHome => 'A casa';

  @override
  String get badgeTogether => 'Insieme';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(
      area,
      {
        'cognitivo': 'Prerequisiti',
        'autonomia': 'Autonomia',
        'sociale': 'In classe',
        'paure': 'Primo giorno',
        'vitaPratica': 'Vita pratica',
        'sensoriale': 'Sensoriale',
        'linguaggio': 'Linguaggio e scrittura',
        'matematica': 'Matematica',
        'cultura': 'Cultura',
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
        'emozioni': 'Emozioni',
        'inclusione': 'Insieme',
        'ambiente': 'Il bosco',
        'sicurezza': 'Il mio corpo',
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
        'emozioni': 'Emozioni e conflitti',
        'inclusione': 'Diversità e inclusione',
        'ambiente': 'Ambiente e viventi',
        'sicurezza': 'Sicurezza e corpo',
        'other': '$world',
      },
    );
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'La frase da ricordare';

  @override
  String get activityTryAgain => 'Riprova.';

  @override
  String get activityHelp => 'Guarda bene. Ti aiuto io.';

  @override
  String get checklistPrompt => 'Cosa è già pronto?';

  @override
  String get checklistSay => 'Cosa è già pronto per domani?';

  @override
  String get checklistAlone => 'da solo';

  @override
  String get checklistAllDone => 'Tutto pronto, buonanotte';

  @override
  String get enoughForToday => 'Per oggi basta così';

  @override
  String get countdownPick => 'Scegli la data';

  @override
  String get countdownToday => 'È oggi!';

  @override
  String get countdownTodaySay => 'Oggi è il giorno!';

  @override
  String countdownDaysTo(int count, String event) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mancano $count giorni a: $event',
      one: 'Manca 1 giorno a: $event',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysSay(int count, String task) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mancano $count giorni. $task',
      one: 'Manca 1 giorno. $task',
    );
    return '$_temp0';
  }

  @override
  String exploreTap(Object scene) {
    return '$scene: tocca per scoprire';
  }

  @override
  String exploreSay(Object scene) {
    return 'Questa è $scene. Tocca per scoprire.';
  }

  @override
  String get exploreAllSeen => 'Ho visto tutto!';

  @override
  String get exploreEnough => 'Per oggi basta';

  @override
  String get patternPrompt => 'Cosa viene dopo?';

  @override
  String get presentationWhatYouNeed => 'Cosa serve';

  @override
  String presentationWhatYouNeedSay(Object items) {
    return 'Cosa serve: $items';
  }

  @override
  String get presentationReady => 'Tutto pronto';

  @override
  String get presentationPrepare =>
      'Prepara tutto su un vassoio prima di chiamare il bambino. Mostra i passi una volta, lentamente e senza parlare; poi lascia fare.';

  @override
  String presentationStep(Object current, Object total) {
    return 'Passo $current di $total';
  }

  @override
  String get presentationWorkAlone => 'Ora lavora da solo';

  @override
  String presentationYourTurnSay(Object name) {
    return 'Adesso tocca a te, $name. Il tablet lo mettiamo via.';
  }

  @override
  String get presentationHowDidItGo => 'Per il grande: com\'è andata?';

  @override
  String get presentationControl => 'Controllo dell\'errore';

  @override
  String get presentationObserve => 'Cosa osservare';

  @override
  String get presentationMarkLater =>
      'Segna quando ha finito di lavorare, anche dopo un po\'. Non correggere mentre lavora.';

  @override
  String get presentationWatched => 'Ha guardato';

  @override
  String get presentationDid => 'L\'ha fatto';

  @override
  String get presentationAlone => 'Da solo';

  @override
  String get presentationRepeat => 'Vuole rifarla';

  @override
  String get forTheAdult => 'Per il grande';

  @override
  String turnYou(Object name) {
    return 'Tocca a te, $name';
  }

  @override
  String get turnAdult => 'Tocca al grande';

  @override
  String spellSay(Object word) {
    return 'Componi: $word';
  }

  @override
  String get spellSentence => 'Componi la frase';

  @override
  String get spellWord => 'Componi la parola';

  @override
  String tracePrompt(Object label) {
    return 'Traccia la $label con il dito';
  }

  @override
  String get traceRestart => 'Ricomincio';

  @override
  String gameWellDone(Object name) {
    return 'Bravo, $name!';
  }

  @override
  String get gameNiceGame => 'Che bella partita.';

  @override
  String gameWellDoneSay(Object name) {
    return 'Bravo, $name! Che bella partita.';
  }

  @override
  String get gameAgain => 'Ancora';

  @override
  String get gameEnough => 'Basta così';

  @override
  String get gameMemoryTitle => 'Memory degli animali';

  @override
  String gameMemoryDesc(int count) {
    return 'Trova le coppie: $count coppie.';
  }

  @override
  String get memoryIntro => 'Trova le coppie di animali uguali.';

  @override
  String get memoryCovered => 'Carta coperta';

  @override
  String animalName(String animal) {
    String _temp0 = intl.Intl.selectLogic(
      animal,
      {
        'dog': 'il cane',
        'cat': 'il gatto',
        'rabbit': 'il coniglio',
        'fox': 'la volpe',
        'bear': 'l\'orso',
        'panda': 'il panda',
        'frog': 'la rana',
        'monkey': 'la scimmia',
        'lion': 'il leone',
        'tiger': 'la tigre',
        'cow': 'la mucca',
        'pig': 'il maiale',
        'other': '$animal',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameBalloonsTitle => 'I palloncini';

  @override
  String get gameBalloonsDescSmall => 'Scoppia i palloncini.';

  @override
  String get gameBalloonsDescMid =>
      'Scoppia solo quelli del colore che dice il compagno.';

  @override
  String get gameBalloonsDescBig => 'Scoppia i numeri in ordine, da 1 a 10.';

  @override
  String get balloonsPopAll => 'Scoppia i palloncini!';

  @override
  String balloonsPopColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rossi',
        'blue': 'blu',
        'green': 'verdi',
        'yellow': 'gialli',
        'purple': 'viola',
        'other': '$color',
      },
    );
    return 'Scoppia solo i palloncini $_temp0.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rossi',
        'blue': 'blu',
        'green': 'verdi',
        'yellow': 'gialli',
        'purple': 'viola',
        'other': '$color',
      },
    );
    return 'Adesso i palloncini $_temp0.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rossi',
        'blue': 'blu',
        'green': 'verdi',
        'yellow': 'gialli',
        'purple': 'viola',
        'other': '$color',
      },
    );
    return 'Solo quelli $_temp0';
  }

  @override
  String get balloonsNumbersStart =>
      'Scoppia i numeri in ordine. Comincia dall\'uno.';

  @override
  String balloonsNow(Object n) {
    return 'Adesso il $n.';
  }

  @override
  String balloonsFind(Object n) {
    return 'Trova il $n';
  }

  @override
  String balloonsWrongNumber(Object got, Object want) {
    return 'Quello è il $got. Cerca il $want.';
  }

  @override
  String get balloonsDone => 'Fatto!';

  @override
  String balloonA11yNumber(Object n) {
    return 'Palloncino $n';
  }

  @override
  String balloonA11yColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rosso',
        'blue': 'blu',
        'green': 'verde',
        'yellow': 'giallo',
        'purple': 'viola',
        'other': '$color',
      },
    );
    return 'Palloncino $_temp0';
  }

  @override
  String get gameShapesTitle => 'Le forme al loro posto';

  @override
  String get gameShapesDescSmall => 'Tre forme da trascinare nel buco giusto.';

  @override
  String get gameShapesDescMid => 'Cinque forme da trascinare nel buco giusto.';

  @override
  String get gameShapesDescBig =>
      'Sei forme, grandi e piccole: attenzione alla misura.';

  @override
  String get shapesIntro => 'Metti ogni forma nel suo buco.';

  @override
  String get shapesIntroBig =>
      'Metti ogni forma nel suo buco. Attenzione alla misura: grandi e piccole.';

  @override
  String shapesWrong(Object shape) {
    return 'Questo è $shape. Prova un altro buco.';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(
      shape,
      {
        'circle': 'il cerchio',
        'square': 'il quadrato',
        'triangle': 'il triangolo',
        'star': 'la stella',
        'heart': 'il cuore',
        'hexagon': 'l\'esagono',
        'circleSmall': 'il cerchio piccolo',
        'squareSmall': 'il quadrato piccolo',
        'other': '$shape',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameDrawingTitle => 'Disegna e colora';

  @override
  String get gameDrawingDesc => 'Un foglio bianco, i colori e i timbri.';

  @override
  String get drawingIntro => 'Scegli un colore e disegna con il dito.';

  @override
  String get drawingSheet => 'Foglio da disegno';

  @override
  String get drawingEraser => 'Gomma';

  @override
  String get drawingUndo => 'Torna indietro';

  @override
  String get drawingNewSheet => 'Foglio nuovo';

  @override
  String get gameXyloTitle => 'Lo xilofono';

  @override
  String get gameXyloDescSmall => 'Suona libero.';

  @override
  String gameXyloDescBig(Object song) {
    return 'Suona libero o impara \"$song\".';
  }

  @override
  String get xyloNotes => 'do re mi fa sol la si do';

  @override
  String get xyloSong => 'Fra Martino';

  @override
  String get xyloIntro => 'Tocca le barre e suona.';

  @override
  String xyloIntroSong(Object song) {
    return 'Suona quello che vuoi, oppure impara $song.';
  }

  @override
  String get xyloFree => 'Suona libero';

  @override
  String get xyloFreeSay => 'Suona quello che vuoi.';

  @override
  String get xyloSongSay => 'Suona la barra che si illumina.';

  @override
  String xyloNoteA11y(Object note) {
    return 'Nota $note';
  }

  @override
  String get gamePuzzleTitle => 'Il gioco del 15';

  @override
  String get gamePuzzleDesc =>
      'Rimetti in ordine i numeri da 1 a 8 facendo scorrere le tessere.';

  @override
  String get puzzleIntro =>
      'Fai scorrere le tessere per metterle in ordine, da uno a otto.';

  @override
  String puzzleTileA11y(Object n) {
    return 'Tessera $n';
  }

  @override
  String get gateTitle => 'Area per i grandi';

  @override
  String gateQuestion(Object a, Object b) {
    return 'Quanto fa $a × $b?';
  }

  @override
  String get gateWrong => 'Riprova';

  @override
  String get gateEnter => 'Entra';

  @override
  String get parentTabSession => 'Sessione';

  @override
  String get parentTabProfiles => 'Profili';

  @override
  String get parentTabCards => 'Come parlarne';

  @override
  String get parentTabDiary => 'Diario';

  @override
  String get parentTabGrowth => 'Sviluppo';

  @override
  String get parentHowUse => 'Come usate l\'app adesso?';

  @override
  String get parentHowUseHint =>
      'In modalità \"insieme\" compaiono le pause di dialogo per voi due. In modalità \"da solo\" il bambino risponde toccando e le storie su sicurezza e corpo restano nascoste.';

  @override
  String get parentData => 'Dove vivono i dati';

  @override
  String get parentDataHint =>
      'Solo su questo dispositivo. Il backup su Drive e l\'account cloud arrivano nelle prossime versioni.';

  @override
  String get parentWipe => 'Elimina tutti i dati';

  @override
  String get parentWipeConfirmTitle => 'Eliminare tutto?';

  @override
  String get parentWipeConfirm =>
      'Profili e diario verranno cancellati da questo dispositivo. Non si può annullare.';

  @override
  String get parentWipeYes => 'Elimina';

  @override
  String get parentNewProfile => 'Nuovo profilo';

  @override
  String parentProfileLine(String age, String companion, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storie',
      one: '1 storia',
    );
    return '$age · compagno $companion · $_temp0';
  }

  @override
  String get diaryEmpty => 'Nessuna storia negli ultimi 30 giorni.';

  @override
  String get diaryTogether => 'insieme';

  @override
  String get diaryAlone => 'da solo';

  @override
  String diaryChose(Object answer) {
    return 'alla pausa ha scelto: \"$answer\"';
  }

  @override
  String growthTitle(Object name) {
    return 'Come sta crescendo $name';
  }

  @override
  String get growthIntro =>
      'Il confronto è solo con sé stesso, un mese fa. L\'app vede una parte piccola della sua giornata: per dubbi sullo sviluppo il riferimento è il pediatra o l\'insegnante.';

  @override
  String get growthEmpty =>
      'Nessuna attività negli ultimi 30 giorni. Quando ne farà qualcuna, qui vedrai le tappe.';

  @override
  String get growthOffscreen =>
      'Dove non c\'è miglioramento, prova l\'attività fuori dallo schermo suggerita nella scheda: non più tempo sull\'app.';

  @override
  String growthNew(Object count) {
    return 'Negli ultimi 30 giorni: $count round. Un mese fa non l\'aveva ancora provato.';
  }

  @override
  String growthCompare(Object before, Object now) {
    return 'Oggi: $now · un mese fa: $before (bordo grigio).';
  }

  @override
  String stageLabel(String stage) {
    String _temp0 = intl.Intl.selectLogic(
      stage,
      {
        'starting': 'sta iniziando',
        'working': 'ci sta lavorando',
        'canDo': 'ce la fa',
        'alone': 'lo fa da solo',
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
        'suoni_iniziali': 'Suoni e lettere',
        'pregrafismo': 'Tracciare lettere',
        'numeri': 'Numeri e quantità',
        'logica': 'Logica e sequenze',
        'routine_sera': 'Preparare le cose per domani',
        'routine_mattino': 'La routine del mattino',
        'vestirsi': 'Vestirsi da solo',
        'mensa': 'A mensa',
        'turno_e_condivisione': 'Aspettare il turno e condividere',
        'chiedere_aiuto': 'Chiedere aiuto',
        'distacco': 'Il saluto del mattino',
        'conoscere_la_scuola': 'Conoscere la scuola',
        'primo_giorno': 'Il primo giorno',
        'travasi': 'Travasi e versare',
        'motricita_fine': 'Motricità fine',
        'cura_ambiente': 'Cura dell\'ambiente',
        'dimensioni': 'Grandezze e seriazione',
        'colori': 'Colori',
        'forme': 'Forme',
        'tatto': 'Tatto',
        'udito': 'Udito',
        'scrittura': 'Scrittura',
        'vocabolario': 'Vocabolario',
        'decine': 'Decine e unità',
        'geografia': 'Geografia',
        'botanica': 'Botanica',
        'other': '$skill',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileWelcome => 'Benvenuti in Mirabò';

  @override
  String get profileEdit => 'Modifica profilo';

  @override
  String get profileNew => 'Nuovo profilo';

  @override
  String get profileChild => 'Il bambino';

  @override
  String get profileFirstRunHint =>
      'Questa parte la compila un adulto. Ci vuole un minuto, poi il tablet passa al bambino.';

  @override
  String get profileName => 'Nome';

  @override
  String get profileNameHint => 'Il compagno lo chiamerà così';

  @override
  String get profileAge => 'Età';

  @override
  String profileYears(Object range) {
    return '$range anni';
  }

  @override
  String ageBandLabel(String band) {
    String _temp0 = intl.Intl.selectLogic(
      band,
      {
        'small': 'Piccoli',
        'mid': 'Primi passi',
        'big': 'Grandi',
        'other': '$band',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get profileLanguageHint =>
      'Storie, attività, giochi e voce del compagno saranno in questa lingua.';

  @override
  String get profileCompanion => 'Il compagno';

  @override
  String get profileCompanionEditHint =>
      'Il compagno si sceglie una volta sola: è il suo migliore amico.';

  @override
  String get profileCompanionNewHint =>
      'Fate scegliere al bambino. Si sceglie una volta sola e non si cambia.';

  @override
  String get profileWorlds => 'Mondi delle storie';

  @override
  String get profileWorldsHint =>
      'Scegliete i temi che il bambino troverà nella sua libreria.';

  @override
  String get profileSafetyTogether =>
      '\"Il mio corpo\" solo in modalità insieme';

  @override
  String get profileSafetyTogetherHint =>
      'Consigliato: le storie su sicurezza e corpo si leggono con un adulto.';

  @override
  String get profileAccess => 'Accessibilità e tempo';

  @override
  String get profileDyslexia => 'Testo ad alta leggibilità';

  @override
  String get profileDyslexiaHint =>
      'Carattere Lexend, spaziatura e interlinea maggiori.';

  @override
  String get profileLowStim => 'Bassa stimolazione';

  @override
  String get profileLowStimHint => 'Colori tenui, nessuna animazione.';

  @override
  String get profileAloneSession => 'Sessione \"da solo\"';

  @override
  String profileMinutes(Object count) {
    return '$count minuti';
  }

  @override
  String profileMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String get profileDelete => 'Elimina questo profilo';

  @override
  String get profileMissingName => 'Manca il nome';

  @override
  String get profileMissingCompanion => 'Manca il compagno';

  @override
  String get profileStart => 'Iniziamo';

  @override
  String get translationDraft => 'Traduzione in revisione';
}
