// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mirabò';

  @override
  String get appTagline => 'Cuentos y pequeños pasos para crecer.';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Hecho';

  @override
  String get finish => 'Fin';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get listenAgain => 'Escuchar otra vez';

  @override
  String get readAgain => 'Leer otra vez';

  @override
  String get seeYouTomorrow => '¡Chao!';

  @override
  String get go => '¡Vamos!';

  @override
  String get home => 'Casa';

  @override
  String get parentArea => 'Zona de mayores';

  @override
  String get modeTogether => 'Juntos';

  @override
  String get modeAlone => 'Yo solo';

  @override
  String stepOf(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String homeHello(Object name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeQuestion => '¿Qué hacemos hoy?';

  @override
  String get homeOneStory => 'Un cuento';

  @override
  String goodbyeTitle(Object name) {
    return '¡Por hoy ya está, $name!';
  }

  @override
  String get goodbyeBody =>
      'Ha sido bonito. Llama a un mayor: ¡hasta la próxima!';

  @override
  String closingTitle(Object name) {
    return '¡Buen trabajo, $name!';
  }

  @override
  String get closingBody =>
      'Has hecho un buen camino. Ahora puedes dejar la tablet: todo queda como está, lo encuentras cuando quieras.';

  @override
  String get closingBack => 'Volver a casa';

  @override
  String get closingA11y => 'He terminado';

  @override
  String switchChildA11y(Object name) {
    return 'Cambiar de niño. Ahora juega $name';
  }

  @override
  String get chooseWhoPlays => '¿Quién juega hoy?';

  @override
  String chooseWith(Object companion) {
    return 'con $companion';
  }

  @override
  String get chooseAdd => 'Añadir';

  @override
  String get chooseAddHint => 'para los mayores';

  @override
  String get chooseAddA11y => 'Añadir un niño';

  @override
  String get catEmpty => 'Aquí no hay nada para hoy.';

  @override
  String capacityLabel(String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': 'Yo y los demás',
        'mani': 'Las manos',
        'sensi': 'Los sentidos',
        'parole': 'Las palabras',
        'pensare': 'Contar y pensar',
        'mondo': 'El mundo',
        'other': '$capacity',
      },
    );
    return '$_temp0';
  }

  @override
  String get badgeAtHome => 'En casa';

  @override
  String get badgeTogether => 'Juntos';

  @override
  String areaLabel(String area) {
    String _temp0 = intl.Intl.selectLogic(
      area,
      {
        'cognitivo': 'Preparación',
        'autonomia': 'Autonomía',
        'sociale': 'En clase',
        'paure': 'Primer día',
        'vitaPratica': 'Vida práctica',
        'sensoriale': 'Sensorial',
        'linguaggio': 'Lenguaje y escritura',
        'matematica': 'Matemáticas',
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
        'emozioni': 'Emociones',
        'inclusione': 'Juntos',
        'ambiente': 'El bosque',
        'sicurezza': 'Mi cuerpo',
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
        'emozioni': 'Emociones y conflictos',
        'inclusione': 'Diversidad e inclusión',
        'ambiente': 'Naturaleza y seres vivos',
        'sicurezza': 'Seguridad y cuerpo',
        'other': '$world',
      },
    );
    return '$_temp0';
  }

  @override
  String get storyKeyPhrase => 'La frase para recordar';

  @override
  String get activityTryAgain => 'Inténtalo otra vez.';

  @override
  String get activityHelp => 'Mira bien. Yo te ayudo.';

  @override
  String get activityHelpButton => 'Ayuda';

  @override
  String get activityHelpPoint =>
      'Mira el que tiene color: puede ser ese. Prueba tú.';

  @override
  String get activityHelpDemo =>
      'Te lo enseño: mira el que se ha iluminado y tócalo con suavidad. Ahora prueba tú.';

  @override
  String get checklistPrompt => '¿Qué está ya listo?';

  @override
  String get checklistSay => '¿Qué está ya listo para mañana?';

  @override
  String get checklistAlone => 'yo solo';

  @override
  String get checklistAllDone => 'Todo listo, buenas noches';

  @override
  String get enoughForToday => 'Por hoy ya basta';

  @override
  String get countdownPick => 'Elige la fecha';

  @override
  String get countdownToday => '¡Es hoy!';

  @override
  String get countdownTodaySay => '¡Hoy es el día!';

  @override
  String countdownDaysTo(int count, String event) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días para: $event',
      one: 'Falta 1 día para: $event',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysSay(int count, String task) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días. $task',
      one: 'Falta 1 día. $task',
    );
    return '$_temp0';
  }

  @override
  String exploreTap(Object scene) {
    return 'Toca para explorar $scene';
  }

  @override
  String exploreSay(Object scene) {
    return 'Esto es $scene. Toca para descubrir.';
  }

  @override
  String get exploreAllSeen => '¡Lo he visto todo!';

  @override
  String get exploreEnough => 'Por hoy ya basta';

  @override
  String get patternPrompt => '¿Qué viene después?';

  @override
  String get presentationWhatYouNeed => 'Qué hace falta';

  @override
  String presentationWhatYouNeedSay(Object items) {
    return 'Qué hace falta: $items';
  }

  @override
  String get presentationReady => 'Todo listo';

  @override
  String get presentationPrepare =>
      'Prepara todo en una bandeja antes de llamar al niño. Muestra los pasos una vez, despacio y sin hablar; luego deja que lo haga.';

  @override
  String presentationStep(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get presentationWorkAlone => 'Ahora trabaja solo';

  @override
  String presentationYourTurnSay(Object name) {
    return 'Ahora te toca a ti, $name. Guardamos la tableta.';
  }

  @override
  String get presentationHowDidItGo => 'Para el mayor: ¿cómo ha ido?';

  @override
  String get presentationControl => 'Control del error';

  @override
  String get presentationObserve => 'Qué observar';

  @override
  String get presentationMarkLater =>
      'Márcalo cuando haya terminado, aunque sea un rato después. No lo corrijas mientras trabaja.';

  @override
  String get presentationWatched => 'Ha mirado';

  @override
  String get presentationDid => 'Lo ha hecho';

  @override
  String get presentationAlone => 'Solo';

  @override
  String get presentationRepeat => 'Quiere repetir';

  @override
  String get forTheAdult => 'Para el mayor';

  @override
  String turnYou(Object name) {
    return 'Te toca a ti, $name';
  }

  @override
  String get turnAdult => 'Le toca al mayor';

  @override
  String spellSay(Object word) {
    return 'Forma: $word';
  }

  @override
  String get spellSentence => 'Forma la frase';

  @override
  String get spellWord => 'Forma la palabra';

  @override
  String tracePrompt(Object label) {
    return 'Repasa con el dedo: $label';
  }

  @override
  String get traceRestart => 'Empiezo de nuevo';

  @override
  String gameWellDone(Object name) {
    return '¡Muy bien, $name!';
  }

  @override
  String get gameNiceGame => '¡Qué buena partida!';

  @override
  String gameWellDoneSay(Object name) {
    return '¡Muy bien, $name! ¡Qué buena partida!';
  }

  @override
  String get gameAgain => 'Otra vez';

  @override
  String get gameEnough => 'Ya basta';

  @override
  String get gameMemoryTitle => 'Memoria de animales';

  @override
  String gameMemoryDesc(int count) {
    return 'Encuentra las parejas: $count parejas.';
  }

  @override
  String get memoryIntro => 'Encuentra las parejas de animales iguales.';

  @override
  String get memoryCovered => 'Carta boca abajo';

  @override
  String animalName(String animal) {
    String _temp0 = intl.Intl.selectLogic(
      animal,
      {
        'dog': 'el perro',
        'cat': 'el gato',
        'rabbit': 'el conejo',
        'fox': 'el zorro',
        'bear': 'el oso',
        'panda': 'el panda',
        'frog': 'la rana',
        'monkey': 'el mono',
        'lion': 'el león',
        'tiger': 'el tigre',
        'cow': 'la vaca',
        'pig': 'el cerdo',
        'other': '$animal',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameBalloonsTitle => 'Los globos';

  @override
  String get gameBalloonsDescSmall => 'Explota los globos.';

  @override
  String get gameBalloonsDescMid =>
      'Explota solo los del color que dice el compañero.';

  @override
  String get gameBalloonsDescBig =>
      'Explota los números en orden, del 1 al 10.';

  @override
  String get balloonsPopAll => '¡Explota los globos!';

  @override
  String balloonsPopColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rojos',
        'blue': 'azules',
        'green': 'verdes',
        'yellow': 'amarillos',
        'purple': 'morados',
        'other': '$color',
      },
    );
    return 'Explota solo los globos $_temp0.';
  }

  @override
  String balloonsNowColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rojos',
        'blue': 'azules',
        'green': 'verdes',
        'yellow': 'amarillos',
        'purple': 'morados',
        'other': '$color',
      },
    );
    return 'Ahora los globos $_temp0.';
  }

  @override
  String balloonsOnlyColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rojos',
        'blue': 'azules',
        'green': 'verdes',
        'yellow': 'amarillos',
        'purple': 'morados',
        'other': '$color',
      },
    );
    return 'Solo los $_temp0';
  }

  @override
  String get balloonsNumbersStart =>
      'Explota los números en orden. Empieza por el uno.';

  @override
  String balloonsNow(Object n) {
    return 'Ahora el $n.';
  }

  @override
  String balloonsFind(Object n) {
    return 'Busca el $n';
  }

  @override
  String balloonsWrongNumber(Object got, Object want) {
    return 'Ese es el $got. Busca el $want.';
  }

  @override
  String get balloonsDone => '¡Hecho!';

  @override
  String balloonA11yNumber(Object n) {
    return 'Globo $n';
  }

  @override
  String balloonA11yColor(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'red': 'rojo',
        'blue': 'azul',
        'green': 'verde',
        'yellow': 'amarillo',
        'purple': 'morado',
        'other': '$color',
      },
    );
    return 'Globo $_temp0';
  }

  @override
  String get gameShapesTitle => 'Cada forma en su sitio';

  @override
  String get gameShapesDescSmall =>
      'Tres formas para arrastrar al hueco correcto.';

  @override
  String get gameShapesDescMid =>
      'Cinco formas para arrastrar al hueco correcto.';

  @override
  String get gameShapesDescBig =>
      'Seis formas, grandes y pequeñas: atención al tamaño.';

  @override
  String get shapesIntro => 'Pon cada forma en su hueco.';

  @override
  String get shapesIntroBig =>
      'Pon cada forma en su hueco. Atención al tamaño: grandes y pequeñas.';

  @override
  String shapesWrong(Object shape) {
    return 'Esto es $shape. Prueba otro hueco.';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(
      shape,
      {
        'circle': 'el círculo',
        'square': 'el cuadrado',
        'triangle': 'el triángulo',
        'star': 'la estrella',
        'heart': 'el corazón',
        'hexagon': 'el hexágono',
        'circleSmall': 'el círculo pequeño',
        'squareSmall': 'el cuadrado pequeño',
        'other': '$shape',
      },
    );
    return '$_temp0';
  }

  @override
  String get gameDrawingTitle => 'Dibuja y colorea';

  @override
  String get gameDrawingDesc => 'Una hoja en blanco, los colores y los sellos.';

  @override
  String get drawingIntro => 'Elige un color y dibuja con el dedo.';

  @override
  String get drawingSheet => 'Hoja de dibujo';

  @override
  String get drawingEraser => 'Goma';

  @override
  String get drawingUndo => 'Deshacer';

  @override
  String get drawingNewSheet => 'Hoja nueva';

  @override
  String get gameXyloTitle => 'El xilófono';

  @override
  String get gameXyloDescSmall => 'Toca libremente.';

  @override
  String gameXyloDescBig(Object song) {
    return 'Toca libremente o aprende \"$song\".';
  }

  @override
  String get xyloNotes => 'do re mi fa sol la si do';

  @override
  String get xyloSong => 'Martinillo';

  @override
  String get xyloIntro => 'Toca las barras y haz música.';

  @override
  String xyloIntroSong(Object song) {
    return 'Toca lo que quieras, o aprende $song.';
  }

  @override
  String get xyloFree => 'Toca libre';

  @override
  String get xyloFreeSay => 'Toca lo que quieras.';

  @override
  String get xyloSongSay => 'Toca la barra que se ilumina.';

  @override
  String xyloNoteA11y(Object note) {
    return 'Nota $note';
  }

  @override
  String get gamePuzzleTitle => 'El rompecabezas deslizante';

  @override
  String get gamePuzzleDesc =>
      'Ordena los números del 1 al 8 deslizando las fichas.';

  @override
  String get puzzleIntro =>
      'Desliza las fichas para ponerlas en orden, del uno al ocho.';

  @override
  String puzzleTileA11y(Object n) {
    return 'Ficha $n';
  }

  @override
  String get gateTitle => 'Zona para mayores';

  @override
  String gateQuestion(Object a, Object b) {
    return '¿Cuánto es $a × $b?';
  }

  @override
  String get gateWrong => 'Inténtalo otra vez';

  @override
  String get gateEnter => 'Entrar';

  @override
  String get parentTabSession => 'Sesión';

  @override
  String get parentTabProfiles => 'Perfiles';

  @override
  String get parentTabCards => 'Cómo hablarlo';

  @override
  String get parentTabDiary => 'Diario';

  @override
  String get parentTabGrowth => 'Desarrollo';

  @override
  String get parentTabShelf => 'Estante';

  @override
  String get parentHowUse => '¿Cómo usáis la app ahora?';

  @override
  String get parentHowUseHint =>
      'En el modo \"juntos\" aparecen las pausas de diálogo para los dos. En el modo \"yo solo\" el niño responde tocando y los cuentos sobre seguridad y cuerpo quedan ocultos.';

  @override
  String get parentPlace => 'Dónde vivís';

  @override
  String get parentPlaceHint =>
      'Lo usa el calendario de la naturaleza: los consejos siguen las estaciones de vuestra casa.';

  @override
  String hemisphere(String place) {
    String _temp0 = intl.Intl.selectLogic(
      place,
      {
        'north': 'Hemisferio norte',
        'south': 'Hemisferio sur',
        'equator': 'Cerca del ecuador',
        'other': '$place',
      },
    );
    return '$_temp0';
  }

  @override
  String get parentData => 'Tus datos';

  @override
  String get parentDataHint =>
      'Los perfiles, el diario y el progreso se quedan en este dispositivo, cifrados. La copia en Google Drive de abajo es opcional.';

  @override
  String get parentWipe => 'Eliminar todos los datos de Mirabò en esta tableta';

  @override
  String get parentWipeConfirmTitle => '¿Borrar todo?';

  @override
  String get parentWipeConfirm =>
      'Los perfiles y el diario se borrarán de este dispositivo. No se puede deshacer. La copia en Google Drive, si existe, se queda donde está.';

  @override
  String get parentWipeYes => 'Borrar';

  @override
  String get backupTitle => 'Copia en Google Drive';

  @override
  String get backupHint =>
      'Opcional. La copia va a una carpeta oculta de tu Drive que la app no puede usar para nada más, y está cifrada con una contraseña que solo tú conoces. Sirve para pasar a una tableta nueva o reinstalar la app sin perder nada.';

  @override
  String get backupOff => 'Desactivada: los datos solo están en esta tableta.';

  @override
  String backupOnAccount(String account) {
    return 'Activada con $account';
  }

  @override
  String backupLast(String date) {
    return 'Última copia: $date';
  }

  @override
  String get backupNever => 'Todavía no hay ninguna copia.';

  @override
  String get backupAutoFailed =>
      'La última copia automática no ha funcionado. Prueba con \"Hacer la copia ahora\".';

  @override
  String get backupEnable => 'Activar la copia';

  @override
  String get backupNow => 'Hacer la copia ahora';

  @override
  String get backupRestore => 'Restaurar desde Drive';

  @override
  String get backupDisable => 'Desactivar';

  @override
  String get backupPasswordTitle => 'Elige la contraseña de la copia';

  @override
  String get backupPasswordHint =>
      'La copia se cifra con esta contraseña antes de salir de la tableta. La necesitarás para restaurarla en otro dispositivo: si la olvidas, la copia no se puede recuperar, ni siquiera nosotros.';

  @override
  String get backupPassword => 'Contraseña';

  @override
  String get backupPasswordRepeat => 'Repite la contraseña';

  @override
  String backupPasswordShort(int n) {
    return 'Al menos $n caracteres.';
  }

  @override
  String get backupPasswordMismatch => 'Las dos contraseñas no coinciden.';

  @override
  String get backupRestorePasswordTitle => 'Contraseña de la copia';

  @override
  String get backupRestorePasswordHint =>
      'La contraseña que elegiste al activar la copia.';

  @override
  String get backupWrongPassword => 'Contraseña incorrecta.';

  @override
  String get backupNone =>
      'Esta cuenta de Google todavía no tiene ninguna copia de Mirabò.';

  @override
  String get backupExistsTitle => 'Ya hay una copia';

  @override
  String get backupExists =>
      'Esta cuenta de Google ya tiene una copia de Mirabò. ¿Quieres restaurarla en esta tableta o sustituirla con los datos de esta tableta?';

  @override
  String get backupExistsRestore => 'Restaurar';

  @override
  String get backupExistsReplace => 'Sustituir';

  @override
  String get backupRestoreConfirmTitle => '¿Restaurar la copia?';

  @override
  String get backupRestoreConfirm =>
      'Los perfiles, el diario y el progreso de esta tableta se sustituirán por los de la copia.';

  @override
  String get backupDisableTitle => '¿Desactivar la copia?';

  @override
  String get backupDisableConfirm =>
      'La tableta deja de hacer copias y olvida la cuenta. Puedes conservar la copia en Drive para restaurarla más adelante, o borrarla.';

  @override
  String get backupDisableKeep => 'Desactivar y conservar la copia';

  @override
  String get backupDisableDelete => 'Desactivar y borrar la copia';

  @override
  String get backupDone => 'Copia completada.';

  @override
  String get backupRestored => 'Copia restaurada.';

  @override
  String get backupError =>
      'No ha funcionado. Comprueba la conexión y vuelve a intentarlo.';

  @override
  String get backupContinue => 'Continuar';

  @override
  String get profileRestoreLink =>
      '¿Ya usabas Mirabò? Restaurar desde Google Drive';

  @override
  String get parentNewProfile => 'Nuevo perfil';

  @override
  String parentProfileLine(String age, String companion, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentos',
      one: '1 cuento',
    );
    return '$age · compañero $companion · $_temp0';
  }

  @override
  String get diaryEmpty => 'Ningún cuento en los últimos 30 días.';

  @override
  String get diaryTogether => 'juntos';

  @override
  String get diaryAlone => 'solo';

  @override
  String diaryChose(Object answer) {
    return 'en la pausa eligió: \"$answer\"';
  }

  @override
  String get gesturesTitle => 'Gestos en la vida real';

  @override
  String gesturesIntro(String companion, String name) {
    return '$companion solo crece cuando $name hace de verdad el gesto de una historia, no con el tiempo pasado en la app. Cuando lo hayáis hecho, márcalo aquí.';
  }

  @override
  String gesturesNext(int count, String companion) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count gestos',
      one: 'Falta 1 gesto',
    );
    return '$_temp0 para la próxima etapa de $companion.';
  }

  @override
  String gesturesAllGrown(String companion) {
    return '$companion ha llegado a la última etapa: los gestos siguen valiendo la pena.';
  }

  @override
  String gesturesEmpty(String name) {
    return 'Aquí aparecen los gestos de las historias que $name ha terminado.';
  }

  @override
  String get gestureMark => 'Hecho hoy';

  @override
  String get gestureMarked => 'Marcado hoy';

  @override
  String gestureTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hecho $count veces',
      one: 'hecho 1 vez',
      zero: 'todavía no hecho',
    );
    return '$_temp0';
  }

  @override
  String get ideaTitle => 'Una idea para hoy';

  @override
  String ideaIntro(String name) {
    return 'Algo pequeño para hacer con $name, lejos de la pantalla. Cambia cada día.';
  }

  @override
  String ideaFromStory(String story) {
    return 'De la historia «$story»';
  }

  @override
  String ideaHome(String title, String area) {
    return 'Con las manos: $title ($area)';
  }

  @override
  String get ideaHomeHint =>
      'La presentación paso a paso está en las actividades Montessori.';

  @override
  String ideaReasonRepeat(String name) {
    return '$name ha pedido repetirla';
  }

  @override
  String ideaReasonStory(String name, String story) {
    return '$name ha escuchado «$story»';
  }

  @override
  String get ideaReasonTryAlone =>
      'La habéis hecho juntos: la próxima vez puede intentarlo con autonomía';

  @override
  String ideaReasonCapacity(String name, String capacity) {
    String _temp0 = intl.Intl.selectLogic(
      capacity,
      {
        'insieme': 'A $name le encanta estar con los demás',
        'mani': 'A $name le encanta trabajar con las manos',
        'sensi': 'A $name le encanta explorar con los sentidos',
        'parole': 'A $name le encanta jugar con las palabras',
        'pensare': 'A $name le encanta contar y razonar',
        'mondo': 'A $name le encanta descubrir el mundo',
        'other': '$name lo elige a menudo',
      },
    );
    return '$_temp0';
  }

  @override
  String get ideaAnother => 'Otra idea';

  @override
  String ideaReasonNone(String name) {
    return 'Una presentación adecuada a la edad de $name';
  }

  @override
  String get ideaNeedsNothing => 'Lo necesario: nada especial';

  @override
  String get ideaPrepNone => 'Preparación: ninguna';

  @override
  String get ideaPrepQuick => 'Preparación: unos 2 minutos';

  @override
  String get ideaPrepShort => 'Preparación: unos 5 minutos';

  @override
  String ideaVariant(String text) {
    return 'Variante: $text';
  }

  @override
  String ideaVariantStory(String name) {
    return 'si hoy no es el momento, déjenlo para mañana; o dejen que $name guíe y les diga qué hacer.';
  }

  @override
  String get ideaVariantHome =>
      'pasados unos días, déjenlo hacerlo solo, sin volver a presentarlo.';

  @override
  String get ideaNoMaterials => 'No tenemos estos materiales';

  @override
  String get ideaNotInterested => 'No nos interesa';

  @override
  String ideaEmpty(String name) {
    return 'Cuando $name termine una historia, aquí encontrarás una idea para hacer juntos.';
  }

  @override
  String weekTitle(String name) {
    return 'La semana de $name';
  }

  @override
  String get weekIntro =>
      'Los últimos 7 días, contados. Sin notas: solo lo que ha pasado.';

  @override
  String weekStories(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ha escuchado $count historias: $titles.',
      one: 'Ha escuchado una historia: $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekAllTogether => 'Siempre las habéis escuchado juntos.';

  @override
  String get weekAllAlone =>
      'Las ha escuchado solo: la próxima podéis escucharla juntos.';

  @override
  String weekTogether(int together, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      together,
      locale: localeName,
      other: '$together veces de $total estabais juntos.',
      one: 'Una vez de $total estabais juntos.',
    );
    return '$_temp0';
  }

  @override
  String weekChoice(String story, String answer) {
    return 'En «$story», en la pausa eligió: «$answer».';
  }

  @override
  String weekKeyPhrase(String phrase) {
    return 'Una frase para repetir juntos: «$phrase»';
  }

  @override
  String weekGestures(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En la vida real hizo $count gestos, de las historias $titles.',
      one: 'En la vida real hizo el gesto de $titles.',
    );
    return '$_temp0';
  }

  @override
  String get weekNoGestures =>
      'Ningún gesto marcado: si lo habéis hecho, márcalo aquí abajo.';

  @override
  String weekHome(String titles) {
    return 'Con las manos, lejos de la pantalla: $titles.';
  }

  @override
  String get weekEmpty =>
      'Esta semana no hay historias ni gestos marcados. No pasa nada: las semanas lejos de la pantalla también cuentan.';

  @override
  String growthTitle(Object name) {
    return 'Qué ha explorado $name';
  }

  @override
  String get growthIntro =>
      'Un diario de lo que ha elegido y retomado en los últimos 30 días, no una evaluación: toques, velocidad y finalizaciones no dicen lo que sabe hacer. Sin comparaciones, ni con otros niños ni con hace un mes.';

  @override
  String get growthEmpty =>
      'Ninguna actividad en los últimos 30 días. Cuando elija alguna, aquí verás los temas que ha explorado.';

  @override
  String get growthOffscreen =>
      'Donde no hay mejora, prueba la actividad fuera de la pantalla sugerida en la ficha: no más tiempo en la app.';

  @override
  String exploreTheme(String theme) {
    return 'Ha explorado: $theme';
  }

  @override
  String exploreResumed(int days) {
    return 'Lo ha retomado en $days días distintos.';
  }

  @override
  String get exploreOnce => 'Lo ha probado un día.';

  @override
  String get exploreCreationsTitle => 'Cuentos que ha inventado y guardado';

  @override
  String get exploreCreationsEmpty =>
      'Todavía no hay cuentos inventados en la fábrica de cuentos.';

  @override
  String get exploreNotesTitle => 'Tus observaciones';

  @override
  String get exploreNotesHint =>
      'Algo que has notado: una pregunta, un juego, una frase...';

  @override
  String get exploreNotesAdd => 'Añadir';

  @override
  String get exploreNotesEmpty =>
      'Sin observaciones. Se quedan solo en este dispositivo.';

  @override
  String get exploreNotesDelete => 'Eliminar la observación';

  @override
  String skillLabel(String skill) {
    String _temp0 = intl.Intl.selectLogic(
      skill,
      {
        'progetti_aperti': 'Pequeños proyectos',
        'suoni_iniziali': 'Sonidos y letras',
        'pregrafismo': 'Trazar letras',
        'numeri': 'Números y cantidades',
        'logica': 'Lógica y secuencias',
        'routine_sera': 'Preparar las cosas para mañana',
        'routine_mattino': 'La rutina de la mañana',
        'vestirsi': 'Vestirse solo',
        'mensa': 'En el comedor',
        'turno_e_condivisione': 'Esperar el turno y compartir',
        'chiedere_aiuto': 'Pedir ayuda',
        'distacco': 'La despedida de la mañana',
        'conoscere_la_scuola': 'Conocer la escuela',
        'primo_giorno': 'El primer día',
        'travasi': 'Trasvasar y verter',
        'motricita_fine': 'Motricidad fina',
        'cura_ambiente': 'Cuidado del entorno',
        'dimensioni': 'Tamaños y seriación',
        'colori': 'Colores',
        'forme': 'Formas',
        'tatto': 'Tacto',
        'udito': 'Oído',
        'scrittura': 'Escritura',
        'vocabolario': 'Vocabulario',
        'decine': 'Decenas y unidades',
        'geografia': 'Geografía',
        'botanica': 'Botánica',
        'other': '$skill',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileWelcome => 'Bienvenidos a Mirabò';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileNew => 'Nuevo perfil';

  @override
  String get profileChild => 'El niño';

  @override
  String get profileFirstRunHint =>
      'Esta parte la rellena un adulto. Se tarda un minuto y luego la tableta pasa al niño.';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileNameHint => 'El compañero lo llamará así';

  @override
  String get profileAge => 'Edad';

  @override
  String profileYears(Object range) {
    return '$range años';
  }

  @override
  String ageBandLabel(String band) {
    String _temp0 = intl.Intl.selectLogic(
      band,
      {
        'small': 'Pequeños',
        'mid': 'Primeros pasos',
        'big': 'Mayores',
        'other': '$band',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLanguageHint =>
      'Cuentos, actividades, juegos y la voz del compañero estarán en este idioma.';

  @override
  String get profileCompanion => 'El compañero';

  @override
  String get profileCompanionEditHint =>
      'El compañero se elige una sola vez: es su mejor amigo.';

  @override
  String get profileCompanionNewHint =>
      'Dejad que elija el niño. Se elige una sola vez y no se cambia.';

  @override
  String get profileWorlds => 'Mundos de los cuentos';

  @override
  String get profileWorldsHint =>
      'Elegid los temas que el niño encontrará en su biblioteca.';

  @override
  String get profileSafetyTogether => '\"Mi cuerpo\" solo en modo juntos';

  @override
  String get profileSafetyTogetherHint =>
      'Recomendado: los cuentos sobre seguridad y cuerpo se leen con un adulto.';

  @override
  String get profileAccess => 'Accesibilidad y tiempo';

  @override
  String get profileDyslexia => 'Texto de fácil lectura';

  @override
  String get profileDyslexiaHint =>
      'Tipografía Lexend, más espacio entre letras y líneas.';

  @override
  String get profileLowStim => 'Baja estimulación';

  @override
  String get profileLowStimHint => 'Colores suaves, sin animaciones.';

  @override
  String get profileAloneSession => 'Sesión \"yo solo\"';

  @override
  String profileMinutes(Object count) {
    return '$count minutos';
  }

  @override
  String profileMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String get profileDelete => 'Borrar este perfil';

  @override
  String get profileMissingName => 'Falta el nombre';

  @override
  String get profileMissingCompanion => 'Falta el compañero';

  @override
  String get profileStart => 'Empezamos';

  @override
  String get translationDraft => 'Traducción en revisión';

  @override
  String get lessonNaming => 'Esto es';

  @override
  String get lessonShow => '¿Dónde está?';

  @override
  String get lessonTell => '¿Cómo se llama?';

  @override
  String shelfTitle(Object name) {
    return 'El estante de $name';
  }

  @override
  String shelfHint(String name, int max, int per) {
    return 'Pocos materiales a la vez, como en los estantes de un ambiente Montessori: $name elige libremente entre los que pongas aquí. Como máximo $max en total y $per por capacidad; cámbialos cuando los haya explorado.';
  }

  @override
  String shelfCount(int count, int max) {
    return '$count de $max';
  }

  @override
  String get shelfAuto => 'Elección automática';

  @override
  String get shelfAutoOn =>
      'Ahora el estante se llena solo y cambia una vez por semana.';

  @override
  String get shelfAutoHint =>
      'El estante se llena solo y cambia una vez por semana: se queda aquello con lo que el niño trabaja, el resto deja sitio a otra cosa. Toca un material para elegirlos tú.';

  @override
  String shelfFull(int max) {
    return 'En el estante ya hay $max materiales: quita uno para poner otro.';
  }

  @override
  String shelfCapacityFull(int max) {
    return 'Para esta capacidad ya hay $max materiales: quita uno para poner otro.';
  }

  @override
  String shelfTotal(int count, int max) {
    return 'En el estante: $count de $max';
  }

  @override
  String get shelfRotateNow => 'Cambiar ahora';

  @override
  String get shelfRotated => 'El estante ha cambiado.';

  @override
  String get shelfKindStory => 'Cuento';

  @override
  String get shelfKindGame => 'Juego';

  @override
  String get shelfKindActivity => 'Actividad';

  @override
  String get gesturePause => 'Pausa: hagamos el gesto';

  @override
  String get gestureStart => '¿Listos? ¡Ya!';

  @override
  String get huntFound => '¡Lo encontré!';

  @override
  String get huntNotFound => 'No lo encuentro';

  @override
  String get huntRest => 'Pantalla en reposo';

  @override
  String get huntRestHint =>
      'Toca la pantalla cuando vuelvas. Si no quieres, no pasa nada.';

  @override
  String get huntTellMe => '¿Qué has encontrado? Dilo en voz alta.';

  @override
  String get huntRules =>
      'el niño busca una cosa cada vez, en casa o al aire libre con vosotros. Solo cosas a su alcance: nada de subirse a sitios, nada afilado ni frágil, nada de medicinas ni productos de limpieza. Fuera, solo lo que ya está caído en el suelo. Al final, todo vuelve a su sitio.';

  @override
  String get catMake => 'Creo y descubro';

  @override
  String get factoryTitle => 'Fábrica de cuentos';

  @override
  String get natureTitle => 'Calendario de la naturaleza';

  @override
  String factoryAsk(String step) {
    String _temp0 = intl.Intl.selectLogic(
      step,
      {
        'who': '¿Quién es el protagonista?',
        'place': '¿Dónde vive?',
        'problem': 'Un día, ¿qué pasa?',
        'feeling': '¿Cómo se siente?',
        'helper': '¿Quién viene a ayudar?',
        'ending': '¿Cómo termina?',
        'other': '$step',
      },
    );
    return '$_temp0';
  }

  @override
  String get factoryNameIt => '¿Qué título le ponemos al cuento?';

  @override
  String get factoryRead => '¡Leamos el cuento!';

  @override
  String get factoryMine => 'Mis cuentos';

  @override
  String get factoryNew => 'Inventa uno';

  @override
  String factoryBy(Object name) {
    return 'Un cuento inventado por $name';
  }

  @override
  String get factoryEnd => 'Fin';

  @override
  String get factoryOtherEnding => 'Prueba otro final';

  @override
  String factoryDone(Object name) {
    return '¡Qué cuento tan bonito, $name! Lo guardo con tus cuentos.';
  }

  @override
  String get factoryMineEmpty => 'Aquí encontrarás los cuentos que inventes.';

  @override
  String factoryWhoA(String who) {
    String _temp0 = intl.Intl.selectLogic(
      who,
      {
        'dragon': 'un dragoncito',
        'bunny': 'un conejito',
        'robot': 'un robot amable',
        'penguin': 'un pingüino',
        'unicorn': 'un unicornio',
        'kitten': 'un gatito',
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
        'dragon': 'el dragoncito',
        'bunny': 'el conejito',
        'robot': 'el robot amable',
        'penguin': 'el pingüino',
        'unicorn': 'el unicornio',
        'kitten': 'el gatito',
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
        'forest': 'el bosque',
        'room': 'la habitación',
        'stream': 'el arroyo',
        'sky': 'las nubes',
        'snow': 'la nieve',
        'night': 'la noche',
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
        'forest': 'en un bosque lleno de árboles',
        'room': 'en una habitación llena de juguetes',
        'stream': 'cerca de un arroyo',
        'sky': 'sobre una nube suave',
        'snow': 'en un prado lleno de nieve',
        'night': 'en un prado bajo las estrellas',
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
        'storm': 'la tormenta',
        'star': 'la estrellita caída',
        'sadFriend': 'un amigo triste',
        'litter': 'la basura',
        'lost': 'el camino perdido',
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
        'storm': 'llegó una tormenta muy fuerte',
        'star': 'una estrellita se cayó del cielo y no sabía volver a casa',
        'sadFriend': 'llegó un amigo muy triste que no quería hablar',
        'litter': 'alguien dejó mucha basura en el suelo',
        'lost': 'la niebla escondió el camino de casa',
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
            'encontraron un refugio seco y esperaron a que pasara la tormenta',
        'star':
            'construyeron una escalera altísima y devolvieron la estrellita al cielo',
        'sadFriend':
            'se sentaron junto al amigo y lo escucharon, hasta que volvió a sonreír',
        'litter':
            'recogieron la basura con guantes y la pusieron en los contenedores correctos',
        'lost':
            'siguieron las huellas del sendero y encontraron el camino de casa',
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
        'fear': 'el miedo',
        'sadness': 'la tristeza',
        'anger': 'la rabia',
        'curiosity': 'la curiosidad',
        'courage': 'el valor',
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
        'fear': 'un poco de miedo',
        'sadness': 'un poco de tristeza',
        'anger': 'un poco de rabia',
        'curiosity': 'mucha curiosidad',
        'courage': 'mucho valor',
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
        'turtle': 'una tortuga sabia',
        'owl': 'un búho que sabe muchas cosas',
        'bear': 'un oso amable',
        'bee': 'una abeja rapidísima',
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
        'party': 'una fiesta',
        'sleep': 'a dormir',
        'hug': 'un abrazo',
        'snack': 'una merienda',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String factoryPageStart(Object who, Object place) {
    return 'Había una vez $who que vivía $place.';
  }

  @override
  String factoryPageProblem(Object problem) {
    return 'Un día $problem.';
  }

  @override
  String factoryPageFeeling(Object who, Object feeling) {
    return '$who sintió $feeling y respiró hondo.';
  }

  @override
  String factoryPageHelp(Object helper, Object solution) {
    return 'Por suerte llegó $helper. Juntos, $solution.';
  }

  @override
  String factoryEnding(String ending, Object who) {
    String _temp0 = intl.Intl.selectLogic(
      ending,
      {
        'party': 'Y esa noche $who hizo una gran fiesta con todos sus amigos.',
        'sleep': 'Y esa noche $who se durmió feliz bajo una manta calentita.',
        'hug': 'Y al final $who le dio un fuerte abrazo a su nuevo amigo.',
        'snack': 'Y al final $who merendó con todos, bajo el sol.',
        'other': '$ending',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureAskWeather => '¿Qué tiempo hace?';

  @override
  String get natureAskSeen => '¿Qué has visto fuera?';

  @override
  String get natureUpTo => 'Puedes elegir hasta tres.';

  @override
  String natureWeather(String weather) {
    String _temp0 = intl.Intl.selectLogic(
      weather,
      {
        'sun': 'Sol',
        'clouds': 'Nubes',
        'rain': 'Lluvia',
        'snow': 'Nieve',
        'wind': 'Viento',
        'fog': 'Niebla',
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
        'leaf': 'Hojas',
        'flower': 'Flores',
        'bird': 'Pájaros',
        'bug': 'Mariquitas e insectos',
        'snail': 'Caracoles',
        'fruit': 'Frutas',
        'mushroom': 'Setas',
        'rainbow': 'Un arcoíris',
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
            'Hace frío y muchos árboles están desnudos. ¿Ves algún nido entre las ramas?',
        'm2':
            'Los días se alargan un poquito. Busca los primeros brotes en las ramas.',
        'm3':
            'Llega la primavera: salen las primeras flores. ¿De qué color son?',
        'm4':
            'Los pájaros construyen sus nidos. Escucha: ¿cuántos cantos distintos oyes?',
        'm5':
            'El prado está lleno de flores y abejas. Míralas de lejos: ¡trabajan mucho!',
        'm6':
            'Son los días más largos del año. ¿Qué ves por la tarde, cuando aún hay luz?',
        'm7': 'Hace calor: busca la sombra de los árboles. ¿Oyes las cigarras?',
        'm8':
            'Por la noche, si el cielo está despejado, a veces cae una estrella. ¡Pide un deseo!',
        'm9': 'Maduran muchas frutas: uvas, manzanas, higos. ¿Cuáles conoces?',
        'm10':
            'Las hojas cambian de color y caen. ¿Cuántos colores distintos encuentras?',
        'm11': 'En el bosque salen setas. ¡Se miran, pero no se tocan!',
        'm12':
            'Son los días más cortos del año. El bosque descansa, como en el cuento de Emma.',
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
        'e1': 'Cuando va a llover, el aire huele distinto. ¿Lo notas?',
        'e2':
            'Después de un chaparrón quedan charcos. ¿Qué ves reflejado en ellos?',
        'e3':
            'En los días secos la tierra se pone dura y polvorienta. Tócala: ¿cómo está hoy?',
        'e4':
            'Con la lluvia las plantas crecen deprisa. ¿Encuentras una hoja nueva, todavía clarita?',
        'e5':
            'Busca una hoja grandísima y una pequeñísima. ¿En qué se diferencian?',
        'e6': '¿Hay algún árbol con flores o con frutos? ¿De qué color son?',
        'e7':
            'Las hormigas caminan en fila. Síguelas con la mirada: ¿adónde van?',
        'e8':
            'Después de la lluvia a veces sale el arcoíris. ¿Cuántos colores puedes contar?',
        'other': '$tip',
      },
    );
    return '$_temp0';
  }

  @override
  String get natureThisMonth => 'Este mes';

  @override
  String natureDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get natureEmptyMonth => 'Este mes el calendario todavía está vacío.';

  @override
  String get natureToday => 'Hoy';

  @override
  String get readWord => 'Toca una palabra para volver a oírla';

  @override
  String get profileReadAlong => 'Lectura karaoke';

  @override
  String get profileReadAlongHint =>
      'Mientras la voz lee, la palabra se ilumina; al tocarla se vuelve a oír.';

  @override
  String get parentTabPrint => 'Imprimibles';

  @override
  String printIntro(Object name) {
    return 'Hojas para imprimir y usar lejos de la pantalla, en el idioma de $name.';
  }

  @override
  String get printEveryday => 'Para todos los días';

  @override
  String get printNameTrace => 'Repaso mi nombre';

  @override
  String printNameTraceHint(Object name) {
    return 'El nombre de $name para repasar con el lápiz.';
  }

  @override
  String get printNature => 'Calendario de la naturaleza del mes';

  @override
  String printNatureHint(Object name) {
    return 'La cuadrícula del mes para rellenar a mano, con lo que $name ya ha marcado.';
  }

  @override
  String get printGestures => 'Gestos de los cuentos';

  @override
  String get printGestureHint =>
      'El gesto, dos semanas de círculos para colorear y espacio para dibujarlo.';

  @override
  String printGesturesEmpty(Object name) {
    return 'Aquí aparecerán los gestos de los cuentos que $name ha terminado.';
  }

  @override
  String get printMade => 'Cuentos inventados';

  @override
  String get printMadeHint =>
      'El cuento en forma de librito, con espacio para los dibujos.';

  @override
  String printMadeEmpty(Object name) {
    return 'Aquí aparecerán los cuentos que $name invente en la fábrica.';
  }

  @override
  String get printButton => 'Imprimir';

  @override
  String get pdfDrawHere => 'Dibuja aquí';

  @override
  String get pdfGestureTimes => 'Cada vez que lo hagas, colorea un círculo.';

  @override
  String get pdfTraceName => 'Repasa tu nombre';

  @override
  String get pdfWeather => 'Tiempo';

  @override
  String get pdfSeen => 'He visto';

  @override
  String get exitAsk => '¿Quieres salir?';

  @override
  String get exitStay => 'Me quedo';

  @override
  String get exitLeave => 'Salgo';

  @override
  String get profileInteraction => 'Cómo usa la app';

  @override
  String profileInteractionHint(Object name) {
    return 'Parten de la edad: muévelos si $name hace más o menos. La app no los cambia sola.';
  }

  @override
  String get profileHands => 'Manos';

  @override
  String get profileHandsHint =>
      'Botones más grandes y trazos más anchos para quien empieza.';

  @override
  String get hands1 => 'Solo tocar';

  @override
  String get hands2 => 'Arrastrar';

  @override
  String get hands3 => 'Preciso';

  @override
  String get profileReading => 'Lectura';

  @override
  String get profileReadingHint =>
      'Sin texto (solo voz), solo la frase clave, texto con karaoke o texto completo.';

  @override
  String get readingNone => 'No lee';

  @override
  String get readingLetters => 'Letras';

  @override
  String get readingWords => 'Palabras';

  @override
  String get readingFluent => 'Lee bien';

  @override
  String get profileAutonomy => 'Autonomía';

  @override
  String get profileAutonomyHint =>
      'Cuántas opciones a la vez, consigna repetida, confirmación antes de salir.';

  @override
  String get autonomy1 => 'Con ayuda';

  @override
  String get autonomy2 => 'Un poco solo';

  @override
  String get autonomy3 => 'Solo';

  @override
  String adviceHands(Object name) {
    return 'Estos días $name traza las letras al primer intento: ¿quieres probar trazos más finos?';
  }

  @override
  String adviceReading(Object name) {
    return 'Estos días $name forma las palabras al primer intento: ¿quieres probar a mostrar más texto?';
  }

  @override
  String adviceAutonomy(Object name) {
    return 'Estos días $name acierta al primer intento: ¿quieres probar con más opciones a la vez?';
  }

  @override
  String get adviceYes => 'Sí, probemos';

  @override
  String get adviceNo => 'Ahora no';

  @override
  String get sharedPromptGuide => 'Dime tú qué hacer';

  @override
  String get sharedPromptHelp => '¿Cómo podríamos ayudar?';

  @override
  String get homeActivityHeading => 'Una actividad del cuento';

  @override
  String get homeActivitySteps => 'Qué hace el niño';

  @override
  String get homeActivityMaterials => 'Qué hace falta';

  @override
  String get homeActivityPreparation => 'Preparación';

  @override
  String get homeActivitySupervision => 'Supervisión';

  @override
  String get homeActivityAlternatives => 'Si falta algo';

  @override
  String get supervisionTogether => 'Con el niño, de principio a fin';

  @override
  String get supervisionNearby => 'Un adulto cerca';

  @override
  String get supervisionFree => 'El niño puede hacerlo solo';

  @override
  String get usageTitle => 'Tiempo de pantalla';

  @override
  String usageWeek(Object days, Object minutes) {
    return 'Últimos 7 días, con la pantalla encendida: $minutes min en total, en $days días.';
  }

  @override
  String usageToday(Object minutes) {
    return 'Hoy: $minutes min.';
  }

  @override
  String usageGestures(Object count) {
    return 'Gestos anotados en el diario en los últimos 7 días: $count. Son cosas hechas en la vida real, lejos de la pantalla.';
  }

  @override
  String usageLimit(Object minutes) {
    return 'En el modo \"solo\" el compañero se despide tras $minutes min (se cambia en el perfil).';
  }

  @override
  String get usageCannot =>
      'Lo que la app no puede medir: cuánto mira realmente el niño la pantalla, la escucha con la pantalla apagada, el tiempo en otros dispositivos, lo que hacéis juntos fuera de la pantalla. Los minutos son solo una parte: también cuentan qué mira, con quién y cómo habláis de ello.';

  @override
  String get projectPhaseIdea => 'La idea';

  @override
  String get projectPhasePrediction => 'La predicción';

  @override
  String get projectPhaseTest => 'La prueba';

  @override
  String get projectPhaseRevision => 'La revisión';

  @override
  String get projectNoteHint =>
      'Si quieres, escribe un par de líneas (opcional)';

  @override
  String get projectNext => 'Siguiente';

  @override
  String get projectFinish => 'Ya terminé';

  @override
  String get projectHeld => 'Aguantó';

  @override
  String get projectNotYet => 'Todavía no';

  @override
  String projectLogTitle(String name) {
    return 'Los pequeños proyectos de $name';
  }

  @override
  String get projectResultHeld => 'en la prueba aguantó';

  @override
  String get projectResultNotYet =>
      'en la prueba todavía no: se cambia algo y se prueba otra vez';

  @override
  String get profileNoLimit => 'Sin límite';

  @override
  String get usageNoLimit =>
      'En el modo \"solo\" no hay límite de tiempo (se fija en el perfil).';

  @override
  String get winddownNote =>
      'Pronto nos despedimos. Terminemos con calma lo que estamos haciendo.';

  @override
  String get winddownHint =>
      'Poco antes del final el compañero avisa con calma y no propone nada nuevo. Lo que está abierto se puede terminar.';

  @override
  String get gateSetupTitle => 'Elige un PIN para los adultos';

  @override
  String get gateSetupBody =>
      'De 4 a 6 cifras. Abre el área de adultos y protege las acciones delicadas. Si lo olvidas podrás elegir uno nuevo sin perder nada.';

  @override
  String get gatePinLabel => 'PIN';

  @override
  String get gatePinConfirmLabel => 'Repite el PIN';

  @override
  String get gatePinMismatch => 'Los dos PIN no coinciden';

  @override
  String get gatePinFormat => 'El PIN debe tener de 4 a 6 cifras';

  @override
  String get gatePinWrong => 'PIN incorrecto';

  @override
  String gatePinWait(String time) {
    return 'Demasiados intentos. Vuelve a probar en $time';
  }

  @override
  String get gateForgot => 'He olvidado el PIN';

  @override
  String get gateForgotUnavailable =>
      'No se pudo verificar que eres adulto con el bloqueo del dispositivo. Activa un bloqueo de pantalla de adulto e inténtalo de nuevo.';

  @override
  String get gateDeviceReason =>
      'Confirma que eres adulto para elegir un PIN nuevo';

  @override
  String get gateChangePin => 'Cambiar PIN';

  @override
  String get onbSkip => 'Omitir';

  @override
  String get onbPromiseTitle =>
      'Cuentos para explorar, juegos para entender, ideas para probar juntos';

  @override
  String get onbPromiseBody =>
      'Mirabò es para niños de 3 a 10 años y para el adulto que juega a su lado.';

  @override
  String get onbFactFree => 'Gratuita';

  @override
  String get onbFactOffline =>
      'Funciona sin conexión: la nube es una decisión tuya';

  @override
  String get onbFactNoAds => 'Sin publicidad';

  @override
  String get onbFactNoAccount => 'Sin cuenta para el niño';

  @override
  String get onbSetupTitle => 'Idioma y franja de edad';

  @override
  String get onbSetupHint =>
      'Todo lo demás se ajusta después, desde el área de adultos.';

  @override
  String get onbTryTitle => 'Un adelanto de cuento';

  @override
  String get onbTryNote =>
      'Es solo una vista previa: el cuento completo se abre junto al niño.';

  @override
  String get onbHomeTitle => 'Del cuento a la vida real';

  @override
  String get onbHomeIntro =>
      'Cada cuento puede convertirse en una actividad concreta en casa. Por ejemplo:';

  @override
  String get onbGoTitle => '¿Listos para probar con tu hijo?';

  @override
  String get onbGoBody =>
      'Bastan unos segundos: un compañero, un apodo si quieres y la franja de edad. Sin fecha de nacimiento ni registro.';

  @override
  String get onbGoButton => 'Probar con tu hijo';

  @override
  String get onbReopen => 'Ver de nuevo la presentación';

  @override
  String get onbReopenHint =>
      'El recorrido de bienvenida, con un adelanto de cuento.';

  @override
  String get onbClose => 'Cerrar';

  @override
  String get dataWipeTitle => '¿Eliminar todo de esta tableta?';

  @override
  String get dataWipeBody =>
      'Se borrarán para siempre perfiles, progreso, diario, creaciones y archivos generados (también la voz del nombre), junto con la base de datos y su clave. La tableta volverá a como estaba en el primer arranque. No se puede deshacer. Una copia en Google Drive no se toca.';

  @override
  String dataWipeTypePrompt(String word) {
    return 'Para confirmar, escribe $word';
  }

  @override
  String get dataWipeWord => 'ELIMINAR';

  @override
  String get dataWipeDone =>
      'Se han eliminado todos los datos de Mirabò de esta tableta.';

  @override
  String get dataWipeFailed =>
      'No se ha podido eliminar todo. Inténtalo de nuevo.';

  @override
  String get dataRemoteButton => 'Eliminar también la copia en Google Drive';

  @override
  String get dataRemoteTitle => '¿Eliminar la copia en Drive?';

  @override
  String dataRemoteBody(String account) {
    return 'El archivo de copia en el Drive de $account se borrará; después la tableta cierra la sesión de Google y revoca el permiso dado a la app. Hace falta internet. No se puede deshacer. Los datos de esta tableta se quedan.';
  }

  @override
  String get dataRemoteDone =>
      'Copia de Google Drive eliminada y cuenta desconectada.';

  @override
  String get dataRemoteFailed =>
      'La copia de Google Drive NO se ha eliminado (probablemente no hay red o hace falta volver a iniciar sesión en Google). No ha cambiado nada: conéctate a internet e inténtalo de nuevo.';

  @override
  String get dataOutsideTitle => 'Lo que la app no controla';

  @override
  String get dataOutsideBody =>
      'Mirabò no puede borrar las copias de seguridad del sistema operativo (copia del móvil o la tableta en iCloud o Google), ni los archivos que ya hayas exportado, impreso o compartido. Para eso: abre los ajustes de iCloud o de Google del dispositivo y borra las copias antiguas, y quita a mano los archivos guardados o enviados. Si algo queda en tu Drive, lo encuentras y lo borras en Drive > Ajustes > Administrar aplicaciones.';
}
