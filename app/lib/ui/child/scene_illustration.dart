import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../content/story_repository.dart';
import '../../models/story.dart';
import '../design/palette.dart';
import 'companion_widget.dart';

/// Illustrazione composta di una pagina: sfondo dipinto e figure posizionate.
/// Fa da libro illustrato finché la storia non ha i disegni veri.
class SceneIllustration extends StatelessWidget {
  const SceneIllustration({super.key, required this.scene, required this.companion, required this.stage});
  final SceneSpec scene;
  final Companion companion;
  final int stage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(child: CustomPaint(painter: _BackgroundPainter(scene.background, dirty: scene.dirty))),
          for (final item in scene.items) _place(item, w, h),
        ],
      );
    });
  }

  Widget _place(SceneItem item, double w, double h) {
    final side = h * item.size;
    Widget child = switch (item.paint) {
      'companion' => CompanionWidget(companion: companion, stage: stage, size: side),
      'volcano' => CustomPaint(painter: _VolcanoPainter(item.color ?? 'red', smoke: item.smoke, flower: item.flower)),
      'tower' => CustomPaint(painter: _TowerPainter(item.variant ?? 'tall', flag: item.flag)),
      'pebble' => CustomPaint(painter: _PebblePainter()),
      _ => FittedBox(child: Text(item.emoji ?? '', style: const TextStyle(fontSize: 100, height: 1.15))),
    };
    if (item.flip) child = Transform.flip(flipX: true, child: child);
    if (item.rotation != 0) child = Transform.rotate(angle: item.rotation * math.pi / 180, child: child);
    if (item.opacity < 1) child = Opacity(opacity: item.opacity, child: child);
    return Positioned(
      left: item.x * w - side / 2,
      top: item.y * h - side / 2,
      width: side,
      height: side,
      child: IgnorePointer(child: child),
    );
  }
}

