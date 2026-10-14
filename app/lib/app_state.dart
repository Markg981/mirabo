import 'dart:async';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'audio/name_voice.dart';
import 'content/story_repository.dart';
import 'data/cloud_backup.dart';
import 'data/interaction_advice.dart';
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
  })  : backup = backup ?? CloudBackup(db: db),
        nameVoice = nameVoice ?? NameVoice(),
        _now = clock ?? DateTime.now,
        _region = region ?? (() => PlatformDispatcher.instance.locale.countryCode);

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
  SessionMode mode = SessionMode.together;

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

  void _syncAloneClock() {
    if (mode != SessionMode.alone || currentProfile == null) {
      _aloneTimer?.cancel();
      _aloneTimer = null;
      _aloneSince = null;
      _aloneExpired = false;
      _goodbye = false;
      _nearTimer?.cancel();
      _nearTimer = null;
      _near = false;
      return;
    }
    _aloneSince ??= _now();
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
    onboardingSeen = true;
    notifyListeners();
    await db.setSetting(onboardingSeenKey, '1');
  }

  Future<void> init() async {
    profiles = await db.profiles();
    onboardingSeen = profiles.isNotEmpty || await db.setting(onboardingSeenKey) != null;
    hemisphere = Hemisphere.byName(await db.setting(LocalDb.hemisphereKey)) ?? Hemisphere.fromRegion(_region());
    currentProfile = profiles.isEmpty ? null : profiles.first;
    if (currentProfile != null) mode = currentProfile!.lastMode;
    _syncAloneClock();
    notifyListeners();
    // Profili nati prima della cache, o ripristinati da Drive su un tablet nuovo.
    for (final p in profiles) {
      nameVoice.prepare(p);
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
  Companion companionOf(ChildProfile p) => repo.companionsIn(p.language).firstWhere((c) => c.id == p.companion);

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
  /// Il compagno non cresce: cresce solo con i gesti fatti davvero.
  Future<void> recordActivity(Activity activity, ActivityProgress before, List<RoundResult> results) async {
    final p = currentProfile;
    if (p == null || results.isEmpty) return;
    await db.addRounds(p.id, activity, before.level, results);
    await db.saveProgress(applyAdaptive(before, results, activity.levels.length));
  }

  /// Proposte a cui il genitore ha detto "non ora": per questa apertura dell'app
  /// non tornano.
  final Set<String> _dismissedAdvice = {};

  /// Se i round dell'ultima settimana dicono che il bambino è pronto, propone
  /// di spostare un asse del profilo di interazione. Non cambia niente da sola.
  Future<InteractionAdvice?> interactionAdvice(ChildProfile p, {DateTime? now}) async {
    final rounds = await db.rounds(p.id, from: (now ?? DateTime.now()).subtract(const Duration(days: 7)), to: now);
    final types = {for (final a in repo.activities) a.id: a.type};
    final advice = adviseInteraction(p.interaction, rounds, (id) => types[id]);
    return advice == null || _dismissedAdvice.contains(advice.key(p.id)) ? null : advice;
  }

  void dismissAdvice(ChildProfile p, InteractionAdvice advice) {
    _dismissedAdvice.add(advice.key(p.id));
    notifyListeners();
  }

  Future<void> selectProfile(ChildProfile p) async {
    currentProfile = p;
    mode = p.lastMode;
    _syncAloneClock();
    notifyListeners();
  }

  /// Solo il genitore cambia modalità: chiude la sessione "da solo" in corso
  /// e, se si torna "da solo", ne apre una nuova.
  Future<void> setMode(SessionMode m) async {
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
    mode = saved.lastMode;
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

  Future<void> deleteProfile(int id) async {
    await db.deleteProfile(id);
    await nameVoice.forget(id);
    profiles = await db.profiles();
    if (currentProfile?.id == id) currentProfile = profiles.isEmpty ? null : profiles.first;
    _syncAloneClock();
    notifyListeners();
  }

  /// Registra una storia nel diario. Il compagno non cresce: leggere non basta,
  /// serve il gesto della storia fatto nella vita vera ([recordGesture]).
  Future<void> recordStory(Story story, {required bool completed, String? dialogueAnswer}) async {
    final p = currentProfile;
    if (p == null) return;
    await db.addDiaryEntry(DiaryEntry(
      profileId: p.id,
      storyId: story.id,
      mode: mode,
      completed: completed,
      dialogueAnswer: dialogueAnswer,
      when: DateTime.now(),
    ));
    if (completed) await updateProfile(p.copyWith(storiesCompleted: p.storiesCompleted + 1));
  }

  /// Il genitore segna che il bambino ha fatto il gesto di una storia: è l'unica
  /// cosa che fa crescere il compagno. Lo stesso gesto conta una volta al giorno,
  /// così ripeterlo nei giorni (annaffiare il seme) vale, toccare due volte no.
  /// Restituisce false se oggi era già segnato.
  Future<bool> recordGesture(ChildProfile p, String storyId, {DateTime? now}) async {
    final when = now ?? DateTime.now();
    final done = await db.gestures(p.id);
    if (done.any((g) => g.storyId == storyId && g.when.year == when.year && g.when.month == when.month && g.when.day == when.day)) return false;
    await db.addGesture(GestureEntry(profileId: p.id, storyId: storyId, when: when));
    final fresh = profiles.firstWhere((x) => x.id == p.id, orElse: () => p);
    await updateProfile(fresh.copyWith(gesturesDone: fresh.gesturesDone + 1));
    return true;
  }

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
    hemisphere = h;
    notifyListeners();
    await db.setSetting(LocalDb.hemisphereKey, h.name);
  }

  /// Cancella tutto da questo tablet: profili, diario, creazioni, file generati,
  /// database e relativa chiave. Poi l'app riparte da zero. Il backup su Drive
  /// non si tocca (resta ripristinabile e un tablet vuoto non lo sovrascrive):
  /// per cancellare anche quello c'è [CloudBackup.disable] con `deleteRemote`.
  Future<void> wipeAll() async {
    await backup.forget();
    await nameVoice.forget();
    await db.eraseAndReopen();
    hemisphere = Hemisphere.fromRegion(_region());
    profiles = const [];
    currentProfile = null;
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
