import Flutter
import UIKit
import FirebaseCore
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
     GMSServices.provideAPIKey("AIzaSyDC4-m-JhlRNy139DOrjoo5MEfXkIch-oc")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
