import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/adult_pin.dart';

void main() {
  late MemoryPinStore store;
  late DateTime clock;
  late AdultPin pin;

  setUp(() {
    store = MemoryPinStore();
    clock = DateTime(2026, 1, 1, 12);
    pin = AdultPin(store: store, now: () => clock, iterations: 50);
  });

  test('formato: 4-6 cifre', () {
    expect(AdultPin.isValidFormat('1234'), isTrue);
    expect(AdultPin.isValidFormat('123456'), isTrue);
    expect(AdultPin.isValidFormat('123'), isFalse);
    expect(AdultPin.isValidFormat('1234567'), isFalse);
    expect(AdultPin.isValidFormat('12a4'), isFalse);
  });

  test('il PIN non è in chiaro e il sale rende diversi gli hash', () async {
    await pin.set('4821');
    expect(await pin.isSet, isTrue);
    expect(store.data.values.any((v) => v.contains('4821')), isFalse);
    final first = store.data['adult_pin_hash'];
    await pin.set('4821');
    expect(store.data['adult_pin_hash'], isNot(first));
    expect(await pin.verify('4821'), PinResult.ok);
  });

  test('PIN errato: attesa crescente dopo la soglia', () async {
    await pin.set('4821');
    expect(await pin.verify('0000'), PinResult.wrong);
    expect(await pin.verify('0000'), PinResult.wrong);
    expect(await pin.verify('0000'), PinResult.locked);
    // Anche il PIN giusto è rifiutato durante l'attesa.
    expect(await pin.verify('4821'), PinResult.locked);
    expect((await pin.remainingLock()).inSeconds, inInclusiveRange(29, 30));
    clock = clock.add(const Duration(seconds: 31));
    expect(await pin.verify('0000'), PinResult.locked);
    expect((await pin.remainingLock()).inSeconds, inInclusiveRange(59, 60));
    expect(AdultPin.waitAfter(99), const Duration(hours: 1));
  });

  test('il PIN giusto azzera i tentativi', () async {
    await pin.set('4821');
    await pin.verify('1');
    await pin.verify('1');
    expect(await pin.verify('4821'), PinResult.ok);
    expect(await pin.verify('1'), PinResult.wrong);
  });

  test('reset: toglie PIN e attese senza toccare altro', () async {
    store.data['altro'] = 'dato del bambino';
    await pin.set('4821');
    for (var i = 0; i < 3; i++) {
      await pin.verify('0000');
    }
    await pin.reset();
    expect(await pin.isSet, isFalse);
    expect(await pin.remainingLock(), Duration.zero);
    expect(store.data['altro'], 'dato del bambino');
    await pin.set('9999');
    expect(await pin.verify('9999'), PinResult.ok);
  });
}
