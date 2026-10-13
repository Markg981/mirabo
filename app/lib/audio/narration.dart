import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// La narrazione registrata di una schermata con il nome del bambino inserito
/// in ogni punto di [nameSlots] (millisecondi): pezzo, nome, pezzo, nome, resto.
/// Senza punti, o senza il file del nome, è la registrazione intera.
AudioSource narrationWithName(Uri narration, Uri? name, List<int> nameSlots) {
  if (nameSlots.isEmpty || name == null) return AudioSource.uri(narration);
  final parts = <AudioSource>[];
  var from = 0;
  for (final ms in [...nameSlots]..sort()) {
    if (ms > from) parts.add(_clip(narration, from, ms));
    parts.add(AudioSource.uri(name));
    from = ms;
  }
  parts.add(_clip(narration, from, null));
  return ConcatenatingAudioSource(children: parts, useLazyPreparation: false);
}

/// I pezzi in cui [narrationWithName] divide la registrazione, nello stesso
/// ordine: per ogni pezzo il punto della registrazione da cui parte (ms),
/// null per il nome. Serve al karaoke per sapere a che punto è la voce.
List<int?> narrationOffsets(List<int> nameSlots) {
  if (nameSlots.isEmpty) return const [0];
  final out = <int?>[];
  var from = 0;
  for (final ms in [...nameSlots]..sort()) {
    if (ms > from) out.add(from);
    out.add(null);
    from = ms;
  }
  out.add(from);
  return out;
}

/// Il punto della registrazione (ms) che si sta ascoltando, dal pezzo
/// [index] della sequenza e dalla posizione dentro il pezzo. Null mentre si
/// sente il nome: lì il testo resta fermo.
int? narrationTime(List<int?> offsets, int? index, Duration position) {
  final i = index ?? 0;
  if (i < 0 || i >= offsets.length) return null;
  final from = offsets[i];
  return from == null ? null : from + position.inMilliseconds;
}

ClippingAudioSource _clip(Uri narration, int fromMs, int? toMs) => ClippingAudioSource(
      child: AudioSource.uri(narration),
      start: Duration(milliseconds: fromMs),
      end: toMs == null ? null : Duration(milliseconds: toMs),
    );

/// Il player legge da file: l'audio del pacchetto (che sta in memoria) si copia
/// una volta nella cartella temporanea e poi si riusa.
Future<File> storyAudioFile(String storyId, String path, Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/mirabo_audio/$storyId/$path');
  if (await file.exists() && await file.length() == bytes.length) return file;
  await file.parent.create(recursive: true);
  return file.writeAsBytes(bytes, flush: true);
}
