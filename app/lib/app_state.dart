import 'dart:async';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'audio/name_voice.dart';
import 'content/story_repository.dart';
import 'data/cloud_backup.dart';
import 'data/local_db.dart';
import 'data/usage_tracker.dart';
import 'games/game.dart';
import 'l10n/l10n.dart';
import 'models/activity.dart';
import 'models/made_story.dart';
import 'models/nature_day.dart';
import 'models/profile.dart';
import 'models/shelf.dart';
import 'models/story.dart';
import 'models/themes.dart';

/// Stato dell'app: profili, profilo attivo, modalità della sessione.
/// Volutamente semplice (ChangeNotifier) finché non serve di più.
class AppState extends ChangeNotifier {
  AppState({
    required this.db,
    required this.repo,
    CloudBackup? backup,
    NameVoice? nameVoice,
    DateTime Function()? clock,
    String? Function()? region,
    Future<bool> Function(String ttsCode)? voiceCheck,
  })  : backup = backup ?? CloudBackup(db: db),
        nameVoice = nameVoice ?? NameVoice(),
        _now = clock ?? DateTime.now,
        _region = region ?? (() => PlatformDispatcher.instance.locale.countryCode),
        _voiceCheck = voiceCheck ?? _systemVoice {
    LocalDb.onSaveError = _saveFailed;
  }

  /// L'ultimo salvataggio non riuscito (docs/release-engineering.md). Finché
  /// l'adulto non lo chiude, una fascia in alto dice che qualcosa non è stato
  /// conservato: un errore non diventa un successo né un reset silenzioso.
  Object? saveFailure;

  void _saveFailed(Object error) {
    debugPrint('Salvataggio non riuscito: $error');
    saveFailure = error;
    // Può arrivare mentre si disegna (una scrittura partita da un build).
    scheduleMicrotask(notifyListeners);
  }

  void dismissSaveFailure() {
    saveFailure = null;
    notifyListeners();
  }

  /// Quando l'app è ripartita da zero perché i dati di prima, cifrati, non si
  /// potevano più leggere (chiave sparita). L'onboarding lo dice all'adulto.
  DateTime? storageResetAt;

  static Future<bool> _systemVoice(String ttsCode) async {
    try {
      return await FlutterTts().isLanguageAvailable(ttsCode) != false;
    } catch (_) {
      return true;
    }
  }

  /// Le lingue dei profili senza voce di sistema. Lo chiama main all'avvio;
  /// l'area adulta lo richiama quando l'adulto torna dopo aver installato una voce.
  Future<void> checkVoices() async {
    final missing = <String>{};
    for (final code in {for (final p in profiles) p.language}) {
      if (!await _voiceCheck(AppLanguage.fromCode(code).ttsCode)) missing.add(code);
    }
    if (missing.length == voicesMissing.length && missing.containsAll(voicesMissing)) return;
    voicesMissing = missing;
    notifyListeners();
  }

  bool voiceMissingFor(ChildProfile p) => voicesMissing.contains(p.language);

  /// L'app va in background (o si spegne lo schermo).
  void appHidden() {
    _hiddenAt ??= _now();
    // Se il bambino chiude l'app, il riavvio entro [aloneGrace] riprende il conto.
    if (_aloneSince != null) _bestEffort(() => db.setSetting(aloneLeftAtKey, _now().toIso8601String()));
  }

  /// L'app torna in primo piano: dopo [togetherLapse] "insieme" scade.
  void appResumed() {
    final hidden = _hiddenAt;
    _hiddenAt = null;
    if (hidden != null && mode == SessionMode.together && _now().difference(hidden) >= togetherLapse) {
      unawaited(setMode(SessionMode.alone));
      return;
    }
    // Un Timer sospeso in background può scattare in ritardo (iOS): si
    // riallinea il conto del limite all'orologio.
    if (hidden != null && mode == SessionMode.alone) _syncAloneClock();
  }

  final LocalDb db;
  final StoryRepository repo;

  /// Backup opt-in su Drive: spento finché il genitore non lo attiva.
  final CloudBackup backup;

