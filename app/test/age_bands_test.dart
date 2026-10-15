import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/app_state.dart';
import 'package:mirabo/audio/name_voice.dart';
import 'package:mirabo/content/story_repository.dart';
import 'package:mirabo/data/local_db.dart';
import 'package:mirabo/models/activity.dart';
import 'package:mirabo/models/profile.dart';
import 'package:mirabo/models/story.dart';

class _FakeDb implements LocalDb {
  _FakeDb(this.profile);
  ChildProfile profile;
  final saved = <ActivityProgress>[];

  @override
  Future<List<ChildProfile>> profiles() async => [profile];
  @override
  Future<String?> setting(String key) async => null;
  @override
  Future<void> setSetting(String key, String value) async {}
  @override
  Future<void> updateProfile(ChildProfile p) async => profile = p;
  @override
  Future<void> addRounds(int profileId, Activity a, int level, List<RoundResult> r) async {}
  @override
  Future<ActivityProgress> progress(int profileId, String activityId) async =>
      ActivityProgress(profileId: profileId, activityId: activityId);
  @override
  Future<void> saveProgress(ActivityProgress p) async => saved.add(p);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo implements StoryRepository {
  @override
  List<Activity> get activities => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Una riga del database com'era prima delle fasce attuali.
Map<String, Object?> _row(String band, {Map<String, Object?> extra = const {}}) => {
      'id': 1,
      'name': 'Ada',
      'age_band': band,
      'companion': 'bo',
      'enabled_worlds': 'emozioni,ambiente',
      'safety_together_only': 1,
      'last_mode': 'together',
      'dyslexia_font': 0,
      'low_stimulation': 0,
      'read_along': 1,
      'alone_minutes': 20,
      'stories_completed': 4,
      ...extra,
    };

void main() {
  group('confini', () {
    test('cinque anni nella prima fascia, sei e sette nella seconda, otto-dieci nella terza', () {
      expect([for (var age = 3; age <= 10; age++) AgeBand.forAge(age).key],
          ['3-5', '3-5', '3-5', '6-7', '6-7', '8-10', '8-10', '8-10']);
    });

    test('le fasce non si sovrappongono e coprono 3-10', () {
      final ages = [for (final b in AgeBand.values) for (var a = b.minAge; a <= b.maxAge; a++) a];
      expect(ages, [for (var a = 3; a <= 10; a++) a]);
      for (final b in AgeBand.values) {
        expect(AgeBand.forAge(b.minAge), b);
        expect(AgeBand.forAge(b.maxAge), b);
      }
    });
  });

  group('chiavi di prima', () {
    test('un profilo non accetta le chiavi di prima, un pacchetto sì', () {
      expect(() => AgeBand.fromKey('5-7'), throwsArgumentError);
      expect(AgeBand.fromContentKey('5-7'), AgeBand.b6to7);
      expect(AgeBand.fromContentKey('7-10'), AgeBand.b8to10);
      expect(AgeBand.fromContentKey('3-5'), AgeBand.b3to5);
      expect(() => AgeBand.fromContentKey('4-6'), throwsArgumentError);
    });

    test('ogni fascia di prima propone solo le fasce attuali possibili', () {
      expect(LegacyAgeBand.b5to7.choices, [AgeBand.b3to5, AgeBand.b6to7]);
      expect(LegacyAgeBand.b7to10.choices, [AgeBand.b6to7, AgeBand.b8to10]);
      for (final l in LegacyAgeBand.values) {
        expect(l.choices, contains(l.content));
      }
    });
  });

  group('profili di prima', () {
    test('5-7 resta sugli stessi contenuti e chiede la conferma', () {
      final p = ChildProfile.fromRow(_row('5-7'));
      expect(p.ageBand, AgeBand.b6to7);
      expect(p.bandToConfirm, LegacyAgeBand.b5to7);
      // Gli stessi aiuti che aveva con 5-7.
      expect(p.interaction, const InteractionProfile(hands: 2, reading: ReadingLevel.letters, autonomy: 2));
      expect(p.storiesCompleted, 4);
    });

    test('dopo la migrazione v11 la riga dice ancora quale fascia confermare', () {
      final p = ChildProfile.fromRow(_row('8-10', extra: {'band_to_confirm': '7-10', 'hands': 3, 'reading': 'words', 'autonomy': 3}));
      expect(p.ageBand, AgeBand.b8to10);
      expect(p.bandToConfirm, LegacyAgeBand.b7to10);
    });

    test('3-5 non cambia e non chiede nulla', () {
      final p = ChildProfile.fromRow(_row('3-5'));
      expect(p.ageBand, AgeBand.b3to5);
      expect(p.bandToConfirm, isNull);
    });

    test('modificare il profilo senza scegliere la fascia non la conferma', () {
      final p = ChildProfile.fromRow(_row('5-7')).copyWith(name: 'Adele');
      expect(p.bandToConfirm, LegacyAgeBand.b5to7);
      expect(ChildProfile.fromRow(p.toRow()).bandToConfirm, LegacyAgeBand.b5to7);
    });

    test('confermare la fascia non toglie aiuti, voce né dati', () {
      final before = ChildProfile.fromRow(_row('5-7', extra: {'dyslexia_font': 1, 'low_stimulation': 1}));
      final after = before.withConfirmedBand(AgeBand.b3to5);
      expect(after.ageBand, AgeBand.b3to5);
      expect(after.bandToConfirm, isNull);
      expect(after.interaction, before.interaction);
      expect(after.readAlong, isTrue);
      expect(after.dyslexiaFont, isTrue);
      expect(after.lowStimulation, isTrue);
      expect(after.storiesCompleted, before.storiesCompleted);
      final saved = ChildProfile.fromRow(after.toRow());
      expect(saved.bandToConfirm, isNull);
      expect(saved.interaction, before.interaction);
    });
  });

  group('AppState', () {
    Future<(AppState, _FakeDb)> make(ChildProfile p) async {
      final db = _FakeDb(p);
      final state = AppState(
        db: db,
        repo: _Repo(),
        nameVoice: NameVoice(cacheDir: () async => throw const FileSystemException('no')),
      );
      await state.init();
      return (state, db);
    }

    test("la conferma la fa l'adulto e resta salvata", () async {
      final (state, db) = await make(ChildProfile.fromRow(_row('7-10')));
      expect(state.currentProfile!.bandToConfirm, LegacyAgeBand.b7to10);
      await state.confirmBand(state.currentProfile!, AgeBand.b6to7);
      expect(db.profile.ageBand, AgeBand.b6to7);
      expect(db.profile.bandToConfirm, isNull);
      expect(db.profile.interaction, const InteractionProfile(hands: 3, reading: ReadingLevel.words, autonomy: 3));
    });

    test('nessuna promozione: molti successi non cambiano la fascia', () async {
      final (state, db) = await make(const ChildProfile(id: 1, name: 'Ada', ageBand: AgeBand.b6to7, companion: CompanionId.bo));
      final a = Activity(
        id: 'x',
        version: 1,
        title: 'x',
        area: ActivityArea.values.first,
        skill: 's',
        type: ActivityType.count,
        ageBands: {AgeBand.b6to7},
        togetherSuggested: false,
        intro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
        outro: CompanionLines.fromJson({'bo': 'a', 'pilu': 'a', 'tango': 'a'}),
        offscreen: '',
        levels: const [{}, {}, {}],
      );
      const ok = RoundResult(attempts: 1, hints: 0);
      for (var i = 0; i < 5; i++) {
        await state.recordActivity(a, const ActivityProgress(profileId: 1, activityId: 'x', level: 3), List.filled(8, ok));
      }
      expect(db.profile.ageBand, AgeBand.b6to7);
      expect(state.currentProfile!.ageBand, AgeBand.b6to7);
    });
  });
}
