import 'dart:math' as math;

import '../../l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'palette.dart';

/// Ombra morbida comune a carte e pannelli.
List<BoxShadow> softShadow([double strength = 1]) => [
      BoxShadow(color: const Color(0xFF5A3E1E).withValues(alpha: 0.07 * strength), blurRadius: 24, offset: const Offset(0, 10)),
      BoxShadow(color: const Color(0xFF5A3E1E).withValues(alpha: 0.05 * strength), blurRadius: 4, offset: const Offset(0, 2)),
    ];

/// Bottone grande "a rilievo" per il bambino: si abbassa quando lo tocchi.
/// Mai più basso del target minimo del profilo; per chi non legge, se ha
/// un'icona, mostra solo quella (la scritta resta per lo screen reader).
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.foreground = Colors.white,
    this.iconAfter = false,
    this.height = 68,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color foreground;
  final bool iconAfter;
  final double height;
  final bool expand;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;
  static const _depth = 6.0;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final enabled = widget.onPressed != null;
    final base = enabled ? tokens.tint(widget.color ?? Theme.of(context).colorScheme.primary) : MiraboColors.disabled;
    final edge = MiraboColors.deep(base, enabled ? 0.16 : 0.08);
    final fg = enabled ? widget.foreground : MiraboColors.inkSoft;
    final down = _down && enabled;
    final height = math.max(widget.height, tokens.minTarget);
    final iconOnly = widget.icon != null && !tokens.textMode.showsLabels;
    final icon = widget.icon == null ? null : Icon(widget.icon, color: fg, size: height * (iconOnly ? 0.56 : 0.44));
    final text = Text(
      widget.label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontSize: height * 0.32),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _depth),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            height: height,
            constraints: BoxConstraints(minWidth: height),
            transform: Matrix4.translationValues(0, down ? _depth : 0, 0),
            padding: EdgeInsets.symmetric(horizontal: height * 0.42),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(height * 0.36),
              boxShadow: [BoxShadow(color: edge, offset: Offset(0, down ? 0 : _depth))],
            ),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: iconOnly
                  ? [icon!]
                  : [
                      if (icon != null && !widget.iconAfter) ...[icon, const SizedBox(width: 10)],
                      Flexible(child: text),
                      if (icon != null && widget.iconAfter) ...[const SizedBox(width: 10), icon],
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Esce da una storia o da un'attività. Con poca autonomia (MiraboTokens.confirmExit)
/// prima chiede conferma con due bottoni grandi a icona, così un tocco per
/// sbaglio non chiude tutto.
Future<void> leaveChildPage(BuildContext context) async {
  final nav = Navigator.of(context);
  if (MiraboTokens.of(context).confirmExit && await _confirmExit(context) != true) return;
  nav.pop();
}

Future<bool?> _confirmExit(BuildContext context) {
  final l = context.l10n;
  final tokens = MiraboTokens.of(context);
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: tokens.textMode.showsLabels ? Text(l.exitAsk) : null,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChunkyButton(
            label: l.exitStay,
            icon: Icons.play_arrow_rounded,
            color: MiraboColors.leaf,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(width: 20),
          ChunkyButton(
            label: l.exitLeave,
            icon: Icons.home_rounded,
            color: MiraboColors.apricot,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );
}

/// Il tasto indietro del sistema passa da [leaveChildPage]: con la conferma
/// attiva non chiude la pagina da solo.
class ExitGuard extends StatelessWidget {
  const ExitGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final confirm = MiraboTokens.of(context).confirmExit;
    return PopScope(
      canPop: !confirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveChildPage(context);
      },
      child: child,
    );
  }
}

/// Bottone rotondo bianco con icona, per le azioni secondarie (chiudi, ascolta).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 60,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = math.max(this.size, MiraboTokens.of(context).minTarget);
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: MiraboColors.paper, shape: BoxShape.circle, boxShadow: softShadow(0.9)),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Icon(icon, size: size * 0.5, color: color ?? MiraboColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Rimpicciolisce leggermente il figlio mentre lo tocchi.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.semanticLabel});
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final animate = MiraboTokens.of(context).animate;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down && animate ? 0.96 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Pannello bianco arrotondato con ombra morbida.
class SoftPanel extends StatelessWidget {
  const SoftPanel({super.key, required this.child, this.padding = const EdgeInsets.all(24), this.radius = 28, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MiraboColors.paper,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: softShadow(),
      ),
      child: child,
    );
  }
}

enum TailSide { left, bottom, top }

