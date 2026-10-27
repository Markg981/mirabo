// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mirabò';

  @override
  String get appTagline => 'Stories and little steps for growing up.';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get finish => 'The end';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get listenAgain => 'Listen again';

  @override
  String get readAgain => 'Read again';

  @override
  String get outroDone => 'Done';

  @override
  String get go => 'Let\'s go!';

  @override
  String get home => 'Home';

  @override
  String get parentArea => 'Grown-ups area';

  @override
  String get modeTogether => 'Together';

  @override
  String get modeAlone => 'On my own';

  @override
  String stepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String homeHello(Object name) {
    return 'Hi $name!';
  }

  @override
  String get homeQuestion => 'What shall we do today?';

  @override
  String get homeOneStory => 'A story';

  @override
  String goodbyeTitle(Object name) {
    return 'That\'s all for today, $name!';
  }

  @override
  String get goodbyeBody => 'We\'re done for today. Go and find a grown-up.';

  @override
  String closingTitle(Object name) {
    return 'Nice work, $name!';
  }

  @override
  String get closingBody =>
      'You\'ve come a long way. You can put the tablet down now: everything stays just as it is, ready whenever you want.';

  @override
  String get closingBack => 'Back home';

  @override
  String get closingA11y => 'I\'m done';

  @override
  String switchChildA11y(Object name) {
    return 'Change child. $name is playing now';
  }

  @override
  String get chooseWhoPlays => 'Who\'s playing today?';

  @override
  String chooseWith(Object companion) {
    return 'with $companion';
  }

  @override
  String get chooseAdd => 'Add';

  @override
  String get chooseAddHint => 'for grown-ups';

  @override
  String get chooseAddA11y => 'Add a child';

  @override
  String get catEmpty => 'Nothing here for today.';

  @override
  String capacityLabel(String capacity) {
    String _temp0 = intl.Intl.selectLogic(capacity, {
      'insieme': 'Me and others',
      'mani': 'Hands',
      'sensi': 'Senses',
      'parole': 'Words',
      'pensare': 'Counting and thinking',
      'mondo': 'The world',
      'other': '$capacity',
    });
    return '$_temp0';
  }

  @override
  String themeLabel(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'emozioniRelazioni': 'How I feel',
      'naturaViventi': 'Nature',
      'autonomiaScuola': 'I can do it',
      'other': '$theme',
    });
    return '$_temp0';
  }

  @override
  String experienceModeLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'story': 'A story',
      'game': 'A game',
      'practice': 'I try it',
      'other': '$mode',
    });
    return '$_temp0';
  }

  @override
  String get modeComing => 'Coming soon';

  @override
  String get practiceHint => 'To try in real life, with whoever is with you';

  @override
  String get badgeAtHome => 'At home';

  @override
  String get badgeTogether => 'Together';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(area, {
      'cognitivo': 'Getting ready',
      'autonomia': 'Independence',
      'sociale': 'In class',
      'paure': 'First day',
      'vitaPratica': 'Practical life',
      'sensoriale': 'Sensorial',
      'linguaggio': 'Language and writing',
      'matematica': 'Maths',
      'cultura': 'Culture',
      'other': '$area',
    });
    return '$_temp0';
  }

  @override
  String worldShort(String world) {
    String _temp0 = intl.Intl.selectLogic(world, {
      'emozioni': 'Feelings',
      'inclusione': 'Together',
      'ambiente': 'The woods',
      'sicurezza': 'My body',
      'other': '$world',
    });
    return '$_temp0';
  }

  @override
  String worldLong(String world) {
    String _temp0 = intl.Intl.selectLogic(world, {
      'emozioni': 'Feelings and conflicts',
      'inclusione': 'Diversity and inclusion',
      'ambiente': 'Nature and living things',
      'sicurezza': 'Safety and body',
      'other': '$world',
    });
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'The words to remember';

  @override
  String get activityTryAgain => 'Try again.';

  @override
  String get activityHelp => 'Look carefully. I\'ll help you.';

  @override
  String get activityHelpButton => 'Help';

  @override
  String get activityHelpPoint =>
      'Look at the colored one: it could be that. You try.';

  @override
  String get activityHelpDemo =>
      'Let me show you: look at the one that is lit and gently touch it. Now you try.';

  @override
  String get checklistPrompt => 'What\'s ready already?';

  @override
  String get checklistSay => 'What\'s ready for tomorrow already?';

  @override
  String get checklistAlone => 'on my own';

  @override
  String get checklistAllDone => 'All ready, good night';

  @override
  String get enoughForToday => 'That\'s enough for today';

  @override
  String get countdownPick => 'Pick the date';

  @override
  String get countdownToday => 'It\'s today!';

  @override
  String get countdownTodaySay => 'Today is the day!';

  @override
  String countdownDaysTo(int count, String event) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go until: $event',
      one: '1 day to go until: $event',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysSay(int count, String task) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go. $task',
      one: '1 day to go. $task',
    );
    return '$_temp0';
  }

  @override
  String exploreTap(Object scene) {
    return 'Tap to explore $scene';
  }

  @override
  String exploreSay(Object scene) {
    return 'This is $scene. Tap to find out.';
  }

  @override
  String get exploreAllSeen => 'I\'ve seen everything!';

  @override
  String get exploreEnough => 'That\'s enough for today';

  @override
  String get patternPrompt => 'What comes next?';

  @override
  String get presentationWhatYouNeed => 'What you need';

  @override
  String presentationWhatYouNeedSay(Object items) {
    return 'What you need: $items';
  }

  @override
  String get presentationReady => 'All ready';

  @override
  String get presentationPrepare =>
      'Put everything on a tray before calling your child. Show the steps once, slowly and without talking; then let them try.';

  @override
  String presentationStep(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get presentationWorkAlone => 'Now you try';

  @override
  String presentationYourTurnSay(Object name) {
    return 'Now it\'s your turn, $name. Let\'s put the tablet away.';
  }

  @override
  String get presentationHowDidItGo => 'For the grown-up: how did it go?';

  @override
  String get presentationControl => 'Control of error';

  @override
  String get presentationObserve => 'What to watch for';

  @override
  String get presentationMarkLater =>
      'Mark it when they\'ve finished, even a while later. Don\'t correct them while they work.';

  @override
  String get presentationWatched => 'Watched';

  @override
  String get presentationDid => 'Did it';

  @override
  String get presentationAlone => 'On their own';

  @override
  String get presentationRepeat => 'Wants to do it again';

  @override
  String get forTheAdult => 'For the grown-up';

  @override
  String turnYou(Object name) {
    return 'Your turn, $name';
  }

  @override
  String get turnAdult => 'Grown-up\'s turn';

  @override
  String spellSay(Object word) {
    return 'Make: $word';
  }

  @override
  String get spellSentence => 'Make the sentence';

  @override
  String get spellWord => 'Make the word';

  @override
  String tracePrompt(Object label) {
    return 'Trace the $label with your finger';
  }

  @override
  String get traceRestart => 'Start again';

  @override
  String get traceOtherWay => 'I\'ll trace it on the table';

  @override
  String shapeHole(Object shape) {
    return 'Hole: $shape';
  }

  @override
  String gameWellDone(Object name) {
    return 'Well done, $name!';
  }

  @override
  String get gameNiceGame => 'What a great game.';

  @override
  String gameWellDoneSay(Object name) {
    return 'Well done, $name! What a great game.';
  }

  @override
  String get gameAgain => 'Again';

  @override
  String get gameEnough => 'That\'s enough';

  @override
  String get gameMemoryTitle => 'Animal memory';

  @override
  String gameMemoryDesc(int count) {
    return 'Find the pairs: $count pairs.';
  }

  @override
  String gameMemoryDescFood(Object count) {
    return '$count animal and food pairs: they don\'t look alike, they go together.';
  }

  @override
  String gameMemoryDescHome(Object count) {
    return '$count sets of animal, food and home: three cards at a time.';
  }

  @override
  String get memoryIntro => 'Find the pairs of matching animals.';

  @override
  String get memoryIntroFood => 'Find who eats what: an animal and its food.';

  @override
  String get memoryIntroHome =>
      'Turn three cards: an animal, its food and its home.';

  @override
  String get memoryCovered => 'Face-down card';

  @override
  String animalName(String animal) {
    String _temp0 = intl.Intl.selectLogic(animal, {
      'dog': 'dog',
      'cat': 'cat',
      'rabbit': 'rabbit',
      'fox': 'fox',
      'bear': 'bear',
      'panda': 'panda',
      'frog': 'frog',
      'monkey': 'monkey',
      'lion': 'lion',
      'tiger': 'tiger',
      'cow': 'cow',
      'pig': 'pig',
      'other': '$animal',
    });
    return '$_temp0';
  }

  @override
  String memoryItemName(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'squirrel': 'the squirrel',
      'penguin': 'the penguin',
      'monkey': 'the monkey',
      'rabbit': 'the rabbit',
      'bear': 'the bear',
      'panda': 'the panda',
      'chestnut': 'the chestnut',
      'fish': 'the fish',
      'banana': 'the banana',
      'carrot': 'the carrot',
      'honey': 'the honey',
      'bamboo': 'the bamboo',
      'tree': 'the tree',
      'ice': 'the ice',
      'palm': 'the palm tree',
      'burrow': 'the burrow',
      'forest': 'the forest',
      'mountain': 'the mountain',
      'other': '$item',
    });
    return '$_temp0';
  }

  @override
  String get gameBalloonsTitle => 'Balloons';

  @override
  String get gameBalloonsDescSmall => 'Pop the balloons.';

  @override
  String get gameBalloonsDescMid => 'Pop only the colour your companion says.';

  @override
  String get gameBalloonsDescBig => 'Pop the numbers in order, from 1 to 10.';

  @override
  String get balloonsPopAll => 'Pop the balloons!';

  @override
  String balloonsPopColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'red',
      'blue': 'blue',
      'green': 'green',
      'yellow': 'yellow',
      'purple': 'purple',
      'other': '$color',
    });
    return 'Pop only the $_temp0 balloons.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'red',
      'blue': 'blue',
      'green': 'green',
      'yellow': 'yellow',
      'purple': 'purple',
      'other': '$color',
    });
    return 'Now the $_temp0 balloons.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'red',
      'blue': 'blue',
      'green': 'green',
      'yellow': 'yellow',
      'purple': 'purple',
      'other': '$color',
    });
    return 'Only the $_temp0 ones';
  }

  @override
  String get balloonsNumbersStart =>
      'Pop the numbers in order. Start with one.';

  @override
  String balloonsNow(Object n) {
    return 'Now $n.';
  }

  @override
  String balloonsFind(Object n) {
    return 'Find $n';
  }

  @override
  String balloonsWrongNumber(Object got, Object want) {
    return 'That\'s $got. Look for $want.';
  }

  @override
  String get balloonsDone => 'Done!';

  @override
  String balloonA11yNumber(Object n) {
    return 'Balloon $n';
  }

  @override
  String balloonA11yColor(String color) {
    String _temp0 = intl.Intl.selectLogic(color, {
      'red': 'Red',
      'blue': 'Blue',
      'green': 'Green',
      'yellow': 'Yellow',
      'purple': 'Purple',
      'other': '$color',
    });
    return '$_temp0 balloon';
  }

  @override
  String get gameShapesTitle => 'Shapes in their place';

  @override
  String get gameShapesDescSmall => 'Three shapes to drag into the right hole.';

  @override
  String get gameShapesDescMid =>
      'Five shapes, the holes are turned: the same shape in another position.';

  @override
  String get gameShapesDescBig =>
      'Six turned shapes, big and small: watch the size.';

  @override
  String get shapesIntro => 'Put each shape in its hole.';

  @override
  String get shapesIntroTurned =>
      'Put each shape in its hole. The holes are turned: look closely at the shape.';

  @override
  String get shapesIntroBig =>
      'Put each shape in its hole. The holes are turned, and there are big and small shapes.';

  @override
  String shapesWrong(Object shape) {
    return 'This is $shape. Try another hole.';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'the circle',
      'square': 'the square',
      'triangle': 'the triangle',
      'star': 'the star',
      'heart': 'the heart',
      'hexagon': 'the hexagon',
      'circleSmall': 'the small circle',
      'squareSmall': 'the small square',
      'other': '$shape',
    });
    return '$_temp0';
  }

  @override
  String get gameDrawingTitle => 'Draw and colour';

  @override
  String get gameDrawingDesc => 'A blank sheet, colours and stamps.';

  @override
  String get drawingIntro => 'Pick a colour and draw with your finger.';

  @override
  String get drawingSheet => 'Drawing sheet';

  @override
  String get drawingEraser => 'Eraser';

  @override
  String get drawingUndo => 'Undo';

  @override
  String get drawingNewSheet => 'New sheet';

  @override
  String get gameXyloTitle => 'Xylophone';

  @override
  String get gameXyloDescSmall => 'Play freely.';

  @override
  String gameXyloDescBig(Object song) {
    return 'Play freely or learn \"$song\".';
  }

  @override
  String get xyloNotes => 'C D E F G A B C';

  @override
  String get xyloSong => 'Are You Sleeping';

  @override
  String get xyloIntro => 'Tap the bars and play.';

  @override
  String xyloIntroSong(Object song) {
    return 'Play whatever you like, or learn $song.';
  }

  @override
  String get xyloFree => 'Play freely';

  @override
  String get xyloFreeSay => 'Play whatever you like.';

  @override
  String get xyloSongSay => 'Play the bar that lights up.';

  @override
  String xyloNoteA11y(Object note) {
    return 'Note $note';
  }

  @override
  String get gamePuzzleTitle => 'Sliding puzzle';

  @override
  String get gamePuzzleDesc =>
      'Put the numbers 1 to 8 back in order by sliding the tiles.';

  @override
  String get puzzleIntro =>
      'Slide the tiles to put them in order, from one to eight.';

  @override
  String puzzleTileA11y(Object n) {
    return 'Tile $n';
  }

  @override
  String get gateTitle => 'For grown-ups';

  @override
  String gateQuestion(Object a, Object b) {
    return 'What is $a × $b?';
  }

  @override
  String get gateWrong => 'Try again';

  @override
  String get gateEnter => 'Enter';

  @override
  String get parentTabSession => 'Session';

  @override
  String get parentTabProfiles => 'Profiles';

  @override
  String get parentTabCards => 'Talking about it';

  @override
  String get parentTabDiary => 'Diary';

  @override
  String get parentTabGrowth => 'Growth';

  @override
  String get parentTabShelf => 'Shelf';

  @override
  String get parentHowUse => 'How are you using the app right now?';

  @override
  String get parentHowUseHint =>
      'It\'s your statement, not a check: the app can\'t tell whether an adult is really there. \"Together\" shows the conversation pauses for the two of you and the stories meant to be read with an adult, with no time limit. \"On my own\" hides them (and the safety and body stories, if you chose so in the profile) and applies the profile\'s time limit. \"Together\" lasts for this time only: when the app starts, when the child changes or after 30 minutes with the app closed, it goes back to \"on my own\".';

  @override
  String get parentPlace => 'Where you live';

  @override
  String get parentPlaceHint =>
      'Used by the nature calendar: the tips follow the seasons where you live.';

  @override
  String hemisphere(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'north': 'Northern hemisphere',
      'south': 'Southern hemisphere',
      'equator': 'Near the equator',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String get parentData => 'Your data';

  @override
  String get parentDataHint =>
      'Profiles, diary and progress stay on this device, encrypted. The Google Drive backup below is optional.';

  @override
  String get parentDataHintLocal =>
      'Profiles, diary and progress stay on this device, encrypted.';

  @override
  String get parentWipe => 'Delete all Mirabò data on this tablet';

  @override
  String get parentWipeConfirmTitle => 'Delete everything?';

  @override
  String get parentWipeConfirm =>
      'Profiles and diary will be erased from this device. This can\'t be undone. Any Google Drive backup stays where it is.';

  @override
  String get parentWipeYes => 'Delete';

  @override
  String get backupTitle => 'Google Drive backup';

  @override
  String get backupHint =>
      'Optional. The backup goes into a hidden folder in your Drive that the app can\'t use for anything else, and it\'s encrypted with a password only you know. Use it to move to a new tablet or reinstall the app without losing anything.';

  @override
  String get backupOff => 'Off: the data is only on this tablet.';

  @override
  String backupOnAccount(String account) {
    return 'On, with $account';
  }

  @override
  String backupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupNever => 'No backup yet.';

  @override
  String get backupAutoFailed =>
      'The last automatic backup didn\'t work. Try \"Back up now\".';

  @override
  String get backupEnable => 'Turn on backup';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupRestore => 'Restore from Drive';

  @override
  String get backupDisable => 'Turn off';

  @override
  String get backupPasswordTitle => 'Choose a backup password';

  @override
  String get backupPasswordHint =>
      'The backup is encrypted with this password before it leaves the tablet. You\'ll need it to restore on another device: if you forget it, the backup can\'t be recovered, not even by us.';

  @override
  String get backupPassword => 'Password';

  @override
  String get backupPasswordRepeat => 'Repeat the password';

  @override
  String backupPasswordShort(int n) {
    return 'At least $n characters.';
  }

  @override
  String get backupPasswordMismatch => 'The two passwords don\'t match.';

  @override
  String get backupRestorePasswordTitle => 'Backup password';

  @override
  String get backupRestorePasswordHint =>
      'The password you chose when you turned on backup.';

  @override
  String get backupWrongPassword => 'Wrong password.';

  @override
  String get backupNone =>
      'There\'s no Mirabò backup on this Google account yet.';

  @override
  String get backupExistsTitle => 'There\'s already a backup';

  @override
  String get backupExists =>
      'This Google account already has a Mirabò backup. Do you want to restore it on this tablet, or replace it with this tablet\'s data?';

  @override
  String get backupExistsRestore => 'Restore';

  @override
  String get backupExistsReplace => 'Replace';

  @override
  String get backupRestoreConfirmTitle => 'Restore the backup?';

  @override
  String get backupRestoreConfirm =>
      'Profiles, diary and progress on this tablet will be replaced by the ones in the backup.';

  @override
  String get backupDisableTitle => 'Turn off backup?';

  @override
  String get backupDisableConfirm =>
      'The tablet stops backing up and forgets the account. You can keep the copy on Drive to restore later, or delete it.';

  @override
  String get backupDisableKeep => 'Turn off, keep the copy';

  @override
  String get backupDisableDelete => 'Turn off, delete the copy';

  @override
  String get backupDone => 'Backup complete.';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String get backupError =>
      'That didn\'t work. Check the connection and try again.';

  @override
  String get backupContinue => 'Continue';

  @override
  String get profileRestoreLink =>
      'Used Mirabò before? Restore from Google Drive';

  @override
  String get parentNewProfile => 'New profile';

  @override
  String parentProfileLine(String age, String companion, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return '$age · companion $companion · $_temp0';
  }

  @override
  String get diaryEmpty => 'No stories in the last 30 days.';

  @override
  String get diaryTogether => 'in together mode';

  @override
  String get diaryAlone => 'in on-my-own mode';

  @override
  String diaryChose(Object answer) {
    return 'at the pause they chose: \"$answer\"';
  }

  @override
  String get gesturesTitle => 'Real-life gestures';

  @override
  String gesturesIntro(String companion, String name) {
    return 'A story\'s gesture happens in real life, when it comes up. If you like, note it here: it stays in $name\'s diary. Noting it unlocks nothing and doesn\'t change $companion: it\'s just a memory.';
  }

  @override
  String gesturesEmpty(String name) {
    return 'Gestures from the stories $name has finished appear here.';
  }

  @override
  String get gestureMark => 'Done today';

  @override
  String get gestureMarked => 'Marked today';

  @override
  String gestureTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'done $count times',
      one: 'done once',
      zero: 'not done yet',
    );
    return '$_temp0';
  }

  @override
  String get ideaTitle => 'An idea for today';

  @override
  String ideaIntro(String name) {
    return 'Something small to do with $name, away from the screen. It changes every day.';
  }

  @override
  String ideaFromStory(String story) {
    return 'From the story “$story”';
  }

  @override
  String ideaHome(String title, String area) {
    return 'Hands-on: $title ($area)';
  }

  @override
  String get ideaHomeHint =>
      'The step-by-step presentation is among the activities, in the area shown above.';

  @override
  String ideaReasonRepeat(String name) {
    return '$name asked to do it again';
  }

  @override
  String ideaReasonStory(String name, String story) {
    return '$name listened to “$story”';
  }

  @override
  String get ideaReasonTryAlone =>
      'You did it together: next time they can try it on their own';

  @override
  String ideaReasonCapacity(String name, String capacity) {
    String _temp0 = intl.Intl.selectLogic(capacity, {
      'insieme': '$name loves being with others',
      'mani': '$name loves working with their hands',
      'sensi': '$name loves exploring with the senses',
      'parole': '$name loves playing with words',
      'pensare': '$name loves counting and reasoning',
      'mondo': '$name loves discovering the world',
      'other': '$name often chooses this',
    });
    return '$_temp0';
  }

  @override
  String get ideaAnother => 'Another idea';

  @override
  String ideaReasonNone(String name) {
    return 'A presentation that suits $name\'s age';
  }

  @override
  String get ideaNeedsNothing => 'What you need: nothing special';

  @override
  String get ideaPrepNone => 'Preparation: none';

  @override
  String get ideaPrepQuick => 'Preparation: about 2 minutes';

  @override
  String get ideaPrepShort => 'Preparation: about 5 minutes';

  @override
  String ideaVariant(String text) {
    return 'Variant: $text';
  }

  @override
  String ideaVariantStory(String name) {
    return 'if today is not the moment, try tomorrow; or let $name lead and tell you what to do.';
  }

  @override
  String get ideaVariantHome =>
      'after a few days, let them do it alone, without presenting it again.';

  @override
  String get ideaNoMaterials => 'We don\'t have these materials';

  @override
  String get ideaNotInterested => 'Not interested';

  @override
  String ideaEmpty(String name) {
    return 'Once $name has finished a story, you\'ll find an idea to do together here.';
  }

  @override
  String weekTitle(String name) {
    return '$name\'s week';
  }

  @override
  String get weekIntro =>
      'The last 7 days, told as a story. No grades: just what happened.';

  @override
  String weekStories(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listened to $count stories: $titles.',
      one: 'Listened to one story: $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekAllTogether => 'Always listened to in \"together\" mode.';

  @override
  String get weekAllAlone =>
      'Listened on their own: next time you could listen together.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together times out of $total in \"together\" mode.',
      one: 'Once out of $total in \"together\" mode.',
    );
    return '$_temp0';
  }

  @override
  String weekChoice(String story, String answer) {
    return 'In “$story”, at the pause they chose: “$answer”.';
  }

  @override
  String weekKeyPhrase(String phrase) {
    return 'A phrase to say together: “$phrase”';
  }

  @override
  String weekGestures(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In real life they did $count gestures, from $titles.',
      one: 'In real life they did the gesture from $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekNoGestures =>
      'No gestures marked: if you did one, mark it below.';

  @override
  String weekHome(String titles) {
    return 'Hands-on, away from the screen: $titles.';
  }

  @override
  String get weekEmpty =>
      'No stories or gestures this week. That\'s fine: weeks away from the screen count too.';

  @override
  String growthTitle(Object name) {
    return 'What $name has explored';
  }

  @override
  String get growthIntro =>
      'A diary of what they chose and came back to in the last 30 days, not an assessment: taps, speed and completions don\'t say what they can do. No comparison, neither with other children nor with a month ago.';

  @override
  String get growthEmpty =>
      'No activities in the last 30 days. When they pick some, you\'ll see the themes they explored here.';

  @override
  String get growthOffscreen =>
      'Where there\'s no progress, try the off-screen activity suggested in the card: not more time on the app.';

  @override
  String exploreTheme(String theme) {
    return 'Explored: $theme';
  }

  @override
  String exploreResumed(int days) {
    return 'Came back to it on $days different days.';
  }

  @override
  String get exploreOnce => 'Tried it on one day.';

  @override
  String get exploreCreationsTitle => 'Stories they made up and kept';

  @override
  String get exploreCreationsEmpty =>
      'No made-up stories yet in the story factory.';

  @override
  String get exploreNotesTitle => 'Your observations';

  @override
  String get exploreNotesHint =>
      'Something you noticed: a question, a game, a sentence...';

  @override
  String get exploreNotesAdd => 'Add';

  @override
  String get exploreNotesEmpty =>
      'No observations. They stay on this device only.';

  @override
  String get exploreNotesDelete => 'Delete the observation';

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(skill, {
      'progetti_aperti': 'Small projects',
      'suoni_iniziali': 'Sounds and letters',
      'pregrafismo': 'Tracing letters',
      'numeri': 'Numbers and quantities',
      'logica': 'Logic and sequences',
      'routine_sera': 'Getting ready for tomorrow',
      'routine_mattino': 'The morning routine',
      'vestirsi': 'Getting dressed alone',
      'mensa': 'At lunch',
      'turno_e_condivisione': 'Waiting your turn and sharing',
      'chiedere_aiuto': 'Asking for help',
      'distacco': 'Saying goodbye in the morning',
      'conoscere_la_scuola': 'Getting to know school',
      'primo_giorno': 'The first day',
      'travasi': 'Pouring and transferring',
      'motricita_fine': 'Fine motor skills',
      'cura_ambiente': 'Caring for the environment',
      'dimensioni': 'Sizes and ordering',
      'colori': 'Colours',
      'forme': 'Shapes',
      'tatto': 'Touch',
      'udito': 'Hearing',
      'scrittura': 'Writing',
      'vocabolario': 'Vocabulary',
      'decine': 'Tens and units',
      'geografia': 'Geography',
      'botanica': 'Botany',
      'other': '$skill',
    });
    return '$_temp0';
  }

  @override
  String get profileWelcome => 'Welcome to Mirabò';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileNew => 'New profile';

  @override
  String get profileChild => 'Your child';

  @override
  String get profileFirstRunHint =>
      'A grown-up fills in this part. It takes a minute, then the tablet goes to your child.';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameHint => 'The companion will call them this';

  @override
  String get profileAge => 'Age';

  @override
  String profileYears(Object range) {
    return '$range years';
  }

  @override
  String ageBandLabel(String band) {
    String _temp0 = intl.Intl.selectLogic(band, {
      'small': 'Little ones',
      'mid': 'First steps',
      'big': 'Big kids',
      'other': '$band',
    });
    return '$_temp0';
  }

  @override
  String bandConfirmTitle(Object name, Object old) {
    return 'The age groups have changed: $name was in $old years. Which group fits now?';
  }

  @override
  String bandConfirmHint(Object name) {
    return 'Until you choose, $name sees the same stories and games as before. Voice, text and help stay as you set them.';
  }

  @override
  String profileBandToConfirm(Object old) {
    return 'Before it was $old years: choose the current group.';
  }

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageHint =>
      'Stories, activities, games and the companion\'s voice will be in this language.';

  @override
  String get profileCompanion => 'The companion';

  @override
  String get profileCompanionEditHint =>
      'You can change it whenever you like: stories, drawings and progress stay.';

  @override
  String get profileCompanionNewHint =>
      'Let your child choose. It can be changed later without losing anything.';

  @override
  String get profileWorlds => 'Story worlds';

  @override
  String get profileWorldsHint =>
      'Choose the themes your child will find in their library.';

  @override
  String get profileSafetyTogether => '\"My body\" only in together mode';

  @override
  String get profileSafetyTogetherHint =>
      'Recommended: stories about safety and the body are read with a grown-up.';

  @override
  String get profileAccess => 'Accessibility and time';

  @override
  String get profileDyslexia => 'Easy-to-read text';

  @override
  String get profileDyslexiaHint =>
      'Lexend typeface, more spacing between letters and lines.';

  @override
  String get profileLowStim => 'Low stimulation';

  @override
  String get profileLowStimHint => 'Soft colours, no animations.';

  @override
  String get profileAloneSession => '\"On my own\" session';

  @override
  String profileMinutes(Object count) {
    return '$count minutes';
  }

  @override
  String profileMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String get profileDelete => 'Delete this profile';

  @override
  String get profileMissingName => 'Name missing';

  @override
  String get profileMissingCompanion => 'Companion missing';

  @override
  String get profileStart => 'Let\'s start';

  @override
  String get translationDraft => 'Translation under review';

  @override
  String get lessonNaming => 'This is';

  @override
  String get lessonShow => 'Where is it?';

  @override
  String get lessonTell => 'What is it called?';

  @override
  String shelfTitle(Object name) {
    return '$name\'s shelf';
  }

  @override
  String shelfHint(String name, int max, int per) {
    return 'A few materials at a time, like the shelves of a Montessori environment: $name freely chooses among the ones you put here. At most $max in all and $per per ability; change them once they\'ve been explored.';
  }

  @override
  String get shelfShortcutNote =>
      'The shelf is a shortcut: anything not on it can always be reached from the three themes on the home screen.';

  @override
  String shelfCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String get shelfAuto => 'Automatic choice';

  @override
  String get shelfAutoOn =>
      'The shelf now fills itself and changes once a week.';

  @override
  String get shelfAutoHint =>
      'The shelf fills itself and changes once a week: what the child is working on stays, the rest makes room for something else. Tap a material to choose them yourself.';

  @override
  String shelfFull(int max) {
    return 'The shelf already holds $max materials: take one off to put another on.';
  }

  @override
  String shelfCapacityFull(int max) {
    return 'This ability already has $max materials: take one off to put another on.';
  }

  @override
  String shelfTotal(int count, int max) {
    return 'On the shelf: $count of $max';
  }

  @override
  String get shelfRotateNow => 'Change now';

  @override
  String get shelfRotated => 'The shelf has changed.';

  @override
  String get shelfKindStory => 'Story';

  @override
  String get shelfKindGame => 'Game';

  @override
  String get shelfKindActivity => 'Activity';

  @override
  String get gesturePause => 'Pause: let\'s do the gesture';

  @override
  String get gestureStart => 'Ready? Go!';

  @override
  String get huntFound => 'I found it!';

  @override
  String get huntNotFound => 'I can\'t find it';

  @override
  String get huntRest => 'Rest the screen';

  @override
  String get huntRestHint =>
      'Touch the screen when you\'re back. It\'s fine if you\'d rather not.';

  @override
  String get huntTellMe => 'What did you find? Say it out loud.';

  @override
  String get huntRules =>
      'the child looks for one thing at a time, at home or outdoors with you. Only things within reach: no climbing, nothing sharp or fragile, no medicines or cleaning products. Outdoors, only things that have already fallen to the ground. At the end, everything goes back in its place.';

  @override
  String get catMake => 'Make & discover';

  @override
  String get factoryTitle => 'Story factory';

  @override
  String get natureTitle => 'Nature calendar';

  @override
  String factoryAsk(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'who': 'Who is the hero?',
      'place': 'Where do they live?',
      'problem': 'One day, what happens?',
      'feeling': 'How do they feel?',
      'helper': 'Who comes to help?',
      'ending': 'How does it end?',
      'other': '$step',
    });
    return '$_temp0';
  }

  @override
  String get factoryNameIt => 'What shall we call the story?';

  @override
  String get factoryRead => 'Let\'s read the story!';

  @override
  String get factoryMine => 'My stories';

  @override
  String get factoryNew => 'Make one up';

  @override
  String factoryBy(Object name) {
    return 'A story made up by $name';
  }

  @override
  String get factoryEnd => 'The end';

  @override
  String get factoryOtherEnding => 'Try another ending';

  @override
  String factoryDone(Object name) {
    return 'What a lovely story, $name! I\'ll keep it with your stories.';
  }

  @override
  String get factoryMineEmpty => 'The stories you make up will be here.';

  @override
  String factoryWhoA(String who) {
    String _temp0 = intl.Intl.selectLogic(who, {
      'dragon': 'a little dragon',
      'bunny': 'a bunny',
      'robot': 'a kind robot',
      'penguin': 'a penguin',
      'unicorn': 'a unicorn',
      'kitten': 'a kitten',
      'other': '$who',
    });
    return '$_temp0';
  }

  @override
  String factoryWhoThe(String who) {
    String _temp0 = intl.Intl.selectLogic(who, {
      'dragon': 'the little dragon',
      'bunny': 'the bunny',
      'robot': 'the kind robot',
      'penguin': 'the penguin',
      'unicorn': 'the unicorn',
      'kitten': 'the kitten',
      'other': '$who',
    });
    return '$_temp0';
  }

  @override
  String factoryPlaceName(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'forest': 'the forest',
      'room': 'the bedroom',
      'stream': 'the stream',
      'sky': 'the clouds',
      'snow': 'the snow',
      'night': 'the night',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String factoryPlaceIn(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'forest': 'in a forest full of trees',
      'room': 'in a bedroom full of toys',
      'stream': 'near a little stream',
      'sky': 'on a soft cloud',
      'snow': 'in a meadow full of snow',
      'night': 'in a meadow under the stars',
      'other': '$place',
    });
    return '$_temp0';
  }

  @override
  String factoryProblemName(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'the storm',
      'star': 'the fallen star',
      'sadFriend': 'a sad friend',
      'litter': 'the litter',
      'lost': 'the lost path',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factoryProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'a big storm came',
      'star': 'a little star fell from the sky and could not find its way home',
      'sadFriend': 'a friend came along, very sad, and did not want to talk',
      'litter': 'someone left lots of litter on the ground',
      'lost': 'the fog hid the path home',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factorySolution(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'storm': 'they found a dry shelter and waited for the storm to pass',
      'star': 'they built a very tall ladder and took the little star back to the sky',
      'sadFriend': 'they sat next to their friend and listened, until the friend smiled again',
      'litter':
          'they picked up the litter with gloves and put it in the right bins',
      'lost': 'they followed the footprints on the path and found the way home',
      'other': '$problem',
    });
    return '$_temp0';
  }

  @override
  String factoryFeelingName(String feeling) {
    String _temp0 = intl.Intl.selectLogic(feeling, {
      'fear': 'fear',
      'sadness': 'sadness',
      'anger': 'anger',
      'curiosity': 'curiosity',
      'courage': 'courage',
      'other': '$feeling',
    });
    return '$_temp0';
  }

  @override
  String factoryFeeling(String feeling) {
    String _temp0 = intl.Intl.selectLogic(feeling, {
      'fear': 'a little scared',
      'sadness': 'a little sad',
      'anger': 'a little angry',
      'curiosity': 'very curious',
      'courage': 'very brave',
      'other': '$feeling',
    });
    return '$_temp0';
  }

  @override
  String factoryHelperA(String helper) {
    String _temp0 = intl.Intl.selectLogic(helper, {
      'turtle': 'a wise turtle',
      'owl': 'an owl who knows many things',
      'bear': 'a kind bear',
      'bee': 'a very fast bee',
      'other': '$helper',
    });
    return '$_temp0';
  }

  @override
  String factoryEndingName(String ending) {
    String _temp0 = intl.Intl.selectLogic(ending, {
      'party': 'a party',
      'sleep': 'bedtime',
      'hug': 'a hug',
      'snack': 'a snack',
      'other': '$ending',
    });
    return '$_temp0';
  }

  @override
  String factoryPageStart(Object who, Object place) {
    return 'Once upon a time there was $who, who lived $place.';
  }

  @override
  String factoryPageProblem(Object problem) {
    return 'One day, $problem.';
  }

  @override
  String factoryPageFeeling(Object who, Object feeling) {
    return '$who felt $feeling and took a deep breath.';
  }

  @override
  String factoryPageHelp(Object helper, Object solution) {
    return 'Luckily, $helper came along. Together, $solution.';
  }

  @override
  String factoryEnding(String ending, Object who) {
    String _temp0 = intl.Intl.selectLogic(ending, {
      'party': 'That evening $who had a big party with all their friends.',
      'sleep': 'That evening $who fell asleep happily under a warm blanket.',
      'hug': 'In the end $who gave their new friend a big hug.',
      'snack': 'In the end $who shared a snack with everyone, in the sunshine.',
      'other': '$ending',
    });
    return '$_temp0';
  }

  @override
  String get natureAskWeather => 'What\'s the weather like?';

  @override
  String get natureAskSeen => 'What did you see outside?';

  @override
  String get natureUpTo => 'You can choose up to three.';

  @override
  String natureWeather(String weather) {
    String _temp0 = intl.Intl.selectLogic(weather, {
      'sun': 'Sun',
      'clouds': 'Clouds',
      'rain': 'Rain',
      'snow': 'Snow',
      'wind': 'Wind',
      'fog': 'Fog',
      'other': '$weather',
    });
    return '$_temp0';
  }

  @override
  String natureThing(String thing) {
    String _temp0 = intl.Intl.selectLogic(thing, {
      'leaf': 'Leaves',
      'flower': 'Flowers',
      'bird': 'Birds',
      'bug': 'Ladybirds and bugs',
      'snail': 'Snails',
      'fruit': 'Fruit',
      'mushroom': 'Mushrooms',
      'rainbow': 'A rainbow',
      'moon': 'The moon',
      'other': '$thing',
    });
    return '$_temp0';
  }

  @override
  String natureMonthTip(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'It\'s cold and many trees are bare. Can you spot any nests in the branches?',
      'm2': 'The days are getting a little longer. Look for the first buds on the branches.',
      'm3': 'Spring is coming: the first flowers are popping up. What colour are they?',
      'm4': 'Birds are building their nests. Listen: how many different songs can you hear?',
      'm5': 'The meadow is full of flowers and bees. Watch them from a distance: they work so hard!',
      'm6': 'These are the longest days of the year. What can you see in the evening, while it\'s still light?',
      'm7': 'It\'s hot: look for the shade of the trees. Can you hear the cicadas?',
      'm8': 'At night, if the sky is clear, you might see a shooting star. Make a wish!',
      'm9': 'Lots of fruit is ripening: grapes, apples, figs. Which ones do you know?',
      'm10': 'The leaves change colour and fall. How many different colours can you find?',
      'm11': 'Mushrooms are popping up in the woods. We look at them, but we don\'t touch!',
      'm12': 'These are the shortest days of the year. The forest is resting, like in Emma\'s story.',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String natureEquatorTip(String tip) {
    String _temp0 = intl.Intl.selectLogic(tip, {
      'e1': 'When rain is coming, the air smells different. Can you smell it?',
      'e2': 'After a downpour there are puddles. What can you see reflected in them?',
      'e3': 'On dry days the ground gets hard and dusty. Touch it: how does it feel today?',
      'e4': 'With the rain, plants grow fast. Can you find a new leaf, still light green?',
      'e5': 'Look for a huge leaf and a tiny one. How different are they?',
      'e6': 'Is there a tree with flowers or fruit? What colour are they?',
      'e7': 'Ants walk in a line. Follow them with your eyes: where are they going?',
      'e8': 'After the rain a rainbow sometimes appears. How many colours can you count?',
      'other': '$tip',
    });
    return '$_temp0';
  }

  @override
  String get natureThisMonth => 'This month';

  @override
  String natureDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get natureEmptyMonth => 'The calendar is still empty this month.';

  @override
  String get natureToday => 'Today';

  @override
  String get readWord => 'Tap a word to hear it again';

  @override
  String get profileReadAlong => 'Read-along highlighting';

  @override
  String get profileReadAlongHint =>
      'Each word lights up as the voice reads it; tap a word to hear it again.';

  @override
  String get parentTabPrint => 'Printables';

  @override
  String printIntro(Object name) {
    return 'Sheets to print and use away from the screen, in $name\'s language.';
  }

  @override
  String get printEveryday => 'For every day';

  @override
  String get printNameTrace => 'Trace my name';

  @override
  String printNameTraceHint(Object name) {
    return '$name\'s name to trace over with a pencil.';
  }

  @override
  String get printNature => 'This month\'s nature calendar';

  @override
  String printNatureHint(Object name) {
    return 'The month grid to fill in by hand, with what $name has already marked.';
  }

  @override
  String get printGestures => 'Story gestures';

  @override
  String get printGestureHint =>
      'The gesture, two weeks of circles to colour and space to draw it.';

  @override
  String printGesturesEmpty(Object name) {
    return 'The gestures from the stories $name has finished will appear here.';
  }

  @override
  String get printMade => 'Made-up stories';

  @override
  String get printMadeHint =>
      'The story as a booklet, with space for drawings.';

  @override
  String printMadeEmpty(Object name) {
    return 'The stories $name makes up in the factory will appear here.';
  }

  @override
  String get printButton => 'Print';

  @override
  String get pdfDrawHere => 'Draw here';

  @override
  String get pdfGestureTimes => 'Each time you do it, colour in a circle.';

  @override
  String get pdfTraceName => 'Trace your name';

  @override
  String get pdfWeather => 'Weather';

  @override
  String get pdfSeen => 'I saw';

  @override
  String get exitAsk => 'Do you want to leave?';

  @override
  String get exitStay => 'Stay';

  @override
  String get exitLeave => 'Leave';

  @override
  String get profileInteraction => 'How they use the app';

  @override
  String profileInteractionHint(Object name) {
    return 'These start from the age band: move them if $name can do more or less. The app never changes them on its own.';
  }

  @override
  String get profileHands => 'Hands';

  @override
  String get profileHandsHint =>
      'Bigger buttons and wider tracing for beginners.';

  @override
  String get hands1 => 'Tap only';

  @override
  String get hands2 => 'Drag';

  @override
  String get hands3 => 'Precise';

  @override
  String get profileReading => 'Reading';

  @override
  String get profileReadingHint =>
      'No text (voice only), the key phrase only, text with read-along, or full text.';

  @override
  String get readingNone => 'Doesn\'t read yet';

  @override
  String get readingLetters => 'Letters';

  @override
  String get readingWords => 'Words';

  @override
  String get readingFluent => 'Reads well';

  @override
  String get profileAutonomy => 'Independence';

  @override
  String get profileAutonomyHint =>
      'How many choices at a time, repeated instructions, confirmation before leaving.';

  @override
  String get autonomy1 => 'With help';

  @override
  String get autonomy2 => 'Partly alone';

  @override
  String get autonomy3 => 'Alone';

  @override
  String adviceHands(String name, int n) {
    return 'We suggest finer tracing because in the last $n activities $name traced letters on the first try.';
  }

  @override
  String adviceReading(String name, int n) {
    return 'We suggest more text because in the last $n activities $name built words on the first try.';
  }

  @override
  String adviceAutonomy(String name, int n) {
    return 'We suggest more choices at a time because in the last $n activities $name answered right on the first try.';
  }

  @override
  String get adviceSwitchTitle => 'Interaction profile suggestions';

  @override
  String get adviceSwitchHint =>
      'The app looks at the last 7 days of rounds, on this device only, and suggests one step. If you turn it off, it suggests nothing.';

  @override
  String get levelEasier => 'Easier';

  @override
  String get levelSame => 'Same again';

  @override
  String get levelHarder => 'More challenge';

  @override
  String get adviceYes => 'Yes, let\'s try';

  @override
  String get adviceNo => 'Not now';

  @override
  String get sharedPromptGuide => 'Tell me what to do';

  @override
  String get sharedPromptHelp => 'How could we help?';

  @override
  String get homeActivityHeading => 'An activity from the story';

  @override
  String get homeActivitySteps => 'What the child does';

  @override
  String get homeActivityMaterials => 'What you need';

  @override
  String get homeActivityPreparation => 'Preparation';

  @override
  String get homeActivitySupervision => 'Supervision';

  @override
  String get homeActivityAlternatives => 'If something is missing';

  @override
  String get supervisionTogether => 'With the child, start to finish';

  @override
  String get supervisionNearby => 'An adult nearby';

  @override
  String get supervisionFree => 'The child can do it alone';

  @override
  String get usageTitle => 'Screen time';

  @override
  String usageWeek(Object days, Object minutes) {
    return 'Last 7 days, screen on: $minutes min in total, over $days days.';
  }

  @override
  String usageToday(Object minutes) {
    return 'Today: $minutes min.';
  }

  @override
  String usageGestures(Object count) {
    return 'Gestures marked in the diary in the last 7 days: $count. These happened in real life, away from the screen.';
  }

  @override
  String usageLimit(Object minutes) {
    return 'In \"on my own\" mode the companion says goodbye after about $minutes min: the open story or activity is finished calmly first, so it is not a cut-off to the second (change it in the profile).';
  }

  @override
  String get usageCannot =>
      'What the app cannot measure: how much the child is really looking at the screen, listening with the screen off, time on other devices, what you do together away from the screen. Minutes are only one part: what they watch, with whom and how you talk about it matter too.';

  @override
  String get projectPhaseIdea => 'The idea';

  @override
  String get projectPhasePrediction => 'The prediction';

  @override
  String get projectPhaseTest => 'The test';

  @override
  String get projectPhaseRevision => 'The revision';

  @override
  String get projectNoteHint =>
      'If you like, write a couple of lines (optional)';

  @override
  String get projectNext => 'Next';

  @override
  String get projectFinish => 'I\'m done';

  @override
  String get projectHeld => 'It held';

  @override
  String get projectNotYet => 'Not yet';

  @override
  String projectLogTitle(String name) {
    return '$name\'s small projects';
  }

  @override
  String get projectResultHeld => 'it held in the test';

  @override
  String get projectResultNotYet =>
      'not yet in the test: change something and try again';

  @override
  String get profileNoLimit => 'No limit';

  @override
  String get usageNoLimit =>
      'In \"alone\" mode there is no time limit (set it in the profile).';

  @override
  String get winddownNote =>
      'We\'ll say goodbye soon. Let\'s calmly finish what we\'re doing.';

  @override
  String get winddownHint =>
      'Shortly before the end the companion gently says so and offers nothing new. What is open is finished, then it says goodbye: not a cut-off to the second, it can take a few more minutes.';

  @override
  String get gateSetupTitle => 'Choose a grown-up PIN';

  @override
  String get gateSetupBody =>
      '4 to 6 digits. It opens the grown-ups\' area and guards sensitive actions. Right after, you get a recovery code to write on paper: if you forget the PIN you choose a new one without losing anything.';

  @override
  String get gatePinLabel => 'PIN';

  @override
  String get gatePinConfirmLabel => 'Repeat the PIN';

  @override
  String get gatePinMismatch => 'The two PINs do not match';

  @override
  String get gatePinFormat => 'The PIN must have 4 to 6 digits';

  @override
  String get gatePinWrong => 'Wrong PIN';

  @override
  String gatePinWait(String time) {
    return 'Too many attempts. Try again in $time';
  }

  @override
  String get gateForgot => 'I forgot the PIN';

  @override
  String get gateForgotUnavailable =>
      'Could not verify you are an adult with the device lock. Set an adult screen lock and try again.';

  @override
  String get gateDeviceReason => 'Confirm you are an adult to choose a new PIN';

  @override
  String get gateChangePin => 'Change PIN';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbPromiseTitle =>
      'Stories to explore, games to understand, ideas to try together';

  @override
  String get onbPromiseBody =>
      'Mirabò is for children aged 3 to 10 and the adult who plays alongside them.';

  @override
  String get onbFactFree => 'Free';

  @override
  String get onbFactOffline => 'Works offline: the cloud is your choice';

  @override
  String get onbFactOfflineLocal =>
      'Works offline: your data stays on the device';

  @override
  String get onbFactNoAds => 'No ads';

  @override
  String get onbFactNoAccount => 'No account for the child';

  @override
  String get onbSetupTitle => 'Language and age group';

  @override
  String get onbSetupHint =>
      'Everything else can be adjusted later, from the adult area.';

  @override
  String get onbTryTitle => 'A taste of a story';

  @override
  String get onbTryNote =>
      'This is just a preview: the full story opens together with your child.';

  @override
  String get onbHomeTitle => 'From the story to real life';

  @override
  String get onbHomeIntro =>
      'Every story can become a real activity at home. For example:';

  @override
  String get onbGoTitle => 'Ready to try it with your child?';

  @override
  String get onbGoBody =>
      'It takes a few seconds: a companion, a nickname if you like, the age group. No date of birth, no sign-up.';

  @override
  String get onbGoButton => 'Try it with your child';

  @override
  String get onbReopen => 'See the introduction again';

  @override
  String get onbReopenHint => 'The welcome tour, with a taste of a story.';

  @override
  String get onbClose => 'Close';

  @override
  String get dataWipeTitle => 'Delete everything from this tablet?';

  @override
  String get dataWipeBody =>
      'Profiles, progress, diary, creations and generated files (including the name\'s voice) will be permanently deleted, along with the database and its key. The tablet will go back to how it was on first launch. This cannot be undone. Any Google Drive backup is not touched.';

  @override
  String get dataWipeBodyLocal =>
      'Profiles, progress, diary, creations and generated files (including the name\'s voice) will be permanently deleted, along with the database and its key. The tablet will go back to how it was on first launch. This cannot be undone.';

  @override
  String dataWipeTypePrompt(String word) {
    return 'To confirm, type $word';
  }

  @override
  String get dataWipeWord => 'DELETE';

  @override
  String get dataWipeDone =>
      'All Mirabò data has been deleted from this tablet.';

  @override
  String get dataWipeFailed =>
      'Not everything could be deleted. Please try again.';

  @override
  String get dataRemoteButton => 'Also delete the Google Drive backup';

  @override
  String get dataRemoteTitle => 'Delete the Drive backup?';

  @override
  String dataRemoteBody(String account) {
    return 'The backup file in the Drive of $account will be deleted, then the tablet will sign out of Google and revoke the permission given to the app. An internet connection is needed. This cannot be undone. Data on this tablet stays.';
  }

  @override
  String get dataRemoteDone =>
      'Google Drive backup deleted and account disconnected.';

  @override
  String get dataRemoteFailed =>
      'The Google Drive backup was NOT deleted (probably no network, or Google sign-in is needed again). Nothing has changed: connect to the internet and try again.';

  @override
  String get dataOutsideTitle => 'What the app cannot control';

  @override
  String get dataOutsideBody =>
      'Mirabò cannot delete your operating system\'s backups (the phone or tablet backup on iCloud or Google), nor files you have already exported, printed or shared. For those: open the iCloud or Google settings on the device and delete old backups, and remove saved or sent files by hand. If anything is left in your Drive, you can find and delete it in Drive > Settings > Manage apps.';

  @override
  String get dataOutsideBodyLocal =>
      'Mirabò cannot delete your operating system\'s backups (the phone or tablet backup on iCloud or Google), nor files you have already exported, printed or shared. For those: open the iCloud or Google settings on the device and delete old backups, and remove saved or sent files by hand.';

  @override
  String get gateRecoveryTitle => 'Your recovery code';

  @override
  String get gateRecoveryBody =>
      'Write it on paper and keep it away from the tablet: you need it if you forget the PIN. It won\'t be shown again.';

  @override
  String get gateRecoveryWritten => 'I\'ve written it down';

  @override
  String get gateRecoveryAsk =>
      'Enter the recovery code you got when you chose the PIN.';

  @override
  String get gateRecoveryLabel => 'Recovery code';

  @override
  String get gateRecoveryWrong => 'Wrong code';

  @override
  String get gateUseDevice => 'Use the tablet\'s screen lock';

  @override
  String get gateDeviceOff =>
      'Recovery with the tablet\'s screen lock is off: the recovery code is needed.';

  @override
  String get gateDeviceRecovery =>
      'PIN recovery with the tablet\'s screen lock';

  @override
  String get gateDeviceRecoveryHint =>
      'Turn it off if your child knows the tablet\'s code or has their fingerprint registered: then the PIN can only be recovered with the recovery code.';

  @override
  String get gateNewRecovery => 'New recovery code';

  @override
  String gateResetNotice(String date, String how) {
    return 'The PIN was reset on $date $how. If it wasn\'t you, change it and turn off recovery with the tablet\'s screen lock.';
  }

  @override
  String get gateResetHowCode => 'with the recovery code';

  @override
  String get gateResetHowDevice => 'with the tablet\'s screen lock';

  @override
  String get gateResetSeen => 'OK';

  @override
  String get voiceMissingChild =>
      'There\'s no voice: ask a grown-up to read with you';

  @override
  String voiceMissingParent(String language) {
    return 'This tablet has no text-to-speech voice for $language. A child who can\'t read yet needs an adult to read along: for now the text stays visible. Install the voice from the tablet\'s settings (Text-to-speech on Android, Spoken Content on iPad). Stories with recorded audio still play.';
  }

  @override
  String get saveFailedBanner =>
      'The last change couldn\'t be saved and may not be kept. This is usually about free space on the tablet.';

  @override
  String get saveFailedDismiss => 'Got it';

  @override
  String get startupFailedTitle => 'Mirabò can\'t open its saved data';

  @override
  String get startupFailedBody =>
      'Nothing has been deleted. Try again; if it happens again, check the tablet\'s free space and restart it.';

  @override
  String get startupTooNewBody =>
      'The data on this tablet comes from a newer version of Mirabò. Nothing has been deleted: update the app from the store.';

  @override
  String get startupRetry => 'Try again';

  @override
  String storageResetNotice(String date) {
    return 'On $date Mirabò started over: the data on this tablet was encrypted with a key the tablet no longer has (this can happen, for example, after restoring from another device), so it couldn\'t be read.';
  }
}