// ---------------------------------------------------------------- sfondi

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter(this.kind, {this.dirty = false});
  final String kind;
  final bool dirty;

  Paint _p(Color c) => Paint()..color = c;

  void _sky(Canvas c, Size s, double bottom) {
    final r = Rect.fromLTWH(0, 0, s.width, s.height * bottom);
    c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6FD9F5), Color(0xFFCFF4FC)],
          ).createShader(r));
  }

  void _cloud(Canvas c, Offset o, double k) {
    final p = _p(Colors.white.withValues(alpha: 0.9));
    c.drawOval(Rect.fromCenter(center: o, width: 90 * k, height: 32 * k), p);
    c.drawCircle(o + Offset(-16 * k, -10 * k), 18 * k, p);
    c.drawCircle(o + Offset(12 * k, -14 * k), 22 * k, p);
  }

  void _tree(Canvas c, Offset base, double k, Color leaf) {
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: base + Offset(0, -18 * k), width: 12 * k, height: 40 * k), Radius.circular(4 * k)),
        _p(const Color(0xFF8A5A3B)));
    for (final (dx, dy, r) in [(-16.0, -52.0, 24.0), (16.0, -54.0, 24.0), (0.0, -74.0, 28.0)]) {
      c.drawCircle(base + Offset(dx * k, dy * k), r * k, _p(leaf));
    }
    c.drawCircle(base + Offset(-6 * k, -82 * k), 9 * k, _p(Colors.white.withValues(alpha: 0.12)));
  }

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    switch (kind) {
      case 'room':
        final wall = Rect.fromLTWH(0, 0, w, h * 0.7);
        c.drawRect(
            wall,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFEBC9), Color(0xFFFFDCAE)],
              ).createShader(wall));
        // carta da parati a pois
        for (var y = 30.0; y < h * 0.66; y += 56) {
          for (var x = (y ~/ 56).isEven ? 30.0 : 58.0; x < w; x += 56) {
            c.drawCircle(Offset(x, y), 5, _p(Colors.white.withValues(alpha: 0.45)));
          }
        }
        // finestra
        final win = Rect.fromLTWH(w * 0.07, h * 0.1, w * 0.22, h * 0.32);
        c.drawRRect(RRect.fromRectAndRadius(win.inflate(8), const Radius.circular(14)), _p(Colors.white));
        c.drawRRect(
            RRect.fromRectAndRadius(win, const Radius.circular(8)),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7FD8F7), Color(0xFFD2F4FD)],
              ).createShader(win));
        c.save();
        c.clipRect(win);
        _cloud(c, win.center + Offset(-win.width * 0.1, -win.height * 0.15), win.width / 160);
        c.restore();
        c.drawRect(Rect.fromCenter(center: win.center, width: 7, height: win.height), _p(Colors.white));
        c.drawRect(Rect.fromCenter(center: win.center, width: win.width, height: 7), _p(Colors.white));
        // pavimento di legno
        final floor = Rect.fromLTWH(0, h * 0.7, w, h * 0.3);
        c.drawRect(floor, _p(const Color(0xFFDDA05F)));
        for (var i = 1; i < 5; i++) {
          final y = h * 0.7 + i * h * 0.06;
          c.drawLine(Offset(0, y), Offset(w, y), _p(const Color(0xFFC88A4C))..strokeWidth = 2);
        }
        c.drawRect(Rect.fromLTWH(0, h * 0.68, w, h * 0.025), _p(Colors.white));
        // tappeto
        c.drawOval(Rect.fromCenter(center: Offset(w * 0.55, h * 0.87), width: w * 0.62, height: h * 0.17), _p(const Color(0xFFF59AB0)));
        c.drawOval(Rect.fromCenter(center: Offset(w * 0.55, h * 0.87), width: w * 0.5, height: h * 0.11), _p(const Color(0xFFF9BCCB)));
      case 'forest':
        _sky(c, s, 0.62);
        _cloud(c, Offset(w * 0.7, h * 0.12), w / 700);
        c.drawOval(Rect.fromLTWH(-w * 0.2, h * 0.42, w * 0.8, h * 0.4), _p(const Color(0xFF9BD98E)));
        c.drawOval(Rect.fromLTWH(w * 0.4, h * 0.44, w * 0.9, h * 0.4), _p(const Color(0xFF8DD27F)));
        c.drawRect(Rect.fromLTWH(0, h * 0.58, w, h * 0.42), _p(const Color(0xFF6CC56F)));
        for (final (x, k, col) in [
          (0.06, 1.1, const Color(0xFF2E9E4F)),
          (0.2, 0.85, const Color(0xFF3BAA58)),
          (0.8, 0.9, const Color(0xFF3BAA58)),
          (0.94, 1.15, const Color(0xFF2E9E4F)),
        ]) {
          _tree(c, Offset(w * x, h * 0.62), h / 330 * k, col);
        }
        final path = Path()
          ..moveTo(w * 0.47, h * 0.58)
          ..lineTo(w * 0.53, h * 0.58)
          ..quadraticBezierTo(w * 0.62, h * 0.8, w * 0.8, h)
          ..lineTo(w * 0.3, h)
          ..quadraticBezierTo(w * 0.46, h * 0.78, w * 0.47, h * 0.58)
          ..close();
        c.drawPath(path, _p(const Color(0xFFEBD3A2)));
        for (final (x, y) in [(0.12, 0.9), (0.9, 0.86), (0.25, 0.74)]) {
          c.drawCircle(Offset(w * x, h * y), h * 0.05, _p(const Color(0xFF4FB760)));
          c.drawCircle(Offset(w * x + h * 0.05, h * y + 4), h * 0.04, _p(const Color(0xFF4FB760)));
        }
      case 'stream':
        _sky(c, s, 0.34);
        _cloud(c, Offset(w * 0.25, h * 0.1), w / 800);
        c.drawRect(Rect.fromLTWH(0, h * 0.3, w, h * 0.7), _p(const Color(0xFF7BCB72)));
        for (final x in [0.08, 0.3, 0.72, 0.9]) {
          _tree(c, Offset(w * x, h * 0.34), h / 520, const Color(0xFF3BAA58));
        }
        final water = Path()
          ..moveTo(0, h * 0.5)
          ..cubicTo(w * 0.3, h * 0.44, w * 0.6, h * 0.54, w, h * 0.46)
          ..lineTo(w, h * 0.68)
          ..cubicTo(w * 0.6, h * 0.76, w * 0.3, h * 0.66, 0, h * 0.74)
          ..close();
        c.drawPath(water, _p(dirty ? const Color(0xFF8E9B78) : const Color(0xFF4FC3F7)));
        final ripple = Paint()
          ..color = Colors.white.withValues(alpha: dirty ? 0.18 : 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        for (final (x, y) in [(0.15, 0.58), (0.42, 0.6), (0.68, 0.56), (0.85, 0.6), (0.3, 0.66)]) {
          c.drawArc(Rect.fromCenter(center: Offset(w * x, h * y), width: w * 0.08, height: h * 0.03), math.pi * 0.1, math.pi * 0.8, false, ripple);
        }
        if (dirty) {
          for (final (x, y) in [(0.22, 0.6), (0.55, 0.62), (0.78, 0.57)]) {
            c.drawOval(Rect.fromCenter(center: Offset(w * x, h * y), width: w * 0.09, height: h * 0.035), _p(const Color(0x556B5A3A)));
          }
        }
        for (final (x, y, r) in [(0.05, 0.5, 0.03), (0.35, 0.47, 0.022), (0.62, 0.72, 0.028), (0.92, 0.66, 0.03), (0.18, 0.75, 0.025)]) {
          c.drawOval(Rect.fromCenter(center: Offset(w * x, h * y), width: h * r * 2.6, height: h * r * 1.6), _p(const Color(0xFFA9AEB8)));
        }
      default: // sky
        _sky(c, s, 1);
        _cloud(c, Offset(w * 0.25, h * 0.2), w / 600);
        _cloud(c, Offset(w * 0.75, h * 0.32), w / 800);
        c.drawOval(Rect.fromLTWH(-w * 0.1, h * 0.78, w * 1.2, h * 0.5), _p(const Color(0xFF6CC56F)));
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.kind != kind || old.dirty != dirty;
}

