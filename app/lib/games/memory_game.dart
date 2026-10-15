import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Come si accoppiano le carte: con la fascia cambia la regola, non solo il numero.
enum MemoryRule {
  /// 3-5: due animali uguali. Si guarda e si ricorda.
  same,

  /// 6-7: un animale e il suo cibo. Le due carte non si somigliano: si cerca una relazione.
  food,

  /// 8-10: animale, cibo e casa, tre carte per volta. Bisogna tenere a mente più
  /// gruppi aperti insieme e decidere quale completare.
  foodAndHome,
}

/// Una carta: l'emoji, il gruppo a cui appartiene e la chiave del nome detto
/// dalla voce (animalName per le coppie uguali, memoryItemName per le relazioni).
@immutable
class MemoryCard {
  const MemoryCard(this.emoji, this.group, this.nameKey);
  final String emoji;
  final String group;
  final String nameKey;
}

/// Memory con gli animali. Le carte si girano a gruppi (due o tre); i gruppi
/// trovati restano scoperti. Di fascia in fascia cambia il problema:
/// uguaglianza, relazione animale-cibo, terne animale-cibo-casa.
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key, required this.ctx});
  final GameContext ctx;

  static MemoryRule ruleFor(AgeBand b) => switch (b) {
        AgeBand.b3to5 => MemoryRule.same,
        AgeBand.b6to7 => MemoryRule.food,
        AgeBand.b8to10 => MemoryRule.foodAndHome,
      };

  /// Quanti gruppi ci sono sul tavolo.
  static int groupsFor(AgeBand b) => switch (b) {
        AgeBand.b3to5 => 3,
        AgeBand.b6to7 => 6,
        AgeBand.b8to10 => 5,
      };

  /// Quante carte formano un gruppo.
  static int groupSize(MemoryRule r) => r == MemoryRule.foodAndHome ? 3 : 2;

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

  /// Animale, cibo, casa (nomi in memoryItemName). Ogni cibo e ogni casa sta in
  /// un solo gruppo, così c'è sempre una sola risposta.
  static const relations = [
    [MemoryCard('🐿️', 'squirrel', 'squirrel'), MemoryCard('🌰', 'squirrel', 'chestnut'), MemoryCard('🌳', 'squirrel', 'tree')],
    [MemoryCard('🐧', 'penguin', 'penguin'), MemoryCard('🐟', 'penguin', 'fish'), MemoryCard('🧊', 'penguin', 'ice')],
    [MemoryCard('🐵', 'monkey', 'monkey'), MemoryCard('🍌', 'monkey', 'banana'), MemoryCard('🌴', 'monkey', 'palm')],
    [MemoryCard('🐰', 'rabbit', 'rabbit'), MemoryCard('🥕', 'rabbit', 'carrot'), MemoryCard('🕳️', 'rabbit', 'burrow')],
    [MemoryCard('🐻', 'bear', 'bear'), MemoryCard('🍯', 'bear', 'honey'), MemoryCard('🌲', 'bear', 'forest')],
    [MemoryCard('🐼', 'panda', 'panda'), MemoryCard('🎋', 'panda', 'bamboo'), MemoryCard('⛰️', 'panda', 'mountain')],
  ];

  /// Le carte di una partita, già mescolate.
  static List<MemoryCard> deal(AgeBand band, math.Random rnd) {
    final rule = ruleFor(band);
    final groups = groupsFor(band);
    final cards = switch (rule) {
      MemoryRule.same => [
          for (final e in (_animals.entries.toList()..shuffle(rnd)).take(groups)) ...[
            MemoryCard(e.key, e.value, e.value),
            MemoryCard(e.key, e.value, e.value),
          ],
        ],
      MemoryRule.food || MemoryRule.foodAndHome => [
          for (final g in (relations.toList()..shuffle(rnd)).take(groups)) ...g.take(groupSize(rule)),
        ],
    };
    return cards..shuffle(rnd);
  }

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late final MemoryRule _rule = MemoryGame.ruleFor(widget.ctx.band);
  late final List<MemoryCard> _cards;
  final List<int> _open = [];
  final Set<int> _matched = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _cards = MemoryGame.deal(widget.ctx.band, math.Random());
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say(switch (_rule) {
          MemoryRule.same => context.l10n.memoryIntro,
          MemoryRule.food => context.l10n.memoryIntroFood,
          MemoryRule.foodAndHome => context.l10n.memoryIntroHome,
        }));
  }

  String _name(MemoryCard c) =>
      _rule == MemoryRule.same ? context.l10n.animalName(c.nameKey) : context.l10n.memoryItemName(c.nameKey);

  Future<void> _tap(int i) async {
    if (_busy || _open.contains(i) || _matched.contains(i)) return;
    setState(() => _open.add(i));
    widget.ctx.say(_name(_cards[i]));
    // Nelle terne ci si ferma appena una carta non va con le altre.
    final sameGroup = _open.every((j) => _cards[j].group == _cards[_open.first].group);
    if (sameGroup && _open.length < MemoryGame.groupSize(_rule)) return;

    if (sameGroup) {
      setState(() {
        _matched.addAll(_open);
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
    final cols = n <= 6 ? 3 : (n <= 12 ? 4 : 5);
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
                  emoji: _cards[i].emoji,
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
