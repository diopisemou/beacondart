import Flutter
import UIKit

public class SwiftBeacondartPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "beacondart", binaryMessenger: registrar.messenger())
    let instance = SwiftBeacondartPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
        case "addPeer":
            result("iOS " + UIDevice.current.systemVersion)
        case "removePeer":
            result("iOS " + UIDevice.current.systemVersion)
        case "getPeers":
            result("iOS " + UIDevice.current.systemVersion)
        case "onBeaconRequest":
            result("iOS " + UIDevice.current.systemVersion)
        case "startBeacon":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
      }
  }
}
