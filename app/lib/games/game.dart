import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import 'balloon_game.dart';
import 'drawing_game.dart';
import 'memory_game.dart';
import 'shapes_game.dart';
import 'slide_puzzle_game.dart';
import 'xylophone_game.dart';

/// Quello che un gioco riceve dal guscio: la fascia d'età (decide la
/// difficoltà), la voce del compagno, il segnale di fine partita.
class GameContext {
  const GameContext({required this.band, required this.say, required this.onFinished, required this.calm});

  final AgeBand band;
  final Future<void> Function(String text) say;

  /// I giochi con una fine (memory, palloncini…) la chiamano una volta.
  /// Quelli liberi (disegno, xilofono libero) non la chiamano mai.
  final VoidCallback onFinished;

  /// Bassa stimolazione: niente scoppi, movimenti più lenti.
  final bool calm;
}

/// Un gioco del catalogo. Niente punti né classifiche: si gioca, finisce,
/// il compagno saluta. Il bambino sceglie se rifarlo.
@immutable
class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.emojis,
    required this.color,
    required this.bands,
    required this.describe,
    required this.build,
  });

  final String id;
  final String Function(AppLocalizations l) title;
  final List<String> emojis;
  final Color color;
  final Set<AgeBand> bands;

  /// Una riga per l'adulto: cosa fa il bambino in quella fascia.
  final String Function(AppLocalizations l, AgeBand band) describe;
  final Widget Function(GameContext ctx) build;
}

const _all = {AgeBand.b3to5, AgeBand.b5to7, AgeBand.b7to10};

final List<GameInfo> gameCatalog = [
  GameInfo(
    id: 'memory',
    title: (l) => l.gameMemoryTitle,
    emojis: const ['🐶', '🐱', '🐰'],
    color: MiraboColors.plum,
    bands: _all,
    describe: (l, b) => l.gameMemoryDesc(MemoryGame.pairsFor(b)),
    build: (ctx) => MemoryGame(ctx: ctx),
  ),
  GameInfo(
    id: 'balloons',
    title: (l) => l.gameBalloonsTitle,
    emojis: const ['🎈', '🎈', '✨'],
    color: MiraboColors.rose,
    bands: _all,
    describe: (l, b) => switch (b) {
      AgeBand.b3to5 => l.gameBalloonsDescSmall,
      AgeBand.b5to7 => l.gameBalloonsDescMid,
      AgeBand.b7to10 => l.gameBalloonsDescBig,
    },
    build: (ctx) => BalloonGame(ctx: ctx),
  ),
  GameInfo(
    id: 'shapes',
    title: (l) => l.gameShapesTitle,
    emojis: const ['🔺', '🟦', '⭐'],
    color: MiraboColors.sky,
    bands: _all,
    describe: (l, b) => switch (b) {
      AgeBand.b3to5 => l.gameShapesDescSmall,
      AgeBand.b5to7 => l.gameShapesDescMid,
      AgeBand.b7to10 => l.gameShapesDescBig,
    },
    build: (ctx) => ShapesGame(ctx: ctx),
  ),
  GameInfo(
    id: 'drawing',
    title: (l) => l.gameDrawingTitle,
    emojis: const ['🎨', '🖍️', '🌈'],
    color: MiraboColors.leaf,
    bands: _all,
    describe: (l, _) => l.gameDrawingDesc,
    build: (ctx) => DrawingGame(ctx: ctx),
  ),
  GameInfo(
    id: 'xylophone',
    title: (l) => l.gameXyloTitle,
    emojis: const ['🎵', '🎶', '🎼'],
    color: MiraboColors.sun,
    bands: _all,
    describe: (l, b) => b == AgeBand.b3to5 ? l.gameXyloDescSmall : l.gameXyloDescBig(l.xyloSong),
    build: (ctx) => XylophoneGame(ctx: ctx),
  ),
  GameInfo(
    id: 'puzzle15',
    title: (l) => l.gamePuzzleTitle,
    emojis: const ['🔢', '🧩', '➡️'],
    color: MiraboColors.teal,
    bands: const {AgeBand.b7to10},
    describe: (l, _) => l.gamePuzzleDesc,
    build: (ctx) => SlidePuzzleGame(ctx: ctx),
  ),
];

List<GameInfo> gamesFor(AgeBand band) => gameCatalog.where((g) => g.bands.contains(band)).toList();