/// Fumetto con la punta verso chi parla.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.child,
    this.tail = TailSide.left,
    this.tailAt = 0.5,
    this.color = MiraboColors.paper,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
  });

  final Widget child;
  final TailSide tail;

  /// Posizione della punta lungo il lato, da 0 a 1.
  final double tailAt;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final border = _BubbleBorder(tail: tail, tailAt: tailAt);
    return Container(
      decoration: ShapeDecoration(color: color, shape: border, shadows: softShadow()),
      padding: padding.add(border.dimensions),
      child: child,
    );
  }
}

class _BubbleBorder extends ShapeBorder {
  const _BubbleBorder({required this.tail, required this.tailAt});
  final TailSide tail;
  final double tailAt;
  static const _tail = 14.0;
  static const _radius = 24.0;

  @override
  EdgeInsets get dimensions => switch (tail) {
        TailSide.left => const EdgeInsets.only(left: _tail),
        TailSide.bottom => const EdgeInsets.only(bottom: _tail),
        TailSide.top => const EdgeInsets.only(top: _tail),
      };

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final body = dimensions.deflateRect(rect);
    final path = Path()..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(_radius)));
    final tailPath = Path();
    switch (tail) {
      case TailSide.left:
        final y = (body.top + _radius + (body.height - 2 * _radius) * tailAt).clamp(body.top + 12, body.bottom - 12);
        tailPath
          ..moveTo(body.left + 2, y - 11)
          ..quadraticBezierTo(body.left - 4, y - 2, rect.left, y + 8)
          ..quadraticBezierTo(body.left + 4, y + 9, body.left + 2, y + 11)
          ..close();
      case TailSide.bottom:
        final x = (body.left + _radius + (body.width - 2 * _radius) * tailAt).clamp(body.left + 12, body.right - 12);
        tailPath
          ..moveTo(x - 12, body.bottom - 2)
          ..quadraticBezierTo(x - 2, body.bottom + 4, x - 8, rect.bottom)
          ..quadraticBezierTo(x + 6, body.bottom + 4, x + 12, body.bottom - 2)
          ..close();
      case TailSide.top:
        final x = (body.left + _radius + (body.width - 2 * _radius) * tailAt).clamp(body.left + 12, body.right - 12);
        tailPath
          ..moveTo(x - 12, body.top + 2)
          ..quadraticBezierTo(x - 2, body.top - 4, x - 8, rect.top)
          ..quadraticBezierTo(x + 6, body.top - 4, x + 12, body.top + 2)
          ..close();
    }
    return Path.combine(PathOperation.union, path, tailPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// Pallini di avanzamento: quello corrente è una pillola allungata.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.count, required this.current, this.color});
  final int count;
  final int current;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final c = tokens.tint(color ?? Theme.of(context).colorScheme.primary);
    // Con molti passi i pallini si stringono per stare in una riga.
    final dot = count > 14 ? 8.0 : 12.0;
    return Semantics(
      label: context.l10n.stepOf('${current + 1}', '$count'),
      excludeSemantics: true,
      child: Wrap(
        spacing: dot * 0.6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: Duration(milliseconds: tokens.animate ? 250 : 0),
              width: i == current ? dot * 2.6 : dot,
              height: dot,
              decoration: BoxDecoration(
                color: i < current ? c.withValues(alpha: 0.45) : (i == current ? c : MiraboColors.line),
                borderRadius: BorderRadius.circular(dot),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fondale illustrato: cielo caldo, sole, nuvole, colline.
/// [accent] tinge le colline (ad esempio con il colore del mondo della storia).
class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({super.key, required this.child, this.accent});
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    return CustomPaint(
      painter: _BackdropPainter(
        accent: tokens.tint(accent ?? MiraboColors.leaf),
        calm: tokens.lowStimulation,
      ),
      child: child,
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.accent, required this.calm});
  final Color accent;
  final bool calm;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (calm) {
      canvas.drawRect(rect, Paint()..color = const Color(0xFFE6EFF3));
      final hill = Path()
        ..moveTo(0, size.height * 0.9)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.82, size.width, size.height * 0.9)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(hill, Paint()..color = Color.lerp(accent, const Color(0xFFE6EFF3), 0.6)!);
      return;
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MiraboColors.skyTop, MiraboColors.skyBottom],
        ).createShader(rect),
    );

    // Sole con alone
    // Colori pieni: un giallo trasparente sul ciano diventerebbe verde.
    final sun = Offset(size.width * 0.93, size.height * 0.3);
    final r = size.shortestSide * 0.06;
    canvas.drawCircle(sun, r * 1.9, Paint()..color = Color.lerp(MiraboColors.skyTop, Colors.white, 0.45)!);
    canvas.drawCircle(sun, r * 1.4, Paint()..color = const Color(0xFFFFE680));
    canvas.drawCircle(sun, r, Paint()..color = MiraboColors.sun);

    // Nuvole
    void cloud(double x, double y, double s) {
      final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 120 * s, height: 44 * s), p);
      canvas.drawCircle(Offset(x - 22 * s, y - 14 * s), 24 * s, p);
      canvas.drawCircle(Offset(x + 16 * s, y - 20 * s), 30 * s, p);
    }

    cloud(size.width * 0.45, size.height * 0.22, 1.0);
    cloud(size.width * 0.72, size.height * 0.46, 0.75);
    cloud(size.width * 0.3, size.height * 0.55, 0.6);

    // Colline: due strati
    final back = Color.lerp(accent, Colors.white, 0.3)!;
    final front = accent;
    final h = size.height;
    final w = size.width;
    final p1 = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(w * 0.2, h * 0.72, w * 0.38, h * 0.78, w * 0.55, h * 0.8)
      ..cubicTo(w * 0.72, h * 0.82, w * 0.86, h * 0.7, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p1, Paint()..color = back);
    final p2 = Path()
      ..moveTo(0, h * 0.92)
      ..cubicTo(w * 0.25, h * 0.84, w * 0.5, h * 0.95, w * 0.72, h * 0.89)
      ..cubicTo(w * 0.85, h * 0.86, w * 0.95, h * 0.9, w, h * 0.9)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, Paint()..color = front);

    // Qualche fiorellino sulla collina davanti
    final rnd = math.Random(7);
    for (var i = 0; i < 9; i++) {
      final x = w * (0.04 + rnd.nextDouble() * 0.92);
      final y = h * (0.94 + rnd.nextDouble() * 0.04);
      canvas.drawCircle(Offset(x, y), 3.2, Paint()..color = Colors.white.withValues(alpha: 0.8));
      canvas.drawCircle(Offset(x, y), 1.4, Paint()..color = const Color(0xFFFFC94A));
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.accent != accent || old.calm != calm;
}