  /// Il nome di ogni bambino detto dal TTS, in cache per le storie registrate.
  final NameVoice nameVoice;

  /// Tempo d'uso per bambino; lo avvia main (null nei test).
  UsageTracker? usage;

  List<ChildProfile> profiles = const [];
  ChildProfile? currentProfile;

  /// "Insieme" o "da solo" (docs/child-paths.md). È una dichiarazione
  /// dell'adulto, non una verifica: l'app non sa chi c'è accanto al bambino.
  /// Cambia cosa si propone e cosa si apre, non certifica una presenza. Per
  /// questo "insieme" vale per questa volta: all'avvio, quando cambia il
  /// bambino o dopo [togetherLapse] in background si torna a "da solo".
  SessionMode mode = SessionMode.alone;

  /// Dopo quanto tempo in background "insieme" scade.
  static const togetherLapse = Duration(minutes: 30);
  DateTime? _hiddenAt;

  /// Il bambino per cui l'adulto ha scelto la modalità.
  int? _modeFor;

  /// Lingue (codici it, en…) per cui il dispositivo non ha la voce di sistema.
  /// Senza voce chi non legge ha bisogno di un adulto: il testo si mostra e
  /// l'area adulta lo dice (docs/child-paths.md, "Errori").
  Set<String> voicesMissing = const {};

  /// Controlla se la voce di sistema di una lingua c'è; sostituibile nei test.
  /// Un errore del controllo vale come "c'è": meglio non allarmare per niente.
  final Future<bool> Function(String ttsCode) _voiceCheck;

  /// Con più figli, a ogni avvio il bambino sceglie chi gioca ("Chi gioca oggi?").
  /// Vale per la sessione: non si salva.
  bool _childChosen = false;
  bool get needsChildChoice => profiles.length > 1 && !_childChosen;

  final DateTime Function() _now;

  /// La regione del dispositivo (non la lingua dell'app): da lì l'emisfero iniziale.
  final String? Function() _region;

  /// Dove vive la famiglia, per i suggerimenti stagionali. Finché il genitore
  /// non lo sceglie vale quello della regione del dispositivo.
  Hemisphere hemisphere = Hemisphere.north;

  /// Sessione "da solo": parte quando la modalità diventa "da solo" e dura i
  /// minuti scelti dal genitore nel profilo. Allo scadere il compagno saluta,
  /// ma mai a metà: se una storia o un'attività è aperta ([SessionHold]) il
  /// saluto aspetta che finisca. Cambiare bambino non la azzera; la chiude
  /// solo il genitore cambiando modalità.
  DateTime? _aloneSince;

  /// Chiavi in `settings`: inizio della sessione "da solo" e ultimo momento in
  /// cui l'app è andata in background. Servono a non regalare un limite nuovo a
  /// chi chiude e riapre l'app.
  static const aloneSinceKey = 'alone_since';
  static const aloneLeftAtKey = 'alone_left_at';

  /// Un riavvio entro questo tempo dall'uscita mantiene il conto del limite;
  /// oltre, è una sessione nuova (una pausa vera).
  static const aloneGrace = Duration(minutes: 10);
  Timer? _aloneTimer;
  bool _aloneExpired = false;
  int _holds = 0;
  bool _goodbye = false;
  Timer? _nearTimer;
  bool _near = false;

  /// Minuti prima del limite in cui la casa si fa tranquilla: niente di nuovo
  /// da iniziare, quello che è aperto si conclude. Non è un conto alla rovescia:
  /// il bambino non vede numeri.
  static const winddownLead = Duration(minutes: 3);

  /// Il limite (0 = nessuno) è vicino o scaduto: non si propongono storie o
  /// attività nuove, ma quella in corso si finisce.
  bool get windingDown => _near || _aloneExpired;

  /// Il tempo "da solo" è finito e non c'è niente in corso: si saluta.
  bool get aloneGoodbye => _goodbye;

