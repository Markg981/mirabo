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

  test('codice di recupero: solo hash, vale una volta, toglie il PIN e lascia un avviso', () async {
    await pin.set('1234');
    final code = await pin.newRecoveryCode();
    expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}$')));
    expect(store.data.values.any((v) => v.contains(code.replaceAll('-', ''))), isFalse);
    expect(await pin.hasRecoveryCode, isTrue);

    expect(await pin.recover('AAAA-AAAA'), PinResult.wrong);
    expect(await pin.recover(' ${code.toLowerCase()} '), PinResult.ok);
    expect(await pin.isSet, isFalse);
    expect(await pin.hasRecoveryCode, isFalse);
    expect(await pin.recover(code), PinResult.wrong);

    final notice = await pin.resetNotice();
    expect(notice?.how, RecoveryChannel.code);
    expect(notice?.at, clock);
    await pin.clearResetNotice();
    expect(await pin.resetNotice(), isNull);
  });

  test('il codice di recupero ha le stesse attese del PIN: niente tentativi a raffica', () async {
    await pin.set('1234');
    await pin.newRecoveryCode();
    for (var i = 0; i < AdultPin.freeAttempts - 1; i++) {
      expect(await pin.recover('AAAA-AAAA'), PinResult.wrong);
    }
    expect(await pin.recover('AAAA-AAAA'), PinResult.locked);
    expect(await pin.verify('1234'), PinResult.locked);
  });

  test('recupero con il blocco del tablet: acceso salvo scelta dell\'adulto', () async {
    expect(await pin.deviceRecovery, isTrue);
    await pin.setDeviceRecovery(false);
    expect(await pin.deviceRecovery, isFalse);
    await pin.setDeviceRecovery(true);
    expect(await pin.deviceRecovery, isTrue);
  });

  test('"Elimina tutti i dati" toglie PIN, codice, attese e avvisi: come al primo avvio', () async {
    await pin.set('1234');
    await pin.newRecoveryCode();
    await pin.setDeviceRecovery(false);
    await pin.verify('0000');
    await pin.reset();
    await pin.forget();
    expect(store.data, isEmpty);
  });
}
