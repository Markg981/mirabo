import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/l10n.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Disegno libero con il dito: colori grandi, tre punte, gomma, timbri.
/// Non ha una fine: si esce con la X quando si vuole. Il foglio si salva a
/// a fine tratto (raggruppando i salvataggi ravvicinati) e si ritrova riaprendo il gioco; "Foglio nuovo" lo svuota
/// (docs/child-paths.md, "Uscita e ripresa").
class DrawingGame extends StatefulWidget {
  const DrawingGame({super.key, required this.ctx});
  final GameContext ctx;

  @override
  State<DrawingGame> createState() => _DrawingGameState();
}

sealed class _Mark {}

class _Stroke extends _Mark {
  _Stroke(this.color, this.width);
  final Color color;
  final double width;
  final List<Offset> points = [];
}

class _Stamp extends _Mark {
  _Stamp(this.emoji, this.at);
  final String emoji;
  final Offset at;
}

class _DrawingGameState extends State<DrawingGame> {
  static const _palette = [
    MiraboColors.rose,
    MiraboColors.apricot,
    MiraboColors.sun,
    MiraboColors.leaf,
    MiraboColors.sky,
    MiraboColors.plum,
    Color(0xFF8D5A3B),
    MiraboColors.ink,
  ];
  // Chiavi dei nomi dei colori (drawColorName), nello stesso ordine di _palette.
  static const _paletteNames = ['rose', 'apricot', 'sun', 'leaf', 'sky', 'plum', 'brown', 'ink'];
  static const _stamps = ['⭐', '❤️', '🌸', '🐞', '☀️', '🐟'];
  static const _widths = [8.0, 18.0, 34.0];

  /// Limiti del foglio, perché lista, JSON salvato e ridisegno non crescano
  /// senza fine: oltre [_maxMarks] segni si scartano i più vecchi, oltre
  /// [_maxPointsPerStroke] punti un tratto smette di allungarsi.
  static const _maxMarks = 300;
  static const _maxPointsPerStroke = 2000;
  static const _saveDelay = Duration(milliseconds: 700);

