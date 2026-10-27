import 'package:flutter_test/flutter_test.dart';
import 'package:mirabo/data/adult_pin.dart';

void main() {
  late MemoryPinStore store;
  late DateTime clock;
  late AdultPin pin;
  late Duration mono; // tempo monotono simulato: avanza solo col tempo vero

  setUp(() {
    store = MemoryPinStore();
    clock = DateTime(2026, 1, 1, 12);
    mono = Duration.zero;
    pin = AdultPin(store: store, now: () => clock, monotonic: () => mono, iterations: 50);
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
    mono += const Duration(seconds: 31);
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

  test('reset: toglie le attese senza toccare altro; il PIN cambia solo con set', () async {
    store.data['altro'] = 'dato del bambino';
    await pin.set('4821');
    for (var i = 0; i < 3; i++) {
      await pin.verify('0000');
    }
    await pin.reset();
    expect(await pin.remainingLock(), Duration.zero);
    expect(store.data['altro'], 'dato del bambino');
    await pin.set('9999');
    expect(await pin.verify('9999'), PinResult.ok);
    expect(await pin.verify('4821'), PinResult.wrong);
  });

  test('reset annullato: il tablet non resta senza PIN, il vecchio vale ancora', () async {
    await pin.set('4821');
    final code = await pin.newRecoveryCode();
    expect(await pin.recover(code), PinResult.ok);
    // l'adulto annulla la scelta del PIN nuovo
    expect(await pin.isSet, isTrue);
    expect(await pin.verify('4821'), PinResult.ok);
    expect(await pin.hasRecoveryCode, isTrue);
    await pin.reset(how: RecoveryChannel.device);
    expect(await pin.isSet, isTrue);
  });

  test('codice di recupero: solo hash, vale una volta, si consuma col PIN nuovo e lascia un avviso', () async {
    await pin.set('1234');
    final code = await pin.newRecoveryCode();
    expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}$')));
    expect(store.data.values.any((v) => v.contains(code.replaceAll('-', ''))), isFalse);
    expect(await pin.hasRecoveryCode, isTrue);

    expect(await pin.recover('AAAA-AAAA'), PinResult.wrong);
    expect(await pin.recover(' ${code.toLowerCase()} '), PinResult.ok);
    expect(await pin.isSet, isTrue);
    expect(await pin.hasRecoveryCode, isTrue);
    await pin.set('5555');
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

  test('recupero con il blocco del tablet: spento di default, lo accende un adulto', () async {
    expect(await pin.deviceRecovery, isFalse);
    await pin.setDeviceRecovery(true);
    expect(await pin.deviceRecovery, isTrue);
    await pin.setDeviceRecovery(false);
    expect(await pin.deviceRecovery, isFalse);
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

  Future<void> lockOut() async {
    await pin.set('4821');
    for (var i = 0; i < 3; i++) {
      await pin.verify('0000');
    }
  }

  test("orologio spostato in avanti con app aperta: l'attesa non sparisce", () async {
    await lockOut();
    clock = clock.add(const Duration(days: 2));
    mono += const Duration(seconds: 5);
    expect((await pin.remainingLock()).inSeconds, inInclusiveRange(24, 25));
    expect(await pin.verify('4821'), PinResult.locked);
  });

  test("orologio indietro: non annulla né allunga l'attesa", () async {
    await lockOut();
    clock = clock.subtract(const Duration(days: 2));
    expect((await pin.remainingLock()).inSeconds, inInclusiveRange(29, 30));
    // Dopo il riallineamento l'attesa scorre normalmente.
    clock = clock.add(const Duration(seconds: 10));
    mono += const Duration(seconds: 10);
    expect((await pin.remainingLock()).inSeconds, inInclusiveRange(19, 20));
    clock = clock.add(const Duration(seconds: 21));
    mono += const Duration(seconds: 21);
    expect(await pin.remainingLock(), Duration.zero);
  });

  test("dopo il riavvio l'attesa è una durata residua e gli errori restano", () async {
    await lockOut();
    clock = clock.subtract(const Duration(hours: 5));
    final restarted = AdultPin(store: store, now: () => clock, monotonic: () => mono, iterations: 50);
    expect((await restarted.remainingLock()).inSeconds, inInclusiveRange(29, 30));
    clock = clock.add(const Duration(minutes: 1));
    mono += const Duration(minutes: 1);
    expect(await restarted.remainingLock(), Duration.zero);
    // Il quarto errore consecutivo vale 60 s, non si riparte da 30.
    expect(await restarted.verify('0000'), PinResult.locked);
    expect((await restarted.remainingLock()).inSeconds, inInclusiveRange(59, 60));
  });
}
