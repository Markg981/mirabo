import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../l10n/l10n.dart';
import '../design/palette.dart';
import '../design/widgets.dart';

/// La barra in alto delle schermate del bambino fuori dalla casa (tema,
/// mensola, cosa da provare). I comandi stanno sempre nello stesso posto e
/// vogliono dire sempre la stessa cosa, come in storie, attività e giochi:
/// a sinistra si esce verso il livello sopra, a destra si riascolta. Un
/// posto senza comando resta vuoto, non prende un altro significato
/// (vedi docs/theme-navigation.md).
class ChildTopBar extends StatelessWidget {
  const ChildTopBar({
    super.key,
    required this.exitIcon,
    required this.exitTooltip,
    required this.onExit,
    required this.title,
    this.onListen,
  });

  final IconData exitIcon;
  final String exitTooltip;
  final VoidCallback onExit;
  final Widget title;

  /// Ridice il titolo e cosa c'è da scegliere; null se non c'è niente da dire.
  final VoidCallback? onListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(40),
        boxShadow: softShadow(),
      ),
      child: Row(
        children: [
          _CircleAction(icon: exitIcon, tooltip: exitTooltip, color: MiraboColors.sky, onTap: onExit),
          Expanded(child: title),
          if (onListen != null)
            _CircleAction(icon: Icons.volume_up_rounded, tooltip: context.l10n.readAgain, color: MiraboColors.navy, onTap: onListen!)
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.tooltip, required this.color, required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiraboTokens.of(context).tint(color);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 60, height: 60, child: Icon(icon, color: Colors.white, size: 32)),
        ),
      ),
    );
  }
}

/// Una frase breve detta dalla voce di sistema (nome di un tema, di una
/// capacità, una cosa da provare). Senza voce resta il testo scritto.
class ShortVoice {
  FlutterTts? _tts;

  Future<void> say(String? language, String text) async {
    try {
      final tts = _tts ??= FlutterTts();
      if (language != null) await tts.setLanguage(AppLanguage.fromCode(language).ttsCode);
      await tts.setSpeechRate(0.45);
      await tts.stop();
      await tts.speak(text);
    } catch (_) {
      // Senza voce di sistema il testo resta scritto.
    }
  }

  void dispose() {
    _tts?.stop().catchError((_) => null);
  }
}
