import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let defaults = UserDefaults(suiteName: "group.com.sonus")
    defaults?.set("OK_FROM_APP", forKey: "test")
    print("AppGroup write OK")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
