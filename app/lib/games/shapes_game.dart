import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

enum ShapeKind { circle, square, triangle, star, heart, hexagon }

/// Un pezzo: forma, misura (1 grande, 0.7 piccolo) e colore.
@immutable
class _Piece {
  const _Piece(this.kind, this.scale, this.color);
  final ShapeKind kind;
  final double scale;
  final Color color;

  /// Chiave del nome tradotto (shapeName): "circle", "circleSmall"…
  String get nameKey => scale < 1 ? '${kind.name}Small' : kind.name;
}

/// Incastri: i pezzi colorati si trascinano nei buchi della tavola.
/// 3-5: tre forme; 5-7: cinque; 7-10: sei, con grandi e piccole da distinguere.
class ShapesGame extends StatefulWidget {
  const ShapesGame({super.key, required this.ctx});
  final GameContext ctx;

  @override
  State<ShapesGame> createState() => _ShapesGameState();
}

class _ShapesGameState extends State<ShapesGame> {
  late final List<_Piece> _pieces;
  late final List<int> _holeOrder;
  final Set<int> _placed = {};
  int? _wrongHole;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _pieces = switch (widget.ctx.band) {
      AgeBand.b3to5 => const [
          _Piece(ShapeKind.circle, 1, MiraboColors.rose),
          _Piece(ShapeKind.square, 1, MiraboColors.sky),
          _Piece(ShapeKind.triangle, 1, MiraboColors.sun),
        ],
      AgeBand.b5to7 => const [
          _Piece(ShapeKind.circle, 1, MiraboColors.rose),
          _Piece(ShapeKind.square, 1, MiraboColors.sky),
          _Piece(ShapeKind.triangle, 1, MiraboColors.sun),
          _Piece(ShapeKind.star, 1, MiraboColors.plum),
          _Piece(ShapeKind.heart, 1, MiraboColors.leaf),
        ],
      AgeBand.b7to10 => const [
          _Piece(ShapeKind.circle, 1, MiraboColors.rose),
          _Piece(ShapeKind.circle, 0.68, MiraboColors.rose),
          _Piece(ShapeKind.square, 1, MiraboColors.sky),
          _Piece(ShapeKind.square, 0.68, MiraboColors.sky),
          _Piece(ShapeKind.star, 1, MiraboColors.plum),
          _Piece(ShapeKind.hexagon, 1, MiraboColors.teal),
        ],
    }
        .toList()
      ..shuffle(rnd);
    _holeOrder = List.generate(_pieces.length, (i) => i)..shuffle(rnd);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.ctx.say(widget.ctx.band == AgeBand.b7to10 ? context.l10n.shapesIntroBig : context.l10n.shapesIntro),
    );
  }

  void _drop(int hole, int piece) {
    final h = _pieces[hole];
    final p = _pieces[piece];
    // Si accetta qualunque pezzo identico, non solo "quello": due cerchi grandi sono uguali.
    if (h.kind == p.kind && h.scale == p.scale) {
      setState(() {
        _placed.add(hole);
        _wrongHole = null;
      });
      widget.ctx.say(context.l10n.shapeName(p.nameKey));
      if (_placed.length == _pieces.length) {
        Future.delayed(const Duration(milliseconds: 700), widget.ctx.onFinished);
      }
    } else {
      setState(() => _wrongHole = hole);
      widget.ctx.say(context.l10n.shapesWrong(context.l10n.shapeName(p.nameKey)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final n = _pieces.length;
      const cols = 3;
      final rows = (n / cols).ceil();
      final cell = math.min((c.maxWidth * 0.5 - 80) / cols, (c.maxHeight - 80) / rows).clamp(80.0, 190.0);
      final tokens = MiraboTokens.of(context);

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Row(
          children: [
            // Vassoio con i pezzi
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < n; i++)
                      SizedBox(
                        width: cell,
                        height: cell,
                        child: _usedPiece(i)
                            ? const SizedBox.shrink()
                            : Draggable<int>(
                                data: i,
                                feedback: _shape(_pieces[i], cell * 1.08, tokens),
                                childWhenDragging: Opacity(opacity: 0.25, child: _shape(_pieces[i], cell, tokens)),
                                child: Semantics(label: context.l10n.shapeName(_pieces[i].nameKey), child: _shape(_pieces[i], cell, tokens)),
                              ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Tavola con i buchi
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tokens.tint(const Color(0xFFE8B675)),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: tokens.tint(const Color(0xFFB9864A)), offset: const Offset(0, 8)),
                      ...softShadow(),
                    ],
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final hole in _holeOrder)
                        SizedBox(
                          width: cell,
                          height: cell,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (_) => !_placed.contains(hole),
                            onAcceptWithDetails: (d) => _drop(hole, d.data),
                            builder: (context, candidates, _) {
                              final placed = _placed.contains(hole);
                              final hovering = candidates.isNotEmpty;
                              return AnimatedScale(
                                scale: hovering ? 1.06 : 1,
                                duration: const Duration(milliseconds: 120),
                                child: placed
                                    ? _shape(_pieces[hole], cell, tokens)
                                    : CustomPaint(
                                        painter: _ShapePainter(
                                          _pieces[hole].kind,
                                          _pieces[hole].scale,
                                          _wrongHole == hole ? const Color(0x55C6384C) : const Color(0x553A2A10),
                                          hole: true,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Un pezzo è "usato" quando un buco identico l'ha già accolto: nel vassoio
  /// spariscono tanti pezzi uguali quanti buchi uguali sono pieni.
  bool _usedPiece(int i) {
    final p = _pieces[i];
    final same = [for (var j = 0; j < _pieces.length; j++) if (_pieces[j].kind == p.kind && _pieces[j].scale == p.scale) j];
    final filled = same.where(_placed.contains).length;
    return same.indexOf(i) < filled;
  }

  Widget _shape(_Piece p, double size, MiraboTokens tokens) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _ShapePainter(p.kind, p.scale, tokens.tint(p.color))),
      );
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.kind, this.scale, this.color, {this.hole = false});
  final ShapeKind kind;
  final double scale;
  final Color color;
  final bool hole;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide * 0.86 * scale;
    final c = size.center(Offset.zero);
    final path = shapePath(kind, Rect.fromCenter(center: c, width: s, height: s));
    if (hole) {
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0x33000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      return;
    }
    canvas.drawPath(path.shift(const Offset(0, 6)), Paint()..color = MiraboColors.deep(color, 0.15));
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.kind != kind || old.color != color || old.scale != scale;
}

Path shapePath(ShapeKind kind, Rect r) {
  final c = r.center;
  final h = r.width / 2;
  switch (kind) {
    case ShapeKind.circle:
      return Path()..addOval(r);
    case ShapeKind.square:
      return Path()..addRRect(RRect.fromRectAndRadius(r.deflate(h * 0.08), Radius.circular(h * 0.18)));
    case ShapeKind.triangle:
      return Path()
        ..moveTo(c.dx, r.top + h * 0.05)
        ..lineTo(r.right, r.bottom - h * 0.1)
        ..lineTo(r.left, r.bottom - h * 0.1)
        ..close();
    case ShapeKind.star:
      final p = Path();
      for (var i = 0; i < 10; i++) {
        final a = -math.pi / 2 + i * math.pi / 5;
        final rad = i.isEven ? h : h * 0.45;
        final pt = c + Offset(math.cos(a), math.sin(a)) * rad;
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      return p..close();
    case ShapeKind.hexagon:
      final p = Path();
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3;
        final pt = c + Offset(math.cos(a), math.sin(a)) * h;
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      return p..close();
    case ShapeKind.heart:
      // Un solo contorno: lobo sinistro, punta, lobo destro.
      final x0 = r.left, x1 = r.right, y0 = r.top + r.height * 0.06, h2 = r.height * 0.9;
      return Path()
        ..moveTo(c.dx, y0 + h2 * 0.26)
        ..cubicTo(c.dx - r.width * 0.06, y0 - h2 * 0.04, x0, y0 - h2 * 0.02, x0, y0 + h2 * 0.32)
        ..cubicTo(x0, y0 + h2 * 0.6, c.dx - r.width * 0.12, y0 + h2 * 0.78, c.dx, y0 + h2)
        ..cubicTo(c.dx + r.width * 0.12, y0 + h2 * 0.78, x1, y0 + h2 * 0.6, x1, y0 + h2 * 0.32)
        ..cubicTo(x1, y0 - h2 * 0.02, c.dx + r.width * 0.06, y0 - h2 * 0.04, c.dx, y0 + h2 * 0.26)
        ..close();
  }
}
