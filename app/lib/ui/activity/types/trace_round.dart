import 'package:flutter/material.dart';

import '../activity_player.dart';

/// "Traccia con il dito": la lettera è disegnata come guida tratteggiata; il
/// bambino la ripassa. Il controllo è volutamente generoso: il tracciato va
/// bene se copre la maggior parte dei punti-guida entro una tolleranza.
class TraceRound extends RoundWidget {
  const TraceRound({super.key, required super.level, required super.ctx, required super.onRound, required super.onFinished});
  @override
  State<TraceRound> createState() => _TraceRoundState();
}

class _TraceRoundState extends RoundState<TraceRound> {
  List<Map<String, dynamic>> get _rounds => (widget.level['rounds'] as List).cast<Map<String, dynamic>>();
  final List<List<Offset>> _strokes = [];
  int _spokenFor = -1;

  @override
  int get roundCount => _rounds.length;

  @override
  void next() {
    _strokes.clear();
    super.next();
  }

  List<List<Offset>> _guide(int index) => (_rounds[index]['paths'] as List)
      .map((p) => (p as List).map((pt) => Offset(((pt as List)[0] as num).toDouble(), (pt[1] as num).toDouble())).toList())
      .toList();

  /// Campiona i segmenti-guida e verifica che quasi tutti i campioni abbiano un
  /// punto del tracciato del bambino vicino (in coordinate 0–1).
  bool _coversGuide(List<List<Offset>> guide, Size size) {
    final drawn = _strokes.expand((s) => s).map((o) => Offset(o.dx / size.width, o.dy / size.height)).toList();
    if (drawn.length < 5) return false;
    var samples = 0, hit = 0;
    for (final path in guide) {
      for (var i = 0; i < path.length - 1; i++) {
        for (var t = 0.0; t <= 1.0; t += 0.1) {
          final p = Offset.lerp(path[i], path[i + 1], t)!;
          samples++;
          if (drawn.any((d) => (d - p).distance < 0.12)) hit++;
        }
      }
    }
    return samples > 0 && hit / samples >= 0.75;
  }

  @override
  Widget buildRound(BuildContext context, int index) {
    final r = _rounds[index];
    final label = r['label'] as String;
    final say = r['say'] as String? ?? label;
    final prompt = 'Traccia la $label con il dito';
    if (_spokenFor != index) {
      _spokenFor = index;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ctx.say('$prompt. $say'));
    }
    final guide = _guide(index);
    return Column(
      children: [
        PromptBar(text: prompt, onSay: () => widget.ctx.say('$prompt. $say')),
        Expanded(
          child: Center(
            child: LayoutBuilder(builder: (context, constraints) {
              final side = (constraints.biggest.shortestSide - 24).clamp(200.0, 420.0);
              final size = Size(side, side);
              return Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                ),
                child: GestureDetector(
                  onPanStart: (d) => setState(() => _strokes.add([d.localPosition])),
                  onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
                  onPanEnd: (_) {
                    if (_coversGuide(guide, size)) {
                      answer(true);
                    } else if (_strokes.length >= 2) {
                      answer(false);
                      if (attempts >= 3) setState(_strokes.clear);
                    }
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _TracePainter(
                      guide: guide,
                      strokes: _strokes,
                      guideColor: showHint ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                      strokeColor: Theme.of(context).colorScheme.primary,
                      done: lastCorrect == true,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Ricomincio'),
            onPressed: lastCorrect == true ? null : () => setState(_strokes.clear),
          ),
        ),
      ],
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.guide, required this.strokes, required this.guideColor, required this.strokeColor, required this.done});
  final List<List<Offset>> guide;
  final List<List<Offset>> strokes;
  final Color guideColor;
  final Color strokeColor;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()
      ..color = guideColor.withValues(alpha: 0.5)
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final path in guide) {
      final p = Path();
      for (var i = 0; i < path.length; i++) {
        final o = Offset(path[i].dx * size.width, path[i].dy * size.height);
        if (i == 0) {
          p.moveTo(o.dx, o.dy);
        } else {
          p.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(p, gp);
      // Punto di partenza
      canvas.drawCircle(Offset(path.first.dx * size.width, path.first.dy * size.height), 10, Paint()..color = guideColor);
    }
    final sp = Paint()
      ..color = done ? Colors.green : strokeColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length < 2) continue;
      final p = Path()..moveTo(s.first.dx, s.first.dy);
      for (final o in s.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, sp);
    }
  }

  @override
  bool shouldRepaint(_TracePainter old) => true;
}
