import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';
import '../models/story.dart';
import '../ui/design/palette.dart';
import '../ui/design/widgets.dart';
import 'game.dart';

/// Xilofono a otto barre (do-do). Le note si generano al primo avvio come
/// piccoli WAV nella cartella temporanea: nessun file audio negli asset.
/// Dai 5 anni c'è anche "Fra Martino": la barra da suonare si illumina.
class XylophoneGame extends StatefulWidget {
  const XylophoneGame({super.key, required this.ctx});
  final GameContext ctx;

  @override
  State<XylophoneGame> createState() => _XylophoneGameState();
}

class _XylophoneGameState extends State<XylophoneGame> {
  static const _freqs = [523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77, 1046.5];
  static const _colors = [
    MiraboColors.rose,
    MiraboColors.apricot,
    MiraboColors.sun,
    MiraboColors.leaf,
    MiraboColors.teal,
    MiraboColors.sky,
    MiraboColors.indigo,
    MiraboColors.plum,
  ];
  // Fra Martino, prime quattro frasi: do re mi do, do re mi do, mi fa sol, mi fa sol.
  static const _song = [0, 1, 2, 0, 0, 1, 2, 0, 2, 3, 4, 2, 3, 4];

  final _players = <AudioPlayer>[];
  bool _ready = false;
  bool _failed = false;
  bool _songMode = false;
  int _songPos = 0;
  int? _down;

  bool get _songAvailable => widget.ctx.band != AgeBand.b3to5;

  @override
  void initState() {
    super.initState();
    _load().catchError((_) {
      // Niente audio disponibile: si esce dallo spinner invece di restare in attesa.
      if (mounted) setState(() => _failed = true);
    });
  }

  Future<void> _load() async {
    final dir = await getTemporaryDirectory();
    for (var i = 0; i < _freqs.length; i++) {
      final f = File('${dir.path}/mirabo_xilofono_$i.wav');
      if (!await f.exists()) {
        // Scrittura atomica: file temporaneo poi rename, così una chiusura a metà non lascia un WAV troncato.
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsBytes(_tone(_freqs[i]), flush: true);
        await tmp.rename(f.path);
      }
      final p = AudioPlayer();
      await p.setFilePath(f.path);
      if (!mounted) {
        await p.dispose();
        return;
      }
      _players.add(p);
    }
    if (!mounted) return;
    setState(() => _ready = true);
    final l = context.l10n;
    widget.ctx.say(_songAvailable ? l.xyloIntroSong(l.xyloSong) : l.xyloIntro);
  }

  @override
  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
    super.dispose();
  }

  /// Nota "a martelletto": sinusoide con un armonico acuto che si spegne
  /// in fretta e una coda che decade piano. 16 bit mono, 22 kHz, 1 s.
  static Uint8List _tone(double freq) {
    const rate = 22050;
    const n = rate;
    final data = ByteData(44 + n * 2);
    void str(int o, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, rate, Endian.little);
    data.setUint32(28, rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      final t = i / rate;
      final attack = math.min(1.0, t / 0.004);
      final body = math.sin(2 * math.pi * freq * t) * math.exp(-t * 4.2);
      final strike = 0.35 * math.sin(2 * math.pi * freq * 3.93 * t) * math.exp(-t * 18);
      final v = (attack * (body + strike) * 0.55).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  Future<void> _hit(int i) async {
    if (!_ready) return;
    setState(() => _down = i);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted && _down == i) setState(() => _down = null);
    });
    final p = _players[i];
    await p.seek(Duration.zero);
    if (!mounted) return;
    p.play();

    if (_songMode && _songPos < _song.length && i == _song[_songPos]) {
      setState(() => _songPos++);
      if (_songPos == _song.length) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) widget.ctx.onFinished();
        });
      }
    }
  }

  void _setSong(bool on) {
    setState(() {
      _songMode = on;
      _songPos = 0;
    });
    widget.ctx.say(on ? context.l10n.xyloSongSay : context.l10n.xyloFreeSay);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MiraboTokens.of(context);
    final next = _songMode && _songPos < _song.length ? _song[_songPos] : null;
    final names = context.l10n.xyloNotes.split(' ');
    return Column(
      children: [
        if (_songAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeChip(label: context.l10n.xyloFree, emoji: '🎶', selected: !_songMode, onTap: () => _setSong(false)),
                const SizedBox(width: 12),
                _ModeChip(label: context.l10n.xyloSong, emoji: '🔔', selected: _songMode, onTap: () => _setSong(true)),
                if (_songMode) ...[
                  const SizedBox(width: 20),
                  StepDots(count: _song.length, current: _songPos.clamp(0, _song.length - 1), color: MiraboColors.sun),
                ],
              ],
            ),
          ),
        Expanded(
          child: !_ready
              ? Center(child: _failed ? const Icon(Icons.volume_off_rounded, size: 48) : const CircularProgressIndicator())
              : LayoutBuilder(builder: (context, c) {
                  final barW = math.min(110.0, (c.maxWidth - 120) / 8 - 14);
                  final maxH = c.maxHeight * 0.82;
                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // le due traverse di legno
                        for (final dy in [-maxH * 0.28, maxH * 0.22])
                          Transform.translate(
                            offset: Offset(0, dy),
                            child: Container(
                              width: (barW + 14) * 8 + 40,
                              height: 22,
                              decoration: BoxDecoration(
                                color: tokens.tint(const Color(0xFFB9864A)),
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 8; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 7),
                                child: _Bar(
                                  label: names[i],
                                  color: tokens.tint(_colors[i]),
                                  width: barW,
                                  height: maxH * (1 - i * 0.05),
                                  pressed: _down == i,
                                  glow: next == i,
                                  onTap: () => _hit(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.color,
    required this.width,
    required this.height,
    required this.pressed,
    required this.glow,
    required this.onTap,
  });
  final String label;
  final Color color;
  final double width;
  final double height;
  final bool pressed;
  final bool glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.xyloNoteA11y(label),
      child: GestureDetector(
        onTapDown: (_) => onTap(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: width,
          height: height,
          transform: Matrix4.translationValues(0, pressed ? 6 : 0, 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width * 0.3),
            border: glow ? Border.all(color: Colors.white, width: 6) : null,
            boxShadow: [
              BoxShadow(color: MiraboColors.deep(color, 0.15), offset: Offset(0, pressed ? 2 : 8)),
              if (glow) BoxShadow(color: MiraboColors.sun.withValues(alpha: 0.9), blurRadius: 24, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.only(top: 18), child: _screw()),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Fredoka', fontSize: width * 0.3, fontWeight: FontWeight.w700, color: Colors.white)),
              Padding(padding: const EdgeInsets.only(bottom: 18), child: _screw()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _screw() => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
      );
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.emoji, required this.selected, required this.onTap});
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BlockTile(
        onTap: onTap,
        radius: 999,
        depth: 5,
        color: selected ? MiraboTokens.of(context).tint(MiraboColors.navy) : MiraboColors.paper,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: selected ? Colors.white : MiraboColors.ink)),
        ]),
      );
}
