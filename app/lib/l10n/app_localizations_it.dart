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
  String get outroDone => 'Fatto';

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
  String goodbyeTitle(Object name) {
    return 'Per oggi basta, $name!';
  }

  @override
  String get goodbyeBody => 'Per oggi abbiamo finito. Chiama un grande.';

  @override
  String closingTitle(Object name) {
    return 'Bel lavoro, $name!';
  }

  @override
  String get closingBody =>
      'Hai fatto un bel pezzo di strada. Ora puoi posare il tablet: tutto resta com\'è, lo ritrovi quando vuoi.';

  @override
  String get closingBack => 'Torna a casa';

  @override
  String get closingA11y => 'Ho finito';

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
  String get catEmpty => 'Qui non c\'è niente per oggi.';

  @override
  String capacityLabel(String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': 'Io e gli altri',
        'mani': 'Le mani',
        'sensi': 'I sensi',
        'parole': 'Le parole',
        'pensare': 'Contare e pensare',
        'mondo': 'Il mondo',
        'other': '$capacity',
      },
    );
    return '$_temp0';
  }

  @override
  String themeLabel(String theme) {
    String _temp0 = intl.Intl.selectLogic(
      theme,
      {
        'emozioniRelazioni': 'Come mi sento',
        'naturaViventi': 'La natura',
        'autonomiaScuola': 'Faccio da me',
        'other': '$theme',
      },
    );
    return '$_temp0';
  }

  @override
  String experienceModeLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'story': 'Una storia',
        'game': 'Un gioco',
        'practice': 'Lo provo',
        'other': '$mode',
      },
    );
    return '$_temp0';
  }

  @override
  String get modeComing => 'Arriva presto';

  @override
  String get practiceHint => 'Da provare nella vita vera, con chi è con te';

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
  String get activityHelpButton => 'Aiuto';

  @override
  String get activityHelpPoint =>
      'Guarda l\'elemento colorato: può essere lui. Prova tu.';

  @override
  String get activityHelpDemo =>
      'Ti faccio vedere: guarda quello che si è acceso e toccalo piano. Ora prova tu.';

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
  String gameMemoryDescFood(Object count) {
    return '$count coppie animale e cibo: non si somigliano, vanno insieme.';
  }

  @override
  String gameMemoryDescHome(Object count) {
    return '$count terne animale, cibo e casa: tre carte per volta.';
  }

  @override
  String get memoryIntro => 'Trova le coppie di animali uguali.';

  @override
  String get memoryIntroFood =>
      'Trova chi mangia cosa: un animale e il suo cibo.';

  @override
  String get memoryIntroHome =>
      'Gira tre carte: un animale, il suo cibo e la sua casa.';

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
  String memoryItemName(String item) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'squirrel': 'lo scoiattolo',
        'penguin': 'il pinguino',
        'monkey': 'la scimmia',
        'rabbit': 'il coniglio',
        'bear': 'l\'orso',
        'panda': 'il panda',
        'chestnut': 'la castagna',
        'fish': 'il pesce',
        'banana': 'la banana',
        'carrot': 'la carota',
        'honey': 'il miele',
        'bamboo': 'il bambù',
        'tree': 'l\'albero',
        'ice': 'il ghiaccio',
        'palm': 'la palma',
        'burrow': 'la tana',
        'forest': 'il bosco',
        'mountain': 'la montagna',
        'other': '$item',
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
  String get gameShapesDescMid =>
      'Cinque forme, i buchi sono girati: la stessa forma in un\'altra posizione.';

  @override
  String get gameShapesDescBig =>
      'Sei forme girate, grandi e piccole: attenzione alla misura.';

  @override
  String get shapesIntro => 'Metti ogni forma nel suo buco.';

  @override
  String get shapesIntroTurned =>
      'Metti ogni forma nel suo buco. I buchi sono girati: guarda bene la forma.';

  @override
  String get shapesIntroBig =>
      'Metti ogni forma nel suo buco. I buchi sono girati, e ci sono forme grandi e piccole.';

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
  String get parentTabGrowth => 'Crescita';

  @override
  String get parentTabShelf => 'Mensola';

  @override
  String get parentHowUse => 'Come usate l\'app adesso?';

  @override
  String get parentHowUseHint =>
      'È una vostra dichiarazione, non una verifica: l\'app non sa se un adulto è davvero accanto. «Insieme» mostra le pause di dialogo per voi due e le storie da leggere con un adulto, senza limite di tempo. «Da solo» le nasconde (con le storie su sicurezza e corpo, se l\'avete scelto nel profilo) e applica il limite di tempo del profilo. «Insieme» vale per questa volta: all\'avvio dell\'app, quando cambia il bambino o dopo 30 minuti con l\'app chiusa si torna a «da solo».';

  @override
  String get parentPlace => 'Dove vivete';

  @override
  String get parentPlaceHint =>
      'Serve al calendario della natura: i suggerimenti seguono le stagioni di casa vostra.';

  @override
  String hemisphere(String place) {
    String _temp0 = intl.Intl.selectLogic(
      place,
      {
        'north': 'Emisfero nord',
        'south': 'Emisfero sud',
        'equator': 'Vicino all\'equatore',
        'other': '$place',
      },
    );
    return '$_temp0';
  }

  @override
  String get parentData => 'I tuoi dati';

  @override
  String get parentDataHint =>
      'Profili, diario e progressi restano su questo dispositivo, cifrati. Il backup su Google Drive qui sotto è facoltativo.';

  @override
  String get parentWipe => 'Elimina tutti i dati di Mirabò su questo tablet';

  @override
  String get parentWipeConfirmTitle => 'Eliminare tutto?';

  @override
  String get parentWipeConfirm =>
      'Profili e diario verranno cancellati da questo dispositivo. Non si può annullare. Un eventuale backup su Google Drive resta dov\'è.';

  @override
  String get parentWipeYes => 'Elimina';

  @override
  String get backupTitle => 'Backup su Google Drive';

  @override
  String get backupHint =>
      'Facoltativo. Il backup finisce in una cartella nascosta del tuo Drive, che l\'app non può usare per altro, ed è cifrato con una password che conosci solo tu. Serve per passare a un nuovo tablet o reinstallare l\'app senza perdere niente.';

  @override
  String get backupOff => 'Non attivo: i dati sono solo su questo tablet.';

  @override
  String backupOnAccount(String account) {
    return 'Attivo su $account';
  }

  @override
  String backupLast(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String get backupNever => 'Nessun backup ancora.';

  @override
  String get backupAutoFailed =>
      'L\'ultimo backup automatico non è riuscito. Prova con \"Fai il backup adesso\".';

  @override
  String get backupEnable => 'Attiva il backup';

  @override
  String get backupNow => 'Fai il backup adesso';

  @override
  String get backupRestore => 'Ripristina da Drive';

  @override
  String get backupDisable => 'Disattiva';

  @override
  String get backupPasswordTitle => 'Scegli la password del backup';

  @override
  String get backupPasswordHint =>
      'Il backup viene cifrato con questa password prima di lasciare il tablet. Ti servirà per ripristinarlo su un altro dispositivo: se la dimentichi il backup non si può recuperare, nemmeno da noi.';

  @override
  String get backupPassword => 'Password';

  @override
  String get backupPasswordRepeat => 'Ripeti la password';

  @override
  String backupPasswordShort(int n) {
    return 'Almeno $n caratteri.';
  }

  @override
  String get backupPasswordMismatch => 'Le due password non coincidono.';

  @override
  String get backupRestorePasswordTitle => 'Password del backup';

  @override
  String get backupRestorePasswordHint =>
      'La password scelta quando hai attivato il backup.';

  @override
  String get backupWrongPassword => 'Password errata.';

  @override
  String get backupNone =>
      'Su questo account Google non c\'è ancora un backup di Mirabò.';

  @override
  String get backupExistsTitle => 'C\'è già un backup';

  @override
  String get backupExists =>
      'Su questo account Google c\'è già un backup di Mirabò. Vuoi ripristinarlo su questo tablet, oppure sostituirlo con i dati di questo tablet?';

  @override
  String get backupExistsRestore => 'Ripristina';

  @override
  String get backupExistsReplace => 'Sostituisci';

  @override
  String get backupRestoreConfirmTitle => 'Ripristinare il backup?';

  @override
  String get backupRestoreConfirm =>
      'Profili, diario e progressi di questo tablet saranno sostituiti da quelli del backup.';

  @override
  String get backupDisableTitle => 'Disattivare il backup?';

  @override
  String get backupDisableConfirm =>
      'Il tablet smette di fare backup e dimentica l\'account. La copia su Drive puoi tenerla, per ripristinarla in futuro, o eliminarla.';

  @override
  String get backupDisableKeep => 'Disattiva e tieni la copia';

  @override
  String get backupDisableDelete => 'Disattiva ed elimina la copia';

  @override
  String get backupDone => 'Backup completato.';

  @override
  String get backupRestored => 'Backup ripristinato.';

  @override
  String get backupError =>
      'Non è riuscito. Controlla la connessione e riprova.';

  @override
  String get backupContinue => 'Continua';

  @override
  String get profileRestoreLink =>
      'Hai già usato Mirabò? Ripristina da Google Drive';

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
  String get diaryTogether => 'in modalità insieme';

  @override
  String get diaryAlone => 'in modalità da solo';

  @override
  String diaryChose(Object answer) {
    return 'alla pausa ha scelto: \"$answer\"';
  }

  @override
  String get gesturesTitle => 'Gesti nella vita vera';

  @override
  String gesturesIntro(String companion, String name) {
    return 'Il gesto di una storia si fa nella vita vera, quando capita. Se volete, segnatelo qui: resta nel diario di $name. Segnarlo non sblocca nulla e non cambia $companion: è solo un ricordo.';
  }

  @override
  String gesturesEmpty(String name) {
    return 'Qui compaiono i gesti delle storie che $name ha finito.';
  }

  @override
  String get gestureMark => 'Fatto oggi';

  @override
  String get gestureMarked => 'Segnato oggi';

  @override
  String gestureTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fatto $count volte',
      one: 'fatto 1 volta',
      zero: 'non ancora fatto',
    );
    return '$_temp0';
  }

  @override
  String get ideaTitle => 'Un\'idea per oggi';

  @override
  String ideaIntro(String name) {
    return 'Una cosa piccola da fare con $name, lontano dallo schermo. Cambia ogni giorno.';
  }

  @override
  String ideaFromStory(String story) {
    return 'Dalla storia «$story»';
  }

  @override
  String ideaHome(String title, String area) {
    return 'Da fare con le mani: $title ($area)';
  }

  @override
  String get ideaHomeHint =>
      'La presentazione passo per passo si trova tra le attività, nell\'area indicata qui sopra.';

  @override
  String ideaReasonRepeat(String name) {
    return '$name ha chiesto di rifarla';
  }

  @override
  String ideaReasonStory(String name, String story) {
    return '$name ha ascoltato «$story»';
  }

  @override
  String get ideaReasonTryAlone =>
      'L\'ha fatta con te: la prossima volta può provarci in autonomia';

  @override
  String ideaReasonCapacity(String name, String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': '$name ama stare con gli altri',
        'mani': '$name ama lavorare con le mani',
        'sensi': '$name ama esplorare con i sensi',
        'parole': '$name ama giocare con le parole',
        'pensare': '$name ama contare e ragionare',
        'mondo': '$name ama scoprire il mondo',
        'other': '$name lo sceglie spesso',
      },
    );
    return '$_temp0';
  }

  @override
  String get ideaAnother => 'Un\'altra idea';

  @override
  String ideaReasonNone(String name) {
    return 'Una presentazione adatta all\'età di $name';
  }

  @override
  String get ideaNeedsNothing => 'Occorrente: niente di particolare';

  @override
  String get ideaPrepNone => 'Preparazione: nessuna';

  @override
  String get ideaPrepQuick => 'Preparazione: circa 2 minuti';

  @override
  String get ideaPrepShort => 'Preparazione: circa 5 minuti';

  @override
  String ideaVariant(String text) {
    return 'Variante: $text';
  }

  @override
  String ideaVariantStory(String name) {
    return 'se oggi non è il momento, rimandate a domani; oppure lasciate che sia $name a guidare e a dirvi cosa fare.';
  }

  @override
  String get ideaVariantHome =>
      'dopo qualche giorno lasciate che la faccia da solo, senza ripresentarla.';

  @override
  String get ideaNoMaterials => 'Non abbiamo questi materiali';

  @override
  String get ideaNotInterested => 'Non ci interessa';

  @override
  String ideaEmpty(String name) {
    return 'Quando $name avrà finito una storia, qui troverai un\'idea da fare insieme.';
  }

  @override
  String weekTitle(String name) {
    return 'La settimana di $name';
  }

  @override
  String get weekIntro =>
      'Gli ultimi 7 giorni, raccontati. Niente voti: solo quello che è successo.';

  @override
  String weekStories(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ha ascoltato $count storie: $titles.',
      one: 'Ha ascoltato una storia: $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekAllTogether => 'Le ha ascoltate sempre in modalità «insieme».';

  @override
  String get weekAllAlone =>
      'Le ha ascoltate da solo: la prossima potete ascoltarla insieme.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together volte su $total in modalità «insieme».',
      one: 'Una volta su $total in modalità «insieme».',
    );
    return '$_temp0';
  }

  @override
  String weekChoice(String story, String answer) {
    return 'In «$story», alla pausa ha scelto: «$answer».';
  }

  @override
  String weekKeyPhrase(String phrase) {
    return 'Una frase da ripetere insieme: «$phrase»';
  }

  @override
  String weekGestures(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nella vita vera ha fatto $count gesti, delle storie $titles.',
      one: 'Nella vita vera ha fatto il gesto di $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekNoGestures =>
      'Nessun gesto segnato: se l\'avete fatto, segnalo qui sotto.';

  @override
  String weekHome(String titles) {
    return 'Con le mani, fuori dallo schermo: $titles.';
  }

  @override
  String get weekEmpty =>
      'Questa settimana nessuna storia e nessun gesto segnato. Va bene così: anche le settimane lontane dallo schermo contano.';

  @override
  String growthTitle(Object name) {
    return 'Cosa ha esplorato $name';
  }

  @override
  String get growthIntro =>
      'Un diario di ciò che ha scelto e ripreso negli ultimi 30 giorni, non una valutazione: tocchi, velocità e completamenti non dicono quanto sa fare. Nessun confronto, né con altri bambini né con un mese fa.';

  @override
  String get growthEmpty =>
      'Nessuna attività negli ultimi 30 giorni. Quando ne sceglierà qualcuna, qui vedrai i temi che ha esplorato.';

  @override
  String get growthOffscreen =>
      'Dove non c\'è miglioramento, prova l\'attività fuori dallo schermo suggerita nella scheda: non più tempo sull\'app.';

  @override
  String exploreTheme(String theme) {
    return 'Ha esplorato: $theme';
  }

  @override
  String exploreResumed(int days) {
    return 'L\'ha ripreso in $days giorni diversi.';
  }

  @override
  String get exploreOnce => 'L\'ha provato in un giorno.';

  @override
  String get exploreCreationsTitle => 'Storie che ha inventato e conservato';

  @override
  String get exploreCreationsEmpty =>
      'Ancora nessuna storia inventata nella fabbrica di storie.';

  @override
  String get exploreNotesTitle => 'Le tue osservazioni';

  @override
  String get exploreNotesHint =>
      'Qualcosa che hai notato: una domanda, un gioco, una frase...';

  @override
  String get exploreNotesAdd => 'Aggiungi';

  @override
  String get exploreNotesEmpty =>
      'Nessuna osservazione. Restano solo su questo dispositivo.';

  @override
  String get exploreNotesDelete => 'Elimina l\'osservazione';

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(
      skill,
      {
        'progetti_aperti': 'Piccoli progetti',
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
  String bandConfirmTitle(Object name, Object old) {
    return 'Le fasce d\'età sono cambiate: $name era in $old anni. In quale fascia è adesso?';
  }

  @override
  String bandConfirmHint(Object name) {
    return 'Finché non scegli, $name vede le stesse storie e gli stessi giochi di prima. Voce, testo e aiuti restano come li hai impostati.';
  }

  @override
  String profileBandToConfirm(Object old) {
    return 'Prima era $old anni: scegli la fascia di adesso.';
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
      'Si può cambiare quando volete: storie, disegni e progressi restano.';

  @override
  String get profileCompanionNewHint =>
      'Fate scegliere al bambino. Si potrà cambiare senza perdere niente.';

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

  @override
  String get lessonNaming => 'Questo è';

  @override
  String get lessonShow => 'Dov\'è?';

  @override
  String get lessonTell => 'Come si chiama?';

  @override
  String shelfTitle(Object name) {
    return 'La mensola di $name';
  }

  @override
  String shelfHint(String name, int max, int per) {
    return 'Pochi materiali alla volta, come sugli scaffali di un ambiente Montessori: $name sceglie liberamente tra quelli che metti qui. Al massimo $max in tutto e $per per capacità; cambiali quando li ha esplorati.';
  }

  @override
  String get shelfShortcutNote =>
      'La mensola è una scorciatoia: quello che non c\'è resta raggiungibile dai tre temi della casa, sempre.';

  @override
  String shelfCount(int count, int max) {
    return '$count di $max';
  }

  @override
  String get shelfAuto => 'Scelta automatica';

  @override
  String get shelfAutoOn =>
      'Ora la mensola si riempie da sola e cambia una volta a settimana.';

  @override
  String get shelfAutoHint =>
      'La mensola si riempie da sola e cambia una volta a settimana: resta ciò su cui il bambino lavora, il resto lascia il posto ad altro. Tocca un materiale per sceglierli tu.';

  @override
  String shelfFull(int max) {
    return 'Sulla mensola ci sono già $max materiali: togline uno per metterne un altro.';
  }

  @override
  String shelfCapacityFull(int max) {
    return 'Per questa capacità ci sono già $max materiali: togline uno per metterne un altro.';
  }

  @override
  String shelfTotal(int count, int max) {
    return 'Sulla mensola: $count di $max';
  }

  @override
  String get shelfRotateNow => 'Cambia adesso';

  @override
  String get shelfRotated => 'La mensola è cambiata.';

  @override
  String get shelfKindStory => 'Storia';

  @override
  String get shelfKindGame => 'Gioco';

  @override
  String get shelfKindActivity => 'Attività';

  @override
  String get gesturePause => 'Pausa: facciamo il gesto';

  @override
  String get gestureStart => 'Pronti? Via!';

  @override
  String get huntFound => 'L\'ho trovato!';

  @override
  String get huntNotFound => 'Non lo trovo';

  @override
  String get huntRest => 'Schermo a riposo';

  @override
  String get huntRestHint =>
      'Tocca lo schermo quando sei tornato. Se non ti va, va bene lo stesso.';

  @override
  String get huntTellMe => 'Che cosa hai trovato? Dillo a voce alta.';

  @override
  String get huntRules =>
      'il bambino cerca una cosa alla volta, in casa o all\'aperto con voi. Solo cose a portata di mano: niente da salire, niente di affilato o di fragile, niente medicine o detersivi. Fuori si prende solo ciò che è già caduto a terra. Alla fine si rimette tutto a posto.';

  @override
  String get catMake => 'Creo e scopro';

  @override
  String get factoryTitle => 'Fabbrica di storie';

  @override
  String get natureTitle => 'Calendario della natura';

  @override
  String factoryAsk(String step) {
    String _temp0 = intl.Intl.selectLogic(
      step,
      {
        'who': 'Chi è il protagonista?',
        'place': 'Dove vive?',
        'problem': 'Un giorno, cosa succede?',
        'feeling': 'Come si sente?',
        'helper': 'Chi arriva ad aiutare?',
        'ending': 'Come finisce?',
        'other': '$step',
      },
    );
    return '$_temp0';
  }

  @override
  String get factoryNameIt => 'Che titolo diamo alla storia?';

  @override
  String get factoryRead => 'Leggiamo la storia!';

  @override
  String get factoryMine => 'Le mie storie';

  @override
  String get factoryNew => 'Inventane una';

  @override
  String factoryBy(Object name) {
    return 'Una storia inventata da $name';
  }

  @override
  String get factoryEnd => 'Fine';

  @override
  String get factoryOtherEnding => 'Prova un altro finale';

  @override
  String factoryDone(Object name) {
    return 'Che bella storia, $name! La metto tra le tue storie.';
  }

  @override
  String get factoryMineEmpty => 'Qui troverai le storie che inventi.';

  @override
  String factoryWhoA(String who) {
    String _temp0 = intl.Intl.selectLogic(
      who,
      {
        'dragon': 'un piccolo drago',
        'bunny': 'un coniglietto',
        'robot': 'un robot gentile',
        'penguin': 'un pinguino',
        'unicorn': 'un unicorno',
        'kitten': 'un gattino',
        'other': '$who',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryWhoThe(String who) {
    String _temp0 = intl.Intl.selectLogic(
      who,
      {
        'dragon': 'il piccolo drago',
        'bunny': 'il coniglietto',
        'robot': 'il robot gentile',
        'penguin': 'il pinguino',
        'unicorn': 'l\'unicorno',
        'kitten': 'il gattino',
        'other': '$who',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryPlaceName(String place) {
    String _temp0 = intl.Intl.selectLogic(
      place,
      {
        'forest': 'il bosco',
        'room': 'la cameretta',
        'stream': 'il ruscello',
        'sky': 'le nuvole',
        'snow': 'la neve',
        'night': 'la notte',
        'other': '$place',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryPlaceIn(String place) {
    String _temp0 = intl.Intl.selectLogic(
      place,
      {
        'forest': 'in un bosco pieno di alberi',
        'room': 'in una cameretta piena di giochi',
        'stream': 'vicino a un ruscello',
        'sky': 'su una nuvola soffice',
        'snow': 'in un prato pieno di neve',
        'night': 'in un prato sotto le stelle',
        'other': '$place',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryProblemName(String problem) {
    String _temp0 = intl.Intl.selectLogic(
      problem,
      {
        'storm': 'il temporale',
        'star': 'la stellina caduta',
        'sadFriend': 'un amico triste',
        'litter': 'i rifiuti',
        'lost': 'la strada persa',
        'other': '$problem',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(
      problem,
      {
        'storm': 'arrivò un temporale fortissimo',
        'star': 'una stellina cadde dal cielo e non sapeva tornare a casa',
        'sadFriend': 'arrivò un amico tutto triste che non voleva parlare',
        'litter': 'qualcuno lasciò tanti rifiuti per terra',
        'lost': 'la nebbia nascose la strada di casa',
        'other': '$problem',
      },
    );
    return '$_temp0';
  }

  @override
  String factorySolution(String problem) {
    String _temp0 = intl.Intl.selectLogic(
      problem,
      {
        'storm':
            'trovarono un riparo asciutto e aspettarono che il temporale passasse',
        'star':
            'costruirono una scala altissima e riportarono la stellina in cielo',
        'sadFriend':
            'si sedettero vicino all\'amico e lo ascoltarono, finché tornò a sorridere',
        'litter':
            'raccolsero i rifiuti con i guanti e li misero nei bidoni giusti',
        'lost':
            'seguirono le impronte sul sentiero e ritrovarono la strada di casa',
        'other': '$problem',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryFeelingName(String feeling) {
    String _temp0 = intl.Intl.selectLogic(
      feeling,
      {
        'fear': 'la paura',
        'sadness': 'la tristezza',
        'anger': 'la rabbia',
        'curiosity': 'la curiosità',
        'courage': 'il coraggio',
        'other': '$feeling',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryFeeling(String feeling) {
    String _temp0 = intl.Intl.selectLogic(
      feeling,
      {
        'fear': 'un po\' di paura',
        'sadness': 'un po\' di tristezza',
        'anger': 'un po\' di rabbia',
        'curiosity': 'tanta curiosità',
        'courage': 'tanto coraggio',
        'other': '$feeling',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryHelperA(String helper) {
    String _temp0 = intl.Intl.selectLogic(
      helper,
      {
        'turtle': 'una tartaruga saggia',
        'owl': 'un gufo che sa tante cose',
        'bear': 'un orso gentile',
        'bee': 'un\'ape velocissima',
        'other': '$helper',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryEndingName(String ending) {
    String _temp0 = intl.Intl.selectLogic(
      ending,
      {
        'party': 'una festa',
        'sleep': 'la nanna',
        'hug': 'un abbraccio',
        'snack': 'una merenda',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryPageStart(Object who, Object place) {
    return 'C\'era una volta $who, che viveva $place.';
  }

  @override
  String factoryPageProblem(Object problem) {
    return 'Un giorno $problem.';
  }

  @override
  String factoryPageFeeling(Object who, Object feeling) {
    return '$who sentì $feeling e fece un bel respiro.';
  }

  @override
  String factoryPageHelp(Object helper, Object solution) {
    return 'Per fortuna arrivò $helper. Insieme $solution.';
  }

  @override
  String factoryEnding(String ending, Object who) {
    String _temp0 = intl.Intl.selectLogic(
      ending,
      {
        'party':
            'E quella sera $who fece una grande festa con tutti gli amici.',
        'sleep':
            'E quella sera $who si addormentò felice, sotto una coperta calda.',
        'hug': 'E alla fine $who abbracciò forte il suo nuovo amico.',
        'snack': 'E alla fine $who fece merenda con tutti, sotto il sole.',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureAskWeather => 'Che tempo fa?';

  @override
  String get natureAskSeen => 'Cosa hai visto fuori?';

  @override
  String get natureUpTo => 'Puoi sceglierne fino a tre.';

  @override
  String natureWeather(String weather) {
    String _temp0 = intl.Intl.selectLogic(
      weather,
      {
        'sun': 'Sole',
        'clouds': 'Nuvole',
        'rain': 'Pioggia',
        'snow': 'Neve',
        'wind': 'Vento',
        'fog': 'Nebbia',
        'other': '$weather',
      },
    );
    return '$_temp0';
  }

  @override
  String natureThing(String thing) {
    String _temp0 = intl.Intl.selectLogic(
      thing,
      {
        'leaf': 'Foglie',
        'flower': 'Fiori',
        'bird': 'Uccellini',
        'bug': 'Coccinelle e insetti',
        'snail': 'Lumache',
        'fruit': 'Frutti',
        'mushroom': 'Funghi',
        'rainbow': 'L\'arcobaleno',
        'moon': 'La luna',
        'other': '$thing',
      },
    );
    return '$_temp0';
  }

  @override
  String natureMonthTip(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        'm1':
            'Fa freddo e tanti alberi sono spogli. Riesci a vedere i nidi tra i rami?',
        'm2':
            'Le giornate si allungano un pochino. Cerca le prime gemme sui rami.',
        'm3':
            'Arriva la primavera: spuntano i primi fiori. Di che colore sono?',
        'm4':
            'Gli uccellini costruiscono i nidi. Ascolta: quanti canti diversi senti?',
        'm5':
            'Il prato è pieno di fiori e di api. Guardale da lontano: lavorano tanto!',
        'm6':
            'Sono i giorni più lunghi dell\'anno. Cosa vedi la sera, quando c\'è ancora luce?',
        'm7': 'Fa caldo: cerca l\'ombra degli alberi. Senti le cicale?',
        'm8':
            'Di notte, se il cielo è limpido, a volte cade una stella. Esprimi un desiderio!',
        'm9': 'Maturano tanti frutti: uva, mele, fichi. Quali conosci?',
        'm10':
            'Le foglie cambiano colore e cadono. Quanti colori diversi trovi?',
        'm11': 'Nel bosco spuntano i funghi. Si guardano, ma non si toccano!',
        'm12':
            'Sono i giorni più corti dell\'anno. Il bosco riposa, come nella storia di Emma.',
        'other': '$month',
      },
    );
    return '$_temp0';
  }

  @override
  String natureEquatorTip(String tip) {
    String _temp0 = intl.Intl.selectLogic(
      tip,
      {
        'e1': 'Quando sta per piovere, l\'aria cambia profumo. Lo senti?',
        'e2':
            'Dopo un acquazzone restano le pozzanghere. Cosa ci vedi riflesso?',
        'e3':
            'Nei giorni secchi la terra diventa dura e polverosa. Toccala: com\'è oggi?',
        'e4':
            'Con la pioggia le piante crescono in fretta. Trovi una foglia nuova, ancora chiara?',
        'e5':
            'Cerca una foglia grandissima e una piccolissima. Quanto sono diverse?',
        'e6': 'C\'è un albero con i fiori o con i frutti? Di che colore sono?',
        'e7':
            'Le formiche camminano in fila. Seguile con gli occhi: dove vanno?',
        'e8':
            'Dopo la pioggia a volte spunta l\'arcobaleno. Quanti colori riesci a contare?',
        'other': '$tip',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureThisMonth => 'Questo mese';

  @override
  String natureDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get natureEmptyMonth => 'Questo mese il calendario è ancora vuoto.';

  @override
  String get natureToday => 'Oggi';

  @override
  String get readWord => 'Tocca una parola per riascoltarla';

  @override
  String get profileReadAlong => 'Lettura karaoke';

  @override
  String get profileReadAlongHint =>
      'Mentre la voce legge, la parola si illumina; toccandola si riascolta.';

  @override
  String get parentTabPrint => 'Stampabili';

  @override
  String printIntro(Object name) {
    return 'Fogli da stampare e usare lontano dallo schermo, nella lingua di $name.';
  }

  @override
  String get printEveryday => 'Per tutti i giorni';

  @override
  String get printNameTrace => 'Ricalco il mio nome';

  @override
  String printNameTraceHint(Object name) {
    return 'Il nome di $name da ripassare con la matita.';
  }

  @override
  String get printNature => 'Calendario della natura del mese';

  @override
  String printNatureHint(Object name) {
    return 'La griglia del mese da riempire a mano, con quello che $name ha già segnato.';
  }

  @override
  String get printGestures => 'Gesti delle storie';

  @override
  String get printGestureHint =>
      'Il gesto, due settimane da colorare e lo spazio per disegnarlo.';

  @override
  String printGesturesEmpty(Object name) {
    return 'Qui compariranno i gesti delle storie che $name ha finito.';
  }

  @override
  String get printMade => 'Storie inventate';

  @override
  String get printMadeHint =>
      'Il libretto della storia, con lo spazio per i disegni.';

  @override
  String printMadeEmpty(Object name) {
    return 'Qui compariranno le storie che $name inventa nella fabbrica.';
  }

  @override
  String get printButton => 'Stampa';

  @override
  String get pdfDrawHere => 'Disegna qui';

  @override
  String get pdfGestureTimes => 'Ogni volta che lo fai, colora un cerchio.';

  @override
  String get pdfTraceName => 'Ripassa il tuo nome';

  @override
  String get pdfWeather => 'Tempo';

  @override
  String get pdfSeen => 'Ho visto';

  @override
  String get exitAsk => 'Vuoi uscire?';

  @override
  String get exitStay => 'Resto';

  @override
  String get exitLeave => 'Esco';

  @override
  String get profileInteraction => 'Come usa l\'app';

  @override
  String profileInteractionHint(Object name) {
    return 'Partono dall\'età: spostali se $name fa di più o di meno. L\'app non li cambia da sola.';
  }

  @override
  String get profileHands => 'Mani';

  @override
  String get profileHandsHint =>
      'Bottoni più grandi e tracciati più larghi per chi è all’inizio.';

  @override
  String get hands1 => 'Solo tocco';

  @override
  String get hands2 => 'Trascina';

  @override
  String get hands3 => 'Preciso';

  @override
  String get profileReading => 'Lettura';

  @override
  String get profileReadingHint =>
      'Niente testo (solo voce), solo la frase-chiave, testo con karaoke o testo pieno.';

  @override
  String get readingNone => 'Non legge';

  @override
  String get readingLetters => 'Lettere';

  @override
  String get readingWords => 'Parole';

  @override
  String get readingFluent => 'Legge bene';

  @override
  String get profileAutonomy => 'Autonomia';

  @override
  String get profileAutonomyHint =>
      'Quante scelte per volta, consegna ripetuta, conferma prima di uscire.';

  @override
  String get autonomy1 => 'Con aiuto';

  @override
  String get autonomy2 => 'Un po’ da solo';

  @override
  String get autonomy3 => 'Da solo';

  @override
  String adviceHands(String name, int n) {
    return 'Ti proponiamo i tracciati più fini perché nelle ultime $n attività $name ha tracciato le lettere al primo tentativo.';
  }

  @override
  String adviceReading(String name, int n) {
    return 'Ti proponiamo più testo perché nelle ultime $n attività $name ha composto le parole al primo tentativo.';
  }

  @override
  String adviceAutonomy(String name, int n) {
    return 'Ti proponiamo più scelte per volta perché nelle ultime $n attività $name ha risposto giusto al primo tentativo.';
  }

  @override
  String get adviceSwitchTitle => 'Proposte sul profilo di interazione';

  @override
  String get adviceSwitchHint =>
      'L’app guarda i round degli ultimi 7 giorni, solo su questo dispositivo, e ti suggerisce un passo. Se la spegni, non propone più nulla.';

  @override
  String get levelEasier => 'Più semplice';

  @override
  String get levelSame => 'Ancora così';

  @override
  String get levelHarder => 'Più sfida';

  @override
  String get adviceYes => 'Sì, proviamo';

  @override
  String get adviceNo => 'Non ora';

  @override
  String get sharedPromptGuide => 'Spiegami tu cosa fare';

  @override
  String get sharedPromptHelp => 'Come potremmo aiutare?';

  @override
  String get homeActivityHeading => 'Un\'attività dalla storia';

  @override
  String get homeActivitySteps => 'Cosa fa il bambino';

  @override
  String get homeActivityMaterials => 'Cosa serve';

  @override
  String get homeActivityPreparation => 'Preparazione';

  @override
  String get homeActivitySupervision => 'Supervisione';

  @override
  String get homeActivityAlternatives => 'Se manca qualcosa';

  @override
  String get supervisionTogether => 'Con il bambino, dall\'inizio alla fine';

  @override
  String get supervisionNearby => 'Un adulto vicino';

  @override
  String get supervisionFree => 'Il bambino può fare da solo';

  @override
  String get usageTitle => 'Tempo con lo schermo';

  @override
  String usageWeek(Object days, Object minutes) {
    return 'Ultimi 7 giorni, con lo schermo acceso: $minutes min in tutto, in $days giorni.';
  }

  @override
  String usageToday(Object minutes) {
    return 'Oggi: $minutes min.';
  }

  @override
  String usageGestures(Object count) {
    return 'Gesti segnati nel diario negli ultimi 7 giorni: $count. Sono cose fatte nella vita vera, a parte dallo schermo.';
  }

  @override
  String usageLimit(Object minutes) {
    return 'Nella modalità \"da solo\" il compagno saluta dopo circa $minutes min: prima si finisce con calma la storia o l\'attività aperta, quindi non è un blocco al secondo (si cambia nel profilo).';
  }

  @override
  String get usageCannot =>
      'Cosa l\'app non può misurare: quanto il bambino guarda davvero lo schermo, l\'ascolto a schermo spento, il tempo su altri dispositivi, ciò che fate insieme fuori dallo schermo. I minuti sono solo una parte: contano anche cosa guarda, con chi e come ne parlate.';

  @override
  String get projectPhaseIdea => 'L\'idea';

  @override
  String get projectPhasePrediction => 'La previsione';

  @override
  String get projectPhaseTest => 'La prova';

  @override
  String get projectPhaseRevision => 'La revisione';

  @override
  String get projectNoteHint => 'Se vuoi, scrivi due righe (facoltativo)';

  @override
  String get projectNext => 'Avanti';

  @override
  String get projectFinish => 'Ho finito';

  @override
  String get projectHeld => 'Ha retto';

  @override
  String get projectNotYet => 'Non ancora';

  @override
  String projectLogTitle(String name) {
    return 'I piccoli progetti di $name';
  }

  @override
  String get projectResultHeld => 'alla prova ha retto';

  @override
  String get projectResultNotYet =>
      'alla prova non ancora: si cambia e si riprova';

  @override
  String get profileNoLimit => 'Nessun limite';

  @override
  String get usageNoLimit =>
      'Nella modalità \"da solo\" non c\'è un limite di tempo (si imposta nel profilo).';

  @override
  String get winddownNote =>
      'Tra poco ci salutiamo. Finiamo con calma quello che stiamo facendo.';

  @override
  String get winddownHint =>
      'Poco prima della fine il compagno avvisa con calma e non propone cose nuove. Quello che è aperto si conclude, poi saluta: non è un blocco al secondo, può volerci qualche minuto in più.';

  @override
  String get gateSetupTitle => 'Scegli un PIN per i grandi';

  @override
  String get gateSetupBody =>
      'Da 4 a 6 cifre. Serve per entrare nell\'area adulta e per le operazioni delicate. Subito dopo ti diamo un codice di recupero da scrivere su un foglio: se dimentichi il PIN ne scegli uno nuovo senza perdere nulla.';

  @override
  String get gatePinLabel => 'PIN';

  @override
  String get gatePinConfirmLabel => 'Ripeti il PIN';

  @override
  String get gatePinMismatch => 'I due PIN non coincidono';

  @override
  String get gatePinFormat => 'Il PIN deve avere da 4 a 6 cifre';

  @override
  String get gatePinWrong => 'PIN sbagliato';

  @override
  String gatePinWait(String time) {
    return 'Troppi tentativi. Riprova tra $time';
  }

  @override
  String get gateForgot => 'Ho dimenticato il PIN';

  @override
  String get gateForgotUnavailable =>
      'Non riesco a verificare che sei un adulto con il blocco del dispositivo. Attiva un blocco schermo dell\'adulto e riprova.';

  @override
  String get gateDeviceReason =>
      'Conferma di essere un adulto per scegliere un nuovo PIN';

  @override
  String get gateChangePin => 'Cambia PIN';

  @override
  String get onbSkip => 'Salta';

  @override
  String get onbPromiseTitle =>
      'Storie da esplorare, giochi da capire, idee da provare insieme';

  @override
  String get onbPromiseBody =>
      'Mirabò è per bambini da 3 a 10 anni e per l\'adulto che gioca accanto a loro.';

  @override
  String get onbFactFree => 'Gratuita';

  @override
  String get onbFactOffline => 'Funziona offline: il cloud è una scelta tua';

  @override
  String get onbFactNoAds => 'Senza pubblicità';

  @override
  String get onbFactNoAccount => 'Nessun account per il bambino';

  @override
  String get onbSetupTitle => 'Lingua e fascia d\'età';

  @override
  String get onbSetupHint =>
      'Tutto il resto si regola dopo, dall\'area adulti.';

  @override
  String get onbTryTitle => 'Un assaggio di storia';

  @override
  String get onbTryNote =>
      'È solo un\'anteprima: la storia intera si apre insieme al bambino.';

  @override
  String get onbHomeTitle => 'Dalla storia alla vita vera';

  @override
  String get onbHomeIntro =>
      'Ogni storia può diventare un gesto concreto a casa. Per esempio:';

  @override
  String get onbGoTitle => 'Pronti a provare con tuo figlio?';

  @override
  String get onbGoBody =>
      'Bastano pochi secondi: un compagno, un soprannome se vuoi, la fascia d\'età. Niente data di nascita, niente iscrizione.';

  @override
  String get onbGoButton => 'Prova con tuo figlio';

  @override
  String get onbReopen => 'Rivedi la presentazione';

  @override
  String get onbReopenHint =>
      'Il percorso di benvenuto, con l\'assaggio di una storia.';

  @override
  String get onbClose => 'Chiudi';

  @override
  String get dataWipeTitle => 'Eliminare tutto da questo tablet?';

  @override
  String get dataWipeBody =>
      'Verranno cancellati per sempre profili, progressi, diario, creazioni e file generati (anche la voce del nome), insieme al database e alla sua chiave. Il tablet tornerà come al primo avvio. Non si può annullare. Un eventuale backup su Google Drive non viene toccato.';

  @override
  String dataWipeTypePrompt(String word) {
    return 'Per confermare scrivi $word';
  }

  @override
  String get dataWipeWord => 'ELIMINA';

  @override
  String get dataWipeDone =>
      'Tutti i dati di Mirabò sono stati eliminati da questo tablet.';

  @override
  String get dataWipeFailed =>
      'Non è stato possibile eliminare tutto. Riprova.';

  @override
  String get dataRemoteButton => 'Elimina anche il backup su Google Drive';

  @override
  String get dataRemoteTitle => 'Eliminare il backup su Drive?';

  @override
  String dataRemoteBody(String account) {
    return 'Il file di backup nel Drive di $account verrà cancellato, poi il tablet si scollega da Google e revoca il permesso dato all\'app. Serve internet. Non si può annullare. I dati su questo tablet restano.';
  }

  @override
  String get dataRemoteDone =>
      'Backup su Google Drive eliminato e account scollegato.';

  @override
  String get dataRemoteFailed =>
      'Il backup su Google Drive NON è stato eliminato (probabilmente manca la rete o serve un nuovo accesso a Google). Non è cambiato niente: collegati a internet e riprova.';

  @override
  String get dataOutsideTitle => 'Cosa resta fuori dal controllo dell\'app';

  @override
  String get dataOutsideBody =>
      'Mirabò non può cancellare le copie di sicurezza del sistema operativo (backup del telefono o del tablet su iCloud o Google), né i file che hai già esportato, stampato o condiviso. Per quelle: apri le impostazioni di iCloud o di Google del dispositivo ed elimina i vecchi backup, e togli a mano i file salvati o inviati. Se resta qualcosa sul tuo Drive, lo trovi e lo elimini in Drive › Impostazioni › Gestisci app.';

  @override
  String get gateRecoveryTitle => 'Il codice di recupero';

  @override
  String get gateRecoveryBody =>
      'Scrivilo su un foglio e tienilo lontano dal tablet: serve se dimentichi il PIN. Non lo mostreremo più.';

  @override
  String get gateRecoveryWritten => 'L\'ho scritto';

  @override
  String get gateRecoveryAsk =>
      'Scrivi il codice di recupero che ti abbiamo dato quando hai scelto il PIN.';

  @override
  String get gateRecoveryLabel => 'Codice di recupero';

  @override
  String get gateRecoveryWrong => 'Codice sbagliato';

  @override
  String get gateUseDevice => 'Usa il blocco del tablet';

  @override
  String get gateDeviceOff =>
      'Il recupero con il blocco del tablet è spento: serve il codice di recupero.';

  @override
  String get gateDeviceRecovery => 'Recupero del PIN con il blocco del tablet';

  @override
  String get gateDeviceRecoveryHint =>
      'Spegnilo se il bambino conosce il codice del tablet o ha la sua impronta registrata: allora il PIN si recupera solo con il codice di recupero.';

  @override
  String get gateNewRecovery => 'Nuovo codice di recupero';

  @override
  String gateResetNotice(String date, String how) {
    return 'Il PIN è stato reimpostato il $date $how. Se non sei stato tu, cambialo e spegni il recupero con il blocco del tablet.';
  }

  @override
  String get gateResetHowCode => 'con il codice di recupero';

  @override
  String get gateResetHowDevice => 'con il blocco del tablet';

  @override
  String get gateResetSeen => 'Ok';

  @override
  String get voiceMissingChild =>
      'La voce non c\'è: chiedi a un grande di leggere con te';

  @override
  String voiceMissingParent(String language) {
    return 'Su questo tablet manca la voce di sintesi per $language. Chi non legge ancora ha bisogno di un adulto che legga con lui: per ora il testo resta in vista. Installala dalle impostazioni del tablet (Sintesi vocale su Android, Contenuti letti ad alta voce su iPad). Le storie con l\'audio registrato si sentono lo stesso.';
  }
}
