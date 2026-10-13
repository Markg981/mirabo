import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/l10n/l10n.dart';
import 'package:mirabo/models/nature_day.dart';
import 'package:mirabo/models/profile.dart';

/// Solo la parte di LocalDb che usa il calendario.
class _FakeDb implements LocalDb {
  final Map<String, NatureDay> days = {};
  final Map<String, String> settings = {};

  @override
  Future<List<ChildProfile>> profiles() async => const [];

  @override
  Future<String?> setting(String key) async => settings[key];

  @override
  Future<void> setSetting(String key, String value) async => settings[key] = value;

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
      final equator = {for (var e = 1; e <= equatorTipCount; e++) l.natureEquatorTip('e$e')};
      expect(equator, hasLength(equatorTipCount), reason: "[$lang] suggerimenti per l'equatore mancanti o ripetuti");
      expect(equator.intersection(tips), isEmpty, reason: '[$lang]');
      for (final w in Weather.values) {
        expect(l.natureWeather(w.name), isNot(w.name), reason: '[$lang] $w');
      }
      for (final t in NatureThing.values) {
        expect(l.natureThing(t.name), isNot(t.name), reason: '[$lang] $t');
      }
    }
  });

  group('emisferi', () {
    final l = lookupAppLocalizations(AppLanguage.it.locale);
    final jan = DateTime(2027, 1);
    String tip(Hemisphere h, DateTime month, [DateTime? today]) =>
        natureTip(l, h, month: month, today: today ?? DateTime(month.year, month.month, 13));

    test('sud: gennaio usa il testo di luglio, e così via di sei mesi', () {
      expect(tip(Hemisphere.south, jan), l.natureMonthTip('m7'));
      for (var m = 1; m <= 12; m++) {
        expect(seasonalMonth(m, Hemisphere.south), (m + 6 - 1) % 12 + 1);
      }
      expect({for (var m = 1; m <= 12; m++) seasonalMonth(m, Hemisphere.south)}, hasLength(12));
    });

    test('nord: gennaio resta il testo di gennaio', () {
      expect(tip(Hemisphere.north, jan), l.natureMonthTip('m1'));
      for (var m = 1; m <= 12; m++) {
        expect(seasonalMonth(m, Hemisphere.north), m);
      }
    });

    test('equatore: non dipende dal mese, cambia di settimana in settimana', () {
      final monday = DateTime(2026, 10, 12);
      final week = {for (var d = 0; d < 7; d++) tip(Hemisphere.equator, jan, DateTime(2026, 10, 12 + d))};
      expect(week, hasLength(1), reason: 'stessa settimana, stesso suggerimento');
      expect(tip(Hemisphere.equator, DateTime(2026, 7), monday), week.single, reason: 'il mese mostrato non conta');
      expect(tip(Hemisphere.equator, jan, DateTime(2026, 10, 11)), isNot(week.single), reason: 'domenica è ancora la settimana prima');
      final weeks = {for (var w = 0; w < equatorTipCount; w++) equatorTip(DateTime(2026, 10, 12 + 7 * w))};
      expect(weeks, hasLength(equatorTipCount), reason: 'ruotano tutti');
      expect(tip(Hemisphere.equator, jan, monday), isNot(anyOf([for (var m = 1; m <= 12; m++) l.natureMonthTip('m$m')])));
    });

    test('dalla regione del dispositivo, non dalla lingua', () {
      expect(Hemisphere.fromRegion('AU'), Hemisphere.south);
      expect(Hemisphere.fromRegion('ar'), Hemisphere.south);
      expect(Hemisphere.fromRegion('KE'), Hemisphere.equator);
      expect(Hemisphere.fromRegion('GB'), Hemisphere.north);
      expect(Hemisphere.fromRegion(null), Hemisphere.north, reason: 'senza regione: nord');
    });

    AppState stateWith(_FakeDb db, String? region) => AppState(
          db: db,
          repo: _NoRepo(),
          nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
          region: () => region,
        );

    test('valore iniziale: regione AU è sud anche in inglese; la scelta del genitore resta', () async {
      final db = _FakeDb();
      final state = stateWith(db, 'AU');
      await state.init();
      expect(state.hemisphere, Hemisphere.south);
      expect(db.settings, isEmpty, reason: 'dedotto, non ancora scelto');

      await state.setHemisphere(Hemisphere.equator);
      expect(db.settings[LocalDb.hemisphereKey], 'equator');
      final again = stateWith(db, 'AU');
      await again.init();
      expect(again.hemisphere, Hemisphere.equator, reason: 'la scelta vince sulla regione');
    });
  });
}
