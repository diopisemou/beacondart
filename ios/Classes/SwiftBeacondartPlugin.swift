import Flutter
import UIKit

import BeaconCore
import BeaconBlockchainSubstrate
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

public class SwiftBeacondartPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "beacondart", binaryMessenger: registrar.messenger())
    let instance = SwiftBeacondartPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
        case "addPeer":
            let peerInfo = call.arguments as! [String: String]
            addPeer(peerInfo: peerInfo)
            result(true)
        case "removePeer":
            let peerPublicKey = call.arguments as! String
            removePeer(peerPublicKey: peerPublicKey)
            result(true)
        case "removePeers":
            removePeers()
            result(true)
        case "getPeers":
            let callBackId = call.arguments as! Int
            getPeers{ result in
                
                switch result {
                    case let .success(peers):
                    let resp: [String: Any] = ["id": callBackId, "args": peers]
                        self.channel!.invokeMethod("callListener", arguments: resp);
                    case  .failure(_):
                        return
                }
            }
            result(nil)
        case "onBeaconRequest":
            let callBackId = call.arguments as! Int
            onBeaconRequest { result in
                
                switch result {
                    case let .success(peers):
                        let resp: [String: Any] = ["id": callBackId, "args": peers]
                        self.channel!.invokeMethod("callListener", arguments: resp);
                    case  .failure(_):
                        return
                }
            }
            result(true)
        case "cancelListening": // stop listening for beacon requests
            let callBackId = call.arguments as! Int
            cancelListening(callBackId: callBackId)
            result(true)
        case "startBeacon":
            let args = call.arguments as! [String: Any]
            print(args)
            startBeacon(appName: args["appName"] as! String, publicKey: args["publicKey"] as! String, address: args["address"] as! String, completion: {res in
                print(["startBeacon!", res])
                switch res {
                case  .success(_):
                    let resp: [String: Any] = ["id": args["callBackId"] as! Int, "args": true]
                    print(resp)
                    self.channel!.invokeMethod("callListener", arguments: resp)
                case let .failure(error):
                    print(error)
                    return
                }
            })
            result(true)
        default:
            result(FlutterMethodNotImplemented)
      }
  }
    
    var beaconWallet: Beacon.WalletClient!
    
    var callbacksById: [Int: () -> Void] = [:]
    
    var channel: FlutterMethodChannel?
        
    func addPeer(peerInfo: [String: String]) {
        let peer = Beacon.P2PPeer(
            id: peerInfo["id"]!,
            name: peerInfo["name"]!,
            publicKey: peerInfo["publicKey"]!,
            relayServer: peerInfo["relayServer"]!,
            version: peerInfo["version"]!
        )
        beaconWallet.add([.p2p(peer)]) { _ in }
    }
    
    func removePeer(peerPublicKey: String) {
        beaconWallet.removePeer(withPublicKey: peerPublicKey) { _ in }
    }
    
    func removePeers() {
        beaconWallet.removeAllPeers { _ in }
    }
    
    func getPeers(completion: @escaping (Result<String, Error>) -> ()) {
        beaconWallet.getPeers{ result in
            switch result {
            case let .success(peers):
                completion(.success(self.objToJson(from: peers)!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func substrateAccount(network: Substrate.Network, publicKey: String, address: String) throws -> Substrate.Account {
        try Substrate.Account(
            publicKey: publicKey,
            address: address,
            network: network
        )
    }

    func tezosAccount(network: Tezos.Network, publicKey: String, address: String) throws -> Tezos.Account {
        try Tezos.Account(
            publicKey: publicKey,
            address: address,
            network: network
        )
    }

    func startBeacon(appName: String, publicKey: String, address: String, completion: @escaping (Result<(), Error>) -> ()) {
        print("startBeacon")
        createBeaconWallet(appName: appName, completion: { result in
            print(["createBeaconWallet!",result])
                guard case .success(_) = result else {
                    return
                }
                switch result {
                case  .success(_):
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }

                self.subscribeToRequests(publicKey: publicKey, address: address, completion:  { result in
                    print(["subscribeToRequests!",result])
                    guard case .success(_) = result else {
                        return
                    }
                    switch result {
                    case  .success(_):
                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                })
        })
    }

    func createBeaconWallet(appName: String, completion: @escaping (Result<(), Error>) -> ()) {
        print("createBeaconWallet")
        do {
            Beacon.WalletClient.create(
                with: .init(
                    name: appName,
                    blockchains: [Tezos.factory],
                    connections: [try Transport.P2P.Matrix.connection()]
                )
            ) { result in
                print(["createBeaconWallet",result])
                switch result {
                case let .success(client):
                    self.beaconWallet = client
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func subscribeToRequests(publicKey: String, address: String, completion: @escaping (Result<(), Error>) -> ()) {
        print("subscribeToRequests")
        beaconWallet.connect { result in
            print(["subscribeToRequests",result])
            switch result {
            case .success(_):
                self.beaconWallet.listen(onRequest: self.onTezosRequest(publicKey: publicKey, address: address))
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func onTezosRequest(publicKey: String, address: String) -> ((Result<BeaconRequest<Tezos>, Beacon.Error>) -> Void){
        return { (_ request: Result<BeaconRequest<Tezos>, Beacon.Error>) in
            do {
                let request = try request.get()
                let response = try self.response(from: request, publicKey: publicKey, address: address)

                self.beaconWallet.respond(with: response) { result in
                    switch result {
                    case .success(_):
                        print("Response sent")
                    case let .failure(error):
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    func response(from request: BeaconRequest<Tezos>, publicKey: String, address: String) throws -> BeaconResponse<Tezos> {
        switch request {
        case let .permission(content):
            let account = try tezosAccount(network: content.network, publicKey: publicKey, address: address)
            return .permission(PermissionTezosResponse(from: content, account: account))
        case let .blockchain(blockchain):
            return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
        }
    }
    
    func onBeaconRequest(completion: @escaping (Result<(), Error>) -> ()) {
        
    }
    
    func cancelListening(callBackId: Int) {
        callbacksById.removeValue(forKey: callBackId)
    }
    
    func objToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