  /// Il conto del limite non deve mai fermare l'app: se non si salva, vale
  /// com'era prima (un riavvio riparte da zero).
  void _bestEffort(Future<void> Function() write) {
    try {
      unawaited(write().catchError((_) {}));
    } catch (_) {}
  }

  void _syncAloneClock() {
    if (mode != SessionMode.alone || currentProfile == null) {
      _aloneTimer?.cancel();
      _aloneTimer = null;
      if (_aloneSince != null) {
        _bestEffort(() => db.removeSetting(aloneSinceKey));
        _bestEffort(() => db.removeSetting(aloneLeftAtKey));
      }
      _aloneSince = null;
      _aloneExpired = false;
      _goodbye = false;
      _nearTimer?.cancel();
      _nearTimer = null;
      _near = false;
      return;
    }
    if (_aloneSince == null) {
      _aloneSince = _now();
      _bestEffort(() => db.setSetting(aloneSinceKey, _aloneSince!.toIso8601String()));
    }
    if (_aloneExpired) return;
    _aloneTimer?.cancel();
    _nearTimer?.cancel();
    _nearTimer = null;
    _near = false;
    // Nessun limite: la sessione non scade mai da sola.
    if (currentProfile!.aloneSessionMinutes <= 0) {
      _aloneTimer = null;
      return;
    }
    // Il genitore può aver cambiato i minuti: si riprogramma sull'inizio di sempre.
    final left = _aloneSince!.add(Duration(minutes: currentProfile!.aloneSessionMinutes)).difference(_now());
    _aloneTimer = Timer(left.isNegative ? Duration.zero : left, _onAloneTimeUp);
    final lead = left - winddownLead;
    if (lead <= Duration.zero) {
      _near = true;
    } else {
      _nearTimer = Timer(lead, () {
        _nearTimer = null;
        _near = true;
        notifyListeners();
      });
    }
  }

  void _onAloneTimeUp() {
    _aloneTimer = null;
    _aloneExpired = true;
    _sayGoodbyeIfFree();
  }

  void _sayGoodbyeIfFree() {
    if (!_aloneExpired || _holds > 0 || _goodbye) return;
    _goodbye = true;
    notifyListeners();
  }

  /// Una storia o un'attività si apre: il saluto aspetta.
  void holdSession() => _holds++;

  /// La storia o l'attività si chiude: se il tempo è finito, ora si saluta.
  /// Fuori dal frame, perché arriva dal dispose della pagina.
  void releaseSession() {
    _holds--;
    if (_aloneExpired) scheduleMicrotask(_sayGoodbyeIfFree);
  }

  @override
  void dispose() {
    _aloneTimer?.cancel();
    _nearTimer?.cancel();
    super.dispose();
  }

  /// Chiave in `settings`: il genitore ha già visto (o saltato) l'onboarding.
  static const onboardingSeenKey = 'onboarding_seen';

  /// Onboarding dell'adulto già visto o saltato: chi lo ha visto non lo rivede
  /// (lo riapre dall'area adulti). Un profilo già esistente vale come "visto".
  bool onboardingSeen = true;

  /// Scelte fatte nell'onboarding, prima che esista un profilo: lingua e fascia
  /// diventano i valori iniziali del modulo del bambino.
  AppLanguage? onboardingLanguage;
  AgeBand? onboardingBand;

  /// Sceglie la lingua già durante l'onboarding (l'interfaccia la segue subito).
  void setOnboardingLanguage(AppLanguage l) {
    onboardingLanguage = l;
    notifyListeners();
  }

  /// Fine (o salto) dell'onboarding: non si ripropone; si passa al profilo del bambino.
  Future<void> finishOnboarding({AppLanguage? language, AgeBand? band}) async {
    onboardingLanguage = language ?? onboardingLanguage;
    onboardingBand = band ?? onboardingBand;
    // Prima si salva, poi si va avanti: se il salvataggio non riesce
    // l'onboarding non risulta fatto.
    await db.setSetting(onboardingSeenKey, '1');
    if (storageResetAt != null) await db.removeSetting(LocalDb.storageResetKey);
    storageResetAt = null;
    onboardingSeen = true;
    notifyListeners();
  }

