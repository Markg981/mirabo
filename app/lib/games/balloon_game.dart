import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Palloncini che salgono: si scoppiano toccandoli.
/// 3-5: tutti; 6-7: solo il colore detto dal compagno; 8-10: i numeri in ordine.
class BalloonGame extends StatefulWidget {
  const BalloonGame({super.key, required this.ctx});
  final GameContext ctx;

  @override
  State<BalloonGame> createState() => _BalloonGameState();
}

class _Balloon {
  _Balloon({required this.id, required this.x, required this.born, required this.secs, required this.color, this.number});
  final int id;
  final double x;
  final Duration born;
  final double secs;
  final (String, Color) color;
  final int? number;
  Duration? wrongAt;
}

class _Pop {
  _Pop(this.at, this.center, this.color);
  final Duration at;
  final Offset center;
  final Color color;
}

class _BalloonGameState extends State<BalloonGame> with SingleTickerProviderStateMixin {
  static const _colors = [
    ('red', MiraboColors.rose),
    ('blue', MiraboColors.sky),
    ('green', MiraboColors.leaf),
    ('yellow', MiraboColors.sun),
    ('purple', MiraboColors.plum),
  ];
  static const _w = 100.0;
  static const _h = 124.0;

  final _rnd = math.Random();
  late final Ticker _ticker = createTicker(_tick);
  final _balloons = <_Balloon>[];
  final _pops = <_Pop>[];
  Duration _now = Duration.zero;
  Duration _lastSpawn = -const Duration(seconds: 10);
  Size _area = Size.zero;
  int _nextId = 0;
  int _progress = 0;
  bool _over = false;

  // 6-7: colore da scoppiare; 8-10: prossimo numero.
  late (String, Color) _target = _colors[_rnd.nextInt(_colors.length)];
  int _next = 1;

  AgeBand get _band => widget.ctx.band;
  int get _goal => _band == AgeBand.b6to7 ? 8 : 10;

