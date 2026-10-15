import 'dart:convert';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/l10n.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Disegno libero con il dito: colori grandi, tre punte, gomma, timbri.
/// Non ha una fine: si esce con la X quando si vuole. Il foglio si salva a
/// ogni tratto e si ritrova riaprendo il gioco; "Foglio nuovo" lo svuota
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
  static const _stamps = ['⭐', '❤️', '🌸', '🐞', '☀️', '🐟'];
  static const _widths = [8.0, 18.0, 34.0];

  final _marks = <_Mark>[];
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
    _save();
    super.dispose();
  }

  /// Letto al primo frame; null dove il gioco gira senza stato (test, anteprime).
  AppState? _state;

  Future<void> _load() async {
    final state = _state = AppStateScope.maybeRead(context);
    final profile = state?.currentProfile;
    if (state == null || profile == null) return;
    final raw = await state.savedDrawing(profile);
    if (!mounted || raw == null || _marks.isNotEmpty) return;
    setState(() => _marks.addAll(decodeMarks(raw).cast<_Mark>()));
  }

  void _save() {
    final state = _state;
    final profile = state?.currentProfile;
    if (state == null || profile == null) return;
    state.saveDrawing(profile, _marks.isEmpty ? null : encodeMarks(_marks));
  }

  void _start(Offset p) {
    setState(() {
      if (_stamp != null) {
        _marks.add(_Stamp(_stamp!, p));
      } else {
        _marks.add(_Stroke(_eraser ? Colors.white : _color, _eraser ? _width * 1.8 : _width)..points.add(p));
      }
    });
  }

  void _move(Offset p) {
    final last = _marks.lastOrNull;
    if (_stamp == null && last is _Stroke) setState(() => last.points.add(p));
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
                  for (final c in _palette)
                    _Swatch(
                      color: tokens.tint(c),
                      selected: !_eraser && _stamp == null && _color == c,
                      onTap: () => setState(() {
                        _color = c;
                        _eraser = false;
                        _stamp = null;
                      }),
                    ),
                  const Divider(height: 20),
                  for (final w in _widths)
                    _ToolButton(
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
                  child: CustomPaint(painter: _SheetPainter(_marks), size: Size.infinite),
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
                            setState(_marks.removeLast);
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
                            setState(_marks.clear);
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
String encodeMarks(List<Object> marks) => jsonEncode([
      for (final m in marks.cast<_Mark>())
        switch (m) {
          _Stroke s => {'c': s.color.toARGB32(), 'w': s.width, 'p': [for (final p in s.points) ...[p.dx.roundToDouble(), p.dy.roundToDouble()]]},
          _Stamp t => {'e': t.emoji, 'x': t.at.dx.roundToDouble(), 'y': t.at.dy.roundToDouble()},
        },
    ]);

/// Il contrario di [encodeMarks]; un foglio illeggibile riparte vuoto.
List<Object> decodeMarks(String raw) {
  try {
    return [
      for (final m in (jsonDecode(raw) as List).cast<Map<String, dynamic>>())
        if (m['e'] is String)
          _Stamp(m['e'] as String, Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble()))
        else
          _strokeFrom(m),
    ];
  } catch (_) {
    return [];
  }
}

_Stroke _strokeFrom(Map<String, dynamic> m) {
  final s = _Stroke(Color(m['c'] as int), (m['w'] as num).toDouble());
  final p = (m['p'] as List).cast<num>();
  for (var i = 0; i + 1 < p.length; i += 2) {
    s.points.add(Offset(p[i].toDouble(), p[i + 1].toDouble()));
  }
  return s;
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: GestureDetector(
          onTap: onTap,
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
      );
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.selected, required this.onTap, required this.child, this.tooltip});
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
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
            child: SizedBox(width: 58, height: 54, child: Center(child: child)),
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }
}

class _SheetPainter extends CustomPainter {
  _SheetPainter(this.marks);
  final List<_Mark> marks;

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in marks) {
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
  }

  // I tratti si allungano sul posto: ridisegna sempre.
  @override
  bool shouldRepaint(_SheetPainter old) => true;
}