  Future<void> init() async {
    profiles = await db.profiles();
    onboardingSeen = profiles.isNotEmpty || await db.setting(onboardingSeenKey) != null;
    storageResetAt = DateTime.tryParse(await db.setting(LocalDb.storageResetKey) ?? '');
    hemisphere = Hemisphere.byName(await db.setting(LocalDb.hemisphereKey)) ?? Hemisphere.fromRegion(_region());
    currentProfile = profiles.isEmpty ? null : profiles.first;
    // Ogni avvio parte da "da solo": "insieme" lo dichiara l'adulto ogni volta.
    mode = SessionMode.alone;
    await _restoreAloneSince();
    _syncAloneClock();
    notifyListeners();
    if (!nameVoice.enabled) {
      // Fuori dall'MVP: via i file del nome lasciati da una versione precedente.
      // Senza attendere, come prepare: l'avvio non dipende dal file system.
      unawaited(nameVoice.forget());
      return;
    }
    // Profili nati prima della cache, o ripristinati da Drive su un tablet nuovo.
    for (final p in profiles) {
      nameVoice.prepare(p);
    }
  }

  /// Riavvio entro [aloneGrace] dall'uscita: la sessione "da solo" è la stessa.
  Future<void> _restoreAloneSince() async {
    if (_aloneSince != null) return;
    final DateTime? since, left;
    try {
      since = DateTime.tryParse(await db.setting(aloneSinceKey) ?? '');
      left = DateTime.tryParse(await db.setting(aloneLeftAtKey) ?? '');
    } catch (_) {
      return;
    }
    if (since == null || left == null) return;
    final now = _now();
    if (!left.isBefore(since) && !left.isAfter(now) && now.difference(left) <= aloneGrace) {
      _aloneSince = since;
      await db.removeSetting(aloneLeftAtKey);
    }
  }

  /// Dopo un ripristino da Drive: ricarica tutto e ripropone "Chi gioca oggi?".
  Future<void> reloadAfterRestore() async {
    _childChosen = false;
    await init();
  }

  /// Il bambino tocca il suo compagno nella schermata di scelta.
  Future<void> chooseChild(ChildProfile p) async {
    _childChosen = true;
    await selectProfile(p);
  }

  /// Torna a "Chi gioca oggi?" (fratelli che si passano il tablet).
  void switchChild() {
    _childChosen = false;
    notifyListeners();
  }

  /// Il compagno, le storie e le attività arrivano nella lingua del bambino.
  Companion companionOf(ChildProfile p) => repo.companionsIn(p.language).firstWhere(
        (c) => c.id == p.companion,
        orElse: () => repo.companionsIn(p.language).first,
      );

  List<Story> storiesFor(ChildProfile p, {SessionMode? mode}) =>
      repo.storiesIn(p.language).where((s) => p.canOpen(s, mode ?? this.mode)).toList();

  List<Activity> activitiesFor(ChildProfile p, {ActivityModule? module}) => repo.activitiesIn(p.language)
      .where((a) => a.supports(p.ageBand) && (module == null || a.module == module))
      .toList();

  /// Tutto quello che potrebbe stare sulla mensola di questo bambino: storie,
  /// attività e giochi della sua fascia, nella sua lingua, più fabbrica di
  /// storie e calendario della natura. Con [mode] null vale la modalità
  /// della sessione.
  List<ShelfItem> shelfCandidates(ChildProfile p, {SessionMode? mode}) => [
        for (final s in storiesFor(p, mode: mode)) StoryItem(s),
        for (final a in activitiesFor(p)) ActivityItem(a),
        for (final g in gamesFor(p.ageBand)) GameItem(g),
        for (final t in MakeTool.values) MakeItem(t),
      ];

