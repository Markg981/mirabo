import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/nature_day.dart';

/// Solo la parte di LocalDb che usa il calendario.
class _FakeDb implements LocalDb {
  final Map<String, NatureDay> days = {};

  @override
  Future<void> saveNatureDay(NatureDay d) async =>
      d.isEmpty ? days.remove(NatureDay.key(d.day)) : days[NatureDay.key(d.day)] = d;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final oct13 = DateTime(2026, 10, 13);
  NatureDay day([DateTime? d]) => NatureDay(profileId: 1, day: d ?? oct13);

  test('al massimo tre cose viste al giorno; toccarne una la toglie', () {
    var d = day().toggle(NatureThing.leaf).toggle(NatureThing.bird).toggle(NatureThing.moon);
    expect(d.seen, {NatureThing.leaf, NatureThing.bird, NatureThing.moon});
    expect(identical(d.toggle(NatureThing.snail), d), isTrue, reason: 'la quarta non entra');
    d = d.toggle(NatureThing.bird);
    expect(d.seen, {NatureThing.leaf, NatureThing.moon});
  });

  test('si salva e si rilegge dal database', () {
    final d = day().copyWith(weather: Weather.rain).toggle(NatureThing.snail).toggle(NatureThing.mushroom);
    final row = d.toRow();
    expect(row['day'], '2026-10-13');
    final back = NatureDay.fromRow(row);
    expect(back.day, oct13);
    expect(back.weather, Weather.rain);
    expect(back.seen, d.seen);
    expect(NatureDay.fromRow(day().toRow()).isEmpty, isTrue);
  });

  test('il riassunto del mese conta i giorni, non premia', () {
    final month = NatureMonth([
      day(DateTime(2026, 10, 1)).copyWith(weather: Weather.sun).toggle(NatureThing.leaf),
      day(DateTime(2026, 10, 2)).copyWith(weather: Weather.sun),
      day(DateTime(2026, 10, 5)).copyWith(weather: Weather.rain).toggle(NatureThing.leaf).toggle(NatureThing.snail),
      day(DateTime(2026, 10, 6)),
    ]);
    expect(month.observed, 3);
    expect(month.weather, {Weather.sun: 2, Weather.rain: 1});
    expect(month.seen, {NatureThing.leaf: 2, NatureThing.snail: 1});
  });

  test('giorni del mese', () {
    expect(daysInMonth(DateTime(2026, 2)), 28);
    expect(daysInMonth(DateTime(2028, 2)), 29);
    expect(daysInMonth(DateTime(2026, 10)), 31);
    expect(daysInMonth(DateTime(2026, 12)), 31);
  });

  test('si segnano oggi e i giorni passati, non quelli futuri', () async {
    final db = _FakeDb();
    final state = AppState(
      db: db,
      repo: _NoRepo(),
      nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
    );
    final now = DateTime(2026, 10, 13, 18);
    await state.saveNatureDay(day().copyWith(weather: Weather.sun), now: now);
    await state.saveNatureDay(day(DateTime(2026, 10, 2)).copyWith(weather: Weather.fog), now: now);
    expect(db.days.keys, containsAll(['2026-10-13', '2026-10-02']));
    expect(state.saveNatureDay(day(DateTime(2026, 10, 14)).copyWith(weather: Weather.sun), now: now), throwsArgumentError);
    // Svuotare un giorno lo toglie dal calendario.
    await state.saveNatureDay(day(), now: now);
    expect(db.days.keys, ['2026-10-02']);
  });

  test('un suggerimento per ogni mese, in tutte le lingue', () {
    for (final lang in AppLanguage.values) {
      final l = lookupAppLocalizations(lang.locale);
      final tips = {for (var m = 1; m <= 12; m++) l.natureMonthTip('m$m')};
      expect(tips, hasLength(12), reason: '[$lang] suggerimenti mancanti o ripetuti');
      for (final w in Weather.values) {
        expect(l.natureWeather(w.name), isNot(w.name), reason: '[$lang] $w');
      }
      for (final t in NatureThing.values) {
        expect(l.natureThing(t.name), isNot(t.name), reason: '[$lang] $t');
      }
    }
  });
}
