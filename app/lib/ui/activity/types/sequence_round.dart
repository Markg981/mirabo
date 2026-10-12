import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../activity_player.dart';

/// "Rimetti in ordine": le carte compaiono mescolate; il bambino le tocca
/// nell'ordine giusto e vanno a riempire la fila. Un tocco fuori ordine conta
/// un tentativo; dopo due errori la carta giusta viene evidenziata.
/// Con `turns: true` il round alterna "tocca a te / tocca al grande".
class SequenceRound extends RoundWidget {
  const SequenceRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<SequenceRound> createState() => _SequenceRoundState();
}

class _SequenceRoundState extends RoundState<SequenceRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  List<int> _shuffled = [];
  final List<int> _placed = [];
  int _preparedFor = -1;

  @override
  int get roundCount => _rounds.length;

  void _prepare(int index) {
    final n = ((_rounds[index]['cards'] as List)).length;
    _shuffled = List.generate(n, (i) => i)..shuffle();
    // Non lasciare la soluzione già in ordine.
    if (n > 1 && List.generate(n, (i) => i).toString() == _shuffled.toString()) {
      _shuffled = _shuffled.reversed.toList();
    }
    _placed.clear();
    _preparedFor = index;
  }

  @override
  void next() {
    _placed.clear();
    super.next();
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    if (_preparedFor != index) {
      _prepare(index);
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say(_rounds[index]['prompt'] as String));
    }
    final r = _rounds[index];
    final cards = (r['cards'] as List).cast<Map<String, dynamic>>();
    final turns = r['turns'] == true;
    final sizes = r['sizes'] == true;
    double sizeOf(int i) => sizes ? 40 + 100 * ((cards[i]['size'] as num).toDouble()) : 110;
    final expected = _placed.length;
    final whoseTurn = turns ? (expected.isEven ? context.l10n.turnYou(widget.ctx.profile.name) : context.l10n.turnAdult) : null;

    return Column(
      children: [
        PromptBar(text: r['prompt'] as String, onSay: () => widget.ctx.say(r['prompt'] as String)),
        if (whoseTurn != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(avatar: Icon(expected.isEven ? Icons.child_care_rounded : Icons.person_rounded), label: Text(whoseTurn)),
          ),
        // Fila da riempire
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                i < _placed.length
                    ? PicTile(emoji: cards[i]['emoji'] as String, label: cards[i]['label'] as String?, size: sizeOf(i), selected: true)
                    : Container(
                        width: sizes ? 48 : 110,
                        height: sizes ? 48 : 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: Theme.of(context).textTheme.titleLarge),
                      ),
                if (i < cards.length - 1) const Icon(Icons.arrow_forward_rounded),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Carte mescolate
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final i in _shuffled)
                  if (!_placed.contains(i))
                    PicTile(
                      emoji: cards[i]['emoji'] as String,
                      label: cards[i]['label'] as String?,
                      size: sizes ? sizeOf(i) : 140,
                      highlight: showHint && i == expected,
                      dimmed: showHint && i != expected,
                      onTap: lastCorrect == true
                          ? null
                          : () {
                              if (i == expected) {
                                setState(() => _placed.add(i));
                                widget.ctx.say(cards[i]['label'] as String? ?? '');
                                if (_placed.length == cards.length) answer(true);
                              } else {
                                answer(false);
                              }
                            },
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
