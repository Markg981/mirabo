/// La mensola: pochi materiali alla volta, ordinati per capacità come gli
/// scaffali di un ambiente Montessori. Il bambino sceglie liberamente tra
/// quelli che ci sono; l'adulto decide cosa metterci e quando cambiarlo.
library;

import '../games/game.dart';
import 'activity.dart';
import 'story.dart';

/// Le capacità che il bambino esercita. Storie, giochi e attività stanno
/// insieme sotto la stessa capacità, non divisi per tipo di contenuto.
enum Capacity { insieme, mani, sensi, parole, pensare, mondo }

/// Un materiale che può stare sulla mensola. La chiave ("story:…", "game:…",
/// "activity:…") è quella salvata nel profilo.
sealed class ShelfItem {
  const ShelfItem();

  String get key;
  Capacity get capacity;

  /// Da dove viene: in automatico la mensola alterna le fonti, così una
  /// capacità non si riempie solo di storie o solo di un'area.
  String get source;
}

class StoryItem extends ShelfItem {
  const StoryItem(this.story);
  final Story story;

  @override
  String get key => 'story:${story.id}';
  @override
  Capacity get capacity => Capacity.insieme;
  @override
  String get source => 'story';
}

class GameItem extends ShelfItem {
  const GameItem(this.game);
  final GameInfo game;

  @override
  String get key => 'game:${game.id}';
  @override
  Capacity get capacity => capacityOfGame(game.id);
  @override
  String get source => 'game';
}

class ActivityItem extends ShelfItem {
  const ActivityItem(this.activity);
  final Activity activity;

  @override
  String get key => 'activity:${activity.id}';
  @override
  Capacity get capacity => capacityOfActivity(activity);
  @override
  String get source => activity.area.name;
}

/// Gli strumenti di "Creo e scopro": la fabbrica di storie esercita le
/// parole, il calendario della natura l'osservazione del mondo.
enum MakeTool { factory, nature }

class MakeItem extends ShelfItem {
  const MakeItem(this.tool);
  final MakeTool tool;

  @override
  String get key => 'make:${tool.name}';
  @override
  Capacity get capacity => switch (tool) {
        MakeTool.factory => Capacity.parole,
        MakeTool.nature => Capacity.mondo,
      };
  @override
  String get source => 'make';
}

/// Le aree "Verso la scuola" e Montessori portate sulle capacità. I
/// prerequisiti si dividono per abilità: lettere e suoni alle parole,
/// numeri e logica al pensare.
Capacity capacityOfActivity(Activity a) => switch (a.area) {
      ActivityArea.sociale || ActivityArea.paure => Capacity.insieme,
      ActivityArea.vitaPratica || ActivityArea.autonomia => Capacity.mani,
      ActivityArea.sensoriale => Capacity.sensi,
      ActivityArea.linguaggio => Capacity.parole,
      ActivityArea.matematica => Capacity.pensare,
      ActivityArea.cultura => Capacity.mondo,
      ActivityArea.cognitivo => const {'suoni-iniziali', 'pregrafismo'}.contains(a.skill) ? Capacity.parole : Capacity.pensare,
    };

Capacity capacityOfGame(String id) => switch (id) {
      'drawing' => Capacity.mani,
      'shapes' || 'xylophone' || 'balloons' => Capacity.sensi,
      _ => Capacity.pensare,
    };

/// Un uso di un materiale: una storia letta, una sessione di attività, una
/// storia inventata, un giorno del calendario. [repeat] è il "vuole rifarla"
/// segnato dall'adulto dopo una presentazione.
class ShelfUse {
  const ShelfUse(this.key, this.at, {this.repeat = false});
  final String key;
  final DateTime at;
  final bool repeat;
}

/// Un periodo in cui un materiale è stato sulla mensola automatica;
/// [to] null se c'è ancora.
class ShelfStint {
  const ShelfStint(this.key, this.from, [this.to]);
  final String key;
  final DateTime from;
  final DateTime? to;
}

abstract final class Shelf {
  /// Al massimo due materiali per capacità: la mensola si guarda tutta con
  /// uno sguardo, e una capacità non la riempie da sola.
  static const maxPerCapacity = 2;

  /// La mensola automatica cambia una volta a settimana.
  static const rotation = Duration(days: 7);

  /// Uno sguardo basta per vederli tutti e scegliere davvero.
  static int size(AgeBand band) => switch (band) {
        AgeBand.b3to5 => 4,
        AgeBand.b6to7 => 6,
        AgeBand.b8to10 => 8,
      };