  /// La mensola che il bambino vede adesso, capacità per capacità: quella
  /// scelta dal genitore o, se non c'è, quella automatica salvata. Se la
  /// settimana è finita la mensola automatica ruota; quando ha finito arriva
  /// una notifica e la casa si ridisegna.
  Map<Capacity, List<ShelfItem>> shelfFor(ChildProfile p, {SessionMode? mode}) {
    if (p.shelf == null && _shelfDue(p)) scheduleMicrotask(() => rotateShelf(p));
    return Shelf.arrange(shelfCandidates(p, mode: mode), p.shelf ?? p.shelfAuto, p.ageBand);
  }

  /// Le esperienze di un tema per il bambino, modalità per modalità: tutte
  /// quelle della sua fascia che l'adulto permette (mondi, modalità della
  /// sessione). Non dipende dalla mensola, da cosa ha finito o dalla
  /// settimana: niente si sblocca e niente sparisce perché poco usato.
  Map<ExperienceMode, List<ThemeExperience>> themeFor(ChildProfile p, ChildTheme theme, {SessionMode? mode}) =>
      repo.themes.resolve(theme, p.ageBand, stories: storiesFor(p, mode: mode), activities: activitiesFor(p));

  bool _shelfDue(ChildProfile p) =>
      p.shelfAuto == null || p.shelfRotatedAt == null || !_now().isBefore(p.shelfRotatedAt!.add(Shelf.rotation));

  Future<void>? _rotating;

  /// Ruota la mensola automatica (vedi [Shelf.rotate]) e la salva. Senza
  /// [force] solo se la settimana è finita; con [force] è il "Cambia adesso"
  /// del genitore. La scelta del genitore non si tocca.
  Future<void> rotateShelf(ChildProfile p, {bool force = false}) =>
      _rotating ??= _rotateShelf(p, force).whenComplete(() => _rotating = null);

  Future<void> _rotateShelf(ChildProfile p, bool force) async {
    final fresh = profiles.firstWhere((x) => x.id == p.id, orElse: () => p);
    if (fresh.shelf != null || !(force || _shelfDue(fresh))) return;
    final now = _now();
    final current = fresh.shelfAuto ?? const <String>[];
    final next = Shelf.rotate(
      available: shelfCandidates(fresh, mode: SessionMode.together),
      band: fresh.ageBand,
      current: current,
      usage: await db.shelfUsage(fresh.id, since: now.subtract(Shelf.rotation)),
      history: await db.shelfHistory(fresh.id),
      now: now,
    );
    await db.moveShelf(fresh.id, before: current, after: next, at: now);
    await updateProfile(fresh.withAutoShelf(next, now));
  }

  /// Il genitore cambia la mensola; null la lascia riempire da sola.
  Future<void> setShelf(ChildProfile p, List<String>? keys) => updateProfile(p.withShelf(keys));

  /// Chiude una sessione di attività: salva i round e applica l'adattività.
  /// Il compagno non cresce (docs/child-paths.md).
  Future<void> recordActivity(Activity activity, ActivityProgress before, List<RoundResult> results) async {
    final p = currentProfile;
    if (p == null || results.isEmpty) return;
    await db.addRounds(p.id, activity, results);
    // Il livello non cambia da solo: lo sceglie il bambino a fine attività
    // (più semplice / ancora così / più sfida), vedi setActivityLevel.
    await db.saveProgress(before.copyWith(sessions: before.sessions + 1, lastPlayed: _now()));
  }

  /// Scelta facoltativa a fine attività: cambia solo il livello di quell'attività
  /// (una dimensione per volta, sempre in [1, maxLevel]) e si può annullare
  /// con la scelta opposta. Non tocca fascia, profilo di interazione né audio.
  Future<ActivityProgress> setActivityLevel(ActivityProgress p, int level, int maxLevel) async {
    final next = p.copyWith(level: level.clamp(1, maxLevel));
    await db.saveProgress(next);
    return next;
  }

  Future<void> selectProfile(ChildProfile p) async {
    currentProfile = p;
    // Un altro bambino: "insieme" valeva per chi c'era prima.
    if (p.id != _modeFor) mode = SessionMode.alone;
    _syncAloneClock();
    notifyListeners();
  }

