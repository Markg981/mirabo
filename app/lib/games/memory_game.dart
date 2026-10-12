import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Memory con gli animali. Le carte si girano a due a due; le coppie trovate
/// restano scoperte. Il numero di coppie cresce con la fascia d'età.
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key, required this.ctx});
  final GameContext ctx;

  static int pairsFor(AgeBand b) => switch (b) {
        AgeBand.b3to5 => 3,
        AgeBand.b5to7 => 6,
        AgeBand.b7to10 => 8,
      };

  /// Emoji e chiave del nome (tradotto in animalName).
  static const _animals = {
    '🐶': 'dog',
    '🐱': 'cat',
    '🐰': 'rabbit',
    '🦊': 'fox',
    '🐻': 'bear',
    '🐼': 'panda',
    '🐸': 'frog',
    '🐵': 'monkey',
    '🦁': 'lion',
    '🐯': 'tiger',
    '🐮': 'cow',
    '🐷': 'pig',
  };

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late final List<String> _cards;
  final Set<int> _open = {};
  final Set<int> _matched = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    final pairs = MemoryGame.pairsFor(widget.ctx.band);
    final pool = MemoryGame._animals.keys.toList()..shuffle(rnd);
    _cards = [...pool.take(pairs), ...pool.take(pairs)]..shuffle(rnd);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say(context.l10n.memoryIntro));
  }

  Future<void> _tap(int i) async {
    if (_busy || _open.contains(i) || _matched.contains(i)) return;
    setState(() => _open.add(i));
    widget.ctx.say(context.l10n.animalName(MemoryGame._animals[_cards[i]]!));
    if (_open.length < 2) return;

    final [a, b] = _open.toList();
    if (_cards[a] == _cards[b]) {
      setState(() {
        _matched.addAll([a, b]);
        _open.clear();
      });
      if (_matched.length == _cards.length) {
        await Future.delayed(const Duration(milliseconds: 700));
        widget.ctx.onFinished();
      }
    } else {
      _busy = true;
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() {
        _open.clear();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _cards.length;
    final cols = n <= 6 ? 3 : 4;
    final rows = (n / cols).ceil();
    return LayoutBuilder(builder: (context, c) {
      const gap = 18.0;
      final side = math.min(
        (c.maxWidth - 80 - gap * (cols - 1)) / cols,
        (c.maxHeight - 40 - gap * (rows - 1) - 8 * rows) / rows,
      ).clamp(60.0, 200.0);
      return Center(
        child: Wrap(
          spacing: gap,
          runSpacing: gap - 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < n; i++)
              SizedBox(
                width: side,
                child: _Card(
                  emoji: _cards[i],
                  faceUp: _open.contains(i) || _matched.contains(i),
                  matched: _matched.contains(i),
                  size: side,
                  calm: widget.ctx.calm,
                  onTap: () => _tap(i),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.emoji,
    required this.faceUp,
    required this.matched,
    required this.size,
    required this.calm,
    required this.onTap,
  });
  final String emoji;
  final bool faceUp;
  final bool matched;
  final double size;
  final bool calm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final back = tokens.tint(MiraboColors.plum);
    // Mezzo giro sull'asse verticale: a metà cambia faccia.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: faceUp ? 1 : 0),
      duration: Duration(milliseconds: calm ? 0 : 320),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final showFront = t >= 0.5;
        final angle = (showFront ? 1 - t : t) * math.pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: BlockTile(
            onTap: faceUp ? null : onTap,
            width: size,
            height: size,
            radius: size * 0.16,
            color: showFront ? (matched ? MiraboColors.pale(tokens.tint(MiraboColors.leaf), 0.75) : MiraboColors.paper) : back,
            semanticLabel: showFront ? emoji : context.l10n.memoryCovered,
            child: Center(
              child: showFront
                  ? Text(emoji, style: TextStyle(fontSize: size * 0.55))
                  : Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.85), size: size * 0.42),
            ),
          ),
        );
      },
    );
  }
}
