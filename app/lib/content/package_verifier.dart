import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

import 'trusted_key.dart';

/// Un pacchetto .mirabo aperto e verificato: i file sono disponibili solo se la
/// firma del manifest è valida e ogni file corrisponde al suo hash.
class VerifiedPackage {
  VerifiedPackage._(this.id, this.kind, this.version, this._files);

  final String id;

  /// 'story' o 'activity'.
  final String kind;
  final int version;
  final Map<String, Uint8List> _files;

  Uint8List? bytes(String path) => _files[path];
  String? text(String path) => _files[path] == null ? null : utf8.decode(_files[path]!);
  Map<String, dynamic>? json(String path) =>
      text(path) == null ? null : jsonDecode(text(path)!) as Map<String, dynamic>;
  Iterable<String> get paths => _files.keys;
}

class PackageVerificationException implements Exception {
  PackageVerificationException(this.message);
  final String message;
  @override
  String toString() => 'Pacchetto rifiutato: $message';
}

class PackageVerifier {
  PackageVerifier({String? publicKeyHex}) : _publicKeyHex = publicKeyHex ?? trustedPublicKeyHex;

  final String _publicKeyHex;
  final _ed25519 = Ed25519();

  /// Apre e verifica un archivio .mirabo. Lancia [PackageVerificationException]
  /// se il manifest manca, la firma non è valida o un file non corrisponde.
  Future<VerifiedPackage> open(Uint8List archiveBytes) async {
    final archive = ZipDecoder().decodeBytes(archiveBytes);
    final files = <String, Uint8List>{};
    for (final f in archive.files) {
      if (f.isFile) files[f.name] = Uint8List.fromList(f.content as List<int>);
    }
    final manifestBytes = files.remove('manifest.json');
    if (manifestBytes == null) throw PackageVerificationException('manifest.json assente');
    final manifest = jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;

    final signatureHex = manifest.remove('signature') as String?;
    if (signatureHex == null) throw PackageVerificationException('pacchetto non firmato');
    final ok = await _ed25519.verify(
      utf8.encode(_canonical(manifest)),
      signature: Signature(_hex(signatureHex), publicKey: SimplePublicKey(_hex(_publicKeyHex), type: KeyPairType.ed25519)),
    );
    if (!ok) throw PackageVerificationException('firma non valida');

    final expected = (manifest['files'] as Map<String, dynamic>).cast<String, String>();
    for (final entry in expected.entries) {
      final data = files[entry.key];
      if (data == null) throw PackageVerificationException('file mancante: ${entry.key}');
      if (sha256.convert(data).toString() != entry.value) {
        throw PackageVerificationException('hash diverso per ${entry.key}');
      }
    }
    files.removeWhere((k, _) => !expected.containsKey(k));
    return VerifiedPackage._(
        manifest['id'] as String, (manifest['kind'] as String?) ?? 'story', manifest['version'] as int, files);
  }

  /// JSON canonico identico a quello prodotto da studio/pack.py:
  /// chiavi ordinate ricorsivamente, nessuno spazio, caratteri non ASCII non escapati.
  static String _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      return '{${keys.map((k) => '${jsonEncode(k)}:${_canonical(value[k])}').join(',')}}';
    }
    if (value is List) return '[${value.map(_canonical).join(',')}]';
    return jsonEncode(value);
  }

  static Uint8List _hex(String hex) {
    final out = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }
}
