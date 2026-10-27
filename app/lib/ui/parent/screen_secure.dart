import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Impedisce screenshot e anteprima nel selettore delle app (FLAG_SECURE su
/// Android) finché il widget è nell'albero. Si usa solo per il codice di
/// recupero e per l'area adulta. Il contatore regge più widget annidati.
/// Dove il canale non esiste (iOS, test) la chiamata viene ignorata.
class ScreenSecure extends StatefulWidget {
  const ScreenSecure({super.key, required this.child});
  final Widget child;

  static const _channel = MethodChannel('mirabo/screen_secure');
  static int _count = 0;

  static Future<void> _apply(bool on) async {
    try {
      await _channel.invokeMethod<void>('set', on);
    } catch (_) {
      // Canale assente: nessuna protezione, ma niente errore.
    }
  }

  @override
  State<ScreenSecure> createState() => _ScreenSecureState();
}

class _ScreenSecureState extends State<ScreenSecure> {
  @override
  void initState() {
    super.initState();
    if (ScreenSecure._count++ == 0) ScreenSecure._apply(true);
  }

  @override
  void dispose() {
    if (--ScreenSecure._count == 0) ScreenSecure._apply(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
