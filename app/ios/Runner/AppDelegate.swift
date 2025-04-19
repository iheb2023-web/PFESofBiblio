import Flutter
import UIKit

//je ajouter ce import la 
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

     //je ajouter les deux lignes suivantes
    flutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
  GeneratedPluginRegistrant.register(with: registry)
}

    GeneratedPluginRegistrant.register(with: self)

    //je ajouter ce code la
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()
      center.delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
