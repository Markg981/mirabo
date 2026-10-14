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
  String get seeYouTomorrow => 'See you tomorrow!';

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
  String get goodbyeBody =>
      'That was fun. Go and find a grown-up: see you next time!';

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
  String get memoryIntro => 'Find the pairs of matching animals.';

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
  String get gameShapesDescMid => 'Five shapes to drag into the right hole.';

  @override
  String get gameShapesDescBig => 'Six shapes, big and small: watch the size.';

  @override
  String get shapesIntro => 'Put each shape in its hole.';

  @override
  String get shapesIntroBig =>
      'Put each shape in its hole. Watch the size: big and small.';

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
      'In \"together\" mode, dialogue pauses appear for the two of you. In \"on my own\" mode, your child answers by tapping and stories about safety and the body stay hidden.';

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
  String get parentData => 'Where the data lives';

  @override
  String get parentDataHint =>
      'Profiles, diary and progress stay on this device, encrypted. The Google Drive backup below is optional.';

  @override
  String get parentWipe => 'Delete all data';

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
  String get diaryTogether => 'together';

  @override
  String get diaryAlone => 'on their own';

  @override
  String diaryChose(Object answer) {
    return 'at the pause they chose: \"$answer\"';
  }

  @override
  String get gesturesTitle => 'Real-life gestures';

  @override
  String gesturesIntro(String companion, String name) {
    return '$companion only grows when $name really does the gesture from a story, not with time spent on the app. When you\'ve done it, mark it here.';
  }

  @override
  String gesturesNext(int count, String companion) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more gestures',
      one: '1 more gesture',
    );
    return '$_temp0 until $companion\'s next step.';
  }

  @override
  String gesturesAllGrown(String companion) {
    return '$companion has reached the last step: the gestures are still worth doing.';
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
      'The step-by-step presentation is in the Montessori activities.';

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
  String get weekAllTogether => 'You always listened together.';

  @override
  String get weekAllAlone =>
      'Listened on their own: next time you could listen together.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together times out of $total you were together.',
      one: 'Once out of $total you were together.',
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
    return 'How $name is growing';
  }

  @override
  String get growthIntro =>
      'The only comparison is with themselves, a month ago. The app sees a small part of their day: for any concerns about development, talk to your paediatrician or teacher.';

  @override
  String get growthEmpty =>
      'No activities in the last 30 days. Once they do some, you\'ll see the milestones here.';

  @override
  String get growthOffscreen =>
      'Where there\'s no progress, try the off-screen activity suggested in the card: not more time on the app.';

  @override
  String growthNew(Object count) {
    return 'In the last 30 days: $count rounds. A month ago they hadn\'t tried it yet.';
  }

  @override
  String growthCompare(Object before, Object now) {
    return 'Today: $now · a month ago: $before (grey border).';
  }

  @override
  String stageLabel(String stage) {
    String _temp0 = intl.Intl.selectLogic(stage, {
      'starting': 'getting started',
      'working': 'working on it',
      'canDo': 'can do it',
      'alone': 'does it alone',
      'other': '$stage',
    });
    return '$_temp0';
  }

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(skill, {
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
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageHint =>
      'Stories, activities, games and the companion\'s voice will be in this language.';

  @override
  String get profileCompanion => 'The companion';

  @override
  String get profileCompanionEditHint =>
      'The companion is chosen only once: it\'s their best friend.';

  @override
  String get profileCompanionNewHint =>
      'Let your child choose. It\'s chosen only once and doesn\'t change.';

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
  String adviceHands(Object name) {
    return 'Lately $name traces letters on the first try: would you like to try finer tracing?';
  }

  @override
  String adviceReading(Object name) {
    return 'Lately $name builds words on the first try: would you like to show more text?';
  }

  @override
  String adviceAutonomy(Object name) {
    return 'Lately $name answers right on the first try: would you like to try more choices at a time?';
  }

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
}