// ---------------------------------------------------------------- elementi dipinti

abstract class _GridPainter extends CustomPainter {
  void draw(Canvas c);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    draw(canvas);
    canvas.restore();
  }

  Paint p(Color c) => Paint()..color = c;
}

/// Il vulcano delle emozioni: rosso e fumante, poi arancione, rosa, verde con un fiore.
class _VolcanoPainter extends _GridPainter {
  _VolcanoPainter(this.color, {this.smoke = false, this.flower = false});
  final String color;
  final bool smoke;
  final bool flower;

  static const _colors = {
    'red': Color(0xFFE5484D),
    'orange': Color(0xFFFF8A3D),
    'pink': Color(0xFFF49AC1),
    'green': Color(0xFF5DBB63),
  };

  @override
  void draw(Canvas c) {
    final base = _colors[color] ?? _colors['red']!;
    if (smoke) {
      for (final (x, y, r) in [(46.0, 20.0, 7.0), (54.0, 14.0, 8.0), (48.0, 6.0, 9.0), (58.0, 3.0, 6.0)]) {
        c.drawCircle(Offset(x, y), r, p(const Color(0xAA9EA3AE)));
      }
    }
    final mountain = Path()..addPolygon(const [Offset(4, 98), Offset(36, 32), Offset(44, 28), Offset(56, 28), Offset(64, 32), Offset(96, 98)], true);
    c.drawPath(mountain, p(base));
    final shade = Path()..addPolygon(const [Offset(50, 30), Offset(56, 28), Offset(64, 32), Offset(96, 98), Offset(58, 98)], true);
    c.drawPath(shade, p(MiraboColors.deep(base, 0.08)));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 29.5), width: 20, height: 5), p(MiraboColors.deep(base, 0.2)));
    if (color != 'green') {
      final lava = color == 'red' ? const Color(0xFFFFC14D) : Colors.white.withValues(alpha: 0.7);
      final drips = Path()
        ..moveTo(42, 30)
        ..lineTo(58, 30)
        ..lineTo(57, 40)
        ..quadraticBezierTo(55, 46, 53, 40)
        ..lineTo(51, 52)
        ..quadraticBezierTo(49, 56, 47, 50)
        ..lineTo(45, 38)
        ..quadraticBezierTo(43, 42, 42, 36)
        ..close();
      c.drawPath(drips, p(lava));
    }
    if (flower) {
      c.drawLine(const Offset(50, 28), const Offset(50, 14), p(const Color(0xFF2E9E4F))..strokeWidth = 2.2);
      c.drawOval(Rect.fromCenter(center: const Offset(46, 22), width: 7, height: 3.5), p(const Color(0xFF2E9E4F)));
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5 - math.pi / 2;
        c.drawCircle(const Offset(50, 11) + Offset(math.cos(a), math.sin(a)) * 4.5, 3.6, p(const Color(0xFFFF8FB1)));
      }
      c.drawCircle(const Offset(50, 11), 3, p(MiraboColors.sun));
    }
  }

  @override
  bool shouldRepaint(_VolcanoPainter old) => old.color != color || old.smoke != smoke || old.flower != flower;
}

/// La torre di costruzioni: alta, in bilico, crollata o bassa e larga.
class _TowerPainter extends _GridPainter {
  _TowerPainter(this.variant, {this.flag = true});
  final String variant;
  final bool flag;

