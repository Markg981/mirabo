import 'dart:math';

import 'story.dart';

/// I tre tempi della lezione Montessori, più la fine.
enum LessonPeriod {
  /// "Questa è la luna": il compagno nomina una figura alla volta.
  naming,

  /// "Dov'è la luna?": il bambino la tocca tra le altre.
  recognition,

  /// "E questa, cos'è?": il bambino dice il nome a voce.
  recall,
  done,
}

/// Una lezione in tre tempi in corso, da sola (senza Flutter), così le regole
/// si provano nei test.
///
/// Non c'è errore: se nel secondo tempo il bambino tocca un'altra figura, il
/// compagno gli dice il nome di quella che ha toccato e ripete la domanda,
/// come fa l'adulto Montessori che torna al primo tempo senza correggere.
/// Dopo due tocchi su altre figure, quella chiesta si illumina. Nel terzo tempo
/// l'app non può sentire la risposta: il bambino la dice, poi tocca la figura
/// e ascolta il nome.
class LessonRun {
  LessonRun(this.lesson, {Random? random}) {
    final rnd = random ?? Random();
    _recognition = _shuffled(rnd, avoidFirst: lesson.items.last.id);
    _recall = _shuffled(rnd, avoidFirst: _recognition.last.id);
  }

  final Lesson lesson;
  late final List<LessonItem> _recognition;
  late final List<LessonItem> _recall;

  LessonPeriod _period = LessonPeriod.naming;
  int _step = 0;
  int _misses = 0;
  bool _revealed = false;

  LessonPeriod get period => _period;
  bool get isDone => _period == LessonPeriod.done;

  /// Nel terzo tempo, il nome della figura è stato detto: si aspetta advance().
  bool get revealed => _revealed;

  /// La figura in primo piano: quella che si nomina o che si deve ricordare.
  /// Nel secondo tempo nessuna, salvo l'aiuto dopo due tocchi altrove.
  LessonItem? get focus => switch (_period) {
        LessonPeriod.naming => lesson.items[_step],
        LessonPeriod.recognition => _misses >= 2 ? _recognition[_step] : null,
        LessonPeriod.recall => _recall[_step],
        LessonPeriod.done => null,
      };

  /// Se la figura mostra il nome scritto: solo quando lo si è appena detto.
  bool showsName(LessonItem item) => switch (_period) {
        LessonPeriod.naming => lesson.items.indexOf(item) <= _step,
        LessonPeriod.recognition => false,
        LessonPeriod.recall => _revealed && item.id == _recall[_step].id,
        LessonPeriod.done => true,
      };

  /// Quello che dice il compagno adesso.
  String get prompt => switch (_period) {
        LessonPeriod.naming => lesson.items[_step].naming,
        LessonPeriod.recognition => _recognition[_step].show,
        LessonPeriod.recall => _revealed ? _recall[_step].naming : lesson.ask,
        LessonPeriod.done => lesson.done,
      };

  /// Il bambino tocca una figura. Restituisce cosa dire, o null se il tocco
  /// non cambia niente.
  String? tap(String id) {
    switch (_period) {
      case LessonPeriod.naming:
        if (id != lesson.items[_step].id) {
          // Una figura già nominata si ripete; una non ancora nominata non si anticipa.
          final i = lesson.items.indexWhere((x) => x.id == id);
          return i < _step ? lesson.items[i].naming : prompt;
        }
        _step++;
        if (_step == lesson.items.length) _start(LessonPeriod.recognition);
        return prompt;
      case LessonPeriod.recognition:
        if (id != _recognition[_step].id) {
          _misses++;
          return '${lesson.item(id).naming} ${_recognition[_step].show}';
        }
        _misses = 0;
        _step++;
        if (_step == _recognition.length) _start(LessonPeriod.recall);
        return prompt;
      case LessonPeriod.recall:
        if (id != _recall[_step].id) return null;
        if (_revealed) return advance();
        _revealed = true;
        return prompt;
      case LessonPeriod.done:
        return lesson.item(id).naming;
    }
  }

  /// Terzo tempo: dopo aver sentito il nome, si passa alla figura dopo.
  String advance() {
    if (_period != LessonPeriod.recall || !_revealed) return prompt;
    _revealed = false;
    _step++;
    if (_step == _recall.length) _start(LessonPeriod.done);
    return prompt;
  }

  void _start(LessonPeriod p) {
    _period = p;
    _step = 0;
    _misses = 0;
  }

  /// Un ordine diverso da quello del primo tempo, che non cominci dalla figura
  /// appena detta: altrimenti il secondo tempo si risolve a memoria.
  List<LessonItem> _shuffled(Random rnd, {required String avoidFirst}) {
    final out = [...lesson.items]..shuffle(rnd);
    if (out.length > 1 && out.first.id == avoidFirst) out.add(out.removeAt(0));
    return out;
  }
}