  /// Dispone i materiali disponibili sulla mensola, capacità per capacità
  /// (solo quelle con almeno un materiale), entro il tetto della fascia.
  ///
  /// [chosen] è la scelta del genitore o la mensola automatica salvata: si
  /// tengono, nel suo ordine, i materiali ancora disponibili (età, lingua e
  /// modalità possono cambiare). Senza lista ([chosen] null) la mensola si
  /// riempie da sola, una capacità per volta.
  static Map<Capacity, List<ShelfItem>> arrange(List<ShelfItem> available, List<String>? chosen, AgeBand band) {
    final List<ShelfItem> items;
    if (chosen == null) {
      items = _fill(_byCapacity(_alternate(available)), const [], size(band));
    } else {
      final byKey = {for (final i in available) i.key: i};
      items = _fit([for (final k in chosen) if (byKey[k] case final i?) i], size(band));
    }
    final byCapacity = {for (final c in Capacity.values) c: <ShelfItem>[]};
    for (final i in items) {
      byCapacity[i.capacity]!.add(i);
    }
    return {
      for (final e in byCapacity.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    };
  }

  /// La rotazione settimanale della mensola automatica, come fa l'adulto
  /// osservando il bambino:
  /// - resta ciò su cui il bambino lavora (usato 2 o più volte nell'ultima
  ///   settimana, o "vuole rifarla"), ma al massimo metà della mensola, così
  ///   qualcosa di nuovo entra sempre;
  /// - esce tutto il resto;
  /// - entra ciò che non è stato sulla mensola da più tempo (o mai).
  ///
  /// Un materiale appena uscito rientra solo se non c'è nient'altro.
  static List<String> rotate({
    required List<ShelfItem> available,
    required AgeBand band,
    required List<String> current,
    required List<ShelfUse> usage,
    required List<ShelfStint> history,
    required DateTime now,
  }) {
    final cap = size(band);
    final byKey = {for (final i in available) i.key: i};
    final onShelf = _fit([for (final k in current) if (byKey[k] case final i?) i], cap);

    final since = now.subtract(rotation);
    final times = <String, int>{};
    final repeat = <String>{};
    for (final u in usage) {
      if (u.at.isBefore(since) || u.at.isAfter(now)) continue;
      times[u.key] = (times[u.key] ?? 0) + 1;
      if (u.repeat) repeat.add(u.key);
    }
    final working = onShelf.where((i) => (times[i.key] ?? 0) >= 2 || repeat.contains(i.key)).toList()
      ..sort((a, b) => (times[b.key] ?? 0).compareTo(times[a.key] ?? 0));
    final stay = working.take(cap ~/ 2).toList();

    // Da quanto un materiale non c'è: mai stato prima di tutto, poi chi è
    // uscito da più tempo. A parità resta l'alternanza delle fonti.
    final lastSeen = <String, DateTime>{};
    for (final s in history) {
      final end = s.to ?? now;
      if (lastSeen[s.key]?.isAfter(end) ?? false) continue;
      lastSeen[s.key] = end;
    }
    final leaving = {for (final i in onShelf) i.key}..removeAll(stay.map((i) => i.key));
    final order = _alternate(available);
    final rank = {for (var n = 0; n < order.length; n++) order[n].key: n};
    int compare(ShelfItem a, ShelfItem b) {
      final la = lastSeen[a.key], lb = lastSeen[b.key];
      if (la != lb) {
        if (la == null) return -1;
        if (lb == null) return 1;
        return la.compareTo(lb);
      }
      return rank[a.key]!.compareTo(rank[b.key]!);
    }

    final fresh = order.where((i) => !leaving.contains(i.key)).toList()..sort(compare);
    final next = _fill(_byCapacity(order.where((i) => leaving.contains(i.key))), _fill(_byCapacity(fresh), stay, cap), cap);
    return [for (final i in next) i.key];
  }

  /// I materiali nell'ordine dato, saltando chi supera il tetto della
  /// capacità o della mensola.
  static List<ShelfItem> _fit(Iterable<ShelfItem> items, int cap) {
    final out = <ShelfItem>[];
    final count = <Capacity, int>{};
    for (final i in items) {
      if (out.length >= cap) break;
      if (out.any((o) => o.key == i.key)) continue;
      if ((count[i.capacity] ?? 0) >= maxPerCapacity) continue;
      count[i.capacity] = (count[i.capacity] ?? 0) + 1;
      out.add(i);
    }
    return out;
  }

  /// Parte da [already] e aggiunge un materiale per capacità a giro, finché
  /// non arriva al tetto. Una capacità senza posto o senza materiali si salta.
  static List<ShelfItem> _fill(Map<Capacity, List<ShelfItem>> pool, List<ShelfItem> already, int cap) {
    final out = [...already];
    final count = <Capacity, int>{};
    for (final i in out) {
      count[i.capacity] = (count[i.capacity] ?? 0) + 1;
    }
    final queues = {for (final e in pool.entries) e.key: e.value.where((i) => !out.any((o) => o.key == i.key)).toList()};
    var added = true;
    while (out.length < cap && added) {
      added = false;
      for (final c in Capacity.values) {
        if (out.length >= cap) break;
        final q = queues[c];
        if (q == null || q.isEmpty || (count[c] ?? 0) >= maxPerCapacity) continue;
        out.add(q.removeAt(0));
        count[c] = (count[c] ?? 0) + 1;
        added = true;
      }
    }
    return out;
  }

  static Map<Capacity, List<ShelfItem>> _byCapacity(Iterable<ShelfItem> items) {
    final out = <Capacity, List<ShelfItem>>{};
    for (final i in items) {
      out.putIfAbsent(i.capacity, () => []).add(i);
    }
    return out;
  }

  /// Un materiale per fonte a turno, nell'ordine in cui arrivano.
  static List<ShelfItem> _alternate(Iterable<ShelfItem> items) {
    final queues = <String, List<ShelfItem>>{};
    var total = 0;
    for (final i in items) {
      queues.putIfAbsent(i.source, () => []).add(i);
      total++;
    }
    final out = <ShelfItem>[];
    for (var round = 0; out.length < total; round++) {
      for (final q in queues.values) {
        if (round < q.length) out.add(q[round]);
      }
    }
    return out;
  }

  static List<String> keysOf(Map<Capacity, List<ShelfItem>> shelf) => [for (final l in shelf.values) ...l.map((i) => i.key)];
}
