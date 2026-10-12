import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Gioco del 15 in versione 3×3: tessere da 1 a 8 da rimettere in ordine.
/// Il mescolamento parte dalla soluzione con mosse valide, quindi è sempre risolvibile.
class SlidePuzzleGame extends StatefulWidget {
  const SlidePuzzleGame({super.key, required this.ctx});
  final GameContext ctx;

  @override
  State<SlidePuzzleGame> createState() => _SlidePuzzleGameState();
}

class _SlidePuzzleGameState extends State<SlidePuzzleGame> {
  static const _n = 3;
  // _cells[pos] = tessera in quella posizione (0 = vuoto).
  late List<int> _cells;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _cells = [for (var i = 1; i < _n * _n; i++) i, 0];
    final rnd = math.Random();
    var prev = -1;
    for (var k = 0; k < 120; k++) {
      final empty = _cells.indexOf(0);
      final moves = _neighbours(empty).where((p) => p != prev).toList();
      final pick = moves[rnd.nextInt(moves.length)];
      _swap(pick, empty);
      prev = empty;
    }
    if (_isSolved) _swap(_neighbours(_cells.indexOf(0)).first, _cells.indexOf(0));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.ctx.say(context.l10n.puzzleIntro),
    );
  }

  List<int> _neighbours(int p) {
    final r = p ~/ _n, c = p % _n;
    return [
      if (r > 0) p - _n,
      if (r < _n - 1) p + _n,
      if (c > 0) p - 1,
      if (c < _n - 1) p + 1,
    ];
  }

  void _swap(int a, int b) {
    final t = _cells[a];
    _cells[a] = _cells[b];
    _cells[b] = t;
  }

  bool get _isSolved {
    for (var i = 0; i < _cells.length - 1; i++) {
      if (_cells[i] != i + 1) return false;
    }
    return true;
  }

  void _tap(int tile) {
    if (_solved) return;
    final pos = _cells.indexOf(tile);
    final empty = _cells.indexOf(0);
    if (!_neighbours(empty).contains(pos)) return;
    setState(() => _swap(pos, empty));
    if (_isSolved) {
      _solved = true;
      Future.delayed(const Duration(milliseconds: 600), widget.ctx.onFinished);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    return LayoutBuilder(builder: (context, c) {
      final board = math.min(c.maxWidth - 60, c.maxHeight - 60).clamp(240.0, 560.0);
      const pad = 14.0;
      final cell = (board - pad * 2) / _n;
      return Center(
        child: Container(
          width: board,
          height: board,
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: tokens.tint(MiraboColors.navy),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: MiraboColors.deep(tokens.tint(MiraboColors.navy), 0.08), offset: const Offset(0, 8))],
          ),
          child: Stack(
            children: [
              for (var tile = 1; tile < _n * _n; tile++)
                AnimatedPositioned(
                  key: ValueKey(tile),
                  duration: Duration(milliseconds: widget.ctx.calm ? 0 : 160),
                  curve: Curves.easeOut,
                  left: (_cells.indexOf(tile) % _n) * cell,
                  top: (_cells.indexOf(tile) ~/ _n) * cell,
                  width: cell,
                  height: cell,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: BlockTile(
                      onTap: () => _tap(tile),
                      depth: 6,
                      radius: 20,
                      color: _cells.indexOf(tile) == tile - 1 ? tokens.tint(MiraboColors.leaf) : tokens.tint(MiraboColors.sun),
                      semanticLabel: context.l10n.puzzleTileA11y('$tile'),
                      child: Center(
                        child: Text(
                          '$tile',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w700,
                            fontSize: cell * 0.42,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
