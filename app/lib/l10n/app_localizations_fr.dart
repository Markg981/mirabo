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
  String get seeYouTomorrow => 'Salut !';

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
  String goodbyeTitle(Object name) {
    return 'C\'est fini pour aujourd\'hui, $name !';
  }

  @override
  String get goodbyeBody =>
      'C\'était chouette. Va chercher un grand : à la prochaine !';

  @override
  String closingTitle(Object name) {
    return 'Beau travail, $name !';
  }

  @override
  String get closingBody =>
      'Tu as fait un beau bout de chemin. Tu peux poser la tablette : tout reste comme c\'est, tu le retrouves quand tu veux.';

  @override
  String get closingBack => 'Retour à la maison';

  @override
  String get closingA11y => 'J\'ai fini';

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
  String get catEmpty => 'Rien ici pour aujourd\'hui.';

  @override
  String capacityLabel(String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': 'Moi et les autres',
        'mani': 'Les mains',
        'sensi': 'Les sens',
        'parole': 'Les mots',
        'pensare': 'Compter et penser',
        'mondo': 'Le monde',
        'other': '$capacity',
      },
    );
    return '$_temp0';
  }

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
  String get activityHelpButton => 'Aide';

  @override
  String get activityHelpPoint =>
      'Regarde celui qui est en couleur : ce pourrait être lui. À toi d\'essayer.';

  @override
  String get activityHelpDemo =>
      'Je te montre : regarde celui qui s\'est allumé et touche-le doucement. À toi maintenant.';

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
  String get parentTabShelf => 'Étagère';

  @override
  String get parentHowUse => 'Comment utilisez-vous l\'appli en ce moment ?';

  @override
  String get parentHowUseHint =>
      'En mode « ensemble », des pauses de dialogue apparaissent pour vous deux. En mode « tout seul », l\'enfant répond en touchant et les histoires sur la sécurité et le corps restent cachées.';

  @override
  String get parentPlace => 'Où vous vivez';

  @override
  String get parentPlaceHint =>
      'Pour le calendrier de la nature : les conseils suivent les saisons de chez vous.';

  @override
  String hemisphere(String place) {
    String _temp0 = intl.Intl.selectLogic(
      place,
      {
        'north': 'Hémisphère nord',
        'south': 'Hémisphère sud',
        'equator': 'Près de l\'équateur',
        'other': '$place',
      },
    );
    return '$_temp0';
  }

  @override
  String get parentData => 'Vos données';

  @override
  String get parentDataHint =>
      'Les profils, le journal et les progrès restent sur cet appareil, chiffrés. La sauvegarde sur Google Drive ci-dessous est facultative.';

  @override
  String get parentWipe =>
      'Supprimer toutes les données de Mirabò sur cette tablette';

  @override
  String get parentWipeConfirmTitle => 'Tout effacer ?';

  @override
  String get parentWipeConfirm =>
      'Les profils et le journal seront effacés de cet appareil. C\'est irréversible. Une éventuelle sauvegarde sur Google Drive reste où elle est.';

  @override
  String get parentWipeYes => 'Effacer';

  @override
  String get backupTitle => 'Sauvegarde sur Google Drive';

  @override
  String get backupHint =>
      'Facultative. La sauvegarde va dans un dossier caché de votre Drive, que l\'app ne peut utiliser pour rien d\'autre, et elle est chiffrée avec un mot de passe que vous seul connaissez. Elle sert à passer à une nouvelle tablette ou à réinstaller l\'app sans rien perdre.';

  @override
  String get backupOff =>
      'Désactivée : les données sont seulement sur cette tablette.';

  @override
  String backupOnAccount(String account) {
    return 'Activée avec $account';
  }

  @override
  String backupLast(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get backupNever => 'Pas encore de sauvegarde.';

  @override
  String get backupAutoFailed =>
      'La dernière sauvegarde automatique n\'a pas fonctionné. Essayez « Sauvegarder maintenant ».';

  @override
  String get backupEnable => 'Activer la sauvegarde';

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupRestore => 'Restaurer depuis Drive';

  @override
  String get backupDisable => 'Désactiver';

  @override
  String get backupPasswordTitle =>
      'Choisissez le mot de passe de la sauvegarde';

  @override
  String get backupPasswordHint =>
      'La sauvegarde est chiffrée avec ce mot de passe avant de quitter la tablette. Il vous servira pour la restaurer sur un autre appareil : si vous l\'oubliez, la sauvegarde est irrécupérable, même pour nous.';

  @override
  String get backupPassword => 'Mot de passe';

  @override
  String get backupPasswordRepeat => 'Répétez le mot de passe';

  @override
  String backupPasswordShort(int n) {
    return 'Au moins $n caractères.';
  }

  @override
  String get backupPasswordMismatch =>
      'Les deux mots de passe ne correspondent pas.';

  @override
  String get backupRestorePasswordTitle => 'Mot de passe de la sauvegarde';

  @override
  String get backupRestorePasswordHint =>
      'Le mot de passe choisi quand vous avez activé la sauvegarde.';

  @override
  String get backupWrongPassword => 'Mot de passe incorrect.';

  @override
  String get backupNone =>
      'Ce compte Google n\'a pas encore de sauvegarde Mirabò.';

  @override
  String get backupExistsTitle => 'Une sauvegarde existe déjà';

  @override
  String get backupExists =>
      'Ce compte Google a déjà une sauvegarde Mirabò. Voulez-vous la restaurer sur cette tablette, ou la remplacer par les données de cette tablette ?';

  @override
  String get backupExistsRestore => 'Restaurer';

  @override
  String get backupExistsReplace => 'Remplacer';

  @override
  String get backupRestoreConfirmTitle => 'Restaurer la sauvegarde ?';

  @override
  String get backupRestoreConfirm =>
      'Les profils, le journal et les progrès de cette tablette seront remplacés par ceux de la sauvegarde.';

  @override
  String get backupDisableTitle => 'Désactiver la sauvegarde ?';

  @override
  String get backupDisableConfirm =>
      'La tablette arrête les sauvegardes et oublie le compte. Vous pouvez garder la copie sur Drive pour la restaurer plus tard, ou la supprimer.';

  @override
  String get backupDisableKeep => 'Désactiver et garder la copie';

  @override
  String get backupDisableDelete => 'Désactiver et supprimer la copie';

  @override
  String get backupDone => 'Sauvegarde terminée.';

  @override
  String get backupRestored => 'Sauvegarde restaurée.';

  @override
  String get backupError =>
      'Ça n\'a pas marché. Vérifiez la connexion et réessayez.';

  @override
  String get backupContinue => 'Continuer';

  @override
  String get profileRestoreLink =>
      'Vous utilisiez déjà Mirabò ? Restaurer depuis Google Drive';

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
  String get gesturesTitle => 'Gestes dans la vraie vie';

  @override
  String gesturesIntro(String companion, String name) {
    return '$companion ne grandit que quand $name fait vraiment le geste d\'une histoire, pas avec le temps passé sur l\'appli. Quand vous l\'avez fait, note-le ici.';
  }

  @override
  String gesturesNext(int count, String companion) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count gestes',
      one: 'Encore 1 geste',
    );
    return '$_temp0 avant la prochaine étape de $companion.';
  }

  @override
  String gesturesAllGrown(String companion) {
    return '$companion a atteint la dernière étape : les gestes valent toujours la peine.';
  }

  @override
  String gesturesEmpty(String name) {
    return 'Les gestes des histoires que $name a terminées apparaissent ici.';
  }

  @override
  String get gestureMark => 'Fait aujourd\'hui';

  @override
  String get gestureMarked => 'Noté aujourd\'hui';

  @override
  String gestureTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fait $count fois',
      one: 'fait 1 fois',
      zero: 'pas encore fait',
    );
    return '$_temp0';
  }

  @override
  String get ideaTitle => 'Une idée pour aujourd\'hui';

  @override
  String ideaIntro(String name) {
    return 'Une petite chose à faire avec $name, loin de l\'écran. Elle change chaque jour.';
  }

  @override
  String ideaFromStory(String story) {
    return 'D\'après l\'histoire « $story »';
  }

  @override
  String ideaHome(String title, String area) {
    return 'Avec les mains : $title ($area)';
  }

  @override
  String get ideaHomeHint =>
      'La présentation pas à pas se trouve dans les activités Montessori.';

  @override
  String ideaReasonRepeat(String name) {
    return '$name a demandé à la refaire';
  }

  @override
  String ideaReasonStory(String name, String story) {
    return '$name a écouté « $story »';
  }

  @override
  String get ideaReasonTryAlone =>
      'Vous l\'avez faite ensemble : la prochaine fois, l\'enfant peut essayer en autonomie';

  @override
  String ideaReasonCapacity(String name, String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': '$name aime être avec les autres',
        'mani': '$name aime travailler avec les mains',
        'sensi': '$name aime explorer avec les sens',
        'parole': '$name aime jouer avec les mots',
        'pensare': '$name aime compter et réfléchir',
        'mondo': '$name aime découvrir le monde',
        'other': '$name le choisit souvent',
      },
    );
    return '$_temp0';
  }

  @override
  String get ideaAnother => 'Une autre idée';

  @override
  String ideaReasonNone(String name) {
    return 'Une présentation adaptée à l\'âge de $name';
  }

  @override
  String get ideaNeedsNothing => 'Il faut : rien de particulier';

  @override
  String get ideaPrepNone => 'Préparation : aucune';

  @override
  String get ideaPrepQuick => 'Préparation : environ 2 minutes';

  @override
  String get ideaPrepShort => 'Préparation : environ 5 minutes';

  @override
  String ideaVariant(String text) {
    return 'Variante : $text';
  }

  @override
  String ideaVariantStory(String name) {
    return 'si ce n\'est pas le moment aujourd\'hui, remettez à demain ; ou laissez $name guider et vous dire quoi faire.';
  }

  @override
  String get ideaVariantHome =>
      'après quelques jours, laissez-le le faire seul, sans la présenter à nouveau.';

  @override
  String get ideaNoMaterials => 'Nous n\'avons pas ce matériel';

  @override
  String get ideaNotInterested => 'Cela ne nous intéresse pas';

  @override
  String ideaEmpty(String name) {
    return 'Quand $name aura fini une histoire, vous trouverez ici une idée à faire ensemble.';
  }

  @override
  String weekTitle(String name) {
    return 'La semaine de $name';
  }

  @override
  String get weekIntro =>
      'Les 7 derniers jours, racontés. Pas de notes : seulement ce qui s\'est passé.';

  @override
  String weekStories(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A écouté $count histoires : $titles.',
      one: 'A écouté une histoire : $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekAllTogether => 'Vous les avez toujours écoutées ensemble.';

  @override
  String get weekAllAlone =>
      'Il les a écoutées tout seul : la prochaine, vous pouvez l\'écouter ensemble.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together fois sur $total, vous étiez ensemble.',
      one: 'Une fois sur $total, vous étiez ensemble.',
    );
    return '$_temp0';
  }

  @override
  String weekChoice(String story, String answer) {
    return 'Dans « $story », à la pause, il a choisi : « $answer ».';
  }

  @override
  String weekKeyPhrase(String phrase) {
    return 'Une phrase à répéter ensemble : « $phrase »';
  }

  @override
  String weekGestures(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Dans la vraie vie, il a fait $count gestes, des histoires $titles.',
      one: 'Dans la vraie vie, il a fait le geste de $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekNoGestures =>
      'Aucun geste noté : si vous l\'avez fait, notez-le ci-dessous.';

  @override
  String weekHome(String titles) {
    return 'Avec les mains, loin de l\'écran : $titles.';
  }

  @override
  String get weekEmpty =>
      'Aucune histoire ni aucun geste cette semaine. Ce n\'est pas grave : les semaines loin de l\'écran comptent aussi.';

  @override
  String growthTitle(Object name) {
    return 'Ce que $name a exploré';
  }

  @override
  String get growthIntro =>
      'Un journal de ce qu\'il ou elle a choisi et repris ces 30 derniers jours, pas une évaluation : les touches, la vitesse et les réussites ne disent pas ce qu\'il ou elle sait faire. Aucune comparaison, ni avec d\'autres enfants ni avec il y a un mois.';

  @override
  String get growthEmpty =>
      'Aucune activité ces 30 derniers jours. Quand il ou elle en choisira, vous verrez ici les thèmes explorés.';

  @override
  String get growthOffscreen =>
      'Là où il n\'y a pas de progrès, essayez l\'activité hors écran proposée dans la fiche : pas plus de temps sur l\'appli.';

  @override
  String exploreTheme(String theme) {
    return 'A exploré : $theme';
  }

  @override
  String exploreResumed(int days) {
    return 'L\'a repris sur $days jours différents.';
  }

  @override
  String get exploreOnce => 'L\'a essayé un jour.';

  @override
  String get exploreCreationsTitle => 'Histoires inventées et gardées';

  @override
  String get exploreCreationsEmpty =>
      'Pas encore d\'histoire inventée dans la fabrique d\'histoires.';

  @override
  String get exploreNotesTitle => 'Vos observations';

  @override
  String get exploreNotesHint =>
      'Quelque chose que vous avez remarqué : une question, un jeu, une phrase...';

  @override
  String get exploreNotesAdd => 'Ajouter';

  @override
  String get exploreNotesEmpty =>
      'Aucune observation. Elles restent sur cet appareil uniquement.';

  @override
  String get exploreNotesDelete => 'Supprimer l\'observation';

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(
      skill,
      {
        'progetti_aperti': 'Petits projets',
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

  @override
  String get lessonNaming => 'Voici';

  @override
  String get lessonShow => 'Où est-il ?';

  @override
  String get lessonTell => 'Comment ça s\'appelle ?';

  @override
  String shelfTitle(Object name) {
    return 'L\'étagère de $name';
  }

  @override
  String shelfHint(String name, int max, int per) {
    return 'Peu de matériel à la fois, comme sur les étagères d\'une ambiance Montessori : $name choisit librement parmi ce que tu poses ici. $max au plus en tout et $per par capacité ; change-les quand ils ont été explorés.';
  }

  @override
  String shelfCount(int count, int max) {
    return '$count sur $max';
  }

  @override
  String get shelfAuto => 'Choix automatique';

  @override
  String get shelfAutoOn =>
      'L\'étagère se remplit maintenant toute seule et change une fois par semaine.';

  @override
  String get shelfAutoHint =>
      'L\'étagère se remplit toute seule et change une fois par semaine : ce sur quoi l\'enfant travaille reste, le reste laisse la place à autre chose. Touche un matériel pour les choisir toi-même.';

  @override
  String shelfFull(int max) {
    return 'L\'étagère contient déjà $max matériels : retires-en un pour en poser un autre.';
  }

  @override
  String shelfCapacityFull(int max) {
    return 'Cette capacité a déjà $max matériels : retires-en un pour en poser un autre.';
  }

  @override
  String shelfTotal(int count, int max) {
    return 'Sur l\'étagère : $count sur $max';
  }

  @override
  String get shelfRotateNow => 'Changer maintenant';

  @override
  String get shelfRotated => 'L\'étagère a changé.';

  @override
  String get shelfKindStory => 'Histoire';

  @override
  String get shelfKindGame => 'Jeu';

  @override
  String get shelfKindActivity => 'Activité';

  @override
  String get gesturePause => 'Pause : faisons le geste';

  @override
  String get gestureStart => 'Prêts ? Partez !';

  @override
  String get huntFound => 'Je l\'ai trouvé !';

  @override
  String get huntNotFound => 'Je ne le trouve pas';

  @override
  String get huntRest => 'Écran au repos';

  @override
  String get huntRestHint =>
      'Touche l\'écran quand tu es de retour. Si tu préfères ne pas le faire, ce n\'est pas grave.';

  @override
  String get huntTellMe => 'Qu\'est-ce que tu as trouvé ? Dis-le à voix haute.';

  @override
  String get huntRules =>
      'l\'enfant cherche une chose à la fois, à la maison ou dehors avec vous. Seulement des choses à sa portée : pas d\'escalade, rien de coupant ni de fragile, pas de médicaments ni de produits ménagers. Dehors, seulement ce qui est déjà tombé par terre. À la fin, on remet tout à sa place.';

  @override
  String get catMake => 'Je crée, je découvre';

  @override
  String get factoryTitle => 'Fabrique à histoires';

  @override
  String get natureTitle => 'Calendrier de la nature';

  @override
  String factoryAsk(String step) {
    String _temp0 = intl.Intl.selectLogic(
      step,
      {
        'who': 'Qui est le héros ?',
        'place': 'Où vit-il ?',
        'problem': 'Un jour, que se passe-t-il ?',
        'feeling': 'Que ressent-il ?',
        'helper': 'Qui vient aider ?',
        'ending': 'Comment ça finit ?',
        'other': '$step',
      },
    );
    return '$_temp0';
  }

  @override
  String get factoryNameIt => 'Quel titre donne-t-on à l\'histoire ?';

  @override
  String get factoryRead => 'Lisons l\'histoire !';

  @override
  String get factoryMine => 'Mes histoires';

  @override
  String get factoryNew => 'Invente une histoire';

  @override
  String factoryBy(Object name) {
    return 'Une histoire inventée par $name';
  }

  @override
  String get factoryEnd => 'Fin';

  @override
  String get factoryOtherEnding => 'Essaie une autre fin';

  @override
  String factoryDone(Object name) {
    return 'Quelle belle histoire, $name ! Je la range avec tes histoires.';
  }

  @override
  String get factoryMineEmpty =>
      'Tu trouveras ici les histoires que tu inventes.';

  @override
  String factoryWhoA(String who) {
    String _temp0 = intl.Intl.selectLogic(
      who,
      {
        'dragon': 'un petit dragon',
        'bunny': 'un petit lapin',
        'robot': 'un gentil robot',
        'penguin': 'un pingouin',
        'unicorn': 'une licorne',
        'kitten': 'un chaton',
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
        'dragon': 'le petit dragon',
        'bunny': 'le petit lapin',
        'robot': 'le gentil robot',
        'penguin': 'le pingouin',
        'unicorn': 'la licorne',
        'kitten': 'le chaton',
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
        'forest': 'la forêt',
        'room': 'la chambre',
        'stream': 'le ruisseau',
        'sky': 'les nuages',
        'snow': 'la neige',
        'night': 'la nuit',
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
        'forest': 'dans une forêt pleine d\'arbres',
        'room': 'dans une chambre pleine de jouets',
        'stream': 'près d\'un petit ruisseau',
        'sky': 'sur un nuage tout doux',
        'snow': 'dans un pré plein de neige',
        'night': 'dans un pré sous les étoiles',
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
        'storm': 'l\'orage',
        'star': 'la petite étoile tombée',
        'sadFriend': 'un ami triste',
        'litter': 'les déchets',
        'lost': 'le chemin perdu',
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
        'storm': 'un gros orage arriva',
        'star':
            'une petite étoile tomba du ciel et ne savait plus rentrer chez elle',
        'sadFriend': 'un ami arriva, tout triste, et ne voulait pas parler',
        'litter': 'quelqu\'un laissa plein de déchets par terre',
        'lost': 'le brouillard cacha le chemin de la maison',
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
            'ils trouvèrent un abri au sec et attendirent la fin de l\'orage',
        'star':
            'ils construisirent une très haute échelle et ramenèrent la petite étoile dans le ciel',
        'sadFriend':
            'ils s\'assirent près de leur ami et l\'écoutèrent, jusqu\'à ce qu\'il sourie de nouveau',
        'litter':
            'ils ramassèrent les déchets avec des gants et les mirent dans les bonnes poubelles',
        'lost':
            'ils suivirent les traces sur le sentier et retrouvèrent le chemin de la maison',
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
        'fear': 'la peur',
        'sadness': 'la tristesse',
        'anger': 'la colère',
        'curiosity': 'la curiosité',
        'courage': 'le courage',
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
        'fear': 'un peu de peur',
        'sadness': 'un peu de tristesse',
        'anger': 'un peu de colère',
        'curiosity': 'beaucoup de curiosité',
        'courage': 'beaucoup de courage',
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
        'turtle': 'une tortue sage',
        'owl': 'un hibou qui sait plein de choses',
        'bear': 'un ours gentil',
        'bee': 'une abeille très rapide',
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
        'party': 'une fête',
        'sleep': 'au lit',
        'hug': 'un câlin',
        'snack': 'un goûter',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryPageStart(Object who, Object place) {
    return 'Il était une fois $who qui vivait $place.';
  }

  @override
  String factoryPageProblem(Object problem) {
    return 'Un jour, $problem.';
  }

  @override
  String factoryPageFeeling(Object who, Object feeling) {
    return '$who ressentit $feeling et prit une grande inspiration.';
  }

  @override
  String factoryPageHelp(Object helper, Object solution) {
    return 'Heureusement, $helper arriva. Ensemble, $solution.';
  }

  @override
  String factoryEnding(String ending, Object who) {
    String _temp0 = intl.Intl.selectLogic(
      ending,
      {
        'party': 'Et ce soir-là, $who fit une grande fête avec tous ses amis.',
        'sleep':
            'Et ce soir-là, $who s\'endormit avec le sourire, sous une couverture bien chaude.',
        'hug': 'Et à la fin, $who fit un gros câlin à son nouvel ami.',
        'snack':
            'Et à la fin, $who partagea un goûter avec tout le monde, au soleil.',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureAskWeather => 'Quel temps fait-il ?';

  @override
  String get natureAskSeen => 'Qu\'as-tu vu dehors ?';

  @override
  String get natureUpTo => 'Tu peux en choisir jusqu\'à trois.';

  @override
  String natureWeather(String weather) {
    String _temp0 = intl.Intl.selectLogic(
      weather,
      {
        'sun': 'Soleil',
        'clouds': 'Nuages',
        'rain': 'Pluie',
        'snow': 'Neige',
        'wind': 'Vent',
        'fog': 'Brouillard',
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
        'leaf': 'Feuilles',
        'flower': 'Fleurs',
        'bird': 'Oiseaux',
        'bug': 'Coccinelles et insectes',
        'snail': 'Escargots',
        'fruit': 'Fruits',
        'mushroom': 'Champignons',
        'rainbow': 'Un arc-en-ciel',
        'moon': 'La lune',
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
            'Il fait froid et beaucoup d\'arbres sont nus. Vois-tu des nids dans les branches ?',
        'm2':
            'Les jours rallongent un tout petit peu. Cherche les premiers bourgeons sur les branches.',
        'm3':
            'Le printemps arrive : les premières fleurs sortent. De quelle couleur sont-elles ?',
        'm4':
            'Les oiseaux construisent leurs nids. Écoute : combien de chants différents entends-tu ?',
        'm5':
            'Le pré est plein de fleurs et d\'abeilles. Regarde-les de loin : elles travaillent beaucoup !',
        'm6':
            'Ce sont les jours les plus longs de l\'année. Que vois-tu le soir, quand il fait encore clair ?',
        'm7':
            'Il fait chaud : cherche l\'ombre des arbres. Entends-tu les cigales ?',
        'm8':
            'La nuit, si le ciel est dégagé, on voit parfois une étoile filante. Fais un vœu !',
        'm9':
            'Beaucoup de fruits mûrissent : raisins, pommes, figues. Lesquels connais-tu ?',
        'm10':
            'Les feuilles changent de couleur et tombent. Combien de couleurs différentes trouves-tu ?',
        'm11':
            'Dans la forêt, les champignons poussent. On les regarde, mais on ne les touche pas !',
        'm12':
            'Ce sont les jours les plus courts de l\'année. La forêt se repose, comme dans l\'histoire d\'Emma.',
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
        'e1': 'Quand la pluie arrive, l\'air change d\'odeur. Tu la sens ?',
        'e2':
            'Après une averse, il reste des flaques. Qu\'est-ce que tu vois dedans ?',
        'e3':
            'Les jours secs, la terre devient dure et poussiéreuse. Touche-la : comment est-elle aujourd\'hui ?',
        'e4':
            'Avec la pluie, les plantes poussent vite. Tu trouves une feuille nouvelle, encore toute claire ?',
        'e5':
            'Cherche une feuille immense et une toute petite. En quoi sont-elles différentes ?',
        'e6':
            'Y a-t-il un arbre avec des fleurs ou des fruits ? De quelle couleur sont-ils ?',
        'e7':
            'Les fourmis marchent en file. Suis-les des yeux : où vont-elles ?',
        'e8':
            'Après la pluie, parfois un arc-en-ciel apparaît. Combien de couleurs comptes-tu ?',
        'other': '$tip',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureThisMonth => 'Ce mois-ci';

  @override
  String natureDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get natureEmptyMonth => 'Ce mois-ci, le calendrier est encore vide.';

  @override
  String get natureToday => 'Aujourd\'hui';

  @override
  String get readWord => 'Touche un mot pour le réécouter';

  @override
  String get profileReadAlong => 'Lecture karaoké';

  @override
  String get profileReadAlongHint =>
      'Pendant que la voix lit, le mot s\'allume ; en le touchant, on le réécoute.';

  @override
  String get parentTabPrint => 'À imprimer';

  @override
  String printIntro(Object name) {
    return 'Des fiches à imprimer et à utiliser loin de l\'écran, dans la langue de $name.';
  }

  @override
  String get printEveryday => 'Pour tous les jours';

  @override
  String get printNameTrace => 'J\'écris mon prénom';

  @override
  String printNameTraceHint(Object name) {
    return 'Le prénom de $name à repasser au crayon.';
  }

  @override
  String get printNature => 'Calendrier de la nature du mois';

  @override
  String printNatureHint(Object name) {
    return 'La grille du mois à remplir à la main, avec ce que $name a déjà noté.';
  }

  @override
  String get printGestures => 'Gestes des histoires';

  @override
  String get printGestureHint =>
      'Le geste, deux semaines de ronds à colorier et un espace pour le dessiner.';

  @override
  String printGesturesEmpty(Object name) {
    return 'Les gestes des histoires que $name a terminées apparaîtront ici.';
  }

  @override
  String get printMade => 'Histoires inventées';

  @override
  String get printMadeHint =>
      'L\'histoire en petit livre, avec de la place pour les dessins.';

  @override
  String printMadeEmpty(Object name) {
    return 'Les histoires que $name invente dans la fabrique apparaîtront ici.';
  }

  @override
  String get printButton => 'Imprimer';

  @override
  String get pdfDrawHere => 'Dessine ici';

  @override
  String get pdfGestureTimes => 'Chaque fois que tu le fais, colorie un rond.';

  @override
  String get pdfTraceName => 'Repasse ton prénom';

  @override
  String get pdfWeather => 'Temps';

  @override
  String get pdfSeen => 'J\'ai vu';

  @override
  String get exitAsk => 'Tu veux sortir ?';

  @override
  String get exitStay => 'Je reste';

  @override
  String get exitLeave => 'Je sors';

  @override
  String get profileInteraction => 'Comment il utilise l\'app';

  @override
  String profileInteractionHint(Object name) {
    return 'Ils partent de l\'âge : déplacez-les si $name fait plus ou moins. L\'app ne les change jamais seule.';
  }

  @override
  String get profileHands => 'Mains';

  @override
  String get profileHandsHint =>
      'Boutons plus grands et tracés plus larges pour les débutants.';

  @override
  String get hands1 => 'Toucher';

  @override
  String get hands2 => 'Glisser';

  @override
  String get hands3 => 'Précis';

  @override
  String get profileReading => 'Lecture';

  @override
  String get profileReadingHint =>
      'Pas de texte (voix seule), la phrase-clé seule, texte en karaoké ou texte complet.';

  @override
  String get readingNone => 'Ne lit pas';

  @override
  String get readingLetters => 'Lettres';

  @override
  String get readingWords => 'Mots';

  @override
  String get readingFluent => 'Lit bien';

  @override
  String get profileAutonomy => 'Autonomie';

  @override
  String get profileAutonomyHint =>
      'Combien de choix à la fois, consigne répétée, confirmation avant de sortir.';

  @override
  String get autonomy1 => 'Avec aide';

  @override
  String get autonomy2 => 'Un peu seul';

  @override
  String get autonomy3 => 'Seul';

  @override
  String adviceHands(Object name) {
    return 'Ces derniers jours, $name trace les lettres du premier coup : voulez-vous essayer des tracés plus fins ?';
  }

  @override
  String adviceReading(Object name) {
    return 'Ces derniers jours, $name compose les mots du premier coup : voulez-vous afficher plus de texte ?';
  }

  @override
  String adviceAutonomy(Object name) {
    return 'Ces derniers jours, $name répond juste du premier coup : voulez-vous essayer avec plus de choix à la fois ?';
  }

  @override
  String get adviceYes => 'Oui, essayons';

  @override
  String get adviceNo => 'Pas maintenant';

  @override
  String get sharedPromptGuide => 'Dis-moi ce qu\'il faut faire';

  @override
  String get sharedPromptHelp => 'Comment pourrait-on aider ?';

  @override
  String get homeActivityHeading => 'Une activité de l\'histoire';

  @override
  String get homeActivitySteps => 'Ce que fait l\'enfant';

  @override
  String get homeActivityMaterials => 'Ce qu\'il faut';

  @override
  String get homeActivityPreparation => 'Préparation';

  @override
  String get homeActivitySupervision => 'Supervision';

  @override
  String get homeActivityAlternatives => 'S\'il manque quelque chose';

  @override
  String get supervisionTogether => 'Avec l\'enfant, du début à la fin';

  @override
  String get supervisionNearby => 'Un adulte à proximité';

  @override
  String get supervisionFree => 'L\'enfant peut le faire seul';

  @override
  String get usageTitle => 'Temps d\'écran';

  @override
  String usageWeek(Object days, Object minutes) {
    return '7 derniers jours, écran allumé : $minutes min au total, sur $days jours.';
  }

  @override
  String usageToday(Object minutes) {
    return 'Aujourd\'hui : $minutes min.';
  }

  @override
  String usageGestures(Object count) {
    return 'Gestes notés dans le journal ces 7 derniers jours : $count. Ce sont des choses faites dans la vraie vie, loin de l\'écran.';
  }

  @override
  String usageLimit(Object minutes) {
    return 'En mode « seul », le compagnon dit au revoir après $minutes min (à modifier dans le profil).';
  }

  @override
  String get usageCannot =>
      'Ce que l\'appli ne peut pas mesurer : combien l\'enfant regarde vraiment l\'écran, l\'écoute écran éteint, le temps sur d\'autres appareils, ce que vous faites ensemble hors de l\'écran. Les minutes ne sont qu\'une partie : ce qu\'il regarde, avec qui et comment vous en parlez comptent aussi.';

  @override
  String get projectPhaseIdea => 'L\'idée';

  @override
  String get projectPhasePrediction => 'La prévision';

  @override
  String get projectPhaseTest => 'L\'essai';

  @override
  String get projectPhaseRevision => 'La révision';

  @override
  String get projectNoteHint => 'Si tu veux, écris deux lignes (facultatif)';

  @override
  String get projectNext => 'Suivant';

  @override
  String get projectFinish => 'J\'ai fini';

  @override
  String get projectHeld => 'Ça a tenu';

  @override
  String get projectNotYet => 'Pas encore';

  @override
  String projectLogTitle(String name) {
    return 'Les petits projets de $name';
  }

  @override
  String get projectResultHeld => 'à l\'essai, ça a tenu';

  @override
  String get projectResultNotYet =>
      'à l\'essai, pas encore : on change quelque chose et on réessaie';

  @override
  String get profileNoLimit => 'Sans limite';

  @override
  String get usageNoLimit =>
      'En mode « seul », il n\'y a pas de limite de temps (à régler dans le profil).';

  @override
  String get winddownNote =>
      'On se dit bientôt au revoir. Finissons doucement ce qu\'on fait.';

  @override
  String get winddownHint =>
      'Peu avant la fin, le compagnon prévient calmement et ne propose rien de nouveau. Ce qui est ouvert peut se terminer.';

  @override
  String get dataWipeTitle => 'Tout supprimer de cette tablette ?';

  @override
  String get dataWipeBody =>
      'Profils, progrès, journal, créations et fichiers générés (y compris la voix du prénom) seront supprimés définitivement, avec la base de données et sa clé. La tablette reviendra comme au premier lancement. Impossible d\'annuler. Une éventuelle sauvegarde Google Drive n\'est pas touchée.';

  @override
  String dataWipeTypePrompt(String word) {
    return 'Pour confirmer, écrivez $word';
  }

  @override
  String get dataWipeWord => 'SUPPRIMER';

  @override
  String get dataWipeDone =>
      'Toutes les données de Mirabò ont été supprimées de cette tablette.';

  @override
  String get dataWipeFailed => 'Impossible de tout supprimer. Réessayez.';

  @override
  String get dataRemoteButton => 'Supprimer aussi la sauvegarde Google Drive';

  @override
  String get dataRemoteTitle => 'Supprimer la sauvegarde sur Drive ?';

  @override
  String dataRemoteBody(String account) {
    return 'Le fichier de sauvegarde dans le Drive de $account sera supprimé, puis la tablette se déconnecte de Google et révoque l\'autorisation donnée à l\'app. Une connexion internet est nécessaire. Impossible d\'annuler. Les données de cette tablette restent.';
  }

  @override
  String get dataRemoteDone =>
      'Sauvegarde Google Drive supprimée et compte déconnecté.';

  @override
  String get dataRemoteFailed =>
      'La sauvegarde Google Drive n\'a PAS été supprimée (probablement pas de réseau, ou une nouvelle connexion Google est requise). Rien n\'a changé : connectez-vous à internet et réessayez.';

  @override
  String get dataOutsideTitle => 'Ce que l\'app ne contrôle pas';

  @override
  String get dataOutsideBody =>
      'Mirabò ne peut pas supprimer les sauvegardes du système (sauvegarde du téléphone ou de la tablette sur iCloud ou Google), ni les fichiers déjà exportés, imprimés ou partagés. Pour ceux-ci : ouvrez les réglages iCloud ou Google de l\'appareil et supprimez les anciennes sauvegardes, puis retirez à la main les fichiers enregistrés ou envoyés. S\'il reste quelque chose dans votre Drive, vous le trouvez et le supprimez dans Drive > Paramètres > Gérer les applications.';
}