/// Tessera "solida": faccia colorata con il bordo inferiore più scuro, come i
/// blocchi dei materiali Montessori. Si abbassa quando la tocchi. Se si può
/// toccare non è mai più piccola del target minimo del profilo.
class BlockTile extends StatefulWidget {
  const BlockTile({
    super.key,
    required this.child,
    required this.onTap,
    this.color = MiraboColors.paper,
    this.edgeColor,
    this.radius = 28,
    this.depth = 8,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
    this.width,
    this.height,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color? edgeColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final double? width;
  final double? height;
  final BoxBorder? border;

  @override
  State<BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends State<BlockTile> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final down = _down && enabled;
    final edge = widget.edgeColor ??
        (widget.color == MiraboColors.paper ? const Color(0xFFC9DAE7) : MiraboColors.deep(widget.color, 0.14));
    final d = widget.depth;
    final min = enabled ? MiraboTokens.of(context).minTarget : 0.0;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.only(bottom: d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: widget.width,
            height: widget.height,
            constraints: BoxConstraints(minWidth: min, minHeight: min),
            transform: Matrix4.translationValues(0, down ? d * 0.7 : 0, 0),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.radius),
              border: widget.border,
              boxShadow: [
                BoxShadow(color: edge, offset: Offset(0, down ? d * 0.3 : d)),
                BoxShadow(
                  color: const Color(0xFF0B3A5E).withValues(alpha: down ? 0.08 : 0.14),
                  blurRadius: 18,
                  offset: Offset(0, down ? d * 0.6 : d + 6),
                ),
              ],
            ),
            // Il ritaglio arrotondato sta fuori dal padding, così non morde il contenuto.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fascia blu notte con il titolo in bianco, come un'insegna.
class TitleBanner extends StatelessWidget {
  const TitleBanner({super.key, required this.title, this.trailing, this.leading});
  final String title;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final navy = tokens.tint(MiraboColors.navy);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 12, 12),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: MiraboColors.deep(navy, 0.1), offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 16)],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Bollino con icona su fondo colorato tenue (carte, intestazioni).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 56});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: MiraboColors.pale(c, 0.8), borderRadius: BorderRadius.circular(size * 0.32)),
      child: Icon(icon, color: MiraboColors.deep(c, 0.08), size: size * 0.55),
    );
  }
}
