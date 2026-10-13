import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

/// Lo stato di una pausa di gesto da soli: prima si aspetta il "via", poi il
/// bambino fa il gesto per qualche secondo, poi la storia riprende.
enum GesturePhase { ready, running, done }

/// Il cerchio della pausa di gesto: l'emoji del gesto al centro, che si gonfia
/// e si sgonfia piano come un respiro, e un anello che si riempie mentre passa
/// il tempo. Nessun numero: non è un conto alla rovescia da battere.
/// Con la bassa stimolazione il cerchio sta fermo e si riempie solo l'anello.
class GesturePauseBoard extends StatefulWidget {
  const GesturePauseBoard({
    super.key,
    required this.emoji,
    required this.seconds,
    required this.phase,
    required this.color,
    this.onStart,
    this.size = 150,
  });

  final String emoji;
  final int seconds;
  final GesturePhase phase;
  final Color color;

  /// Il "via" del bambino; null quando la pausa non si avvia da qui (insieme).
  final VoidCallback? onStart;
  final double size;

  @override
  State<GesturePauseBoard> createState() => _GesturePauseBoardState();
}

class _GesturePauseBoardState extends State<GesturePauseBoard> with TickerProviderStateMixin {
  /// Un respiro: quattro secondi a gonfiarsi, quattro a sgonfiarsi.
  late final AnimationController _breath =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: Duration(seconds: widget.seconds));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(GesturePauseBoard old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase) _sync();
  }

  void _sync() {
    switch (widget.phase) {
      case GesturePhase.ready:
        _progress.value = 0;
        _breath.stop();
      case GesturePhase.running:
        _progress.forward(from: 0);
        _breath.repeat(reverse: true);
      case GesturePhase.done:
        _progress.value = 1;
        _breath.animateTo(0, duration: const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calm = MiraboTokens.of(context).lowStimulation;
    final size = widget.size;
    final circle = AnimatedBuilder(
      animation: Listenable.merge([_breath, _progress]),
      builder: (context, _) {
        final scale = calm ? 1.0 : 0.82 + 0.18 * Curves.easeInOut.transform(_breath.value);
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(progress: _progress.value, color: widget.color),
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size * 0.74,
                  height: size * 0.74,
                  decoration: BoxDecoration(
                    color: MiraboColors.pale(widget.color, 0.8),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(widget.emoji, style: TextStyle(fontSize: size * 0.36)),
                ),
              ),
            ),
          ),
        );
      },
    );
    return Semantics(
      label: context.l10n.gesturePause,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle,
          if (widget.phase == GesturePhase.ready && widget.onStart != null) ...[
            const SizedBox(height: 12),
            ChunkyButton(
              label: context.l10n.gestureStart,
              icon: Icons.self_improvement_rounded,
              color: MiraboColors.leaf,
              height: 60,
              onPressed: widget.onStart,
            ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.06;
    final rect = Offset.zero & size;
    final ring = rect.deflate(stroke / 2);
    canvas.drawArc(ring, 0, 2 * pi, false, Paint()
      ..color = MiraboColors.pale(color, 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke);
    if (progress > 0) {
      canvas.drawArc(ring, -pi / 2, 2 * pi * progress, false, Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
