import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../design/palette.dart';
import '../../design/widgets.dart';
import '../activity_player.dart';

/// Caccia al tesoro in casa: una cosa alla volta, il bambino si alza, la cerca
/// e la porta qui. Il tablet non controlla niente: quando torna dice a voce che
/// cosa ha trovato. "Non la trovo" va bene uguale e si passa alla cosa dopo.
/// Alla fine si rimette ogni cosa al suo posto (lo dice l'outro del compagno).
class HuntRound extends RoundWidget {
  const HuntRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<HuntRound> createState() => _HuntRoundState();
}

class _HuntRoundState extends RoundState<HuntRound> {
  List<Map<String, dynamic>> get _items => (widget.level['items'] as List).cast<Map<String, dynamic>>();

  /// True dopo "L'ho trovato": si chiede di dire a voce che cosa.
  bool _found = false;
  bool _started = false;

  @override
  int get roundCount => _items.length;

  /// Prima della prima cosa, la regola per il grande: solo cose a portata di mano.
  void _ask(int i) => widget.ctx.say(_items[i]['say'] as String);

  void _foundIt() {
    setState(() => _found = true);
    widget.ctx.say(context.l10n.huntTellMe);
  }

  void _nextItem({required bool found}) {
    final last = index + 1 >= roundCount;
    setState(() => _found = false);
    complete(choice: found ? 'hunt=found' : 'hunt=skip');
    if (!last) _ask(index);
  }

  @override
  Widget buildRound(BuildContext context, int i) {
    if (!_started) return _buildRules(context);
    final item = _items[i];
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        PromptBar(text: item['label'] as String, onSay: () => _ask(i)),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PicTile(emoji: item['emoji'] as String, size: 190, selected: _found),
                  const SizedBox(height: 16),
                  SpeechBubble(
                    tail: TailSide.top,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    child: Text(
                      _found ? context.l10n.huntTellMe : widget.ctx.withName(item['say'] as String),
                      textAlign: TextAlign.center,
                      style: text.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _found
                ? [
                    ChunkyButton(
                      label: context.l10n.next,
                      icon: Icons.arrow_forward_rounded,
                      iconAfter: true,
                      color: MiraboColors.leaf,
                      onPressed: () => _nextItem(found: true),
                    ),
                  ]
                : [
                    ChunkyButton(
                      label: context.l10n.huntFound,
                      icon: Icons.back_hand_rounded,
                      color: MiraboColors.leaf,
                      onPressed: _foundIt,
                    ),
                    ChunkyButton(
                      label: context.l10n.huntNotFound,
                      color: MiraboColors.sky,
                      onPressed: () => _nextItem(found: false),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  /// La regola per il grande, prima di cominciare.
  Widget _buildRules(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SoftPanel(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBadge(icon: Icons.person_rounded, color: MiraboColors.teal, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: '${context.l10n.forTheAdult}  ',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: MiraboColors.teal),
                            ),
                            TextSpan(text: context.l10n.huntRules),
                          ]),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ChunkyButton(
            label: context.l10n.go,
            icon: Icons.search_rounded,
            color: MiraboColors.leaf,
            onPressed: () {
              setState(() => _started = true);
              _ask(0);
            },
          ),
        ),
      ],
    );
  }
}
