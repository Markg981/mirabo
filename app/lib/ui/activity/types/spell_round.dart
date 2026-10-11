import 'package:flutter/material.dart';

import '../activity_player.dart';

/// Alfabeto mobile: la figura, la parola da comporre (o la frase per i grandi) e
/// le lettere mescolate; si toccano nell'ordine giusto. Vocali blu, consonanti
/// rosse come nel materiale Montessori. Una lettera sbagliata non entra nella
/// parola: il controllo dell'errore è nel posto che resta vuoto.
class SpellRound extends RoundWidget {
  const SpellRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<SpellRound> createState() => _SpellRoundState();
}

class _SpellRoundState extends RoundState<SpellRound> {
  static const _vowels = 'AEIOU';

  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  String _target = '';
  List<String> _pool = [];
  final List<int> _used = [];
  int _pos = 0;
  int _preparedFor = -1;

  @override
  int get roundCount => _rounds.length;

  String _targetOf(int i) => (_rounds[i]['word'] ?? _rounds[i]['sentence']) as String;

  void _prepare(int i) {
    _target = _targetOf(i);
    final letters = _target.replaceAll(' ', '').split('') + ((_rounds[i]['extra'] as String?) ?? '').split('');
    _pool = letters.where((l) => l.isNotEmpty).toList()..shuffle();
    _used.clear();
    _pos = 0;
    _preparedFor = i;
  }

  @override
  void next() {
    _used.clear();
    super.next();
  }

  /// Prossima lettera attesa (saltando gli spazi).
  String? get _expected {
    while (_pos < _target.length && _target[_pos] == ' ') {
      _pos++;
    }
    return _pos < _target.length ? _target[_pos] : null;
  }

  void _tap(int poolIndex) {
    final letter = _pool[poolIndex];
    if (letter == _expected) {
      setState(() {
        _used.add(poolIndex);
        _pos++;
      });
      widget.ctx.say(letter.toLowerCase());
      if (_expected == null) {
        widget.ctx.say(_target.toLowerCase());
        answer(true);
      }
    } else {
      answer(false);
    }
  }

  Color _letterColor(BuildContext context, String l) =>
      _vowels.contains(l) ? const Color(0xFF1E6FD9) : const Color(0xFFD93A2B);

  @override
  Widget buildRound(BuildContext context, int index) {
    if (_preparedFor != index) {
      _prepare(index);
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say('Componi: ${_target.toLowerCase()}'));
    }
    final emoji = _rounds[index]['emoji'] as String? ?? '';
    final expected = _expected;
    final isSentence = _rounds[index].containsKey('sentence');
    final slotSize = _target.length > 12 ? 40.0 : 56.0;

    return Column(
      children: [
        PromptBar(
          text: isSentence ? 'Componi la frase' : 'Componi la parola',
          onSay: () => widget.ctx.say(_target.toLowerCase()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < _target.length; i++)
                      if (_target[i] == ' ')
                        SizedBox(width: slotSize * 0.6)
                      else
                        Container(
                          width: slotSize,
                          height: slotSize * 1.2,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: i == _pos ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                              width: i == _pos ? 3 : 1.5,
                            ),
                          ),
                          child: i < _pos
                              ? Text(_target[i], style: TextStyle(fontSize: slotSize * 0.7, fontWeight: FontWeight.w700, color: _letterColor(context, _target[i])))
                              : null,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _pool.length; i++)
                  if (!_used.contains(i))
                    Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      elevation: showHint && _pool[i] == expected ? 6 : 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: lastCorrect == true ? null : () => _tap(i),
                        child: Container(
                          width: 72,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 3,
                              color: showHint && _pool[i] == expected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            ),
                          ),
                          child: Text(_pool[i], style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: _letterColor(context, _pool[i]))),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