  static const _blocks = [MiraboColors.rose, MiraboColors.sky, MiraboColors.sun, MiraboColors.leaf, MiraboColors.plum, MiraboColors.apricot, MiraboColors.teal];

  void _block(Canvas c, Offset center, double w, double h, Color color, [double angle = 0]) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    final r = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    c.drawRRect(RRect.fromRectAndRadius(r.shift(const Offset(0, 1.6)), const Radius.circular(2.4)), p(MiraboColors.deep(color, 0.15)));
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2.4)), p(color));
    c.drawLine(r.topLeft + const Offset(2, 1.6), r.topRight + const Offset(-2, 1.6), p(Colors.white.withValues(alpha: 0.45))..strokeWidth = 1.2);
    c.restore();
  }

  void _flag(Canvas c, Offset base, [double angle = 0]) {
    c.save();
    c.translate(base.dx, base.dy);
    c.rotate(angle);
    c.drawLine(Offset.zero, const Offset(0, -14), p(const Color(0xFF6E6680))..strokeWidth = 1.4);
    c.drawPath(Path()..addPolygon(const [Offset(0, -14), Offset(10, -10.5), Offset(0, -7)], true), p(MiraboColors.rose));
    c.restore();
  }

  @override
  void draw(Canvas c) {
    switch (variant) {
      case 'wide':
        const bw = 22.0, bh = 13.0;
        var i = 0;
        for (var row = 0; row < 3; row++) {
          final n = 3 - row;
          for (var k = 0; k < n; k++) {
            final x = 50 + (k - (n - 1) / 2) * (bw + 1);
            _block(c, Offset(x, 98 - bh / 2 - row * bh), bw, bh, _blocks[i++ % _blocks.length]);
          }
        }
        if (flag) _flag(c, const Offset(50, 98 - 3 * 13));
      case 'fallen':
        const spots = [(18.0, 92.0, 0.5), (34.0, 95.0, -0.2), (52.0, 90.0, 1.1), (68.0, 95.0, 0.15), (82.0, 91.0, -0.7), (44.0, 80.0, 0.4), (62.0, 82.0, -1.0)];
        for (var i = 0; i < spots.length; i++) {
          final (x, y, a) = spots[i];
          _block(c, Offset(x, y), 16, 9, _blocks[i % _blocks.length], a);
        }
        if (flag) _flag(c, const Offset(90, 97), 1.4);
      default: // tall, leaning
        const bw = 18.0, bh = 11.0;
        final lean = variant == 'leaning' ? 1.8 : 0.0;
        const wobble = [0.0, 1.2, -0.8, 0.9, -1.1, 0.6, -0.4];
        for (var i = 0; i < 7; i++) {
          _block(c, Offset(50 + wobble[i] + i * lean, 98 - bh / 2 - i * bh), bw, bh, _blocks[i]);
        }
        if (flag) _flag(c, Offset(50 + 6 * lean, 98 - 7 * bh));
    }
  }

  @override
  bool shouldRepaint(_TowerPainter old) => old.variant != variant || old.flag != flag;
}

/// Pietrolino: sassolino grigio, tondo e liscio, che sembra sorridere.
class _PebblePainter extends _GridPainter {
  @override
  void draw(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 64), width: 84, height: 60), p(const Color(0xFF858A96)));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 60), width: 82, height: 56), p(const Color(0xFFA4A9B4)));
    c.drawOval(Rect.fromCenter(center: const Offset(34, 46), width: 22, height: 10), p(Colors.white.withValues(alpha: 0.35)));
    final ink = Paint()
      ..color = MiraboColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    c.drawArc(Rect.fromCenter(center: const Offset(40, 60), width: 9, height: 7), math.pi, math.pi, false, ink);
    c.drawArc(Rect.fromCenter(center: const Offset(60, 60), width: 9, height: 7), math.pi, math.pi, false, ink);
    c.drawArc(Rect.fromCenter(center: const Offset(50, 67), width: 14, height: 9), 0.2, math.pi - 0.4, false, ink);
    c.drawOval(Rect.fromCenter(center: const Offset(32, 67), width: 9, height: 5), p(const Color(0x66FF8FA3)));
    c.drawOval(Rect.fromCenter(center: const Offset(68, 67), width: 9, height: 5), p(const Color(0x66FF8FA3)));
  }

  @override
  bool shouldRepaint(_PebblePainter old) => false;
}
