import '../features.dart';

/// Segnaposto del nome del bambino nei contenuti (story-format.md).
const namePlaceholder = '{nome}';

/// Un testo dei contenuti con il nome del bambino al posto di `{nome}`.
/// Senza [Features.spokenName] il nome non entra nelle battute, né scritte né
/// dette: il testo che si legge è lo stesso che si ascolta (karaoke) e il nome
/// non arriva al motore TTS. "Tu cosa faresti, {nome}?" diventa "Tu cosa faresti?".
String fillName(String text, String name, {bool spoken = Features.spokenName}) =>
    spoken ? text.replaceAll(namePlaceholder, name) : tidyWithoutName(text.replaceAll(namePlaceholder, ''));

/// Una frase dell'app da dire a voce che contiene il nome ("Bravo, {name}!"):
/// [build] è la frase localizzata. Senza [Features.spokenName] si costruisce
/// senza nome ("Bravo!"); la stessa frase scritta sullo schermo può tenerlo,
/// perché resta sul dispositivo.
String spokenWithName(String Function(String name) build, String name, {bool spoken = Features.spokenName}) =>
    spoken ? build(name) : tidyWithoutName(build(''));

/// Toglie la punteggiatura rimasta orfana dove c'era il nome.
String tidyWithoutName(String s) {
  // "{nome}, guarda" → "Guarda": la frase comincia ancora con la maiuscola.
  final leading = RegExp(r'^\s*,').hasMatch(s);
  var out = s
      .replaceAll(RegExp(r',\s*,'), ',')
      .replaceAllMapped(RegExp(r',\s*([!?.:;])'), (m) => m[1]!)
      .replaceAllMapped(RegExp(r'\s+([!?.,:;])'), (m) => m[1]!)
      .replaceAll(RegExp(r',\s*$'), '')
      .replaceAll(RegExp(r'^\s*,\s*'), '')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
  if (leading && out.isNotEmpty) out = out[0].toUpperCase() + out.substring(1);
  return out;
}
