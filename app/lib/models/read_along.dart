/// Lettura karaoke: la parola che la voce sta dicendo si illumina nel testo.
/// Qui solo i conti, senza widget: dove sono le parole, quale si sta leggendo.
library;

/// Una parola del testo: dove inizia e dove finisce (caratteri, fine esclusa).
typedef WordSpan = ({int start, int end});

final _word = RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);

/// Le parole del testo, nell'ordine. La punteggiatura resta fuori:
/// "Ciao, Emma!" sono due parole, "l'albero" una sola.
List<WordSpan> readAlongWords(String text) =>
    [for (final m in _word.allMatches(text)) (start: m.start, end: m.end)];

/// La parola che contiene il carattere [offset] (o quella subito dopo, se
/// [offset] cade su uno spazio). -1 se è oltre l'ultima.
int wordAtChar(List<WordSpan> words, int offset) {
  for (var i = 0; i < words.length; i++) {
    if (offset < words[i].end) return i;
  }
  return -1;
}

/// La parola che la registrazione sta dicendo al millisecondo [ms]:
/// l'ultima di [timings] già iniziata. -1 prima della prima.
int wordAtTime(List<(int, String)> timings, int ms) {
  var found = -1;
  for (var i = 0; i < timings.length; i++) {
    if (timings[i].$1 > ms) break;
    found = i;
  }
  return found;
}
