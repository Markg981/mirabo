import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Dove finisce il file di backup. Un'interfaccia sola perché i test usano
/// una versione in memoria al posto di Drive.
abstract class BackupStore {
  /// Accesso con conferma del genitore. Restituisce l'account (es. l'email).
  Future<String> connect();

  /// Accesso senza interfaccia, per il backup automatico. False se serve
  /// di nuovo il consenso del genitore.
  Future<bool> reconnect();

  Future<void> upload(List<int> bytes);

  /// Null se sull'account non c'è ancora un backup.
  Future<List<int>?> download();

  Future<void> deleteRemote();

  Future<void> disconnect();
}

/// Backup nella cartella nascosta dell'app sul Google Drive personale del
/// genitore (appDataFolder): l'app vede solo i propri file, non il resto del
/// Drive, e il genitore lo trova in Drive › Impostazioni › Gestisci app.
///
/// ID client OAuth passati a build time:
///   --dart-define=GOOGLE_SERVER_CLIENT_ID=<id client Web>   (Android)
///   --dart-define=GOOGLE_IOS_CLIENT_ID=<id client iOS>      (iOS)
class DriveStore implements BackupStore {
  static const _scopes = [drive.DriveApi.driveAppdataScope];
  static const _fileName = 'mirabo-backup.json';
  static const _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static Future<void>? _initialized;
  GoogleSignInAccount? _account;

  GoogleSignIn get _gsi => GoogleSignIn.instance;

  Future<void> _init() => _initialized ??= _gsi.initialize(
        clientId: _iosClientId.isEmpty ? null : _iosClientId,
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );

  @override
  Future<String> connect() async {
    await _init();
    final account = await _gsi.authenticate(scopeHint: _scopes);
    // Il permesso su Drive si chiede subito, finché il genitore è lì.
    await account.authorizationClient.authorizeScopes(_scopes);
    _account = account;
    return account.email;
  }

  @override
  Future<bool> reconnect() async {
    await _init();
    try {
      _account ??= await _gsi.attemptLightweightAuthentication();
    } on GoogleSignInException {
      return false;
    }
    final account = _account;
    return account != null && await account.authorizationClient.authorizationForScopes(_scopes) != null;
  }

  /// Se l'accesso è scaduto lo richiede: il backup automatico chiama prima
  /// [reconnect], quindi qui arriva solo con il permesso già valido.
  Future<drive.DriveApi> _api() async {
    if (_account == null && !await reconnect()) await connect();
    final client = _account!.authorizationClient;
    final authz = await client.authorizationForScopes(_scopes) ?? await client.authorizeScopes(_scopes);
    return drive.DriveApi(authz.authClient(scopes: _scopes));
  }

  Future<String?> _fileId(drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_fileName' and trashed = false",
      $fields: 'files(id)',
      pageSize: 1,
    );
    return list.files?.firstOrNull?.id;
  }

  @override
  Future<void> upload(List<int> bytes) async {
    final api = await _api();
    final media = drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/json');
    final id = await _fileId(api);
    if (id == null) {
      await api.files.create(
        drive.File(name: _fileName, parents: ['appDataFolder']),
        uploadMedia: media,
      );
    } else {
      await api.files.update(drive.File(), id, uploadMedia: media);
    }
  }

  @override
  Future<List<int>?> download() async {
    final api = await _api();
    final id = await _fileId(api);
    if (id == null) return null;
    final media = await api.files.get(id, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  @override
  Future<void> deleteRemote() async {
    final api = await _api();
    final id = await _fileId(api);
    if (id != null) await api.files.delete(id);
  }

  @override
  Future<void> disconnect() async {
    await _init();
    _account = null;
    // disconnect revoca anche il permesso concesso all'app, non solo la sessione.
    await _gsi.disconnect();
  }
}
