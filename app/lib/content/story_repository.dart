import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/activity.dart';
import '../models/story.dart';
import 'package_verifier.dart';

/// Descrizione di un compagno, da companions.json.
class Companion {
  const Companion({required this.id, required this.name, required this.kind, required this.tagline, required this.growth});
  final CompanionId id;
  final String name;
  final String kind;
  final String tagline;
  final List<String> growth;

  factory Companion.fromJson(Map<String, dynamic> j) => Companion(
        id: CompanionId.values.byName(j['id'] as String),
        name: j['name'] as String,
        kind: j['kind'] as String,
        tagline: j['tagline'] as String,
        growth: (j['growth'] as List).map((g) => (g as Map<String, dynamic>)['label'] as String).toList(),
      );
}

/// Carica le storie dai pacchetti firmati inclusi negli asset (MVP) e, in
/// futuro, da quelli scaricati nella cartella dell'app.
class StoryRepository {
  StoryRepository({PackageVerifier? verifier}) : _verifier = verifier ?? PackageVerifier();

  final PackageVerifier _verifier;
  final Map<String, Story> _stories = {};
  final Map<String, Activity> _activities = {};
  final List<String> rejected = [];
  List<Companion> companions = const [];

  List<Story> get stories => _stories.values.toList()
    ..sort((a, b) => (a.world.index.compareTo(b.world.index)) != 0
        ? a.world.index.compareTo(b.world.index)
        : (a.episode ?? 999).compareTo(b.episode ?? 999));

  Story? byId(String id) => _stories[id];

  List<Activity> get activities => _activities.values.toList()
    ..sort((a, b) => a.area.index != b.area.index ? a.area.index.compareTo(b.area.index) : a.title.compareTo(b.title));

  Activity? activityById(String id) => _activities[id];

  Future<void> load() async {
    final companionsJson = jsonDecode(await rootBundle.loadString('assets/companions/companions.json')) as Map<String, dynamic>;
    companions = (companionsJson['companions'] as List).map((c) => Companion.fromJson(c as Map<String, dynamic>)).toList();

    final index = (jsonDecode(await rootBundle.loadString('assets/stories/index.json')) as List).cast<String>();
    for (final file in index) {
      try {
        final data = await rootBundle.load('assets/stories/$file');
        final pkg = await _verifier.open(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        if (pkg.kind == 'activity') {
          _activities[pkg.id] = Activity.fromJson(pkg.json('activity.json')!);
        } else {
          _stories[pkg.id] = _storyFromPackage(pkg);
        }
      } on PackageVerificationException catch (e) {
        rejected.add('$file: ${e.message}');
      }
    }
  }

  Story _storyFromPackage(VerifiedPackage pkg) {
    final meta = Story.fromJson(pkg.json('story.json')!);
    final variants = <AgeBand, StoryVariant>{};
    for (final entry in meta.variantFiles.entries) {
      final v = pkg.json(entry.value);
      if (v != null) variants[entry.key] = StoryVariant.fromJson(v);
    }
    return meta.withContent(variants: variants, parentCard: pkg.text(meta.parentCardFile));
  }
}
