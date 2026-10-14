import 'dart:async';

import 'package:flutter/widgets.dart';

import 'local_db.dart';

/// Un giorno di uso: secondi con l'app in primo piano e schermo acceso.
class DayUsage {
  const DayUsage(this.day, this.seconds);
  final DateTime day;
  final int seconds;
  int get minutes => (seconds / 60).round();
}

/// Misura una cosa sola: quanto tempo l'app è stata aperta e in primo piano
/// per ciascun bambino (schermo attivo). Non sa se il bambino stava guardando,
/// né misura l'ascolto a schermo spento o le attività fuori dallo schermo
/// (quelle le dichiara la famiglia nel diario). Niente schema nuovo: un
/// contatore al giorno per bambino nella tabella `settings`, che il backup
/// già include. Solo dati neutri, mai un obiettivo: nessuno li premia.
class UsageTracker with WidgetsBindingObserver {
  UsageTracker({required this.db, required this.profileId, DateTime Function()? clock, this.flushEvery = const Duration(seconds: 30)})
      : _now = clock ?? DateTime.now;

  final LocalDb db;

  /// Il bambino che sta usando il tablet adesso (null: nessuno).
  final int? Function() profileId;
  final DateTime Function() _now;
  final Duration flushEvery;

  DateTime? _since;
  int? _creditId;
  DateTime? _lastFlush;
  final Map<String, int> _pending = {};
  Timer? _timer;

  static String key(int profileId, DateTime day) =>
      'usage.$profileId.${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  /// Da chiamare una volta, con l'app già in primo piano.
  void start() {
    WidgetsBinding.instance.addObserver(this);
    resume();
    _timer = Timer.periodic(flushEvery, (_) => tick());
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    pause();
  }

  /// L'app torna in primo piano: il conteggio riparte.
  void resume() {
    _since ??= _now();
    _creditId = profileId();
  }

  /// L'app esce dal primo piano: si chiude il tratto e si salva.
  void pause() {
    tick(force: true);
    _since = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resume();
    } else {
      pause();
    }
  }

  /// Accredita il tempo trascorso dall'ultimo tick al bambino di allora.
  /// Se il bambino è cambiato salva subito, altrimenti al massimo ogni [flushEvery].
  void tick({bool force = false}) {
    final now = _now();
    final since = _since;
    if (since != null && _creditId != null) {
      final secs = now.difference(since).inSeconds;
      if (secs > 0) {
        final k = key(_creditId!, now);
        _pending[k] = (_pending[k] ?? 0) + secs;
        _since = since.add(Duration(seconds: secs));
      }
    }
    final changed = since != null && _creditId != profileId();
    _creditId = profileId();
    if (force || changed || _lastFlush == null || now.difference(_lastFlush!) >= flushEvery) {
      unawaited(flush());
    }
  }

  Future<void> _saving = Future.value();

  /// Scritture una dopo l'altra: due salvataggi insieme si perderebbero minuti.
  Future<void> flush() => _saving = _saving.then((_) => _flush());

  Future<void> _flush() async {
    _lastFlush = _now();
    final todo = Map<String, int>.of(_pending);
    _pending.clear();
    for (final e in todo.entries) {
      final before = int.tryParse(await db.setting(e.key) ?? '') ?? 0;
      await db.setSetting(e.key, '${before + e.value}');
    }
  }

  /// Gli ultimi [days] giorni (oggi compreso), dal più vecchio al più recente.
  Future<List<DayUsage>> lastDays(int profileId, {int days = 7}) async {
    tick(force: true);
    await flush();
    final today = _now();
    final out = <DayUsage>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime(today.year, today.month, today.day - i);
      out.add(DayUsage(d, int.tryParse(await db.setting(key(profileId, d)) ?? '') ?? 0));
    }
    return out;
  }
}
