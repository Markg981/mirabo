import 'package:flutter/material.dart';

import '../activity_player.dart';

/// Abbinamenti: due colonne mescolate. Si tocca a sinistra, poi a destra; se la
/// coppia è giusta resta unita, altrimenti conta un tentativo. Il controllo
/// dell'errore è nel materiale: una coppia sbagliata non "si chiude".
class PairsRound extends RoundWidget {
  const PairsRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<PairsRound> createState() => _PairsRoundState();
}

class _PairsRoundState extends RoundState<PairsRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  List<int> _left = [];
  List<int> _right = [];
  final Set<int> _matched = {};
  int? _selectedLeft;
  int _preparedFor = -1;

  @override
  int get roundCount => _rounds.length;

  List<List<String>> _pairs(int i) => (_rounds[i]['pairs'] as List).map((p) => (p as List).cast<String>()).toList();

  void _prepare(int i) {
    final n = _pairs(i).length;
    _left = List.generate(n, (k) => k)..shuffle();
    _right = List.generate(n, (k) => k)..shuffle();
    _matched.clear();
    _selectedLeft = null;
    _preparedFor = i;
  }

  @override
  void next() {
    _matched.clear();
    _selectedLeft = null;
    super.next();
  }

  String _say(int round, String item) {
    final labels = _rounds[round]['labels'] as Map<String, dynamic>?;
    return labels?[item] as String? ?? item;
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    if (_preparedFor != index) {
      _prepare(index);
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say(_rounds[index]['prompt'] as String));
    }
    final pairs = _pairs(index);
    final wordPairs = _rounds[index]['wordPairs'] == true;
    final tileSize = pairs.length > 4 ? 96.0 : 120.0;

    Widget tile(int pairIndex, int side) {
      final value = pairs[pairIndex][side];
      final matched = _matched.contains(pairIndex);
      final selected = side == 0 && _selectedLeft == pairIndex;
      final isWord = side == 1 && wordPairs;
      return PicTile(
        emoji: isWord ? '' : value,
        label: isWord ? value : null,
        size: tileSize,
        selected: selected || matched,
        dimmed: matched,
        highlight: showHint && _selectedLeft != null && side == 1 && pairIndex == _selectedLeft,
        onTap: matched || lastCorrect == true
            ? null
            : () {
                if (side == 0) {
                  setState(() => _selectedLeft = pairIndex);
                  widget.ctx.say(_say(index, value));
                  return;
                }
                final left = _selectedLeft;
                if (left == null) {
                  widget.ctx.say('Prima tocca una tessera a sinistra.');
                  return;
                }
                if (left == pairIndex) {
                  setState(() {
                    _matched.add(pairIndex);
                    _selectedLeft = null;
                  });
                  widget.ctx.say(_say(index, value));
                  if (_matched.length == pairs.length) answer(true);
                } else {
                  answer(false);
                }
              },
      );
    }

    return Column(
      children: [
        PromptBar(text: _rounds[index]['prompt'] as String, onSay: () => widget.ctx.say(_rounds[index]['prompt'] as String)),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [for (final i in _left) tile(i, 0)]),
                ),
              ),
              Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 24), color: Theme.of(context).colorScheme.outlineVariant),
              Expanded(
                child: Center(
                  child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [for (final i in _right) tile(i, 1)]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
