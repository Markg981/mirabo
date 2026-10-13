import 'package:flutter/widgets.dart';

import 'audio/name_voice.dart';
import 'content/story_repository.dart';
import 'data/cloud_backup.dart';
import 'data/local_db.dart';
import 'models/activity.dart';
import 'models/profile.dart';
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

  List<Story> storiesFor(ChildProfile p) => repo.storiesIn(p.language).where((s) => p.canOpen(s, mode)).toList();

  List<Activity> activitiesFor(ChildProfile p, {ActivityModule? module}) => repo.activitiesIn(p.language)
      .where((a) => a.supports(p.ageBand) && (module == null || a.module == module))
      .toList();

  /// Chiude una sessione di attività: salva i round, applica l'adattività,
  /// e conta la sessione come "storia completata" ai fini della crescita del compagno
  /// solo se almeno un round è stato fatto.
  Future<void> recordActivity(Activity activity, ActivityProgress before, List<RoundResult> results) async {
    final p = currentProfile;
    if (p == null || results.isEmpty) return;
    await db.addRounds(p.id, activity, before.level, results);
    await db.saveProgress(applyAdaptive(before, results, activity.levels.length));
    await updateProfile(p.copyWith(storiesCompleted: p.storiesCompleted + 1));
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

  /// Registra una storia nel diario; se completata, fa crescere il compagno.
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
