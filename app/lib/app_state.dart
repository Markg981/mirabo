import 'package:flutter/widgets.dart';

import 'audio/name_voice.dart';
import 'content/story_repository.dart';
import 'data/cloud_backup.dart';
import 'data/interaction_advice.dart';
import 'data/local_db.dart';
import 'games/game.dart';
import 'models/activity.dart';
import 'models/made_story.dart';
import 'models/nature_day.dart';
import 'models/profile.dart';
import 'models/shelf.dart';
import 'models/story.dart';

/// Stato dell'app: profili, profilo attivo, modalità della sessione.
/// Volutamente semplice (ChangeNotifier) finché non serve di più.
class AppState extends ChangeNotifier {
  AppState({required this.db, required this.repo, CloudBackup? backup, NameVoice? nameVoice})
      : backup = backup ?? CloudBackup(db: db),
        nameVoice = nameVoice ?? NameVoice();

  final LocalDb db;
  final StoryRepository repo;

  /// Backup opt-in su Drive: spento finché il genitore non lo attiva.
  final CloudBackup backup;

  /// Il nome di ogni bambino detto dal TTS, in cache per le storie registrate.
  final NameVoice nameVoice;

  List<ChildProfile> profiles = const [];
  ChildProfile? currentProfile;
  SessionMode mode = SessionMode.together;

  /// Con più figli, a ogni avvio il bambino sceglie chi gioca ("Chi gioca oggi?").
  /// Vale per la sessione: non si salva.
  bool _childChosen = false;
  bool get needsChildChoice => profiles.length > 1 && !_childChosen;

  Future<void> init() async {
    profiles = await db.profiles();
    currentProfile = profiles.isEmpty ? null : profiles.first;
    if (currentProfile != null) mode = currentProfile!.lastMode;
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

  /// La mensola che il bambino vede adesso, capacità per capacità.
  Map<Capacity, List<ShelfItem>> shelfFor(ChildProfile p) => Shelf.arrange(shelfCandidates(p), p.shelf);

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
    notifyListeners();
  }

  Future<void> setMode(SessionMode m) async {
    mode = m;
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
    notifyListeners();
    nameVoice.prepare(saved);
  }

  Future<void> updateProfile(ChildProfile p) async {
    await db.updateProfile(p);
    profiles = await db.profiles();
    if (currentProfile?.id == p.id) currentProfile = p;
    notifyListeners();
    // Se nome e lingua non sono cambiati il file c'è già e non si rigenera.
    nameVoice.prepare(p);
  }

  Future<void> deleteProfile(int id) async {
    await db.deleteProfile(id);
    await nameVoice.forget(id);
    profiles = await db.profiles();
    if (currentProfile?.id == id) currentProfile = profiles.isEmpty ? null : profiles.first;
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

  /// Il backup su Drive non si tocca: il tablet lo dimentica e basta, così
  /// resta ripristinabile e un tablet vuoto non lo sovrascrive.
  Future<void> wipeAll() async {
    await db.wipe();
    await backup.forget();
    await nameVoice.forget();
    profiles = const [];
    currentProfile = null;
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
