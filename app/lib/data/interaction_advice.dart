import '../models/activity.dart';
import '../models/profile.dart';

/// Un asse del profilo di interazione.
enum InteractionAxis { hands, reading, autonomy }

/// Una proposta al genitore: spostare un asse di un passo. L'app propone, non
/// cambia da sola: decide sempre il genitore.
class InteractionAdvice {
  const InteractionAdvice(this.axis, this.next, {this.rounds = 0, this.days = 0});
  final InteractionAxis axis;

  /// Su cosa si basa la proposta, da dire al genitore: quanti round e in quanti giorni.
  final int rounds;
  final int days;

  /// Il profilo come sarebbe accettando la proposta.
  final InteractionProfile next;

  /// Chiave per ricordare che il genitore ha detto "non ora" a questo passo.
  String key(int profileId) => '$profileId:${axis.name}:${next.toRow().values.join('-')}';
}

/// Round per abilità con cui decidere: abbastanza da non fidarsi di un giorno fortunato.
const adviceMinRounds = 6;
const adviceMinDays = 2;

/// Quota di round riusciti al primo tentativo, senza aiuti, oltre la quale si propone il passo.
const adviceFirstTryShare = 0.8;

/// Tipi a scelta: misurano quante opzioni il bambino gestisce da solo.
const _choiceTypes = {ActivityType.tapMatch, ActivityType.count, ActivityType.pattern};

/// Guarda i round degli ultimi giorni (righe di activity_rounds: activity_id,
/// attempts, hints, at) e propone al massimo un passo avanti:
/// - mani: traccia al primo tentativo → tracciati più fini;
/// - lettura: compone le parole con l'alfabeto mobile al primo tentativo → più testo;
/// - autonomia: risponde giusto al primo tentativo nei giochi a scelta → più scelte.
InteractionAdvice? adviseInteraction(
  InteractionProfile profile,
  List<Map<String, Object?>> rounds,
  ActivityType? Function(String activityId) typeOf,
) {
  // Quanti round e giorni hanno portato alla proposta; vale per l'ultimo ready() riuscito.
  var basisRounds = 0, basisDays = 0;
  bool ready(bool Function(ActivityType t) which) {
    final mine = rounds.where((r) {
      final t = typeOf(r['activity_id'] as String);
      return t != null && which(t);
    }).toList();
    if (mine.length < adviceMinRounds) return false;
    final days = mine.map((r) => (r['at'] as String).substring(0, 10)).toSet();
    if (days.length < adviceMinDays) return false;
    final firstTry = mine.where((r) => r['attempts'] == 1 && r['hints'] == 0).length;
    if (firstTry / mine.length < adviceFirstTryShare) return false;
    basisRounds = mine.length;
    basisDays = days.length;
    return true;
  }

  if (profile.hands < InteractionProfile.maxLevel && ready((t) => t == ActivityType.trace)) {
    return InteractionAdvice(InteractionAxis.hands, profile.copyWith(hands: profile.hands + 1),
        rounds: basisRounds, days: basisDays);
  }
  if (profile.reading != ReadingLevel.fluent && ready((t) => t == ActivityType.spell)) {
    return InteractionAdvice(InteractionAxis.reading, profile.copyWith(reading: ReadingLevel.values[profile.reading.index + 1]),
        rounds: basisRounds, days: basisDays);
  }
  if (profile.autonomy < InteractionProfile.maxLevel && ready(_choiceTypes.contains)) {
    return InteractionAdvice(InteractionAxis.autonomy, profile.copyWith(autonomy: profile.autonomy + 1),
        rounds: basisRounds, days: basisDays);
  }
  return null;
}
