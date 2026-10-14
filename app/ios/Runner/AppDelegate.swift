import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeSupportDirectoryFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Politica di backup (docs/privacy/data-inventory.md): il database cifrato e
  /// la voce del nome stanno in Application Support e non vanno nei backup
  /// iCloud/iTunes. La chiave e' nel Keychain "solo questo dispositivo", quindi
  /// una copia non sarebbe leggibile altrove; il backup e' quello scelto dal genitore.
  private func excludeSupportDirectoryFromBackup() {
    guard var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? url.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
