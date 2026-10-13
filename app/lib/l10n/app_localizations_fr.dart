// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mirabò';

  @override
  String get appTagline => 'Des histoires et des petits pas pour grandir.';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Fini';

  @override
  String get finish => 'Fin';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get listenAgain => 'Réécouter';

  @override
  String get readAgain => 'Relire';

  @override
  String get seeYouTomorrow => 'À demain !';

  @override
  String get go => 'C\'est parti !';

  @override
  String get home => 'Maison';

  @override
  String get parentArea => 'Espace parents';

  @override
  String get modeTogether => 'Ensemble';

  @override
  String get modeAlone => 'Tout seul';

  @override
  String stepOf(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String homeHello(Object name) {
    return 'Coucou $name !';
  }

  @override
  String get homeQuestion => 'Qu\'est-ce qu\'on fait aujourd\'hui ?';

  @override
  String get homeOneStory => 'Une histoire';

  @override
  String get homeLetsPlay => 'On joue';

  @override
  String switchChildA11y(Object name) {
    return 'Changer d\'enfant. C\'est $name qui joue';
  }

  @override
  String get chooseWhoPlays => 'Qui joue aujourd\'hui ?';

  @override
  String chooseWith(Object companion) {
    return 'avec $companion';
  }

  @override
  String get chooseAdd => 'Ajouter';

  @override
  String get chooseAddHint => 'pour les grands';

  @override
  String get chooseAddA11y => 'Ajouter un enfant';

  @override
  String get catStories => 'Histoires';

  @override
  String get catGames => 'Jeux';

  @override
  String get catEmpty => 'Rien ici pour aujourd\'hui.';

  @override
  String get badgeAtHome => 'À la maison';

  @override
  String get badgeTogether => 'Ensemble';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(
      area,
      {
        'cognitivo': 'Se préparer',
        'autonomia': 'Autonomie',
        'sociale': 'En classe',
        'paure': 'Premier jour',
        'vitaPratica': 'Vie pratique',
        'sensoriale': 'Sensoriel',
        'linguaggio': 'Langage et écriture',
        'matematica': 'Maths',
        'cultura': 'Culture',
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
        'emozioni': 'Émotions',
        'inclusione': 'Ensemble',
        'ambiente': 'La forêt',
        'sicurezza': 'Mon corps',
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
        'emozioni': 'Émotions et conflits',
        'inclusione': 'Diversité et inclusion',
        'ambiente': 'Nature et êtres vivants',
        'sicurezza': 'Sécurité et corps',
        'other': '$world',
      },
    );
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'La phrase à retenir';

  @override
  String get activityTryAgain => 'Essaie encore.';

  @override
  String get activityHelp => 'Regarde bien. Je t\'aide.';

  @override
  String get checklistPrompt => 'Qu\'est-ce qui est déjà prêt ?';

  @override
  String get checklistSay => 'Qu\'est-ce qui est déjà prêt pour demain ?';

  @override
  String get checklistAlone => 'tout seul';

  @override
  String get checklistAllDone => 'Tout est prêt, bonne nuit';

  @override
  String get enoughForToday => 'Ça suffit pour aujourd\'hui';

  @override
  String get countdownPick => 'Choisis la date';

  @override
  String get countdownToday => 'C\'est aujourd\'hui !';

  @override
  String get countdownTodaySay => 'C\'est le grand jour !';

  @override
  String countdownDaysTo(int count, String event) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus que $count jours avant : $event',
      one: 'Plus que 1 jour avant : $event',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysSay(int count, String task) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus que $count jours. $task',
      one: 'Plus que 1 jour. $task',
    );
    return '$_temp0';
  }

  @override
  String exploreTap(Object scene) {
    return 'Touche pour explorer $scene';
  }

  @override
  String exploreSay(Object scene) {
    return 'Voici $scene. Touche pour découvrir.';
  }

  @override
  String get exploreAllSeen => 'J\'ai tout vu !';

  @override
  String get exploreEnough => 'Ça suffit pour aujourd\'hui';

  @override
  String get patternPrompt => 'Qu\'est-ce qui vient après ?';

  @override
  String get presentationWhatYouNeed => 'Ce qu\'il faut';

  @override
  String presentationWhatYouNeedSay(Object items) {
    return 'Ce qu\'il faut : $items';
  }

  @override
  String get presentationReady => 'Tout est prêt';

  @override
  String get presentationPrepare =>
      'Prépare tout sur un plateau avant d\'appeler l\'enfant. Montre les étapes une fois, lentement et sans parler ; puis laisse-le faire.';

  @override
  String presentationStep(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String get presentationWorkAlone => 'À toi de jouer';

  @override
  String presentationYourTurnSay(Object name) {
    return 'Maintenant c\'est à toi, $name. On range la tablette.';
  }

  @override
  String get presentationHowDidItGo =>
      'Pour le grand : comment ça s\'est passé ?';

  @override
  String get presentationControl => 'Contrôle de l\'erreur';

  @override
  String get presentationObserve => 'Ce qu\'il faut observer';

  @override
  String get presentationMarkLater =>
      'Note-le quand il a fini de travailler, même un peu plus tard. Ne le corrige pas pendant qu\'il travaille.';

  @override
  String get presentationWatched => 'A regardé';

  @override
  String get presentationDid => 'L\'a fait';

  @override
  String get presentationAlone => 'Tout seul';

  @override
  String get presentationRepeat => 'Veut recommencer';

  @override
  String get forTheAdult => 'Pour le grand';

  @override
  String turnYou(Object name) {
    return 'À toi, $name';
  }

  @override
  String get turnAdult => 'Au tour du grand';

  @override
  String spellSay(Object word) {
    return 'Compose : $word';
  }

  @override
  String get spellSentence => 'Compose la phrase';

  @override
  String get spellWord => 'Compose le mot';

  @override
  String tracePrompt(Object label) {
    return 'Suis avec le doigt : $label';
  }

  @override
  String get traceRestart => 'Je recommence';

  @override
  String gameWellDone(Object name) {
    return 'Bravo, $name !';
  }

  @override
  String get gameNiceGame => 'Quelle belle partie.';

  @override
  String gameWellDoneSay(Object name) {
    return 'Bravo, $name ! Quelle belle partie.';
  }

  @override
  String get gameAgain => 'Encore';

  @override
  String get gameEnough => 'Ça suffit';

  @override
  String get gameMemoryTitle => 'Memory des animaux';

  @override
  String gameMemoryDesc(int count) {
    return 'Trouve les paires : $count paires.';
  }

  @override
  String get memoryIntro => 'Trouve les paires d\'animaux pareils.';

  @override
  String get memoryCovered => 'Carte retournée';

  @override
  String animalName(String animal) {
    String _temp0 = intl.Intl.selectLogic(
      animal,
      {
        'dog': 'le chien',
        'cat': 'le chat',
        'rabbit': 'le lapin',
        'fox': 'le renard',
        'bear': 'l\'ours',
        'panda': 'le panda',
        'frog': 'la grenouille',
        'monkey': 'le singe',
        'lion': 'le lion',
        'tiger': 'le tigre',
        'cow': 'la vache',
        'pig': 'le cochon',
        'other': '$animal',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameBalloonsTitle => 'Les ballons';

  @override
  String get gameBalloonsDescSmall => 'Éclate les ballons.';

  @override
  String get gameBalloonsDescMid =>
      'Éclate seulement ceux de la couleur que dit le compagnon.';

  @override
  String get gameBalloonsDescBig =>
      'Éclate les nombres dans l\'ordre, de 1 à 10.';

  @override
  String get balloonsPopAll => 'Éclate les ballons !';

  @override
  String balloonsPopColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rouges',
        'blue': 'bleus',
        'green': 'verts',
        'yellow': 'jaunes',
        'purple': 'violets',
        'other': '$color',
      },
    );
    return 'Éclate seulement les ballons $_temp0.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rouges',
        'blue': 'bleus',
        'green': 'verts',
        'yellow': 'jaunes',
        'purple': 'violets',
        'other': '$color',
      },
    );
    return 'Maintenant les ballons $_temp0.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rouges',
        'blue': 'bleus',
        'green': 'verts',
        'yellow': 'jaunes',
        'purple': 'violets',
        'other': '$color',
      },
    );
    return 'Seulement les $_temp0';
  }

  @override
  String get balloonsNumbersStart =>
      'Éclate les nombres dans l\'ordre. Commence par le un.';

  @override
  String balloonsNow(Object n) {
    return 'Maintenant le $n.';
  }

  @override
  String balloonsFind(Object n) {
    return 'Trouve le $n';
  }

  @override
  String balloonsWrongNumber(Object got, Object want) {
    return 'Ça, c\'est le $got. Cherche le $want.';
  }

  @override
  String get balloonsDone => 'Fini !';

  @override
  String balloonA11yNumber(Object n) {
    return 'Ballon $n';
  }

  @override
  String balloonA11yColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rouge',
        'blue': 'bleu',
        'green': 'vert',
        'yellow': 'jaune',
        'purple': 'violet',
        'other': '$color',
      },
    );
    return 'Ballon $_temp0';
  }

  @override
  String get gameShapesTitle => 'Chaque forme à sa place';

  @override
  String get gameShapesDescSmall => 'Trois formes à glisser dans le bon trou.';

  @override
  String get gameShapesDescMid => 'Cinq formes à glisser dans le bon trou.';

  @override
  String get gameShapesDescBig =>
      'Six formes, grandes et petites : attention à la taille.';

  @override
  String get shapesIntro => 'Mets chaque forme dans son trou.';

  @override
  String get shapesIntroBig =>
      'Mets chaque forme dans son trou. Attention à la taille : grandes et petites.';

  @override
  String shapesWrong(Object shape) {
    return 'Ça, c\'est $shape. Essaie un autre trou.';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(
      shape,
      {
        'circle': 'le cercle',
        'square': 'le carré',
        'triangle': 'le triangle',
        'star': 'l\'étoile',
        'heart': 'le cœur',
        'hexagon': 'l\'hexagone',
        'circleSmall': 'le petit cercle',
        'squareSmall': 'le petit carré',
        'other': '$shape',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameDrawingTitle => 'Dessine et colorie';

  @override
  String get gameDrawingDesc =>
      'Une feuille blanche, les couleurs et les tampons.';

  @override
  String get drawingIntro => 'Choisis une couleur et dessine avec le doigt.';

  @override
  String get drawingSheet => 'Feuille à dessin';

  @override
  String get drawingEraser => 'Gomme';

  @override
  String get drawingUndo => 'Annuler';

  @override
  String get drawingNewSheet => 'Nouvelle feuille';

  @override
  String get gameXyloTitle => 'Le xylophone';

  @override
  String get gameXyloDescSmall => 'Joue librement.';

  @override
  String gameXyloDescBig(Object song) {
    return 'Joue librement ou apprends « $song ».';
  }

  @override
  String get xyloNotes => 'do ré mi fa sol la si do';

  @override
  String get xyloSong => 'Frère Jacques';

  @override
  String get xyloIntro => 'Touche les lames et joue.';

  @override
  String xyloIntroSong(Object song) {
    return 'Joue ce que tu veux, ou apprends $song.';
  }

  @override
  String get xyloFree => 'Jouer librement';

  @override
  String get xyloFreeSay => 'Joue ce que tu veux.';

  @override
  String get xyloSongSay => 'Joue la lame qui s\'allume.';

  @override
  String xyloNoteA11y(Object note) {
    return 'Note $note';
  }

  @override
  String get gamePuzzleTitle => 'Le taquin';

  @override
  String get gamePuzzleDesc =>
      'Remets les nombres de 1 à 8 dans l\'ordre en faisant glisser les pièces.';

  @override
  String get puzzleIntro =>
      'Fais glisser les pièces pour les mettre dans l\'ordre, de un à huit.';

  @override
  String puzzleTileA11y(Object n) {
    return 'Pièce $n';
  }

  @override
  String get gateTitle => 'Espace pour les grands';

  @override
  String gateQuestion(Object a, Object b) {
    return 'Combien font $a × $b ?';
  }

  @override
  String get gateWrong => 'Essaie encore';

  @override
  String get gateEnter => 'Entrer';

  @override
  String get parentTabSession => 'Séance';

  @override
  String get parentTabProfiles => 'Profils';

  @override
  String get parentTabCards => 'En parler';

  @override
  String get parentTabDiary => 'Journal';

  @override
  String get parentTabGrowth => 'Développement';

  @override
  String get parentHowUse => 'Comment utilisez-vous l\'appli en ce moment ?';

  @override
  String get parentHowUseHint =>
      'En mode « ensemble », des pauses de dialogue apparaissent pour vous deux. En mode « tout seul », l\'enfant répond en touchant et les histoires sur la sécurité et le corps restent cachées.';

  @override
  String get parentData => 'Où sont les données';

  @override
  String get parentDataHint =>
      'Uniquement sur cet appareil. La sauvegarde sur Drive et le compte cloud arriveront dans les prochaines versions.';

  @override
  String get parentWipe => 'Effacer toutes les données';

  @override
  String get parentWipeConfirmTitle => 'Tout effacer ?';

  @override
  String get parentWipeConfirm =>
      'Les profils et le journal seront effacés de cet appareil. C\'est irréversible.';

  @override
  String get parentWipeYes => 'Effacer';

  @override
  String get parentNewProfile => 'Nouveau profil';

  @override
  String parentProfileLine(String age, String companion, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count histoires',
      one: '1 histoire',
    );
    return '$age · compagnon $companion · $_temp0';
  }

  @override
  String get diaryEmpty => 'Aucune histoire ces 30 derniers jours.';

  @override
  String get diaryTogether => 'ensemble';

  @override
  String get diaryAlone => 'tout seul';

  @override
  String diaryChose(Object answer) {
    return 'à la pause, il a choisi : « $answer »';
  }

  @override
  String growthTitle(Object name) {
    return 'Comment $name grandit';
  }

  @override
  String get growthIntro =>
      'La seule comparaison est avec lui-même, il y a un mois. L\'appli ne voit qu\'une petite partie de sa journée : en cas de doute sur le développement, la référence est le pédiatre ou l\'enseignant.';

  @override
  String get growthEmpty =>
      'Aucune activité ces 30 derniers jours. Quand il en fera, vous verrez les étapes ici.';

  @override
  String get growthOffscreen =>
      'Là où il n\'y a pas de progrès, essayez l\'activité hors écran proposée dans la fiche : pas plus de temps sur l\'appli.';

  @override
  String growthNew(Object count) {
    return 'Ces 30 derniers jours : $count manches. Il y a un mois, il ne l\'avait pas encore essayé.';
  }

  @override
  String growthCompare(Object before, Object now) {
    return 'Aujourd\'hui : $now · il y a un mois : $before (bord gris).';
  }

  @override
  String stageLabel(String stage) {
    String _temp0 = intl.Intl.selectLogic(
      stage,
      {
        'starting': 'débute',
        'working': 'y travaille',
        'canDo': 'y arrive',
        'alone': 'le fait seul',
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
        'suoni_iniziali': 'Sons et lettres',
        'pregrafismo': 'Tracer les lettres',
        'numeri': 'Nombres et quantités',
        'logica': 'Logique et suites',
        'routine_sera': 'Préparer ses affaires pour demain',
        'routine_mattino': 'La routine du matin',
        'vestirsi': 'S\'habiller seul',
        'mensa': 'À la cantine',
        'turno_e_condivisione': 'Attendre son tour et partager',
        'chiedere_aiuto': 'Demander de l\'aide',
        'distacco': 'Se dire au revoir le matin',
        'conoscere_la_scuola': 'Découvrir l\'école',
        'primo_giorno': 'Le premier jour',
        'travasi': 'Transvaser et verser',
        'motricita_fine': 'Motricité fine',
        'cura_ambiente': 'Prendre soin de l\'environnement',
        'dimensioni': 'Tailles et sériation',
        'colori': 'Couleurs',
        'forme': 'Formes',
        'tatto': 'Toucher',
        'udito': 'Ouïe',
        'scrittura': 'Écriture',
        'vocabolario': 'Vocabulaire',
        'decine': 'Dizaines et unités',
        'geografia': 'Géographie',
        'botanica': 'Botanique',
        'other': '$skill',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileWelcome => 'Bienvenue dans Mirabò';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileNew => 'Nouveau profil';

  @override
  String get profileChild => 'L\'enfant';

  @override
  String get profileFirstRunHint =>
      'Un adulte remplit cette partie. Ça prend une minute, puis la tablette passe à l\'enfant.';

  @override
  String get profileName => 'Prénom';

  @override
  String get profileNameHint => 'Le compagnon l\'appellera ainsi';

  @override
  String get profileAge => 'Âge';

  @override
  String profileYears(Object range) {
    return '$range ans';
  }

  @override
  String ageBandLabel(String band) {
    String _temp0 = intl.Intl.selectLogic(
      band,
      {
        'small': 'Petits',
        'mid': 'Premiers pas',
        'big': 'Grands',
        'other': '$band',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLanguageHint =>
      'Histoires, activités, jeux et voix du compagnon seront dans cette langue.';

  @override
  String get profileCompanion => 'Le compagnon';

  @override
  String get profileCompanionEditHint =>
      'Le compagnon se choisit une seule fois : c\'est son meilleur ami.';

  @override
  String get profileCompanionNewHint =>
      'Laissez l\'enfant choisir. On le choisit une seule fois et on ne le change pas.';

  @override
  String get profileWorlds => 'Mondes des histoires';

  @override
  String get profileWorldsHint =>
      'Choisissez les thèmes que l\'enfant trouvera dans sa bibliothèque.';

  @override
  String get profileSafetyTogether =>
      '« Mon corps » seulement en mode ensemble';

  @override
  String get profileSafetyTogetherHint =>
      'Conseillé : les histoires sur la sécurité et le corps se lisent avec un adulte.';

  @override
  String get profileAccess => 'Accessibilité et temps';

  @override
  String get profileDyslexia => 'Texte facile à lire';

  @override
  String get profileDyslexiaHint =>
      'Police Lexend, plus d\'espace entre les lettres et les lignes.';

  @override
  String get profileLowStim => 'Faible stimulation';

  @override
  String get profileLowStimHint => 'Couleurs douces, aucune animation.';

  @override
  String get profileAloneSession => 'Séance « tout seul »';

  @override
  String profileMinutes(Object count) {
    return '$count minutes';
  }

  @override
  String profileMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String get profileDelete => 'Supprimer ce profil';

  @override
  String get profileMissingName => 'Il manque le prénom';

  @override
  String get profileMissingCompanion => 'Il manque le compagnon';

  @override
  String get profileStart => 'On commence';

  @override
  String get translationDraft => 'Traduction en cours de relecture';
}
