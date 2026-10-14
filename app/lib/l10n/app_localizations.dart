import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Mirabò'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In it, this message translates to:
  /// **'Storie e piccoli passi per crescere.'**
  String get appTagline;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @next.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get next;

  /// No description provided for @done.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get done;

  /// No description provided for @finish.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get finish;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @listenAgain.
  ///
  /// In it, this message translates to:
  /// **'Riascolta'**
  String get listenAgain;

  /// No description provided for @readAgain.
  ///
  /// In it, this message translates to:
  /// **'Rileggi'**
  String get readAgain;

  /// No description provided for @seeYouTomorrow.
  ///
  /// In it, this message translates to:
  /// **'A domani!'**
  String get seeYouTomorrow;

  /// No description provided for @go.
  ///
  /// In it, this message translates to:
  /// **'Via!'**
  String get go;

  /// No description provided for @home.
  ///
  /// In it, this message translates to:
  /// **'Casa'**
  String get home;

  /// No description provided for @parentArea.
  ///
  /// In it, this message translates to:
  /// **'Area genitori'**
  String get parentArea;

  /// No description provided for @modeTogether.
  ///
  /// In it, this message translates to:
  /// **'Insieme'**
  String get modeTogether;

  /// No description provided for @modeAlone.
  ///
  /// In it, this message translates to:
  /// **'Da solo'**
  String get modeAlone;

  /// No description provided for @stepOf.
  ///
  /// In it, this message translates to:
  /// **'Passo {current} di {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @homeHello.
  ///
  /// In it, this message translates to:
  /// **'Ciao {name}!'**
  String homeHello(Object name);

  /// No description provided for @homeQuestion.
  ///
  /// In it, this message translates to:
  /// **'Cosa facciamo oggi?'**
  String get homeQuestion;

  /// No description provided for @homeOneStory.
  ///
  /// In it, this message translates to:
  /// **'Una storia'**
  String get homeOneStory;

  /// No description provided for @goodbyeTitle.
  ///
  /// In it, this message translates to:
  /// **'Per oggi basta, {name}!'**
  String goodbyeTitle(Object name);

  /// No description provided for @goodbyeBody.
  ///
  /// In it, this message translates to:
  /// **'È stato bello. Chiama un grande: ci vediamo la prossima volta!'**
  String get goodbyeBody;

  /// No description provided for @closingTitle.
  ///
  /// In it, this message translates to:
  /// **'Bel lavoro, {name}!'**
  String closingTitle(Object name);

  /// No description provided for @closingBody.
  ///
  /// In it, this message translates to:
  /// **'Hai fatto un bel pezzo di strada. Ora puoi posare il tablet: tutto resta com\'è, lo ritrovi quando vuoi.'**
  String get closingBody;

  /// No description provided for @closingBack.
  ///
  /// In it, this message translates to:
  /// **'Torna a casa'**
  String get closingBack;

  /// No description provided for @closingA11y.
  ///
  /// In it, this message translates to:
  /// **'Ho finito'**
  String get closingA11y;

  /// No description provided for @switchChildA11y.
  ///
  /// In it, this message translates to:
  /// **'Cambia bambino. Ora gioca {name}'**
  String switchChildA11y(Object name);

  /// No description provided for @chooseWhoPlays.
  ///
  /// In it, this message translates to:
  /// **'Chi gioca oggi?'**
  String get chooseWhoPlays;

  /// No description provided for @chooseWith.
  ///
  /// In it, this message translates to:
  /// **'con {companion}'**
  String chooseWith(Object companion);

  /// No description provided for @chooseAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get chooseAdd;

  /// No description provided for @chooseAddHint.
  ///
  /// In it, this message translates to:
  /// **'per i grandi'**
  String get chooseAddHint;

  /// No description provided for @chooseAddA11y.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un bambino'**
  String get chooseAddA11y;

  /// No description provided for @catEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui non c\'è niente per oggi.'**
  String get catEmpty;

  /// No description provided for @capacityLabel.
  ///
  /// In it, this message translates to:
  /// **'{capacity, select, insieme{Io e gli altri} mani{Le mani} sensi{I sensi} parole{Le parole} pensare{Contare e pensare} mondo{Il mondo} other{{capacity}}}'**
  String capacityLabel(String capacity);

  /// No description provided for @badgeAtHome.
  ///
  /// In it, this message translates to:
  /// **'A casa'**
  String get badgeAtHome;

  /// No description provided for @badgeTogether.
  ///
  /// In it, this message translates to:
  /// **'Insieme'**
  String get badgeTogether;

  /// No description provided for @areaLabel.
  ///
  /// In it, this message translates to:
  /// **'{area, select, cognitivo{Prerequisiti} autonomia{Autonomia} sociale{In classe} paure{Primo giorno} vitaPratica{Vita pratica} sensoriale{Sensoriale} linguaggio{Linguaggio e scrittura} matematica{Matematica} cultura{Cultura} other{{area}}}'**
  String areaLabel(String area);

  /// No description provided for @worldShort.
  ///
  /// In it, this message translates to:
  /// **'{world, select, emozioni{Emozioni} inclusione{Insieme} ambiente{Il bosco} sicurezza{Il mio corpo} other{{world}}}'**
  String worldShort(String world);

  /// No description provided for @worldLong.
  ///
  /// In it, this message translates to:
  /// **'{world, select, emozioni{Emozioni e conflitti} inclusione{Diversità e inclusione} ambiente{Ambiente e viventi} sicurezza{Sicurezza e corpo} other{{world}}}'**
  String worldLong(String world);

  /// No description provided for @storyKeyPhrase.
  ///
  /// In it, this message translates to:
  /// **'La frase da ricordare'**
  String get storyKeyPhrase;

  /// No description provided for @activityTryAgain.
  ///
  /// In it, this message translates to:
  /// **'Riprova.'**
  String get activityTryAgain;

  /// No description provided for @activityHelp.
  ///
  /// In it, this message translates to:
  /// **'Guarda bene. Ti aiuto io.'**
  String get activityHelp;

  /// No description provided for @activityHelpButton.
  ///
  /// In it, this message translates to:
  /// **'Aiuto'**
  String get activityHelpButton;

  /// No description provided for @activityHelpPoint.
  ///
  /// In it, this message translates to:
  /// **'Guarda l\'elemento colorato: può essere lui. Prova tu.'**
  String get activityHelpPoint;

  /// No description provided for @activityHelpDemo.
  ///
  /// In it, this message translates to:
  /// **'Ti faccio vedere: guarda quello che si è acceso e toccalo piano. Ora prova tu.'**
  String get activityHelpDemo;

  /// No description provided for @checklistPrompt.
  ///
  /// In it, this message translates to:
  /// **'Cosa è già pronto?'**
  String get checklistPrompt;

  /// No description provided for @checklistSay.
  ///
  /// In it, this message translates to:
  /// **'Cosa è già pronto per domani?'**
  String get checklistSay;

  /// No description provided for @checklistAlone.
  ///
  /// In it, this message translates to:
  /// **'da solo'**
  String get checklistAlone;

  /// No description provided for @checklistAllDone.
  ///
  /// In it, this message translates to:
  /// **'Tutto pronto, buonanotte'**
  String get checklistAllDone;

  /// No description provided for @enoughForToday.
  ///
  /// In it, this message translates to:
  /// **'Per oggi basta così'**
  String get enoughForToday;

  /// No description provided for @countdownPick.
  ///
  /// In it, this message translates to:
  /// **'Scegli la data'**
  String get countdownPick;

  /// No description provided for @countdownToday.
  ///
  /// In it, this message translates to:
  /// **'È oggi!'**
  String get countdownToday;

  /// No description provided for @countdownTodaySay.
  ///
  /// In it, this message translates to:
  /// **'Oggi è il giorno!'**
  String get countdownTodaySay;

  /// No description provided for @countdownDaysTo.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Manca 1 giorno a: {event}} other{Mancano {count} giorni a: {event}}}'**
  String countdownDaysTo(int count, String event);

  /// No description provided for @countdownDaysSay.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Manca 1 giorno. {task}} other{Mancano {count} giorni. {task}}}'**
  String countdownDaysSay(int count, String task);

  /// No description provided for @exploreTap.
  ///
  /// In it, this message translates to:
  /// **'{scene}: tocca per scoprire'**
  String exploreTap(Object scene);

  /// No description provided for @exploreSay.
  ///
  /// In it, this message translates to:
  /// **'Questa è {scene}. Tocca per scoprire.'**
  String exploreSay(Object scene);

  /// No description provided for @exploreAllSeen.
  ///
  /// In it, this message translates to:
  /// **'Ho visto tutto!'**
  String get exploreAllSeen;

  /// No description provided for @exploreEnough.
  ///
  /// In it, this message translates to:
  /// **'Per oggi basta'**
  String get exploreEnough;

  /// No description provided for @patternPrompt.
  ///
  /// In it, this message translates to:
  /// **'Cosa viene dopo?'**
  String get patternPrompt;

  /// No description provided for @presentationWhatYouNeed.
  ///
  /// In it, this message translates to:
  /// **'Cosa serve'**
  String get presentationWhatYouNeed;

  /// No description provided for @presentationWhatYouNeedSay.
  ///
  /// In it, this message translates to:
  /// **'Cosa serve: {items}'**
  String presentationWhatYouNeedSay(Object items);

  /// No description provided for @presentationReady.
  ///
  /// In it, this message translates to:
  /// **'Tutto pronto'**
  String get presentationReady;

  /// No description provided for @presentationPrepare.
  ///
  /// In it, this message translates to:
  /// **'Prepara tutto su un vassoio prima di chiamare il bambino. Mostra i passi una volta, lentamente e senza parlare; poi lascia fare.'**
  String get presentationPrepare;

  /// No description provided for @presentationStep.
  ///
  /// In it, this message translates to:
  /// **'Passo {current} di {total}'**
  String presentationStep(Object current, Object total);

  /// No description provided for @presentationWorkAlone.
  ///
  /// In it, this message translates to:
  /// **'Ora lavora da solo'**
  String get presentationWorkAlone;

  /// No description provided for @presentationYourTurnSay.
  ///
  /// In it, this message translates to:
  /// **'Adesso tocca a te, {name}. Il tablet lo mettiamo via.'**
  String presentationYourTurnSay(Object name);

  /// No description provided for @presentationHowDidItGo.
  ///
  /// In it, this message translates to:
  /// **'Per il grande: com\'è andata?'**
  String get presentationHowDidItGo;

  /// No description provided for @presentationControl.
  ///
  /// In it, this message translates to:
  /// **'Controllo dell\'errore'**
  String get presentationControl;

  /// No description provided for @presentationObserve.
  ///
  /// In it, this message translates to:
  /// **'Cosa osservare'**
  String get presentationObserve;

  /// No description provided for @presentationMarkLater.
  ///
  /// In it, this message translates to:
  /// **'Segna quando ha finito di lavorare, anche dopo un po\'. Non correggere mentre lavora.'**
  String get presentationMarkLater;

  /// No description provided for @presentationWatched.
  ///
  /// In it, this message translates to:
  /// **'Ha guardato'**
  String get presentationWatched;

  /// No description provided for @presentationDid.
  ///
  /// In it, this message translates to:
  /// **'L\'ha fatto'**
  String get presentationDid;

  /// No description provided for @presentationAlone.
  ///
  /// In it, this message translates to:
  /// **'Da solo'**
  String get presentationAlone;

  /// No description provided for @presentationRepeat.
  ///
  /// In it, this message translates to:
  /// **'Vuole rifarla'**
  String get presentationRepeat;

  /// No description provided for @forTheAdult.
  ///
  /// In it, this message translates to:
  /// **'Per il grande'**
  String get forTheAdult;

  /// No description provided for @turnYou.
  ///
  /// In it, this message translates to:
  /// **'Tocca a te, {name}'**
  String turnYou(Object name);

  /// No description provided for @turnAdult.
  ///
  /// In it, this message translates to:
  /// **'Tocca al grande'**
  String get turnAdult;

  /// No description provided for @spellSay.
  ///
  /// In it, this message translates to:
  /// **'Componi: {word}'**
  String spellSay(Object word);

  /// No description provided for @spellSentence.
  ///
  /// In it, this message translates to:
  /// **'Componi la frase'**
  String get spellSentence;

  /// No description provided for @spellWord.
  ///
  /// In it, this message translates to:
  /// **'Componi la parola'**
  String get spellWord;

  /// No description provided for @tracePrompt.
  ///
  /// In it, this message translates to:
  /// **'Traccia la {label} con il dito'**
  String tracePrompt(Object label);

  /// No description provided for @traceRestart.
  ///
  /// In it, this message translates to:
  /// **'Ricomincio'**
  String get traceRestart;

  /// No description provided for @gameWellDone.
  ///
  /// In it, this message translates to:
  /// **'Bravo, {name}!'**
  String gameWellDone(Object name);

  /// No description provided for @gameNiceGame.
  ///
  /// In it, this message translates to:
  /// **'Che bella partita.'**
  String get gameNiceGame;

  /// No description provided for @gameWellDoneSay.
  ///
  /// In it, this message translates to:
  /// **'Bravo, {name}! Che bella partita.'**
  String gameWellDoneSay(Object name);

  /// No description provided for @gameAgain.
  ///
  /// In it, this message translates to:
  /// **'Ancora'**
  String get gameAgain;

  /// No description provided for @gameEnough.
  ///
  /// In it, this message translates to:
  /// **'Basta così'**
  String get gameEnough;

  /// No description provided for @gameMemoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Memory degli animali'**
  String get gameMemoryTitle;

  /// No description provided for @gameMemoryDesc.
  ///
  /// In it, this message translates to:
  /// **'Trova le coppie: {count} coppie.'**
  String gameMemoryDesc(int count);

  /// No description provided for @memoryIntro.
  ///
  /// In it, this message translates to:
  /// **'Trova le coppie di animali uguali.'**
  String get memoryIntro;

  /// No description provided for @memoryCovered.
  ///
  /// In it, this message translates to:
  /// **'Carta coperta'**
  String get memoryCovered;

  /// No description provided for @animalName.
  ///
  /// In it, this message translates to:
  /// **'{animal, select, dog{il cane} cat{il gatto} rabbit{il coniglio} fox{la volpe} bear{l\'orso} panda{il panda} frog{la rana} monkey{la scimmia} lion{il leone} tiger{la tigre} cow{la mucca} pig{il maiale} other{{animal}}}'**
  String animalName(String animal);

  /// No description provided for @gameBalloonsTitle.
  ///
  /// In it, this message translates to:
  /// **'I palloncini'**
  String get gameBalloonsTitle;

  /// No description provided for @gameBalloonsDescSmall.
  ///
  /// In it, this message translates to:
  /// **'Scoppia i palloncini.'**
  String get gameBalloonsDescSmall;

  /// No description provided for @gameBalloonsDescMid.
  ///
  /// In it, this message translates to:
  /// **'Scoppia solo quelli del colore che dice il compagno.'**
  String get gameBalloonsDescMid;

  /// No description provided for @gameBalloonsDescBig.
  ///
  /// In it, this message translates to:
  /// **'Scoppia i numeri in ordine, da 1 a 10.'**
  String get gameBalloonsDescBig;

  /// No description provided for @balloonsPopAll.
  ///
  /// In it, this message translates to:
  /// **'Scoppia i palloncini!'**
  String get balloonsPopAll;

  /// No description provided for @balloonsPopColor.
  ///
  /// In it, this message translates to:
  /// **'Scoppia solo i palloncini {color, select, red{rossi} blue{blu} green{verdi} yellow{gialli} purple{viola} other{{color}}}.'**
  String balloonsPopColor(String color);

  /// No description provided for @balloonsNowColor.
  ///
  /// In it, this message translates to:
  /// **'Adesso i palloncini {color, select, red{rossi} blue{blu} green{verdi} yellow{gialli} purple{viola} other{{color}}}.'**
  String balloonsNowColor(String color);

  /// No description provided for @balloonsOnlyColor.
  ///
  /// In it, this message translates to:
  /// **'Solo quelli {color, select, red{rossi} blue{blu} green{verdi} yellow{gialli} purple{viola} other{{color}}}'**
  String balloonsOnlyColor(String color);

  /// No description provided for @balloonsNumbersStart.
  ///
  /// In it, this message translates to:
  /// **'Scoppia i numeri in ordine. Comincia dall\'uno.'**
  String get balloonsNumbersStart;

  /// No description provided for @balloonsNow.
  ///
  /// In it, this message translates to:
  /// **'Adesso il {n}.'**
  String balloonsNow(Object n);

  /// No description provided for @balloonsFind.
  ///
  /// In it, this message translates to:
  /// **'Trova il {n}'**
  String balloonsFind(Object n);

  /// No description provided for @balloonsWrongNumber.
  ///
  /// In it, this message translates to:
  /// **'Quello è il {got}. Cerca il {want}.'**
  String balloonsWrongNumber(Object got, Object want);

  /// No description provided for @balloonsDone.
  ///
  /// In it, this message translates to:
  /// **'Fatto!'**
  String get balloonsDone;

  /// No description provided for @balloonA11yNumber.
  ///
  /// In it, this message translates to:
  /// **'Palloncino {n}'**
  String balloonA11yNumber(Object n);

  /// No description provided for @balloonA11yColor.
  ///
  /// In it, this message translates to:
  /// **'Palloncino {color, select, red{rosso} blue{blu} green{verde} yellow{giallo} purple{viola} other{{color}}}'**
  String balloonA11yColor(String color);

  /// No description provided for @gameShapesTitle.
  ///
  /// In it, this message translates to:
  /// **'Le forme al loro posto'**
  String get gameShapesTitle;

  /// No description provided for @gameShapesDescSmall.
  ///
  /// In it, this message translates to:
  /// **'Tre forme da trascinare nel buco giusto.'**
  String get gameShapesDescSmall;

  /// No description provided for @gameShapesDescMid.
  ///
  /// In it, this message translates to:
  /// **'Cinque forme da trascinare nel buco giusto.'**
  String get gameShapesDescMid;

  /// No description provided for @gameShapesDescBig.
  ///
  /// In it, this message translates to:
  /// **'Sei forme, grandi e piccole: attenzione alla misura.'**
  String get gameShapesDescBig;

  /// No description provided for @shapesIntro.
  ///
  /// In it, this message translates to:
  /// **'Metti ogni forma nel suo buco.'**
  String get shapesIntro;

  /// No description provided for @shapesIntroBig.
  ///
  /// In it, this message translates to:
  /// **'Metti ogni forma nel suo buco. Attenzione alla misura: grandi e piccole.'**
  String get shapesIntroBig;

  /// No description provided for @shapesWrong.
  ///
  /// In it, this message translates to:
  /// **'Questo è {shape}. Prova un altro buco.'**
  String shapesWrong(Object shape);

  /// No description provided for @shapeName.
  ///
  /// In it, this message translates to:
  /// **'{shape, select, circle{il cerchio} square{il quadrato} triangle{il triangolo} star{la stella} heart{il cuore} hexagon{l\'esagono} circleSmall{il cerchio piccolo} squareSmall{il quadrato piccolo} other{{shape}}}'**
  String shapeName(String shape);

  /// No description provided for @gameDrawingTitle.
  ///
  /// In it, this message translates to:
  /// **'Disegna e colora'**
  String get gameDrawingTitle;

  /// No description provided for @gameDrawingDesc.
  ///
  /// In it, this message translates to:
  /// **'Un foglio bianco, i colori e i timbri.'**
  String get gameDrawingDesc;

  /// No description provided for @drawingIntro.
  ///
  /// In it, this message translates to:
  /// **'Scegli un colore e disegna con il dito.'**
  String get drawingIntro;

  /// No description provided for @drawingSheet.
  ///
  /// In it, this message translates to:
  /// **'Foglio da disegno'**
  String get drawingSheet;

  /// No description provided for @drawingEraser.
  ///
  /// In it, this message translates to:
  /// **'Gomma'**
  String get drawingEraser;

  /// No description provided for @drawingUndo.
  ///
  /// In it, this message translates to:
  /// **'Torna indietro'**
  String get drawingUndo;

  /// No description provided for @drawingNewSheet.
  ///
  /// In it, this message translates to:
  /// **'Foglio nuovo'**
  String get drawingNewSheet;

  /// No description provided for @gameXyloTitle.
  ///
  /// In it, this message translates to:
  /// **'Lo xilofono'**
  String get gameXyloTitle;

  /// No description provided for @gameXyloDescSmall.
  ///
  /// In it, this message translates to:
  /// **'Suona libero.'**
  String get gameXyloDescSmall;

  /// No description provided for @gameXyloDescBig.
  ///
  /// In it, this message translates to:
  /// **'Suona libero o impara \"{song}\".'**
  String gameXyloDescBig(Object song);

  /// No description provided for @xyloNotes.
  ///
  /// In it, this message translates to:
  /// **'do re mi fa sol la si do'**
  String get xyloNotes;

  /// No description provided for @xyloSong.
  ///
  /// In it, this message translates to:
  /// **'Fra Martino'**
  String get xyloSong;

  /// No description provided for @xyloIntro.
  ///
  /// In it, this message translates to:
  /// **'Tocca le barre e suona.'**
  String get xyloIntro;

  /// No description provided for @xyloIntroSong.
  ///
  /// In it, this message translates to:
  /// **'Suona quello che vuoi, oppure impara {song}.'**
  String xyloIntroSong(Object song);

  /// No description provided for @xyloFree.
  ///
  /// In it, this message translates to:
  /// **'Suona libero'**
  String get xyloFree;

  /// No description provided for @xyloFreeSay.
  ///
  /// In it, this message translates to:
  /// **'Suona quello che vuoi.'**
  String get xyloFreeSay;

  /// No description provided for @xyloSongSay.
  ///
  /// In it, this message translates to:
  /// **'Suona la barra che si illumina.'**
  String get xyloSongSay;

  /// No description provided for @xyloNoteA11y.
  ///
  /// In it, this message translates to:
  /// **'Nota {note}'**
  String xyloNoteA11y(Object note);

  /// No description provided for @gamePuzzleTitle.
  ///
  /// In it, this message translates to:
  /// **'Il gioco del 15'**
  String get gamePuzzleTitle;

  /// No description provided for @gamePuzzleDesc.
  ///
  /// In it, this message translates to:
  /// **'Rimetti in ordine i numeri da 1 a 8 facendo scorrere le tessere.'**
  String get gamePuzzleDesc;

  /// No description provided for @puzzleIntro.
  ///
  /// In it, this message translates to:
  /// **'Fai scorrere le tessere per metterle in ordine, da uno a otto.'**
  String get puzzleIntro;

  /// No description provided for @puzzleTileA11y.
  ///
  /// In it, this message translates to:
  /// **'Tessera {n}'**
  String puzzleTileA11y(Object n);

  /// No description provided for @gateTitle.
  ///
  /// In it, this message translates to:
  /// **'Area per i grandi'**
  String get gateTitle;

  /// No description provided for @gateQuestion.
  ///
  /// In it, this message translates to:
  /// **'Quanto fa {a} × {b}?'**
  String gateQuestion(Object a, Object b);

  /// No description provided for @gateWrong.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get gateWrong;

  /// No description provided for @gateEnter.
  ///
  /// In it, this message translates to:
  /// **'Entra'**
  String get gateEnter;

  /// No description provided for @parentTabSession.
  ///
  /// In it, this message translates to:
  /// **'Sessione'**
  String get parentTabSession;

  /// No description provided for @parentTabProfiles.
  ///
  /// In it, this message translates to:
  /// **'Profili'**
  String get parentTabProfiles;

  /// No description provided for @parentTabCards.
  ///
  /// In it, this message translates to:
  /// **'Come parlarne'**
  String get parentTabCards;

  /// No description provided for @parentTabDiary.
  ///
  /// In it, this message translates to:
  /// **'Diario'**
  String get parentTabDiary;

  /// No description provided for @parentTabGrowth.
  ///
  /// In it, this message translates to:
  /// **'Sviluppo'**
  String get parentTabGrowth;

  /// No description provided for @parentTabShelf.
  ///
  /// In it, this message translates to:
  /// **'Mensola'**
  String get parentTabShelf;

  /// No description provided for @parentHowUse.
  ///
  /// In it, this message translates to:
  /// **'Come usate l\'app adesso?'**
  String get parentHowUse;

  /// No description provided for @parentHowUseHint.
  ///
  /// In it, this message translates to:
  /// **'In modalità \"insieme\" compaiono le pause di dialogo per voi due. In modalità \"da solo\" il bambino risponde toccando e le storie su sicurezza e corpo restano nascoste.'**
  String get parentHowUseHint;

  /// No description provided for @parentPlace.
  ///
  /// In it, this message translates to:
  /// **'Dove vivete'**
  String get parentPlace;

  /// No description provided for @parentPlaceHint.
  ///
  /// In it, this message translates to:
  /// **'Serve al calendario della natura: i suggerimenti seguono le stagioni di casa vostra.'**
  String get parentPlaceHint;

  /// No description provided for @hemisphere.
  ///
  /// In it, this message translates to:
  /// **'{place, select, north{Emisfero nord} south{Emisfero sud} equator{Vicino all\'equatore} other{{place}}}'**
  String hemisphere(String place);

  /// No description provided for @parentData.
  ///
  /// In it, this message translates to:
  /// **'I tuoi dati'**
  String get parentData;

  /// No description provided for @parentDataHint.
  ///
  /// In it, this message translates to:
  /// **'Profili, diario e progressi restano su questo dispositivo, cifrati. Il backup su Google Drive qui sotto è facoltativo.'**
  String get parentDataHint;

  /// No description provided for @parentWipe.
  ///
  /// In it, this message translates to:
  /// **'Elimina tutti i dati di Mirabò su questo tablet'**
  String get parentWipe;

  /// No description provided for @parentWipeConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare tutto?'**
  String get parentWipeConfirmTitle;

  /// No description provided for @parentWipeConfirm.
  ///
  /// In it, this message translates to:
  /// **'Profili e diario verranno cancellati da questo dispositivo. Non si può annullare. Un eventuale backup su Google Drive resta dov\'è.'**
  String get parentWipeConfirm;

  /// No description provided for @parentWipeYes.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get parentWipeYes;

  /// No description provided for @backupTitle.
  ///
  /// In it, this message translates to:
  /// **'Backup su Google Drive'**
  String get backupTitle;

  /// No description provided for @backupHint.
  ///
  /// In it, this message translates to:
  /// **'Facoltativo. Il backup finisce in una cartella nascosta del tuo Drive, che l\'app non può usare per altro, ed è cifrato con una password che conosci solo tu. Serve per passare a un nuovo tablet o reinstallare l\'app senza perdere niente.'**
  String get backupHint;

  /// No description provided for @backupOff.
  ///
  /// In it, this message translates to:
  /// **'Non attivo: i dati sono solo su questo tablet.'**
  String get backupOff;

  /// No description provided for @backupOnAccount.
  ///
  /// In it, this message translates to:
  /// **'Attivo su {account}'**
  String backupOnAccount(String account);

  /// No description provided for @backupLast.
  ///
  /// In it, this message translates to:
  /// **'Ultimo backup: {date}'**
  String backupLast(String date);

  /// No description provided for @backupNever.
  ///
  /// In it, this message translates to:
  /// **'Nessun backup ancora.'**
  String get backupNever;

  /// No description provided for @backupAutoFailed.
  ///
  /// In it, this message translates to:
  /// **'L\'ultimo backup automatico non è riuscito. Prova con \"Fai il backup adesso\".'**
  String get backupAutoFailed;

  /// No description provided for @backupEnable.
  ///
  /// In it, this message translates to:
  /// **'Attiva il backup'**
  String get backupEnable;

  /// No description provided for @backupNow.
  ///
  /// In it, this message translates to:
  /// **'Fai il backup adesso'**
  String get backupNow;

  /// No description provided for @backupRestore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina da Drive'**
  String get backupRestore;

  /// No description provided for @backupDisable.
  ///
  /// In it, this message translates to:
  /// **'Disattiva'**
  String get backupDisable;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli la password del backup'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordHint.
  ///
  /// In it, this message translates to:
  /// **'Il backup viene cifrato con questa password prima di lasciare il tablet. Ti servirà per ripristinarlo su un altro dispositivo: se la dimentichi il backup non si può recuperare, nemmeno da noi.'**
  String get backupPasswordHint;

  /// No description provided for @backupPassword.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get backupPassword;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In it, this message translates to:
  /// **'Ripeti la password'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordShort.
  ///
  /// In it, this message translates to:
  /// **'Almeno {n} caratteri.'**
  String backupPasswordShort(int n);

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le due password non coincidono.'**
  String get backupPasswordMismatch;

  /// No description provided for @backupRestorePasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Password del backup'**
  String get backupRestorePasswordTitle;

  /// No description provided for @backupRestorePasswordHint.
  ///
  /// In it, this message translates to:
  /// **'La password scelta quando hai attivato il backup.'**
  String get backupRestorePasswordHint;

  /// No description provided for @backupWrongPassword.
  ///
  /// In it, this message translates to:
  /// **'Password errata.'**
  String get backupWrongPassword;

  /// No description provided for @backupNone.
  ///
  /// In it, this message translates to:
  /// **'Su questo account Google non c\'è ancora un backup di Mirabò.'**
  String get backupNone;

  /// No description provided for @backupExistsTitle.
  ///
  /// In it, this message translates to:
  /// **'C\'è già un backup'**
  String get backupExistsTitle;

  /// No description provided for @backupExists.
  ///
  /// In it, this message translates to:
  /// **'Su questo account Google c\'è già un backup di Mirabò. Vuoi ripristinarlo su questo tablet, oppure sostituirlo con i dati di questo tablet?'**
  String get backupExists;

  /// No description provided for @backupExistsRestore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get backupExistsRestore;

  /// No description provided for @backupExistsReplace.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci'**
  String get backupExistsReplace;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristinare il backup?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In it, this message translates to:
  /// **'Profili, diario e progressi di questo tablet saranno sostituiti da quelli del backup.'**
  String get backupRestoreConfirm;

  /// No description provided for @backupDisableTitle.
  ///
  /// In it, this message translates to:
  /// **'Disattivare il backup?'**
  String get backupDisableTitle;

  /// No description provided for @backupDisableConfirm.
  ///
  /// In it, this message translates to:
  /// **'Il tablet smette di fare backup e dimentica l\'account. La copia su Drive puoi tenerla, per ripristinarla in futuro, o eliminarla.'**
  String get backupDisableConfirm;

  /// No description provided for @backupDisableKeep.
  ///
  /// In it, this message translates to:
  /// **'Disattiva e tieni la copia'**
  String get backupDisableKeep;

  /// No description provided for @backupDisableDelete.
  ///
  /// In it, this message translates to:
  /// **'Disattiva ed elimina la copia'**
  String get backupDisableDelete;

  /// No description provided for @backupDone.
  ///
  /// In it, this message translates to:
  /// **'Backup completato.'**
  String get backupDone;

  /// No description provided for @backupRestored.
  ///
  /// In it, this message translates to:
  /// **'Backup ripristinato.'**
  String get backupRestored;

  /// No description provided for @backupError.
  ///
  /// In it, this message translates to:
  /// **'Non è riuscito. Controlla la connessione e riprova.'**
  String get backupError;

  /// No description provided for @backupContinue.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get backupContinue;

  /// No description provided for @profileRestoreLink.
  ///
  /// In it, this message translates to:
  /// **'Hai già usato Mirabò? Ripristina da Google Drive'**
  String get profileRestoreLink;

  /// No description provided for @parentNewProfile.
  ///
  /// In it, this message translates to:
  /// **'Nuovo profilo'**
  String get parentNewProfile;

  /// No description provided for @parentProfileLine.
  ///
  /// In it, this message translates to:
  /// **'{age} · compagno {companion} · {count, plural, =1{1 storia} other{{count} storie}}'**
  String parentProfileLine(String age, String companion, int count);

  /// No description provided for @diaryEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna storia negli ultimi 30 giorni.'**
  String get diaryEmpty;

  /// No description provided for @diaryTogether.
  ///
  /// In it, this message translates to:
  /// **'insieme'**
  String get diaryTogether;

  /// No description provided for @diaryAlone.
  ///
  /// In it, this message translates to:
  /// **'da solo'**
  String get diaryAlone;

  /// No description provided for @diaryChose.
  ///
  /// In it, this message translates to:
  /// **'alla pausa ha scelto: \"{answer}\"'**
  String diaryChose(Object answer);

  /// No description provided for @gesturesTitle.
  ///
  /// In it, this message translates to:
  /// **'Gesti nella vita vera'**
  String get gesturesTitle;

  /// No description provided for @gesturesIntro.
  ///
  /// In it, this message translates to:
  /// **'{companion} cresce solo quando {name} fa davvero il gesto di una storia, non con il tempo passato sull\'app. Quando l\'avete fatto, segnalo qui.'**
  String gesturesIntro(String companion, String name);

  /// No description provided for @gesturesNext.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Manca 1 gesto} other{Mancano {count} gesti}} alla prossima tappa di {companion}.'**
  String gesturesNext(int count, String companion);

  /// No description provided for @gesturesAllGrown.
  ///
  /// In it, this message translates to:
  /// **'{companion} ha raggiunto l\'ultima tappa: i gesti restano belli da fare.'**
  String gesturesAllGrown(String companion);

  /// No description provided for @gesturesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui compaiono i gesti delle storie che {name} ha finito.'**
  String gesturesEmpty(String name);

  /// No description provided for @gestureMark.
  ///
  /// In it, this message translates to:
  /// **'Fatto oggi'**
  String get gestureMark;

  /// No description provided for @gestureMarked.
  ///
  /// In it, this message translates to:
  /// **'Segnato oggi'**
  String get gestureMarked;

  /// No description provided for @gestureTimes.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{non ancora fatto} =1{fatto 1 volta} other{fatto {count} volte}}'**
  String gestureTimes(int count);

  /// No description provided for @ideaTitle.
  ///
  /// In it, this message translates to:
  /// **'Un\'idea per oggi'**
  String get ideaTitle;

  /// No description provided for @ideaIntro.
  ///
  /// In it, this message translates to:
  /// **'Una cosa piccola da fare con {name}, lontano dallo schermo. Cambia ogni giorno.'**
  String ideaIntro(String name);

  /// No description provided for @ideaFromStory.
  ///
  /// In it, this message translates to:
  /// **'Dalla storia «{story}»'**
  String ideaFromStory(String story);

  /// No description provided for @ideaHome.
  ///
  /// In it, this message translates to:
  /// **'Da fare con le mani: {title} ({area})'**
  String ideaHome(String title, String area);

  /// No description provided for @ideaHomeHint.
  ///
  /// In it, this message translates to:
  /// **'La presentazione passo per passo è tra le attività Montessori.'**
  String get ideaHomeHint;

  /// No description provided for @ideaReasonRepeat.
  ///
  /// In it, this message translates to:
  /// **'{name} ha chiesto di rifarla'**
  String ideaReasonRepeat(String name);

  /// No description provided for @ideaReasonStory.
  ///
  /// In it, this message translates to:
  /// **'{name} ha ascoltato «{story}»'**
  String ideaReasonStory(String name, String story);

  /// No description provided for @ideaReasonTryAlone.
  ///
  /// In it, this message translates to:
  /// **'L\'ha fatta con te: la prossima volta può provarci in autonomia'**
  String get ideaReasonTryAlone;

  /// No description provided for @ideaReasonCapacity.
  ///
  /// In it, this message translates to:
  /// **'{capacity, select, insieme{{name} ama stare con gli altri} mani{{name} ama lavorare con le mani} sensi{{name} ama esplorare con i sensi} parole{{name} ama giocare con le parole} pensare{{name} ama contare e ragionare} mondo{{name} ama scoprire il mondo} other{{name} lo sceglie spesso}}'**
  String ideaReasonCapacity(String name, String capacity);

  /// No description provided for @ideaAnother.
  ///
  /// In it, this message translates to:
  /// **'Un\'altra idea'**
  String get ideaAnother;

  /// No description provided for @ideaReasonNone.
  ///
  /// In it, this message translates to:
  /// **'Una presentazione adatta all\'età di {name}'**
  String ideaReasonNone(String name);

  /// No description provided for @ideaNeedsNothing.
  ///
  /// In it, this message translates to:
  /// **'Occorrente: niente di particolare'**
  String get ideaNeedsNothing;

  /// No description provided for @ideaPrepNone.
  ///
  /// In it, this message translates to:
  /// **'Preparazione: nessuna'**
  String get ideaPrepNone;

  /// No description provided for @ideaPrepQuick.
  ///
  /// In it, this message translates to:
  /// **'Preparazione: circa 2 minuti'**
  String get ideaPrepQuick;

  /// No description provided for @ideaPrepShort.
  ///
  /// In it, this message translates to:
  /// **'Preparazione: circa 5 minuti'**
  String get ideaPrepShort;

  /// No description provided for @ideaVariant.
  ///
  /// In it, this message translates to:
  /// **'Variante: {text}'**
  String ideaVariant(String text);

  /// No description provided for @ideaVariantStory.
  ///
  /// In it, this message translates to:
  /// **'se oggi non è il momento, rimandate a domani; oppure lasciate che sia {name} a guidare e a dirvi cosa fare.'**
  String ideaVariantStory(String name);

  /// No description provided for @ideaVariantHome.
  ///
  /// In it, this message translates to:
  /// **'dopo qualche giorno lasciate che la faccia da solo, senza ripresentarla.'**
  String get ideaVariantHome;

  /// No description provided for @ideaNoMaterials.
  ///
  /// In it, this message translates to:
  /// **'Non abbiamo questi materiali'**
  String get ideaNoMaterials;

  /// No description provided for @ideaNotInterested.
  ///
  /// In it, this message translates to:
  /// **'Non ci interessa'**
  String get ideaNotInterested;

  /// No description provided for @ideaEmpty.
  ///
  /// In it, this message translates to:
  /// **'Quando {name} avrà finito una storia, qui troverai un\'idea da fare insieme.'**
  String ideaEmpty(String name);

  /// No description provided for @weekTitle.
  ///
  /// In it, this message translates to:
  /// **'La settimana di {name}'**
  String weekTitle(String name);

  /// No description provided for @weekIntro.
  ///
  /// In it, this message translates to:
  /// **'Gli ultimi 7 giorni, raccontati. Niente voti: solo quello che è successo.'**
  String get weekIntro;

  /// No description provided for @weekStories.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Ha ascoltato una storia: {titles}.} other{Ha ascoltato {count} storie: {titles}.}}'**
  String weekStories(int count, String titles);

  /// No description provided for @weekAllTogether.
  ///
  /// In it, this message translates to:
  /// **'Le avete ascoltate sempre insieme.'**
  String get weekAllTogether;

  /// No description provided for @weekAllAlone.
  ///
  /// In it, this message translates to:
  /// **'Le ha ascoltate da solo: la prossima potete ascoltarla insieme.'**
  String get weekAllAlone;

  /// No description provided for @weekTogether.
  ///
  /// In it, this message translates to:
  /// **'{together, plural, =1{Una volta su {total} eravate insieme.} other{{together} volte su {total} eravate insieme.}}'**
  String weekTogether(int together, int total);

  /// No description provided for @weekChoice.
  ///
  /// In it, this message translates to:
  /// **'In «{story}», alla pausa ha scelto: «{answer}».'**
  String weekChoice(String story, String answer);

  /// No description provided for @weekKeyPhrase.
  ///
  /// In it, this message translates to:
  /// **'Una frase da ripetere insieme: «{phrase}»'**
  String weekKeyPhrase(String phrase);

  /// No description provided for @weekGestures.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Nella vita vera ha fatto il gesto di {titles}.} other{Nella vita vera ha fatto {count} gesti, delle storie {titles}.}}'**
  String weekGestures(int count, String titles);

  /// No description provided for @weekNoGestures.
  ///
  /// In it, this message translates to:
  /// **'Nessun gesto segnato: se l\'avete fatto, segnalo qui sotto.'**
  String get weekNoGestures;

  /// No description provided for @weekHome.
  ///
  /// In it, this message translates to:
  /// **'Con le mani, fuori dallo schermo: {titles}.'**
  String weekHome(String titles);

  /// No description provided for @weekEmpty.
  ///
  /// In it, this message translates to:
  /// **'Questa settimana nessuna storia e nessun gesto segnato. Va bene così: anche le settimane lontane dallo schermo contano.'**
  String get weekEmpty;

  /// No description provided for @growthTitle.
  ///
  /// In it, this message translates to:
  /// **'Cosa ha esplorato {name}'**
  String growthTitle(Object name);

  /// No description provided for @growthIntro.
  ///
  /// In it, this message translates to:
  /// **'Un diario di ciò che ha scelto e ripreso negli ultimi 30 giorni, non una valutazione: tocchi, velocità e completamenti non dicono quanto sa fare. Nessun confronto, né con altri bambini né con un mese fa.'**
  String get growthIntro;

  /// No description provided for @growthEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna attività negli ultimi 30 giorni. Quando ne sceglierà qualcuna, qui vedrai i temi che ha esplorato.'**
  String get growthEmpty;

  /// No description provided for @growthOffscreen.
  ///
  /// In it, this message translates to:
  /// **'Dove non c\'è miglioramento, prova l\'attività fuori dallo schermo suggerita nella scheda: non più tempo sull\'app.'**
  String get growthOffscreen;

  /// No description provided for @exploreTheme.
  ///
  /// In it, this message translates to:
  /// **'Ha esplorato: {theme}'**
  String exploreTheme(String theme);

  /// No description provided for @exploreResumed.
  ///
  /// In it, this message translates to:
  /// **'L\'ha ripreso in {days} giorni diversi.'**
  String exploreResumed(int days);

  /// No description provided for @exploreOnce.
  ///
  /// In it, this message translates to:
  /// **'L\'ha provato in un giorno.'**
  String get exploreOnce;

  /// No description provided for @exploreCreationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Storie che ha inventato e conservato'**
  String get exploreCreationsTitle;

  /// No description provided for @exploreCreationsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessuna storia inventata nella fabbrica di storie.'**
  String get exploreCreationsEmpty;

  /// No description provided for @exploreNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Le tue osservazioni'**
  String get exploreNotesTitle;

  /// No description provided for @exploreNotesHint.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa che hai notato: una domanda, un gioco, una frase...'**
  String get exploreNotesHint;

  /// No description provided for @exploreNotesAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get exploreNotesAdd;

  /// No description provided for @exploreNotesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna osservazione. Restano solo su questo dispositivo.'**
  String get exploreNotesEmpty;

  /// No description provided for @exploreNotesDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina l\'osservazione'**
  String get exploreNotesDelete;

  /// No description provided for @skillLabel.
  ///
  /// In it, this message translates to:
  /// **'{skill, select, progetti_aperti{Piccoli progetti} suoni_iniziali{Suoni e lettere} pregrafismo{Tracciare lettere} numeri{Numeri e quantità} logica{Logica e sequenze} routine_sera{Preparare le cose per domani} routine_mattino{La routine del mattino} vestirsi{Vestirsi da solo} mensa{A mensa} turno_e_condivisione{Aspettare il turno e condividere} chiedere_aiuto{Chiedere aiuto} distacco{Il saluto del mattino} conoscere_la_scuola{Conoscere la scuola} primo_giorno{Il primo giorno} travasi{Travasi e versare} motricita_fine{Motricità fine} cura_ambiente{Cura dell\'ambiente} dimensioni{Grandezze e seriazione} colori{Colori} forme{Forme} tatto{Tatto} udito{Udito} scrittura{Scrittura} vocabolario{Vocabolario} decine{Decine e unità} geografia{Geografia} botanica{Botanica} other{{skill}}}'**
  String skillLabel(String skill);

  /// No description provided for @profileWelcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuti in Mirabò'**
  String get profileWelcome;

  /// No description provided for @profileEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica profilo'**
  String get profileEdit;

  /// No description provided for @profileNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo profilo'**
  String get profileNew;

  /// No description provided for @profileChild.
  ///
  /// In it, this message translates to:
  /// **'Il bambino'**
  String get profileChild;

  /// No description provided for @profileFirstRunHint.
  ///
  /// In it, this message translates to:
  /// **'Questa parte la compila un adulto. Ci vuole un minuto, poi il tablet passa al bambino.'**
  String get profileFirstRunHint;

  /// No description provided for @profileName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get profileName;

  /// No description provided for @profileNameHint.
  ///
  /// In it, this message translates to:
  /// **'Il compagno lo chiamerà così'**
  String get profileNameHint;

  /// No description provided for @profileAge.
  ///
  /// In it, this message translates to:
  /// **'Età'**
  String get profileAge;

  /// No description provided for @profileYears.
  ///
  /// In it, this message translates to:
  /// **'{range} anni'**
  String profileYears(Object range);

  /// No description provided for @ageBandLabel.
  ///
  /// In it, this message translates to:
  /// **'{band, select, small{Piccoli} mid{Primi passi} big{Grandi} other{{band}}}'**
  String ageBandLabel(String band);

  /// No description provided for @profileLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get profileLanguage;

  /// No description provided for @profileLanguageHint.
  ///
  /// In it, this message translates to:
  /// **'Storie, attività, giochi e voce del compagno saranno in questa lingua.'**
  String get profileLanguageHint;

  /// No description provided for @profileCompanion.
  ///
  /// In it, this message translates to:
  /// **'Il compagno'**
  String get profileCompanion;

  /// No description provided for @profileCompanionEditHint.
  ///
  /// In it, this message translates to:
  /// **'Il compagno si sceglie una volta sola: è il suo migliore amico.'**
  String get profileCompanionEditHint;

  /// No description provided for @profileCompanionNewHint.
  ///
  /// In it, this message translates to:
  /// **'Fate scegliere al bambino. Si sceglie una volta sola e non si cambia.'**
  String get profileCompanionNewHint;

  /// No description provided for @profileWorlds.
  ///
  /// In it, this message translates to:
  /// **'Mondi delle storie'**
  String get profileWorlds;

  /// No description provided for @profileWorldsHint.
  ///
  /// In it, this message translates to:
  /// **'Scegliete i temi che il bambino troverà nella sua libreria.'**
  String get profileWorldsHint;

  /// No description provided for @profileSafetyTogether.
  ///
  /// In it, this message translates to:
  /// **'\"Il mio corpo\" solo in modalità insieme'**
  String get profileSafetyTogether;

  /// No description provided for @profileSafetyTogetherHint.
  ///
  /// In it, this message translates to:
  /// **'Consigliato: le storie su sicurezza e corpo si leggono con un adulto.'**
  String get profileSafetyTogetherHint;

  /// No description provided for @profileAccess.
  ///
  /// In it, this message translates to:
  /// **'Accessibilità e tempo'**
  String get profileAccess;

  /// No description provided for @profileDyslexia.
  ///
  /// In it, this message translates to:
  /// **'Testo ad alta leggibilità'**
  String get profileDyslexia;

  /// No description provided for @profileDyslexiaHint.
  ///
  /// In it, this message translates to:
  /// **'Carattere Lexend, spaziatura e interlinea maggiori.'**
  String get profileDyslexiaHint;

  /// No description provided for @profileLowStim.
  ///
  /// In it, this message translates to:
  /// **'Bassa stimolazione'**
  String get profileLowStim;

  /// No description provided for @profileLowStimHint.
  ///
  /// In it, this message translates to:
  /// **'Colori tenui, nessuna animazione.'**
  String get profileLowStimHint;

  /// No description provided for @profileAloneSession.
  ///
  /// In it, this message translates to:
  /// **'Sessione \"da solo\"'**
  String get profileAloneSession;

  /// No description provided for @profileMinutes.
  ///
  /// In it, this message translates to:
  /// **'{count} minuti'**
  String profileMinutes(Object count);

  /// No description provided for @profileMinutesShort.
  ///
  /// In it, this message translates to:
  /// **'{count} min'**
  String profileMinutesShort(Object count);

  /// No description provided for @profileDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina questo profilo'**
  String get profileDelete;

  /// No description provided for @profileMissingName.
  ///
  /// In it, this message translates to:
  /// **'Manca il nome'**
  String get profileMissingName;

  /// No description provided for @profileMissingCompanion.
  ///
  /// In it, this message translates to:
  /// **'Manca il compagno'**
  String get profileMissingCompanion;

  /// No description provided for @profileStart.
  ///
  /// In it, this message translates to:
  /// **'Iniziamo'**
  String get profileStart;

  /// No description provided for @translationDraft.
  ///
  /// In it, this message translates to:
  /// **'Traduzione in revisione'**
  String get translationDraft;

  /// No description provided for @lessonNaming.
  ///
  /// In it, this message translates to:
  /// **'Questo è'**
  String get lessonNaming;

  /// No description provided for @lessonShow.
  ///
  /// In it, this message translates to:
  /// **'Dov\'è?'**
  String get lessonShow;

  /// No description provided for @lessonTell.
  ///
  /// In it, this message translates to:
  /// **'Come si chiama?'**
  String get lessonTell;

  /// No description provided for @shelfTitle.
  ///
  /// In it, this message translates to:
  /// **'La mensola di {name}'**
  String shelfTitle(Object name);

  /// No description provided for @shelfHint.
  ///
  /// In it, this message translates to:
  /// **'Pochi materiali alla volta, come sugli scaffali di un ambiente Montessori: {name} sceglie liberamente tra quelli che metti qui. Al massimo {max} in tutto e {per} per capacità; cambiali quando li ha esplorati.'**
  String shelfHint(String name, int max, int per);

  /// No description provided for @shelfCount.
  ///
  /// In it, this message translates to:
  /// **'{count} di {max}'**
  String shelfCount(int count, int max);

  /// No description provided for @shelfAuto.
  ///
  /// In it, this message translates to:
  /// **'Scelta automatica'**
  String get shelfAuto;

  /// No description provided for @shelfAutoOn.
  ///
  /// In it, this message translates to:
  /// **'Ora la mensola si riempie da sola e cambia una volta a settimana.'**
  String get shelfAutoOn;

  /// No description provided for @shelfAutoHint.
  ///
  /// In it, this message translates to:
  /// **'La mensola si riempie da sola e cambia una volta a settimana: resta ciò su cui il bambino lavora, il resto lascia il posto ad altro. Tocca un materiale per sceglierli tu.'**
  String get shelfAutoHint;

  /// No description provided for @shelfFull.
  ///
  /// In it, this message translates to:
  /// **'Sulla mensola ci sono già {max} materiali: togline uno per metterne un altro.'**
  String shelfFull(int max);

  /// No description provided for @shelfCapacityFull.
  ///
  /// In it, this message translates to:
  /// **'Per questa capacità ci sono già {max} materiali: togline uno per metterne un altro.'**
  String shelfCapacityFull(int max);

  /// No description provided for @shelfTotal.
  ///
  /// In it, this message translates to:
  /// **'Sulla mensola: {count} di {max}'**
  String shelfTotal(int count, int max);

  /// No description provided for @shelfRotateNow.
  ///
  /// In it, this message translates to:
  /// **'Cambia adesso'**
  String get shelfRotateNow;

  /// No description provided for @shelfRotated.
  ///
  /// In it, this message translates to:
  /// **'La mensola è cambiata.'**
  String get shelfRotated;

  /// No description provided for @shelfKindStory.
  ///
  /// In it, this message translates to:
  /// **'Storia'**
  String get shelfKindStory;

  /// No description provided for @shelfKindGame.
  ///
  /// In it, this message translates to:
  /// **'Gioco'**
  String get shelfKindGame;

  /// No description provided for @shelfKindActivity.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get shelfKindActivity;

  /// No description provided for @gesturePause.
  ///
  /// In it, this message translates to:
  /// **'Pausa: facciamo il gesto'**
  String get gesturePause;

  /// No description provided for @gestureStart.
  ///
  /// In it, this message translates to:
  /// **'Pronti? Via!'**
  String get gestureStart;

  /// No description provided for @huntFound.
  ///
  /// In it, this message translates to:
  /// **'L\'ho trovato!'**
  String get huntFound;

  /// No description provided for @huntNotFound.
  ///
  /// In it, this message translates to:
  /// **'Non lo trovo'**
  String get huntNotFound;

  /// No description provided for @huntRest.
  ///
  /// In it, this message translates to:
  /// **'Schermo a riposo'**
  String get huntRest;

  /// No description provided for @huntRestHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca lo schermo quando sei tornato. Se non ti va, va bene lo stesso.'**
  String get huntRestHint;

  /// No description provided for @huntTellMe.
  ///
  /// In it, this message translates to:
  /// **'Che cosa hai trovato? Dillo a voce alta.'**
  String get huntTellMe;

  /// No description provided for @huntRules.
  ///
  /// In it, this message translates to:
  /// **'il bambino cerca una cosa alla volta, in casa o all\'aperto con voi. Solo cose a portata di mano: niente da salire, niente di affilato o di fragile, niente medicine o detersivi. Fuori si prende solo ciò che è già caduto a terra. Alla fine si rimette tutto a posto.'**
  String get huntRules;

  /// No description provided for @catMake.
  ///
  /// In it, this message translates to:
  /// **'Creo e scopro'**
  String get catMake;

  /// No description provided for @factoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Fabbrica di storie'**
  String get factoryTitle;

  /// No description provided for @natureTitle.
  ///
  /// In it, this message translates to:
  /// **'Calendario della natura'**
  String get natureTitle;

  /// No description provided for @factoryAsk.
  ///
  /// In it, this message translates to:
  /// **'{step, select, who{Chi è il protagonista?} place{Dove vive?} problem{Un giorno, cosa succede?} feeling{Come si sente?} helper{Chi arriva ad aiutare?} ending{Come finisce?} other{{step}}}'**
  String factoryAsk(String step);

  /// No description provided for @factoryNameIt.
  ///
  /// In it, this message translates to:
  /// **'Che titolo diamo alla storia?'**
  String get factoryNameIt;

  /// No description provided for @factoryRead.
  ///
  /// In it, this message translates to:
  /// **'Leggiamo la storia!'**
  String get factoryRead;

  /// No description provided for @factoryMine.
  ///
  /// In it, this message translates to:
  /// **'Le mie storie'**
  String get factoryMine;

  /// No description provided for @factoryNew.
  ///
  /// In it, this message translates to:
  /// **'Inventane una'**
  String get factoryNew;

  /// No description provided for @factoryBy.
  ///
  /// In it, this message translates to:
  /// **'Una storia inventata da {name}'**
  String factoryBy(Object name);

  /// No description provided for @factoryEnd.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get factoryEnd;

  /// No description provided for @factoryOtherEnding.
  ///
  /// In it, this message translates to:
  /// **'Prova un altro finale'**
  String get factoryOtherEnding;

  /// No description provided for @factoryDone.
  ///
  /// In it, this message translates to:
  /// **'Che bella storia, {name}! La metto tra le tue storie.'**
  String factoryDone(Object name);

  /// No description provided for @factoryMineEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui troverai le storie che inventi.'**
  String get factoryMineEmpty;

  /// No description provided for @factoryWhoA.
  ///
  /// In it, this message translates to:
  /// **'{who, select, dragon{un piccolo drago} bunny{un coniglietto} robot{un robot gentile} penguin{un pinguino} unicorn{un unicorno} kitten{un gattino} other{{who}}}'**
  String factoryWhoA(String who);

  /// No description provided for @factoryWhoThe.
  ///
  /// In it, this message translates to:
  /// **'{who, select, dragon{il piccolo drago} bunny{il coniglietto} robot{il robot gentile} penguin{il pinguino} unicorn{l\'unicorno} kitten{il gattino} other{{who}}}'**
  String factoryWhoThe(String who);

  /// No description provided for @factoryPlaceName.
  ///
  /// In it, this message translates to:
  /// **'{place, select, forest{il bosco} room{la cameretta} stream{il ruscello} sky{le nuvole} snow{la neve} night{la notte} other{{place}}}'**
  String factoryPlaceName(String place);

  /// No description provided for @factoryPlaceIn.
  ///
  /// In it, this message translates to:
  /// **'{place, select, forest{in un bosco pieno di alberi} room{in una cameretta piena di giochi} stream{vicino a un ruscello} sky{su una nuvola soffice} snow{in un prato pieno di neve} night{in un prato sotto le stelle} other{{place}}}'**
  String factoryPlaceIn(String place);

  /// No description provided for @factoryProblemName.
  ///
  /// In it, this message translates to:
  /// **'{problem, select, storm{il temporale} star{la stellina caduta} sadFriend{un amico triste} litter{i rifiuti} lost{la strada persa} other{{problem}}}'**
  String factoryProblemName(String problem);

  /// No description provided for @factoryProblem.
  ///
  /// In it, this message translates to:
  /// **'{problem, select, storm{arrivò un temporale fortissimo} star{una stellina cadde dal cielo e non sapeva tornare a casa} sadFriend{arrivò un amico tutto triste che non voleva parlare} litter{qualcuno lasciò tanti rifiuti per terra} lost{la nebbia nascose la strada di casa} other{{problem}}}'**
  String factoryProblem(String problem);

  /// No description provided for @factorySolution.
  ///
  /// In it, this message translates to:
  /// **'{problem, select, storm{trovarono un riparo asciutto e aspettarono che il temporale passasse} star{costruirono una scala altissima e riportarono la stellina in cielo} sadFriend{si sedettero vicino all\'amico e lo ascoltarono, finché tornò a sorridere} litter{raccolsero i rifiuti con i guanti e li misero nei bidoni giusti} lost{seguirono le impronte sul sentiero e ritrovarono la strada di casa} other{{problem}}}'**
  String factorySolution(String problem);

  /// No description provided for @factoryFeelingName.
  ///
  /// In it, this message translates to:
  /// **'{feeling, select, fear{la paura} sadness{la tristezza} anger{la rabbia} curiosity{la curiosità} courage{il coraggio} other{{feeling}}}'**
  String factoryFeelingName(String feeling);

  /// No description provided for @factoryFeeling.
  ///
  /// In it, this message translates to:
  /// **'{feeling, select, fear{un po\' di paura} sadness{un po\' di tristezza} anger{un po\' di rabbia} curiosity{tanta curiosità} courage{tanto coraggio} other{{feeling}}}'**
  String factoryFeeling(String feeling);

  /// No description provided for @factoryHelperA.
  ///
  /// In it, this message translates to:
  /// **'{helper, select, turtle{una tartaruga saggia} owl{un gufo che sa tante cose} bear{un orso gentile} bee{un\'ape velocissima} other{{helper}}}'**
  String factoryHelperA(String helper);

  /// No description provided for @factoryEndingName.
  ///
  /// In it, this message translates to:
  /// **'{ending, select, party{una festa} sleep{la nanna} hug{un abbraccio} snack{una merenda} other{{ending}}}'**
  String factoryEndingName(String ending);

  /// No description provided for @factoryPageStart.
  ///
  /// In it, this message translates to:
  /// **'C\'era una volta {who}, che viveva {place}.'**
  String factoryPageStart(Object who, Object place);

  /// No description provided for @factoryPageProblem.
  ///
  /// In it, this message translates to:
  /// **'Un giorno {problem}.'**
  String factoryPageProblem(Object problem);

  /// No description provided for @factoryPageFeeling.
  ///
  /// In it, this message translates to:
  /// **'{who} sentì {feeling} e fece un bel respiro.'**
  String factoryPageFeeling(Object who, Object feeling);

  /// No description provided for @factoryPageHelp.
  ///
  /// In it, this message translates to:
  /// **'Per fortuna arrivò {helper}. Insieme {solution}.'**
  String factoryPageHelp(Object helper, Object solution);

  /// No description provided for @factoryEnding.
  ///
  /// In it, this message translates to:
  /// **'{ending, select, party{E quella sera {who} fece una grande festa con tutti gli amici.} sleep{E quella sera {who} si addormentò felice, sotto una coperta calda.} hug{E alla fine {who} abbracciò forte il suo nuovo amico.} snack{E alla fine {who} fece merenda con tutti, sotto il sole.} other{{ending}}}'**
  String factoryEnding(String ending, Object who);

  /// No description provided for @natureAskWeather.
  ///
  /// In it, this message translates to:
  /// **'Che tempo fa?'**
  String get natureAskWeather;

  /// No description provided for @natureAskSeen.
  ///
  /// In it, this message translates to:
  /// **'Cosa hai visto fuori?'**
  String get natureAskSeen;

  /// No description provided for @natureUpTo.
  ///
  /// In it, this message translates to:
  /// **'Puoi sceglierne fino a tre.'**
  String get natureUpTo;

  /// No description provided for @natureWeather.
  ///
  /// In it, this message translates to:
  /// **'{weather, select, sun{Sole} clouds{Nuvole} rain{Pioggia} snow{Neve} wind{Vento} fog{Nebbia} other{{weather}}}'**
  String natureWeather(String weather);

  /// No description provided for @natureThing.
  ///
  /// In it, this message translates to:
  /// **'{thing, select, leaf{Foglie} flower{Fiori} bird{Uccellini} bug{Coccinelle e insetti} snail{Lumache} fruit{Frutti} mushroom{Funghi} rainbow{L\'arcobaleno} moon{La luna} other{{thing}}}'**
  String natureThing(String thing);

  /// No description provided for @natureMonthTip.
  ///
  /// In it, this message translates to:
  /// **'{month, select, m1{Fa freddo e tanti alberi sono spogli. Riesci a vedere i nidi tra i rami?} m2{Le giornate si allungano un pochino. Cerca le prime gemme sui rami.} m3{Arriva la primavera: spuntano i primi fiori. Di che colore sono?} m4{Gli uccellini costruiscono i nidi. Ascolta: quanti canti diversi senti?} m5{Il prato è pieno di fiori e di api. Guardale da lontano: lavorano tanto!} m6{Sono i giorni più lunghi dell\'anno. Cosa vedi la sera, quando c\'è ancora luce?} m7{Fa caldo: cerca l\'ombra degli alberi. Senti le cicale?} m8{Di notte, se il cielo è limpido, a volte cade una stella. Esprimi un desiderio!} m9{Maturano tanti frutti: uva, mele, fichi. Quali conosci?} m10{Le foglie cambiano colore e cadono. Quanti colori diversi trovi?} m11{Nel bosco spuntano i funghi. Si guardano, ma non si toccano!} m12{Sono i giorni più corti dell\'anno. Il bosco riposa, come nella storia di Emma.} other{{month}}}'**
  String natureMonthTip(String month);

  /// No description provided for @natureEquatorTip.
  ///
  /// In it, this message translates to:
  /// **'{tip, select, e1{Quando sta per piovere, l\'aria cambia profumo. Lo senti?} e2{Dopo un acquazzone restano le pozzanghere. Cosa ci vedi riflesso?} e3{Nei giorni secchi la terra diventa dura e polverosa. Toccala: com\'è oggi?} e4{Con la pioggia le piante crescono in fretta. Trovi una foglia nuova, ancora chiara?} e5{Cerca una foglia grandissima e una piccolissima. Quanto sono diverse?} e6{C\'è un albero con i fiori o con i frutti? Di che colore sono?} e7{Le formiche camminano in fila. Seguile con gli occhi: dove vanno?} e8{Dopo la pioggia a volte spunta l\'arcobaleno. Quanti colori riesci a contare?} other{{tip}}}'**
  String natureEquatorTip(String tip);

  /// No description provided for @natureThisMonth.
  ///
  /// In it, this message translates to:
  /// **'Questo mese'**
  String get natureThisMonth;

  /// No description provided for @natureDays.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 giorno} other{{count} giorni}}'**
  String natureDays(int count);

  /// No description provided for @natureEmptyMonth.
  ///
  /// In it, this message translates to:
  /// **'Questo mese il calendario è ancora vuoto.'**
  String get natureEmptyMonth;

  /// No description provided for @natureToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get natureToday;

  /// No description provided for @readWord.
  ///
  /// In it, this message translates to:
  /// **'Tocca una parola per riascoltarla'**
  String get readWord;

  /// No description provided for @profileReadAlong.
  ///
  /// In it, this message translates to:
  /// **'Lettura karaoke'**
  String get profileReadAlong;

  /// No description provided for @profileReadAlongHint.
  ///
  /// In it, this message translates to:
  /// **'Mentre la voce legge, la parola si illumina; toccandola si riascolta.'**
  String get profileReadAlongHint;

  /// No description provided for @parentTabPrint.
  ///
  /// In it, this message translates to:
  /// **'Stampabili'**
  String get parentTabPrint;

  /// No description provided for @printIntro.
  ///
  /// In it, this message translates to:
  /// **'Fogli da stampare e usare lontano dallo schermo, nella lingua di {name}.'**
  String printIntro(Object name);

  /// No description provided for @printEveryday.
  ///
  /// In it, this message translates to:
  /// **'Per tutti i giorni'**
  String get printEveryday;

  /// No description provided for @printNameTrace.
  ///
  /// In it, this message translates to:
  /// **'Ricalco il mio nome'**
  String get printNameTrace;

  /// No description provided for @printNameTraceHint.
  ///
  /// In it, this message translates to:
  /// **'Il nome di {name} da ripassare con la matita.'**
  String printNameTraceHint(Object name);

  /// No description provided for @printNature.
  ///
  /// In it, this message translates to:
  /// **'Calendario della natura del mese'**
  String get printNature;

  /// No description provided for @printNatureHint.
  ///
  /// In it, this message translates to:
  /// **'La griglia del mese da riempire a mano, con quello che {name} ha già segnato.'**
  String printNatureHint(Object name);

  /// No description provided for @printGestures.
  ///
  /// In it, this message translates to:
  /// **'Gesti delle storie'**
  String get printGestures;

  /// No description provided for @printGestureHint.
  ///
  /// In it, this message translates to:
  /// **'Il gesto, due settimane da colorare e lo spazio per disegnarlo.'**
  String get printGestureHint;

  /// No description provided for @printGesturesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui compariranno i gesti delle storie che {name} ha finito.'**
  String printGesturesEmpty(Object name);

  /// No description provided for @printMade.
  ///
  /// In it, this message translates to:
  /// **'Storie inventate'**
  String get printMade;

  /// No description provided for @printMadeHint.
  ///
  /// In it, this message translates to:
  /// **'Il libretto della storia, con lo spazio per i disegni.'**
  String get printMadeHint;

  /// No description provided for @printMadeEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui compariranno le storie che {name} inventa nella fabbrica.'**
  String printMadeEmpty(Object name);

  /// No description provided for @printButton.
  ///
  /// In it, this message translates to:
  /// **'Stampa'**
  String get printButton;

  /// No description provided for @pdfDrawHere.
  ///
  /// In it, this message translates to:
  /// **'Disegna qui'**
  String get pdfDrawHere;

  /// No description provided for @pdfGestureTimes.
  ///
  /// In it, this message translates to:
  /// **'Ogni volta che lo fai, colora un cerchio.'**
  String get pdfGestureTimes;

  /// No description provided for @pdfTraceName.
  ///
  /// In it, this message translates to:
  /// **'Ripassa il tuo nome'**
  String get pdfTraceName;

  /// No description provided for @pdfWeather.
  ///
  /// In it, this message translates to:
  /// **'Tempo'**
  String get pdfWeather;

  /// No description provided for @pdfSeen.
  ///
  /// In it, this message translates to:
  /// **'Ho visto'**
  String get pdfSeen;

  /// No description provided for @exitAsk.
  ///
  /// In it, this message translates to:
  /// **'Vuoi uscire?'**
  String get exitAsk;

  /// No description provided for @exitStay.
  ///
  /// In it, this message translates to:
  /// **'Resto'**
  String get exitStay;

  /// No description provided for @exitLeave.
  ///
  /// In it, this message translates to:
  /// **'Esco'**
  String get exitLeave;

  /// No description provided for @profileInteraction.
  ///
  /// In it, this message translates to:
  /// **'Come usa l\'app'**
  String get profileInteraction;

  /// No description provided for @profileInteractionHint.
  ///
  /// In it, this message translates to:
  /// **'Partono dall\'età: spostali se {name} fa di più o di meno. L\'app non li cambia da sola.'**
  String profileInteractionHint(Object name);

  /// No description provided for @profileHands.
  ///
  /// In it, this message translates to:
  /// **'Mani'**
  String get profileHands;

  /// No description provided for @profileHandsHint.
  ///
  /// In it, this message translates to:
  /// **'Bottoni più grandi e tracciati più larghi per chi è all’inizio.'**
  String get profileHandsHint;

  /// No description provided for @hands1.
  ///
  /// In it, this message translates to:
  /// **'Solo tocco'**
  String get hands1;

  /// No description provided for @hands2.
  ///
  /// In it, this message translates to:
  /// **'Trascina'**
  String get hands2;

  /// No description provided for @hands3.
  ///
  /// In it, this message translates to:
  /// **'Preciso'**
  String get hands3;

  /// No description provided for @profileReading.
  ///
  /// In it, this message translates to:
  /// **'Lettura'**
  String get profileReading;

  /// No description provided for @profileReadingHint.
  ///
  /// In it, this message translates to:
  /// **'Niente testo (solo voce), solo la frase-chiave, testo con karaoke o testo pieno.'**
  String get profileReadingHint;

  /// No description provided for @readingNone.
  ///
  /// In it, this message translates to:
  /// **'Non legge'**
  String get readingNone;

  /// No description provided for @readingLetters.
  ///
  /// In it, this message translates to:
  /// **'Lettere'**
  String get readingLetters;

  /// No description provided for @readingWords.
  ///
  /// In it, this message translates to:
  /// **'Parole'**
  String get readingWords;

  /// No description provided for @readingFluent.
  ///
  /// In it, this message translates to:
  /// **'Legge bene'**
  String get readingFluent;

  /// No description provided for @profileAutonomy.
  ///
  /// In it, this message translates to:
  /// **'Autonomia'**
  String get profileAutonomy;

  /// No description provided for @profileAutonomyHint.
  ///
  /// In it, this message translates to:
  /// **'Quante scelte per volta, consegna ripetuta, conferma prima di uscire.'**
  String get profileAutonomyHint;

  /// No description provided for @autonomy1.
  ///
  /// In it, this message translates to:
  /// **'Con aiuto'**
  String get autonomy1;

  /// No description provided for @autonomy2.
  ///
  /// In it, this message translates to:
  /// **'Un po’ da solo'**
  String get autonomy2;

  /// No description provided for @autonomy3.
  ///
  /// In it, this message translates to:
  /// **'Da solo'**
  String get autonomy3;

  /// No description provided for @adviceHands.
  ///
  /// In it, this message translates to:
  /// **'Ti proponiamo i tracciati più fini perché nelle ultime {n} attività {name} ha tracciato le lettere al primo tentativo.'**
  String adviceHands(String name, int n);

  /// No description provided for @adviceReading.
  ///
  /// In it, this message translates to:
  /// **'Ti proponiamo più testo perché nelle ultime {n} attività {name} ha composto le parole al primo tentativo.'**
  String adviceReading(String name, int n);

  /// No description provided for @adviceAutonomy.
  ///
  /// In it, this message translates to:
  /// **'Ti proponiamo più scelte per volta perché nelle ultime {n} attività {name} ha risposto giusto al primo tentativo.'**
  String adviceAutonomy(String name, int n);

  /// No description provided for @adviceSwitchTitle.
  ///
  /// In it, this message translates to:
  /// **'Proposte sul profilo di interazione'**
  String get adviceSwitchTitle;

  /// No description provided for @adviceSwitchHint.
  ///
  /// In it, this message translates to:
  /// **'L’app guarda i round degli ultimi 7 giorni, solo su questo dispositivo, e ti suggerisce un passo. Se la spegni, non propone più nulla.'**
  String get adviceSwitchHint;

  /// No description provided for @levelEasier.
  ///
  /// In it, this message translates to:
  /// **'Più semplice'**
  String get levelEasier;

  /// No description provided for @levelSame.
  ///
  /// In it, this message translates to:
  /// **'Ancora così'**
  String get levelSame;

  /// No description provided for @levelHarder.
  ///
  /// In it, this message translates to:
  /// **'Più sfida'**
  String get levelHarder;

  /// No description provided for @adviceYes.
  ///
  /// In it, this message translates to:
  /// **'Sì, proviamo'**
  String get adviceYes;

  /// No description provided for @adviceNo.
  ///
  /// In it, this message translates to:
  /// **'Non ora'**
  String get adviceNo;

  /// No description provided for @sharedPromptGuide.
  ///
  /// In it, this message translates to:
  /// **'Spiegami tu cosa fare'**
  String get sharedPromptGuide;

  /// No description provided for @sharedPromptHelp.
  ///
  /// In it, this message translates to:
  /// **'Come potremmo aiutare?'**
  String get sharedPromptHelp;

  /// No description provided for @homeActivityHeading.
  ///
  /// In it, this message translates to:
  /// **'Un\'attività dalla storia'**
  String get homeActivityHeading;

  /// No description provided for @homeActivitySteps.
  ///
  /// In it, this message translates to:
  /// **'Cosa fa il bambino'**
  String get homeActivitySteps;

  /// No description provided for @homeActivityMaterials.
  ///
  /// In it, this message translates to:
  /// **'Cosa serve'**
  String get homeActivityMaterials;

  /// No description provided for @homeActivityPreparation.
  ///
  /// In it, this message translates to:
  /// **'Preparazione'**
  String get homeActivityPreparation;

  /// No description provided for @homeActivitySupervision.
  ///
  /// In it, this message translates to:
  /// **'Supervisione'**
  String get homeActivitySupervision;

  /// No description provided for @homeActivityAlternatives.
  ///
  /// In it, this message translates to:
  /// **'Se manca qualcosa'**
  String get homeActivityAlternatives;

  /// No description provided for @supervisionTogether.
  ///
  /// In it, this message translates to:
  /// **'Con il bambino, dall\'inizio alla fine'**
  String get supervisionTogether;

  /// No description provided for @supervisionNearby.
  ///
  /// In it, this message translates to:
  /// **'Un adulto vicino'**
  String get supervisionNearby;

  /// No description provided for @supervisionFree.
  ///
  /// In it, this message translates to:
  /// **'Il bambino può fare da solo'**
  String get supervisionFree;

  /// No description provided for @usageTitle.
  ///
  /// In it, this message translates to:
  /// **'Tempo con lo schermo'**
  String get usageTitle;

  /// No description provided for @usageWeek.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 7 giorni, con lo schermo acceso: {minutes} min in tutto, in {days} giorni.'**
  String usageWeek(Object days, Object minutes);

  /// No description provided for @usageToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi: {minutes} min.'**
  String usageToday(Object minutes);

  /// No description provided for @usageGestures.
  ///
  /// In it, this message translates to:
  /// **'Gesti segnati nel diario negli ultimi 7 giorni: {count}. Sono cose fatte nella vita vera, a parte dallo schermo.'**
  String usageGestures(Object count);

  /// No description provided for @usageLimit.
  ///
  /// In it, this message translates to:
  /// **'Nella modalità \"da solo\" il compagno saluta dopo {minutes} min (si cambia nel profilo).'**
  String usageLimit(Object minutes);

  /// No description provided for @usageCannot.
  ///
  /// In it, this message translates to:
  /// **'Cosa l\'app non può misurare: quanto il bambino guarda davvero lo schermo, l\'ascolto a schermo spento, il tempo su altri dispositivi, ciò che fate insieme fuori dallo schermo. I minuti sono solo una parte: contano anche cosa guarda, con chi e come ne parlate.'**
  String get usageCannot;

  /// No description provided for @projectPhaseIdea.
  ///
  /// In it, this message translates to:
  /// **'L\'idea'**
  String get projectPhaseIdea;

  /// No description provided for @projectPhasePrediction.
  ///
  /// In it, this message translates to:
  /// **'La previsione'**
  String get projectPhasePrediction;

  /// No description provided for @projectPhaseTest.
  ///
  /// In it, this message translates to:
  /// **'La prova'**
  String get projectPhaseTest;

  /// No description provided for @projectPhaseRevision.
  ///
  /// In it, this message translates to:
  /// **'La revisione'**
  String get projectPhaseRevision;

  /// No description provided for @projectNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Se vuoi, scrivi due righe (facoltativo)'**
  String get projectNoteHint;

  /// No description provided for @projectNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get projectNext;

  /// No description provided for @projectFinish.
  ///
  /// In it, this message translates to:
  /// **'Ho finito'**
  String get projectFinish;

  /// No description provided for @projectHeld.
  ///
  /// In it, this message translates to:
  /// **'Ha retto'**
  String get projectHeld;

  /// No description provided for @projectNotYet.
  ///
  /// In it, this message translates to:
  /// **'Non ancora'**
  String get projectNotYet;

  /// No description provided for @projectLogTitle.
  ///
  /// In it, this message translates to:
  /// **'I piccoli progetti di {name}'**
  String projectLogTitle(String name);

  /// No description provided for @projectResultHeld.
  ///
  /// In it, this message translates to:
  /// **'alla prova ha retto'**
  String get projectResultHeld;

  /// No description provided for @projectResultNotYet.
  ///
  /// In it, this message translates to:
  /// **'alla prova non ancora: si cambia e si riprova'**
  String get projectResultNotYet;

  /// No description provided for @gateSetupTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli un PIN per i grandi'**
  String get gateSetupTitle;

  /// No description provided for @gateSetupBody.
  ///
  /// In it, this message translates to:
  /// **'Da 4 a 6 cifre. Serve per entrare nell\'area adulta e per le operazioni delicate. Se lo dimentichi potrai sceglierne uno nuovo senza perdere nulla.'**
  String get gateSetupBody;

  /// No description provided for @gatePinLabel.
  ///
  /// In it, this message translates to:
  /// **'PIN'**
  String get gatePinLabel;

  /// No description provided for @gatePinConfirmLabel.
  ///
  /// In it, this message translates to:
  /// **'Ripeti il PIN'**
  String get gatePinConfirmLabel;

  /// No description provided for @gatePinMismatch.
  ///
  /// In it, this message translates to:
  /// **'I due PIN non coincidono'**
  String get gatePinMismatch;

  /// No description provided for @gatePinFormat.
  ///
  /// In it, this message translates to:
  /// **'Il PIN deve avere da 4 a 6 cifre'**
  String get gatePinFormat;

  /// No description provided for @gatePinWrong.
  ///
  /// In it, this message translates to:
  /// **'PIN sbagliato'**
  String get gatePinWrong;

  /// No description provided for @gatePinWait.
  ///
  /// In it, this message translates to:
  /// **'Troppi tentativi. Riprova tra {time}'**
  String gatePinWait(String time);

  /// No description provided for @gateForgot.
  ///
  /// In it, this message translates to:
  /// **'Ho dimenticato il PIN'**
  String get gateForgot;

  /// No description provided for @gateForgotUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a verificare che sei un adulto con il blocco del dispositivo. Attiva un blocco schermo dell\'adulto e riprova.'**
  String get gateForgotUnavailable;

  /// No description provided for @gateDeviceReason.
  ///
  /// In it, this message translates to:
  /// **'Conferma di essere un adulto per scegliere un nuovo PIN'**
  String get gateDeviceReason;

  /// No description provided for @gateChangePin.
  ///
  /// In it, this message translates to:
  /// **'Cambia PIN'**
  String get gateChangePin;

  /// No description provided for @onbSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get onbSkip;

  /// No description provided for @onbPromiseTitle.
  ///
  /// In it, this message translates to:
  /// **'Storie da esplorare, giochi da capire, idee da provare insieme'**
  String get onbPromiseTitle;

  /// No description provided for @onbPromiseBody.
  ///
  /// In it, this message translates to:
  /// **'Mirabò è per bambini da 3 a 10 anni e per l\'adulto che gioca accanto a loro.'**
  String get onbPromiseBody;

  /// No description provided for @onbFactFree.
  ///
  /// In it, this message translates to:
  /// **'Gratuita'**
  String get onbFactFree;

  /// No description provided for @onbFactOffline.
  ///
  /// In it, this message translates to:
  /// **'Funziona offline: il cloud è una scelta tua'**
  String get onbFactOffline;

  /// No description provided for @onbFactNoAds.
  ///
  /// In it, this message translates to:
  /// **'Senza pubblicità'**
  String get onbFactNoAds;

  /// No description provided for @onbFactNoAccount.
  ///
  /// In it, this message translates to:
  /// **'Nessun account per il bambino'**
  String get onbFactNoAccount;

  /// No description provided for @onbSetupTitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua e fascia d\'età'**
  String get onbSetupTitle;

  /// No description provided for @onbSetupHint.
  ///
  /// In it, this message translates to:
  /// **'Tutto il resto si regola dopo, dall\'area adulti.'**
  String get onbSetupHint;

  /// No description provided for @onbTryTitle.
  ///
  /// In it, this message translates to:
  /// **'Un assaggio di storia'**
  String get onbTryTitle;

  /// No description provided for @onbTryNote.
  ///
  /// In it, this message translates to:
  /// **'È solo un\'anteprima: la storia intera si apre insieme al bambino.'**
  String get onbTryNote;

  /// No description provided for @onbHomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Dalla storia alla vita vera'**
  String get onbHomeTitle;

  /// No description provided for @onbHomeIntro.
  ///
  /// In it, this message translates to:
  /// **'Ogni storia può diventare un gesto concreto a casa. Per esempio:'**
  String get onbHomeIntro;

  /// No description provided for @onbGoTitle.
  ///
  /// In it, this message translates to:
  /// **'Pronti a provare con tuo figlio?'**
  String get onbGoTitle;

  /// No description provided for @onbGoBody.
  ///
  /// In it, this message translates to:
  /// **'Bastano pochi secondi: un compagno, un soprannome se vuoi, la fascia d\'età. Niente data di nascita, niente iscrizione.'**
  String get onbGoBody;

  /// No description provided for @onbGoButton.
  ///
  /// In it, this message translates to:
  /// **'Prova con tuo figlio'**
  String get onbGoButton;

  /// No description provided for @onbReopen.
  ///
  /// In it, this message translates to:
  /// **'Rivedi la presentazione'**
  String get onbReopen;

  /// No description provided for @onbReopenHint.
  ///
  /// In it, this message translates to:
  /// **'Il percorso di benvenuto, con l\'assaggio di una storia.'**
  String get onbReopenHint;

  /// No description provided for @onbClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get onbClose;

  /// No description provided for @dataWipeTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare tutto da questo tablet?'**
  String get dataWipeTitle;

  /// No description provided for @dataWipeBody.
  ///
  /// In it, this message translates to:
  /// **'Verranno cancellati per sempre profili, progressi, diario, creazioni e file generati (anche la voce del nome), insieme al database e alla sua chiave. Il tablet tornerà come al primo avvio. Non si può annullare. Un eventuale backup su Google Drive non viene toccato.'**
  String get dataWipeBody;

  /// No description provided for @dataWipeTypePrompt.
  ///
  /// In it, this message translates to:
  /// **'Per confermare scrivi {word}'**
  String dataWipeTypePrompt(String word);

  /// No description provided for @dataWipeWord.
  ///
  /// In it, this message translates to:
  /// **'ELIMINA'**
  String get dataWipeWord;

  /// No description provided for @dataWipeDone.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati di Mirabò sono stati eliminati da questo tablet.'**
  String get dataWipeDone;

  /// No description provided for @dataWipeFailed.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile eliminare tutto. Riprova.'**
  String get dataWipeFailed;

  /// No description provided for @dataRemoteButton.
  ///
  /// In it, this message translates to:
  /// **'Elimina anche il backup su Google Drive'**
  String get dataRemoteButton;

  /// No description provided for @dataRemoteTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il backup su Drive?'**
  String get dataRemoteTitle;

  /// No description provided for @dataRemoteBody.
  ///
  /// In it, this message translates to:
  /// **'Il file di backup nel Drive di {account} verrà cancellato, poi il tablet si scollega da Google e revoca il permesso dato all\'app. Serve internet. Non si può annullare. I dati su questo tablet restano.'**
  String dataRemoteBody(String account);

  /// No description provided for @dataRemoteDone.
  ///
  /// In it, this message translates to:
  /// **'Backup su Google Drive eliminato e account scollegato.'**
  String get dataRemoteDone;

  /// No description provided for @dataRemoteFailed.
  ///
  /// In it, this message translates to:
  /// **'Il backup su Google Drive NON è stato eliminato (probabilmente manca la rete o serve un nuovo accesso a Google). Non è cambiato niente: collegati a internet e riprova.'**
  String get dataRemoteFailed;

  /// No description provided for @dataOutsideTitle.
  ///
  /// In it, this message translates to:
  /// **'Cosa resta fuori dal controllo dell\'app'**
  String get dataOutsideTitle;

  /// No description provided for @dataOutsideBody.
  ///
  /// In it, this message translates to:
  /// **'Mirabò non può cancellare le copie di sicurezza del sistema operativo (backup del telefono o del tablet su iCloud o Google), né i file che hai già esportato, stampato o condiviso. Per quelle: apri le impostazioni di iCloud o di Google del dispositivo ed elimina i vecchi backup, e togli a mano i file salvati o inviati. Se resta qualcosa sul tuo Drive, lo trovi e lo elimini in Drive › Impostazioni › Gestisci app.'**
  String get dataOutsideBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