  @override
  void initState() {
    super.initState();
    _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.ctx.say(_instruction());
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _instruction() => switch (_band) {
        AgeBand.b3to5 => context.l10n.balloonsPopAll,
        AgeBand.b6to7 => context.l10n.balloonsPopColor(_target.$1),
        AgeBand.b8to10 => _next == 1 ? context.l10n.balloonsNumbersStart : context.l10n.balloonsNow('$_next'),
      };

  void _tick(Duration elapsed) {
    if (_area == Size.zero) return;
    _now = elapsed;
    final spawnEvery = Duration(milliseconds: widget.ctx.calm ? 1500 : 950);
    if (!_over && _now - _lastSpawn > spawnEvery && _balloons.length < 7) {
      _spawn();
      _lastSpawn = _now;
    }
    _balloons.removeWhere((b) => _progressOf(b) > 1);
    _pops.removeWhere((p) => _now - p.at > const Duration(milliseconds: 450));
    setState(() {});
    // A fine gioco il ticker si ferma quando lo scoppio è finito: niente rebuild inutili.
    if (_over && _pops.isEmpty) _ticker.stop();
  }

  void _spawn() {
    var color = _colors[_rnd.nextInt(_colors.length)];
    int? number;
    switch (_band) {
      case AgeBand.b6to7:
        if (_rnd.nextDouble() < 0.4) color = _target;
      case AgeBand.b8to10:
        // Il numero cercato arriva spesso, così non si aspetta troppo.
        number = _rnd.nextDouble() < 0.45 ? _next : 1 + _rnd.nextInt(10);
      case AgeBand.b3to5:
        break;
    }
    final base = switch (_band) { AgeBand.b3to5 => 8.5, AgeBand.b6to7 => 7.5, AgeBand.b8to10 => 7.0 };
    _balloons.add(_Balloon(
      id: _nextId++,
      x: 0.06 + _rnd.nextDouble() * 0.88,
      born: _now,
      secs: (widget.ctx.calm ? base * 1.4 : base) + _rnd.nextDouble() * 1.5,
      color: color,
      number: number,
    ));
  }

  double _progressOf(_Balloon b) => (_now - b.born).inMilliseconds / (b.secs * 1000);

  Offset _positionOf(_Balloon b) {
    final p = _progressOf(b);
    final x = b.x * (_area.width - _w) + math.sin(p * math.pi * 3 + b.id) * 14;
    final y = _area.height + 20 - p * (_area.height + _h + 80);
    return Offset(x, y);
  }

  void _tap(_Balloon b) {
    if (_over) return;
    final ok = switch (_band) {
      AgeBand.b3to5 => true,
      AgeBand.b6to7 => b.color == _target,
      AgeBand.b8to10 => b.number == _next,
    };
    if (!ok) {
      b.wrongAt = _now;
      if (_band == AgeBand.b8to10) widget.ctx.say(context.l10n.balloonsWrongNumber('${b.number}', '$_next'));
      return;
    }
    final pos = _positionOf(b);
    _balloons.remove(b);
    if (!widget.ctx.calm) _pops.add(_Pop(_now, pos + const Offset(_w / 2, _h / 2.4), b.color.$2));
    _progress++;
    if (_band == AgeBand.b8to10) {
      widget.ctx.say('${b.number}!');
      _next++;
    }
    if (_progress >= _goal) {
      _over = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) widget.ctx.onFinished();
      });
      return;
    }
    if (_band == AgeBand.b6to7 && _progress % 4 == 0) {
      final others = _colors.where((c) => c != _target).toList();
      _target = others[_rnd.nextInt(others.length)];
      widget.ctx.say(context.l10n.balloonsNowColor(_target.$1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
            decoration: BoxDecoration(color: MiraboColors.paper, borderRadius: BorderRadius.circular(999), boxShadow: softShadow()),
            child: Row(
              children: [
                Material(
                  color: tokens.tint(MiraboColors.sky),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => widget.ctx.say(_instruction()),
                    child: const SizedBox(width: 52, height: 52, child: Icon(Icons.volume_up_rounded, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),
                if (_band == AgeBand.b6to7) ...[
                  Container(width: 30, height: 30, decoration: BoxDecoration(color: tokens.tint(_target.$2), shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    switch (_band) {
                      AgeBand.b3to5 => context.l10n.balloonsPopAll,
                      AgeBand.b6to7 => context.l10n.balloonsOnlyColor(_target.$1),
                      AgeBand.b8to10 => _over ? context.l10n.balloonsDone : context.l10n.balloonsFind('$_next'),
                    },
                    style: text.titleLarge,
                  ),
                ),
                StepDots(count: _goal, current: _progress.clamp(0, _goal - 1), color: MiraboColors.rose),
              ],
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            _area = Size(c.maxWidth, c.maxHeight);
            return ClipRect(
              child: Stack(
                children: [
                  for (final b in _balloons) _buildBalloon(b, tokens),
                  for (final p in _pops)
                    Positioned(
                      left: p.center.dx - 70,
                      top: p.center.dy - 70,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: const Size(140, 140),
                          painter: _PopPainter(((_now - p.at).inMilliseconds / 450).clamp(0, 1), tokens.tint(p.color)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBalloon(_Balloon b, MiraboTokens tokens) {
    var pos = _positionOf(b);
    final wrong = b.wrongAt;
    if (wrong != null && _now - wrong < const Duration(milliseconds: 400)) {
      pos += Offset(math.sin((_now - wrong).inMilliseconds / 30) * 8, 0);
    }
    final color = tokens.tint(b.color.$2);
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _tap(b),
        child: Semantics(
          button: true,
          onTap: () => _tap(b),
          label: b.number != null ? context.l10n.balloonA11yNumber('${b.number}') : context.l10n.balloonA11yColor(b.color.$1),
          child: SizedBox(
            width: _w,
            height: _h + 50,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(size: const Size(_w, _h + 50), painter: _BalloonPainter(color)),
                if (b.number != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: Text(
                      '${b.number}',
                      style: const TextStyle(fontFamily: 'Fredoka', fontSize: 46, fontWeight: FontWeight.w700, color: Colors.white, height: 1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const h = 124.0;
    final body = Rect.fromLTWH(4, 0, w - 8, h - 12);
    // filo
    final string = Path()
      ..moveTo(w / 2, h - 4)
      ..quadraticBezierTo(w / 2 - 10, h + 14, w / 2 + 4, h + 26)
      ..quadraticBezierTo(w / 2 + 14, h + 38, w / 2 - 2, size.height);
    canvas.drawPath(
        string,
        Paint()
          ..color = const Color(0x8854606E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    // nodo
    final knot = Path()
      ..moveTo(w / 2 - 7, h - 2)
      ..lineTo(w / 2 + 7, h - 2)
      ..lineTo(w / 2, h - 14)
      ..close();
    canvas.drawPath(knot, Paint()..color = MiraboColors.deep(color, 0.1));
    // corpo con ombra e riflesso
    canvas.drawOval(body, Paint()..color = MiraboColors.deep(color, 0.08));
    canvas.drawOval(body.deflate(1).translate(-2, -3), Paint()..color = color);
    canvas.save();
    canvas.translate(w * 0.32, h * 0.26);
    canvas.rotate(-0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 14, height: 26), Paint()..color = Colors.white.withValues(alpha: 0.45));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => old.color != color;
}

class _PopPainter extends CustomPainter {
  _PopPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final fade = 1 - t;
    canvas.drawCircle(
        c,
        20 + t * 44,
        Paint()
          ..color = color.withValues(alpha: 0.5 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * fade + 1);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final r = 16 + t * 54;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, 6 * fade, Paint()..color = color.withValues(alpha: fade));
    }
  }

  @override
  bool shouldRepaint(_PopPainter old) => old.t != t;
}