  /// Solo il genitore cambia modalità: chiude la sessione "da solo" in corso
  /// e, se si torna "da solo", ne apre una nuova.
  Future<void> setMode(SessionMode m) async {
    _modeFor = currentProfile?.id;
    mode = SessionMode.together;
    _syncAloneClock();
    mode = m;
    _syncAloneClock();
    final p = currentProfile;
    if (p != null) {
      currentProfile = p.copyWith(lastMode: m);
      await db.updateProfile(currentProfile!);
      profiles = await db.profiles();
    }
    notifyListeners();
  }

  Future<void> createProfile(ChildProfile draft) async {
    final saved = await db.insertProfile(draft);
    profiles = await db.profiles();
    currentProfile = saved;
    _childChosen = true;
    mode = SessionMode.alone;
    _syncAloneClock();
    notifyListeners();
    nameVoice.prepare(saved);
  }

  Future<void> updateProfile(ChildProfile p) async {
    final before = profiles.where((x) => x.id == p.id).firstOrNull;
    await db.updateProfile(p);
    profiles = await db.profiles();
    if (currentProfile?.id == p.id) currentProfile = p;
    _syncAloneClock();
    notifyListeners();
    // Se nome e lingua non sono cambiati il file c'è già e non si rigenera.
    nameVoice.prepare(p);
    // Con un'altra fascia o lingua i materiali sono altri: la mensola
    // automatica si rifà subito, senza aspettare la settimana.
    if (before != null && p.shelfAuto != null && (before.ageBand != p.ageBand || before.language != p.language)) {
      await rotateShelf(p, force: true);
    }
  }

  /// L'adulto sceglie la fascia di un profilo creato con le fasce di prima
  /// (5-7, 7-10). L'app non la deduce: né dall'età, né dalle prestazioni.
  Future<void> confirmBand(ChildProfile p, AgeBand band) {
    assert(p.bandToConfirm?.choices.contains(band) ?? true);
    return updateProfile(p.withConfirmedBand(band));
  }

  Future<void> deleteProfile(int id) async {
    await usage?.forget(id);
    await db.deleteProfile(id);
    await nameVoice.forget(id);
    profiles = await db.profiles();
    if (currentProfile?.id == id) currentProfile = profiles.isEmpty ? null : profiles.first;
    // Un tick durante gli await non deve aver accreditato il bambino eliminato.
    await usage?.forget(id);
    _syncAloneClock();
    notifyListeners();
  }

  /// Registra una storia nel diario: quale, quando, in che modalità, se è finita.
  /// La risposta alla pausa di dialogo non si conserva (docs/privacy/mvp-data.md).
  /// Il compagno non cresce (vedi [ChildProfile.companionStage]).
  Future<void> recordStory(Story story, {required bool completed}) async {
    final p = currentProfile;
    if (p == null) return;
    await db.addDiaryEntry(DiaryEntry(
      profileId: p.id,
      storyId: story.id,
      mode: mode,
      completed: completed,
      when: _now(),
    ));
    if (completed) await updateProfile(p.copyWith(storiesCompleted: p.storiesCompleted + 1));
  }

  /// Il genitore segna nel diario che il bambino ha fatto il gesto di una
  /// storia. È solo una voce descrittiva: il compagno non cresce e niente si
  /// sblocca. Lo stesso gesto si segna una volta al giorno, così il diario
  /// racconta i giorni in cui è successo. Restituisce false se oggi era già segnato.
  Future<bool> recordGesture(ChildProfile p, String storyId, {DateTime? now}) async {
    final when = now ?? DateTime.now();
    final done = await db.gestures(p.id);
    if (done.any((g) => g.storyId == storyId && g.when.year == when.year && g.when.month == when.month && g.when.day == when.day)) return false;
    await db.addGesture(GestureEntry(profileId: p.id, storyId: storyId, when: when));
    // Nessun contatore sul profilo: i gesti stanno nel diario e basta
    // (gestures_done resta solo per lo stadio raggiunto con le regole di prima).
    return true;
  }

