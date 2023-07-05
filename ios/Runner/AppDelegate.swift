import UIKit
import Flutter
import flutter_background_service_ios // add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      SwiftFlutterBackgroundServicePlugin.taskIdentifier = "your.custom.task.identifier"
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)

    // here, Without this code the task will not work.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
      SwiftFlutterBackgroundServicePlugin.taskIdentifier = "your.custom.task.identifier"

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// here
func registerPlugins(registry: FlutterPluginRegistry) {
  GeneratedPluginRegistrant.register(with: registry)
}
