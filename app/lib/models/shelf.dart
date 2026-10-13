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

abstract final class Shelf {
  /// Materiali per capacità: pochi, perché il bambino possa sceglierne uno
  /// e lavorarci invece di scorrere un catalogo.
  static const perCapacity = 3;

  /// Dispone i materiali disponibili sulla mensola, capacità per capacità
  /// (solo quelle con almeno un materiale).
  ///
  /// [chosen] è la scelta del genitore: si tengono, nel suo ordine, i
  /// materiali ancora disponibili (età, lingua e modalità possono cambiare).
  /// Senza scelta ([chosen] null) la mensola si riempie da sola.
  static Map<Capacity, List<ShelfItem>> arrange(List<ShelfItem> available, List<String>? chosen) {
    final byCapacity = {for (final c in Capacity.values) c: <ShelfItem>[]};
    if (chosen == null) {
      for (final c in Capacity.values) {
        byCapacity[c] = _alternate(available.where((i) => i.capacity == c)).take(perCapacity).toList();
      }
    } else {
      final byKey = {for (final i in available) i.key: i};
      for (final k in chosen) {
        final item = byKey[k];
        if (item == null) continue;
        final list = byCapacity[item.capacity]!;
        if (list.length < perCapacity) list.add(item);
      }
    }
    return {
      for (final e in byCapacity.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    };
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
