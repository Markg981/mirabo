import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../content/story_repository.dart';
import '../../models/story.dart';
import '../design/palette.dart';

/// Il compagno del bambino, disegnato in vettoriale finché non arrivano le
/// illustrazioni. Cresce con lo stadio (sciarpa, occhi aperti, cose nella tana:
/// vedi docs/style-guide.md). Con [withHome] compare anche la sua casa; nella
/// tana di Tango, dallo stadio 2, ci sono le cose trovate nei mondi in [found].
/// Respira e sbatte le palpebre piano; in bassa stimolazione sta fermo.
class CompanionWidget extends StatefulWidget {
  const CompanionWidget({
    super.key,
    required this.companion,
    required this.stage,
    this.size = 120,
    this.withHome = false,
    this.found,
  });

  final Companion companion;
  final int stage;
  final double size;
  final bool withHome;
  final Set<World>? found;

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MiraboTokens.of(context).animate) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
      _clock.value = 0;
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.companion;
    return Semantics(
      image: true,
      label: '${c.name}, ${c.kind}. ${c.stageLabel(widget.stage)}',
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) {
            final t = _clock.value;
            // Due respiri per giro; un battito di ciglia verso la fine.
            final breath = math.sin(t * 4 * math.pi) * 0.5 + 0.5;
            final blink = (t > 0.9 && t < 0.94) ? 0.0 : 1.0;
            return CustomPaint(
              size: Size.square(widget.size),
              painter: CompanionPainter(
                id: c.id,
                stage: widget.stage,
                withHome: widget.withHome,
                found: widget.found,
                breath: breath,
                eyeOpen: blink,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Disegno dei tre compagni su una griglia 100×100.
class CompanionPainter extends CustomPainter {
  CompanionPainter({
    required this.id,
    required this.stage,
    this.withHome = false,
    this.found,
    this.breath = 0,
    this.eyeOpen = 1,
  });

  final CompanionId id;
  final int stage;
  final bool withHome;

  /// Mondi di cui il bambino ha finito almeno una storia; null o vuoto: la
  /// tana di Tango mostra la ghianda e la conchiglia di sempre.
  final Set<World>? found;
  final double breath;
  final double eyeOpen;

  static const _ink = MiraboColors.ink;
  static const _blush = Color(0x66FF8FA3);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    if (withHome) _homeBack(canvas);

    canvas.save();
    if (withHome) {
      canvas
        ..translate(id == CompanionId.tango ? 8 : 14, 8)
        ..scale(0.8);
    }
    // Ombra a terra, poi il personaggio che respira (si allunga appena in alto).
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 96), width: 58, height: 7),
        Paint()..color = const Color(0xFF5A3E1E).withValues(alpha: 0.10));
    canvas
      ..translate(50, 96)
      ..scale(1 - 0.008 * breath, 1 + 0.018 * breath)
      ..translate(-50, -96);
    switch (id) {
      case CompanionId.bo:
        _bo(canvas);
      case CompanionId.pilu:
        _pilu(canvas);
      case CompanionId.tango:
        _tango(canvas);
    }
    canvas.restore();

    if (withHome) _homeFront(canvas);
    canvas.restore();
  }

  // ---------- primitive ----------

  void _oval(Canvas c, double cx, double cy, double rx, double ry, Color color) =>
      c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), Paint()..color = color);

  void _poly(Canvas c, List<Offset> pts, Color color) {
    final p = Path()..addPolygon(pts, true);
    c.drawPath(p, Paint()..color = color);
  }

  /// Occhio a goccia scura con due riflessi; chiuso diventa un archetto.
  void _eye(Canvas c, double cx, double cy, double rx, double ry, {double open = 1}) {
    final o = open * eyeOpen;
    if (o < 0.2) {
      final p = Path()
        ..moveTo(cx - rx - 0.6, cy)
        ..quadraticBezierTo(cx, cy + ry * 0.9, cx + rx + 0.6, cy);
      c.drawPath(
          p,
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round);
      return;
    }
    _oval(c, cx, cy, rx, ry * o, _ink);
    _oval(c, cx - rx * 0.32, cy - ry * 0.38 * o, rx * 0.42, rx * 0.42 * o, Colors.white);
    _oval(c, cx + rx * 0.36, cy + ry * 0.36 * o, rx * 0.18, rx * 0.18 * o, Colors.white.withValues(alpha: 0.8));
  }

  Paint _stroke(Color color, double w) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // ---------- Bo, piccolo mammut lanoso ----------

  static const _fur = Color(0xFF9C6B4E);
  static const _furDark = Color(0xFF7A4E36);
  static const _furLight = Color(0xFFC4946F);
  static const _earIn = Color(0xFFE3AC8E);
  static const _tusk = Color(0xFFFFF4E0);
  static const _scarf = Color(0xFFE5484D);

  void _bo(Canvas c) {
    // zampe
    c.drawRRect(RRect.fromLTRBR(31, 78, 44, 95, const Radius.circular(6)), Paint()..color = _furDark);
    c.drawRRect(RRect.fromLTRBR(56, 78, 69, 95, const Radius.circular(6)), Paint()..color = _furDark);
    for (final x in [34.5, 40.5, 59.5, 65.5]) {
      _oval(c, x, 93.2, 2, 1.4, _tusk);
    }
    // corpo
    _oval(c, 50, 72, 28, 19, _fur);
    _oval(c, 50, 77, 17, 9, _furLight.withValues(alpha: 0.45));
    // orecchie
    _oval(c, 24, 44, 15, 16, _furDark);
    _oval(c, 76, 44, 15, 16, _furDark);
    _oval(c, 25, 46, 9, 10, _earIn);
    _oval(c, 75, 46, 9, 10, _earIn);
    // testa
    c.drawCircle(const Offset(50, 42), 25, Paint()..color = _fur);
    _oval(c, 50, 31, 15, 8, _furLight.withValues(alpha: 0.5));
    // ciuffo: da cucciolo è più spettinato
    for (final (x, y, r) in [(43.0, 18.5, 6.0), (50.0, 15.5, 7.0), (57.0, 18.5, 6.0)]) {
      c.drawCircle(Offset(x, y), r, Paint()..color = _furDark);
    }
    if (stage == 0) {
      c.drawCircle(const Offset(38.5, 22), 4.5, Paint()..color = _furDark);
      c.drawCircle(const Offset(61.5, 22), 4.5, Paint()..color = _furDark);
      c.drawCircle(const Offset(50, 11), 3.5, Paint()..color = _furDark);
    }
    // occhi e guance
    _eye(c, 41, 40, 3.4, 4.4);
    _eye(c, 59, 40, 3.4, 4.4);
    _oval(c, 33.5, 50, 4.6, 2.8, _blush);
    _oval(c, 66.5, 50, 4.6, 2.8, _blush);
    // sciarpa rossa (stadio 1+)
    if (stage >= 1) {
      c.drawRRect(RRect.fromLTRBR(28, 61, 72, 69.5, const Radius.circular(4.5)), Paint()..color = _scarf);
      c.drawRRect(RRect.fromLTRBR(28, 64.5, 72, 66, const Radius.circular(1)),
          Paint()..color = Colors.white.withValues(alpha: 0.35));
      c.drawRRect(RRect.fromLTRBR(58, 65, 67, 83, const Radius.circular(3)), Paint()..color = MiraboColors.deep(_scarf, 0.08));
      for (final x in [59.8, 62.5, 65.2]) {
        c.drawLine(Offset(x, 83), Offset(x, 86), _stroke(MiraboColors.deep(_scarf, 0.08), 1.4));
      }
    }
    // zanne
    _poly(c, const [Offset(42.5, 54), Offset(36.5, 60.5), Offset(40, 64.5), Offset(45.5, 57)], _tusk);
    _poly(c, const [Offset(57.5, 54), Offset(63.5, 60.5), Offset(60, 64.5), Offset(54.5, 57)], _tusk);
    // proboscide
    final trunk = Path()
      ..moveTo(50, 46)
      ..cubicTo(50, 56, 45, 62, 47, 69)
      ..cubicTo(48.5, 74, 55, 75, 56, 70.5);
    c.drawPath(trunk, _stroke(_fur, 9.5));
    c.drawPath(trunk, _stroke(_furLight.withValues(alpha: 0.35), 3.5));
    for (final y in [55.0, 60.5]) {
      c.drawArc(Rect.fromCenter(center: Offset(48.2, y), width: 8, height: 3), 0.2, 2.6, false,
          _stroke(_furDark.withValues(alpha: 0.5), 1.1));
    }
    // uccellino sulla testa (stadio 2+)
    if (stage >= 2) _bird(c, 63, 14);
  }

  void _bird(Canvas c, double x, double y) {
    const yellow = Color(0xFFFFC93C);
    const wing = Color(0xFFF2A81D);
    _poly(c, [Offset(x - 6, y - 1), Offset(x - 9.5, y - 3), Offset(x - 8.5, y + 1.5)], wing);
    _oval(c, x, y, 6, 5, yellow);
    c.drawCircle(Offset(x + 4.5, y - 4), 3.6, Paint()..color = yellow);
    _oval(c, x - 1.5, y + 0.5, 3.4, 2.4, wing);
    c.drawCircle(Offset(x + 5.5, y - 4.5), 0.9, Paint()..color = _ink);
    _poly(c, [Offset(x + 7.8, y - 4.6), Offset(x + 10.5, y - 3.6), Offset(x + 7.8, y - 2.6)], const Color(0xFFF28C28));
  }

  // ---------- Pilù, civetta tonda ----------

  static const _owl = Color(0xFF8299B0);
  static const _owlDark = Color(0xFF5F7790);
  static const _belly = Color(0xFFF1F4F7);
  static const _ring = Color(0xFFDCE4EC);
  static const _beak = Color(0xFFF2A33A);

  void _pilu(Canvas c) {
    // ciuffi
    _poly(c, const [Offset(25, 32), Offset(26, 9), Offset(41, 23)], _owlDark);
    _poly(c, const [Offset(75, 32), Offset(74, 9), Offset(59, 23)], _owlDark);
    // zampe
    for (final x in [41.0, 59.0]) {
      for (final dx in [-3.2, 0.0, 3.2]) {
        _oval(c, x + dx, 93.5, 2, 2.6, _beak);
      }
    }
    // ali: dal primo volo (stadio 2) si aprono
    if (stage >= 2) {
      for (final side in [-1, 1]) {
        c.save();
        c.translate(50 + side * 28, 54);
        c.rotate(side * 0.75);
        _oval(c, 0, -8, 8.5, 18, _owlDark);
        for (final dy in [-14.0, -8.0, -2.0]) {
          c.drawLine(Offset(-3, dy), Offset(3, dy + 2), _stroke(_owl, 1.2));
        }
        c.restore();
      }
    }
    // corpo
    _oval(c, 50, 57, 31, 36, _owl);
    if (stage < 2) {
      _oval(c, 21.5, 62, 8, 17, _owlDark);
      _oval(c, 78.5, 62, 8, 17, _owlDark);
    }
    _oval(c, 50, 70, 19, 20, _belly);
    for (final (row, xs) in [
      (64.0, [43.0, 50.0, 57.0]),
      (71.0, [39.5, 46.5, 53.5, 60.5]),
      (78.0, [43.0, 50.0, 57.0]),
    ]) {
      for (final x in xs) {
        c.drawArc(Rect.fromCenter(center: Offset(x, row), width: 6, height: 5), 0.15, math.pi - 0.3, false,
            _stroke(_owlDark.withValues(alpha: 0.35), 1.2));
      }
    }
    _oval(c, 50, 30, 14, 6, Colors.white.withValues(alpha: 0.15));
    // dischi facciali e occhi; da piccola dorme con un occhio aperto
    for (final x in [38.0, 62.0]) {
      c.drawCircle(Offset(x, 44), 13, Paint()..color = _ring);
    }
    _owlEye(c, 38, 44, closed: stage == 0);
    _owlEye(c, 62, 44);
    _poly(c, const [Offset(46.5, 52), Offset(53.5, 52), Offset(50, 59)], _beak);
    _oval(c, 29, 57, 4, 2.5, _blush);
    _oval(c, 71, 57, 4, 2.5, _blush);
  }

  void _owlEye(Canvas c, double x, double y, {bool closed = false}) {
    if (closed) {
      c.drawCircle(Offset(x, y), 10.5, Paint()..color = _owl);
      final p = Path()
        ..moveTo(x - 6.5, y)
        ..quadraticBezierTo(x, y + 5, x + 6.5, y);
      c.drawPath(p, _stroke(_ink, 1.8));
      return;
    }
    c.drawCircle(Offset(x, y), 10.5, Paint()..color = Colors.white);
    _eye(c, x + (x < 50 ? 0.8 : -0.8), y + 1, 5.6, 5.8);
    if (eyeOpen < 0.2) {
      // palpebra durante il battito
      c.drawCircle(Offset(x, y), 10.5, Paint()..color = _owl);
      c.drawPath(
          Path()
            ..moveTo(x - 6.5, y)
            ..quadraticBezierTo(x, y + 5, x + 6.5, y),
          _stroke(_ink, 1.8));
    }
  }

  // ---------- Tango, volpe con la coda a strisce ----------

  static const _fox = Color(0xFFEF8740);
  static const _foxDark = Color(0xFFCF6427);
  static const _foxCream = Color(0xFFFFF5E8);
  static const _sock = Color(0xFF4B3A3A);

  void _tango(Canvas c) {
    // coda a strisce, dietro
    const radii = [8.5, 9.5, 10.0, 10.0, 9.5, 8.5, 7.0];
    for (var i = 0; i < radii.length; i++) {
      final t = i / (radii.length - 1);
      final p = _quad(const Offset(62, 84), const Offset(98, 82), const Offset(86, 40), t);
      final last = i == radii.length - 1;
      c.drawCircle(p, radii[i], Paint()..color = last ? _foxCream : (i.isEven ? _fox : _foxDark));
    }
    // zampe con i calzini scuri
    for (final x in [35.0, 51.0]) {
      c.drawRRect(RRect.fromLTRBR(x, 80, x + 10, 95, const Radius.circular(5)), Paint()..color = _fox);
      c.drawRRect(RRect.fromLTRBR(x, 88, x + 10, 95, const Radius.circular(4)), Paint()..color = _sock);
    }
    // corpo e petto
    _oval(c, 48, 74, 21, 18, _fox);
    _oval(c, 48, 77, 11, 13, _foxCream);
    // orecchie
    _poly(c, const [Offset(25, 32), Offset(27, 5), Offset(45, 22)], _fox);
    _poly(c, const [Offset(71, 32), Offset(69, 5), Offset(51, 22)], _fox);
    _poly(c, const [Offset(29, 27), Offset(30, 12), Offset(39.5, 21.5)], _sock);
    _poly(c, const [Offset(67, 27), Offset(66, 12), Offset(56.5, 21.5)], _sock);
    // testa con il ciuffo sulle guance
    _poly(c, const [Offset(26, 44), Offset(15, 55), Offset(30, 57)], _fox);
    _poly(c, const [Offset(70, 44), Offset(81, 55), Offset(66, 57)], _fox);
    _oval(c, 48, 43, 25, 22, _fox);
    _oval(c, 48, 30, 12, 5, Colors.white.withValues(alpha: 0.18));
    _oval(c, 33, 53, 9, 6.5, _foxCream);
    _oval(c, 63, 53, 9, 6.5, _foxCream);
    _oval(c, 48, 56, 13, 8.5, _foxCream);
    // occhi, naso, bocca
    _eye(c, 39, 42, 3.3, 4.3);
    _eye(c, 57, 42, 3.3, 4.3);
    _oval(c, 48, 50, 3.8, 2.7, _sock);
    _oval(c, 47, 49.2, 1.2, 0.7, Colors.white.withValues(alpha: 0.6));
    final mouth = Path()
      ..moveTo(44.5, 54)
      ..quadraticBezierTo(46.3, 56.6, 48, 54.4)
      ..quadraticBezierTo(49.7, 56.6, 51.5, 54);
    c.drawPath(mouth, _stroke(_sock, 1.2));
    _oval(c, 30.5, 48, 4, 2.5, _blush);
    _oval(c, 65.5, 48, 4, 2.5, _blush);
  }

  Offset _quad(Offset a, Offset b, Offset cc, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + cc * (t * t);
  }

  // ---------- le case ----------

  void _homeBack(Canvas c) {
    switch (id) {
      case CompanionId.bo:
        // casa nel ghiaccio; la finestra si accende allo stadio 3
        const ice = Color(0xFFEAF4FB);
        const iceLine = Color(0xFFC9DFEE);
        final dome = Path()
          ..moveTo(1, 92)
          ..arcTo(Rect.fromCircle(center: const Offset(19, 92), radius: 18), math.pi, math.pi, false)
          ..close();
        c.drawPath(dome, Paint()..color = ice);
        c.drawArc(Rect.fromCircle(center: const Offset(19, 92), radius: 12), math.pi, math.pi, false, _stroke(iceLine, 1.2));
        c.drawLine(const Offset(3, 85), const Offset(35, 85), _stroke(iceLine, 1.2));
        c.drawLine(const Offset(7, 79), const Offset(31, 79), _stroke(iceLine, 1.2));
        final door = Path()
          ..moveTo(13, 92)
          ..arcTo(Rect.fromCircle(center: const Offset(19, 92), radius: 6), math.pi, math.pi, false)
          ..close();
        c.drawPath(door, Paint()..color = const Color(0xFF9DB7CC));
        final lit = stage >= 3;
        if (lit) c.drawCircle(const Offset(28.5, 81.5), 6, Paint()..color = const Color(0xFFFFD45C).withValues(alpha: 0.35));
        c.drawRRect(RRect.fromLTRBR(26, 79, 31, 84, const Radius.circular(1.2)),
            Paint()..color = lit ? const Color(0xFFFFCE45) : const Color(0xFFB8CEDD));
      case CompanionId.pilu:
        // ramo
        c.drawLine(const Offset(2, 96), const Offset(98, 93), _stroke(const Color(0xFF8A6248), 4));
        c.drawLine(const Offset(80, 93.5), const Offset(92, 86), _stroke(const Color(0xFF8A6248), 2.5));
        _oval(c, 93, 84, 4.5, 2.4, MiraboColors.leaf);
        _oval(c, 8, 92, 4.5, 2.4, MiraboColors.leaf);
      case CompanionId.tango:
        // tana: il cuscino c'è sempre, il resto arriva con le storie
        _oval(c, 50, 94, 36, 6.5, const Color(0xFFB79BE0));
        _oval(c, 50, 92.8, 30, 3.5, const Color(0xFFCBB5EC));
        if (stage >= 1) {
          _oval(c, 9, 93, 6, 4, const Color(0xFFA8A6B3));
          _oval(c, 7.5, 91.8, 2.5, 1.2, Colors.white.withValues(alpha: 0.5));
          c.save();
          c.translate(92, 82);
          c.rotate(-0.6);
          _oval(c, 0, 0, 3, 6, MiraboColors.leaf);
          c.drawLine(const Offset(0, -5), const Offset(0, 6), _stroke(MiraboColors.deep(MiraboColors.leaf, 0.15), 0.8));
          c.restore();
        }
        if (stage >= 2) {
          final things = (found == null || found!.isEmpty) ? const {World.ambiente, World.inclusione} : found!;
          for (final w in things) {
            _foundThing(c, w);
          }
        }
        if (stage >= 3) {
          _oval(c, 86, 96, 13, 3.6, const Color(0xFFF7A8B8));
        }
    }
  }

  /// Una cosa trovata in un mondo, ognuna al suo posto ai lati della tana.
  void _foundThing(Canvas c, World w) {
    switch (w) {
      case World.ambiente:
        // ghianda
        _oval(c, 8, 80, 3.6, 4.2, const Color(0xFFB07A45));
        c.drawArc(Rect.fromCenter(center: const Offset(8, 77), width: 8.5, height: 5), math.pi, math.pi, true,
            Paint()..color = const Color(0xFF7B5232));
      case World.inclusione:
        // conchiglia
        final shell = Path()
          ..moveTo(86, 70)
          ..quadraticBezierTo(92, 62, 98, 70)
          ..close();
        c.drawPath(shell, Paint()..color = const Color(0xFFF7C6B5));
      case World.emozioni:
        // sassolino a cuore
        final heart = Path()
          ..moveTo(8, 72)
          ..cubicTo(1, 67, 3, 61, 8, 64.5)
          ..cubicTo(13, 61, 15, 67, 8, 72)
          ..close();
        c.drawPath(heart, Paint()..color = const Color(0xFFF07C8C));
        _oval(c, 6, 65.5, 1.3, 0.8, Colors.white.withValues(alpha: 0.6));
      case World.sicurezza:
        // lanternina
        c.drawRRect(RRect.fromLTRBR(89, 50, 97, 59, const Radius.circular(2)), Paint()..color = const Color(0xFFFFD45C));
        c.drawRRect(RRect.fromLTRBR(88, 48, 98, 50.5, const Radius.circular(1)), Paint()..color = const Color(0xFF6B5B95));
        c.drawArc(Rect.fromCenter(center: const Offset(93, 48), width: 5, height: 5), math.pi, math.pi, false,
            _stroke(const Color(0xFF6B5B95), 0.9));
    }
  }

  void _homeFront(Canvas c) {
    if (id == CompanionId.pilu && stage >= 3) {
      // nido grande davanti alle zampe
      const twig = Color(0xFFA57A55);
      const twigDark = Color(0xFF7E5A3C);
      final nest = Path()
        ..moveTo(20, 86)
        ..quadraticBezierTo(50, 104, 80, 86)
        ..quadraticBezierTo(50, 92, 20, 86)
        ..close();
      c.drawPath(nest, Paint()..color = twig);
      for (var i = 0; i < 6; i++) {
        final x = 25.0 + i * 9;
        c.drawLine(Offset(x, 88.5 + (i % 2) * 2), Offset(x + 10, 91 - (i % 2) * 2), _stroke(twigDark, 1.1));
      }
    }
  }

  @override
  bool shouldRepaint(CompanionPainter old) =>
      old.id != id ||
      old.stage != stage ||
      old.withHome != withHome ||
      !_sameWorlds(old.found, found) ||
      old.breath != breath ||
      old.eyeOpen != eyeOpen;
}

bool _sameWorlds(Set<World>? a, Set<World>? b) =>
    (a?.length ?? 0) == (b?.length ?? 0) && (a ?? const {}).every((w) => b!.contains(w));