  /// Ripresa (docs/child-paths.md, "Uscita e ripresa"): la schermata della
  /// storia a cui il bambino si è fermato, per bambino, storia e fascia. Una
  /// storia finita riparte dall'inizio.
  static String storyResumeKey(int profileId, String storyId, AgeBand band) => 'resume.story.$profileId.$storyId.${band.key}';

  Future<int> storyPosition(ChildProfile p, String storyId) async =>
      int.tryParse(await db.setting(storyResumeKey(p.id, storyId, p.ageBand)) ?? '') ?? 0;

  Future<void> saveStoryPosition(ChildProfile p, String storyId, int screen) =>
      db.setSetting(storyResumeKey(p.id, storyId, p.ageBand), screen <= 0 ? '' : '$screen');

  /// Il disegno lasciato a metà (JSON di DrawingGame), uno per bambino.
  static String drawingKey(int profileId) => 'resume.drawing.$profileId';

  Future<String?> savedDrawing(ChildProfile p) async {
    final raw = await db.setting(drawingKey(p.id));
    return raw == null || raw.isEmpty ? null : raw;
  }

  Future<void> saveDrawing(ChildProfile p, String? json) => db.setSetting(drawingKey(p.id), json ?? '');

  /// Salva una storia della fabbrica. Come le altre storie, non fa crescere il compagno.
  Future<MadeStory> saveMadeStory(MadeStory story) => db.addMadeStory(story);

  Future<List<MadeStory>> madeStoriesOf(ChildProfile p) => db.madeStories(p.id);

  Future<List<NatureDay>> natureMonthOf(ChildProfile p, DateTime month) => db.natureMonth(p.id, month);

  /// Un giorno del calendario della natura. Solo oggi e i giorni passati:
  /// si segna quello che si è visto, non quello che si vedrà.
  Future<void> saveNatureDay(NatureDay day, {DateTime? now}) async {
    final today = NatureDay.dateOnly(now ?? DateTime.now());
    if (NatureDay.dateOnly(day.day).isAfter(today)) throw ArgumentError('Giorno futuro: ${NatureDay.key(day.day)}');
    await db.saveNatureDay(day);
  }

  /// Il genitore sceglie dove vive la famiglia: vale per tutti i bambini.
  Future<void> setHemisphere(Hemisphere h) async {
    await db.setSetting(LocalDb.hemisphereKey, h.name);
    hemisphere = h;
    notifyListeners();
  }

  /// Cancella tutto da questo tablet: profili, diario, creazioni, file generati,
  /// database e relativa chiave. Poi l'app riparte da zero. Il backup su Drive
  /// non si tocca (resta ripristinabile e un tablet vuoto non lo sovrascrive):
  /// per cancellare anche quello c'è [CloudBackup.disable] con `deleteRemote`.
  Future<void> wipeAll() async {
    await usage?.forget();
    await backup.forget();
    await nameVoice.forget();
    await db.eraseAndReopen();
    hemisphere = Hemisphere.fromRegion(_region());
    profiles = const [];
    currentProfile = null;
    await usage?.forget();
    onboardingSeen = false;
    _childChosen = false;
    _hiddenAt = null;
    mode = SessionMode.alone;
    _syncAloneClock();
    notifyListeners();
  }
}

class AppStateScope extends InheritedWidget {
  const AppStateScope({super.key, required this.state, required super.child});
  final AppState state;

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.state;

  /// Senza dipendenza: per initState e callback.
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppStateScope>()!.state;

  static AppState? maybeRead(BuildContext context) => context.getInheritedWidgetOfExactType<AppStateScope>()?.state;

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => state != oldWidget.state;
}

/// Avvolge una pagina che non va interrotta (una storia, un'attività, l'area
/// genitori): finché è aperta il compagno non saluta.
class SessionHold extends StatefulWidget {
  const SessionHold({super.key, required this.child});
  final Widget child;

  @override
  State<SessionHold> createState() => _SessionHoldState();
}

class _SessionHoldState extends State<SessionHold> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppStateScope.read(context)..holdSession();
  }

  @override
  void dispose() {
    _state.releaseSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
