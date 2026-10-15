import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/audio/child_name.dart';
import 'package:mirabo/features.dart';

/// Il nome del bambino nella voce è fuori dall'MVP (docs/privacy/mvp-data.md):
/// le battute si dicono senza nome e la punteggiatura resta in ordine.
void main() {
  test('nella build distribuita il nome nella voce è spento', () {
    expect(Features.spokenName, isFalse);
    expect(Features.cloudBackup, isFalse);
  });

  test('senza nome: la frase resta naturale', () {
    const cases = {
      'Tu cosa faresti, {nome}?': 'Tu cosa faresti?',
      "Ciao {nome}! C'è un vulcano.": "Ciao! C'è un vulcano.",
      'Dai {nome}, facciamolo! Mani sulla pancia.': 'Dai, facciamolo! Mani sulla pancia.',
      'Sai, {nome}? Il fiocco non è sparito.': 'Sai? Il fiocco non è sparito.',
      'Facciamolo anche noi, {nome}. Mani sulla pancia.': 'Facciamolo anche noi. Mani sulla pancia.',
      '{nome}, guarda qui.': 'Guarda qui.',
      'Nessun nome qui.': 'Nessun nome qui.',
    };
    cases.forEach((text, expected) => expect(fillName(text, 'Ada', spoken: false), expected, reason: text));
  });

  test('con il nome acceso il segnaposto diventa il nome', () {
    expect(fillName('Tu cosa faresti, {nome}?', 'Ada', spoken: true), 'Tu cosa faresti, Ada?');
  });

  test('le frasi dell\'app con il nome si dicono senza', () {
    String bravo(String name) => 'Bravo, $name! Che bella partita.';
    String fr(String name) => 'Bravo, $name !';
    String turn(String name) => 'Adesso tocca a te, $name. Il tablet lo mettiamo via.';
    expect(spokenWithName(bravo, 'Ada', spoken: false), 'Bravo! Che bella partita.');
    expect(spokenWithName(fr, 'Ada', spoken: false), 'Bravo!');
    expect(spokenWithName(turn, 'Ada', spoken: false), 'Adesso tocca a te. Il tablet lo mettiamo via.');
    expect(spokenWithName(bravo, 'Ada', spoken: true), 'Bravo, Ada! Che bella partita.');
  });
}
