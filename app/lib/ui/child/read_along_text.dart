import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/read_along.dart';
import '../design/palette.dart';

/// Testo della lettura karaoke: la parola [current] ha lo sfondo giallo, e
/// toccando una parola la si riascolta ([onWord]). Con [enabled] falso è un
/// testo normale.
///
/// L'evidenziazione cambia solo i colori, mai lo spessore: le righe non si
/// muovono mentre la voce legge.
class ReadAlongText extends StatefulWidget {
  const ReadAlongText({
    super.key,
    required this.text,
    required this.current,
    required this.onWord,
    this.style,
    this.enabled = true,
  });

  final String text;

  /// Indice della parola che si sta leggendo, -1 per nessuna.
  final int current;
  final ValueChanged<String> onWord;
  final TextStyle? style;
  final bool enabled;

  @override
  State<ReadAlongText> createState() => _ReadAlongTextState();
}

class _ReadAlongTextState extends State<ReadAlongText> {
  late List<WordSpan> _words;
  final List<TapGestureRecognizer> _taps = [];

  @override
  void initState() {
    super.initState();
    _split();
  }

  @override
  void didUpdateWidget(ReadAlongText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _split();
  }

  void _split() {
    for (final t in _taps) {
      t.dispose();
    }
    _taps.clear();
    _words = readAlongWords(widget.text);
    for (final w in _words) {
      final word = widget.text.substring(w.start, w.end);
      _taps.add(TapGestureRecognizer()..onTap = () => widget.onWord(word));
    }
  }

  @override
  void dispose() {
    for (final t in _taps) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return Text(widget.text, style: widget.style);
    final glow = MiraboColors.pale(MiraboTokens.of(context).tint(MiraboColors.sun), 0.35);
    final spans = <TextSpan>[];
    var at = 0;
    for (var i = 0; i < _words.length; i++) {
      final w = _words[i];
      if (w.start > at) spans.add(TextSpan(text: widget.text.substring(at, w.start)));
      spans.add(TextSpan(
        text: widget.text.substring(w.start, w.end),
        recognizer: _taps[i],
        style: i == widget.current ? TextStyle(backgroundColor: glow, color: MiraboColors.ink) : null,
      ));
      at = w.end;
    }
    if (at < widget.text.length) spans.add(TextSpan(text: widget.text.substring(at)));
    return Semantics(
      hint: context.l10n.readWord,
      child: Text.rich(TextSpan(style: widget.style, children: spans)),
    );
  }
}
