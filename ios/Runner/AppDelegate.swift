import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Bildirishnoma hodisalari FlutterAppDelegate orqali ikkala plaginga
    // (firebase_messaging va flutter_local_notifications) taqsimlanadi.
    // Busiz ulardan biri delegatni egallab, ikkinchisi ochiq ilovadagi
    // xabarlarni ko'rmay qoladi.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