  final _marks = <_Mark>[];
  // Cresce a ogni modifica del foglio: il painter ridisegna solo se cambia.
  int _version = 0;
  bool _loaded = false;
  Timer? _saveTimer;
  // Misura del foglio all'ultimo layout: i punti si salvano in proporzione.
  Size _size = Size.zero;
  // Tratti già chiusi disegnati una volta sola: durante un tratto si ridisegna
  // solo l'ultimo segno.
  ui.Picture? _closed;
  int _closedCount = 0;
  Color _color = MiraboColors.sky;
  double _width = 18;
  bool _eraser = false;
  String? _stamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.ctx.say(context.l10n.drawingIntro);
      _load();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _closed?.dispose();
    // Uscendo prima che il caricamento finisca il foglio in memoria è vuoto:
    // salvarlo cancellerebbe quello vero.
    _saveNow();
    super.dispose();
  }

  /// Letto al primo frame; null dove il gioco gira senza stato (test, anteprime).
  AppState? _state;

  Future<void> _load() async {
    final state = _state = AppStateScope.maybeRead(context);
    final profile = state?.currentProfile;
    if (state == null || profile == null) {
      // Senza stato non c'è nulla da caricare: si può disegnare subito.
      setState(() => _loaded = true);
      return;
    }
    final raw = await state.savedDrawing(profile);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      if (raw == null) return;
      _marks.addAll(decodeMarks(raw, _size).cast<_Mark>());
      _invalidateCache();
      _version++;
    });
  }

  void _save() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, _saveNow);
  }

  void _saveNow() {
    if (!_loaded) return;
    final state = _state;
    final profile = state?.currentProfile;
    if (state == null || profile == null) return;
    state.saveDrawing(profile, _marks.isEmpty ? null : encodeMarks(_marks, _size));
  }

  void _invalidateCache() {
    _closed?.dispose();
    _closed = null;
    _closedCount = 0;
  }

  /// Aggiunge alla cache i segni non ancora inclusi (tutti tranne quello che
  /// sta per nascere).
  void _extendCache() {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    if (_closed != null) c.drawPicture(_closed!);
    for (final m in _marks.skip(_closedCount)) {
      _paintMark(c, m);
    }
    _closed?.dispose();
    _closed = rec.endRecording();
    _closedCount = _marks.length;
  }

  void _start(Offset p) {
    // Prima del caricamento il foglio salvato verrebbe scartato.
    if (!_loaded) return;
    if (_marks.length >= _maxMarks) {
      _marks.removeAt(0);
      _invalidateCache();
    }
    _extendCache();
    setState(() {
      _version++;
      if (_stamp != null) {
        _marks.add(_Stamp(_stamp!, p));
      } else {
        _marks.add(_Stroke(_eraser ? Colors.white : _color, _eraser ? _width * 1.8 : _width)..points.add(p));
      }
    });
  }

  void _move(Offset p) {
    if (!_loaded) return;
    final last = _marks.lastOrNull;
    if (_stamp == null && last is _Stroke && last.points.length < _maxPointsPerStroke) {
      setState(() {
        _version++;
        last.points.add(p);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colori e punte
          SoftPanel(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < _palette.length; i++)
                    _Swatch(
                      name: context.l10n.drawColorName(_paletteNames[i]),
                      color: tokens.tint(_palette[i]),
                      selected: !_eraser && _stamp == null && _color == _palette[i],
                      onTap: () => setState(() {
                        _color = _palette[i];
                        _eraser = false;
                        _stamp = null;
                      }),
                    ),
                  const Divider(height: 20),
                  for (final w in _widths)
                    _ToolButton(
                      label: switch (_widths.indexOf(w)) {
                        0 => context.l10n.drawingBrushThin,
                        1 => context.l10n.drawingBrushMedium,
                        _ => context.l10n.drawingBrushThick,
                      },
                      selected: _stamp == null && _width == w,
                      onTap: () => setState(() {
                        _width = w;
                        _stamp = null;
                      }),
                      child: Container(
                        width: w.clamp(8, 30),
                        height: w.clamp(8, 30),
                        decoration: BoxDecoration(color: _eraser ? MiraboColors.inkSoft : tokens.tint(_color), shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Il foglio
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [const BoxShadow(color: Color(0xFFC9DAE7), offset: Offset(0, 8)), ...softShadow()],
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                // onPanDown arriva al tocco, anche senza movimento: un tocco lascia un punto o un timbro.
                onPanDown: (d) => _start(d.localPosition),
                onPanUpdate: (d) => _move(d.localPosition),
                onPanEnd: (_) => _save(),
                onPanCancel: _save,
                child: Semantics(
                  label: context.l10n.drawingSheet,
                  child: LayoutBuilder(builder: (context, box) {
                    _size = box.biggest;
                    return CustomPaint(painter: _SheetPainter(_marks, _version, _closed, _closedCount), size: Size.infinite);
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Timbri, gomma, ricomincia
          SoftPanel(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final s in _stamps)
                    _ToolButton(
                      label: s,
                      selected: _stamp == s,
                      onTap: () => setState(() {
                        _stamp = s;
                        _eraser = false;
                      }),
                      child: Text(s, style: const TextStyle(fontSize: 30)),
                    ),
                  const Divider(height: 20),
                  _ToolButton(
                    selected: _eraser && _stamp == null,
                    tooltip: context.l10n.drawingEraser,
                    onTap: () => setState(() {
                      _eraser = true;
                      _stamp = null;
                    }),
                    child: const Icon(Icons.auto_fix_normal_rounded, size: 30, color: MiraboColors.ink),
                  ),
                  _ToolButton(
                    selected: false,
                    tooltip: context.l10n.drawingUndo,
                    onTap: _marks.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _marks.removeLast();
                              _invalidateCache();
                              _version++;
                            });
                            _save();
                          },
                    child: const Icon(Icons.undo_rounded, size: 30, color: MiraboColors.ink),
                  ),
                  _ToolButton(
                    selected: false,
                    tooltip: context.l10n.drawingNewSheet,
                    onTap: _marks.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _marks.clear();
                              _invalidateCache();
                              _version++;
                            });
                            _save();
                          },
                    child: const Icon(Icons.note_add_rounded, size: 30, color: MiraboColors.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il foglio in JSON per i `settings`: tratti (colore, spessore, punti) e timbri.
/// Le coordinate sono in proporzione al foglio [size] (0..1), così non si
/// spostano con un'altra finestra; i fogli vecchi, una lista di pixel, si
/// leggono ancora.
String encodeMarks(List<Object> marks, Size size) {
  double nx(double x) => size.width > 0 ? double.parse((x / size.width).toStringAsFixed(4)) : x;
  double ny(double y) => size.height > 0 ? double.parse((y / size.height).toStringAsFixed(4)) : y;
  return jsonEncode({
    'v': 2,
    'm': [
      for (final m in marks.cast<_Mark>())
        switch (m) {
          _Stroke s => {'c': s.color.toARGB32(), 'w': s.width, 'p': [for (final p in s.points) ...[nx(p.dx), ny(p.dy)]]},
          _Stamp t => {'e': t.emoji, 'x': nx(t.at.dx), 'y': ny(t.at.dy)},
        },
    ],
  });
}

/// Il contrario di [encodeMarks]; un foglio illeggibile riparte vuoto.
List<Object> decodeMarks(String raw, Size size) {
  try {
    final j = jsonDecode(raw);
    // Formato vecchio: lista di segni con pixel assoluti.
    final normalized = j is Map;
    final sx = normalized ? size.width : 1.0, sy = normalized ? size.height : 1.0;
    return [
      for (final m in ((normalized ? j['m'] : j) as List).cast<Map<String, dynamic>>())
        if (m['e'] is String)
          _Stamp(m['e'] as String, Offset((m['x'] as num).toDouble() * sx, (m['y'] as num).toDouble() * sy))
        else
          _strokeFrom(m, sx, sy),
    ];
  } catch (_) {
    return [];
  }
}

_Stroke _strokeFrom(Map<String, dynamic> m, double sx, double sy) {
  final s = _Stroke(Color(m['c'] as int), (m['w'] as num).toDouble());
  final p = (m['p'] as List).cast<num>();
  for (var i = 0; i + 1 < p.length; i += 2) {
    s.points.add(Offset(p[i].toDouble() * sx, p[i + 1].toDouble() * sy));
  }
  return s;
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color, required this.selected, required this.onTap});
  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = MiraboTokens.of(context).minTarget;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Semantics(
          button: true,
          selected: selected,
          label: name,
          onTap: onTap,
          child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // L'area che risponde al tocco è almeno quella minima dei bambini,
          // anche se il cerchio disegnato è più piccolo.
          child: SizedBox(
            width: m,
            height: m,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: selected ? 58 : 50,
                height: selected ? 58 : 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: selected ? 5 : 3),
                  boxShadow: [BoxShadow(color: MiraboColors.deep(color, 0.15), offset: const Offset(0, 4))],
                ),
              ),
            ),
          ),
          ),
        ),
      );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.selected, required this.onTap, required this.child, this.tooltip, this.label});
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final String? tooltip;
  /// Nome letto dai lettori di schermo quando non c'è un tooltip.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final m = MiraboTokens.of(context).minTarget;
    final btn = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? MiraboColors.pale(MiraboColors.sky, 0.75) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.35 : 1,
            child: SizedBox(width: m > 58 ? m : 58, height: m > 54 ? m : 54, child: Center(child: child)),
          ),
        ),
      ),
    );
    final named = Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: tooltip ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: btn,
    );
    return tooltip == null ? named : Tooltip(message: tooltip, child: named);
  }
}

void _paintMark(Canvas canvas, _Mark m) {
  switch (m) {
    case _Stroke s:
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
      } else {
        final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
        for (final p in s.points.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, paint);
      }
    case _Stamp st:
      final tp = TextPainter(text: TextSpan(text: st.emoji, style: const TextStyle(fontSize: 64)), textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, st.at - Offset(tp.width / 2, tp.height / 2));
  }
}

class _SheetPainter extends CustomPainter {
  _SheetPainter(this.marks, this.version, this.closed, this.closedCount);
  final List<_Mark> marks;
  final int version;
  final ui.Picture? closed;
  final int closedCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (closed != null) canvas.drawPicture(closed!);
    for (final m in marks.skip(closed == null ? 0 : closedCount)) {
      _paintMark(canvas, m);
    }
  }

  // I tratti si allungano sul posto (stessa lista): conta la versione.
  @override
  bool shouldRepaint(_SheetPainter old) => old.version != version || !identical(old.marks, marks);
}
