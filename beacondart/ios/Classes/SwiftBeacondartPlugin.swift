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
            try
        default:
            result(FlutterMethodNotImplemented)
      }
  }
    
    var beaconWallet: Beacon.WalletClient!

        let dApp = Beacon.P2PPeer(
            id: "0b02d44c-de33-b5ab-7730-ff8e62f61869", /* TODO: change me */
            name: "My dApp",
            publicKey: "6c7870aa1e42477fd7c2baaf4763bd826971e470772f71a0a388c1763de3ea1e", /* TODO: change me */
            relayServer: "beacon-node-1.sky.papers.tech", /* TODO: change me */
            version: "2" /* TODO: change me */
        )

        func substrateAccount(network: Substrate.Network) throws -> Substrate.Account {
            try Substrate.Account(
                publicKey: "f4c6095213a2f6d09464ed882b12d6024d20f7170c3b8bd5c1b071e4b00ced72", /* TODO: change me */
                address: "16XwWkdUqFXFY1tJNf1Q6fGgxQnGYUS6M95wPcrbp2sjjuoC", /* TODO: change me */
                network: network
            )
        }

        func tezosAccount(network: Tezos.Network) throws -> Tezos.Account {
            try Tezos.Network(
                publicKey: "9ae0875d510904b0b15d251d8def1f5f3353e9799841c0ed6d7ac718f04459a0", /* TODO: change me */
                address: "tz1SkbBZg15BXPRkYCrSzhY6rq4tKGtpUSWv", /* TODO: change me */
                network: network
            )
        }

    func startBeacon(appName: String) {
        (createBeaconWallet(appName: <#String#>) { result in
                guard case .success(_) = result else {
                    return
                }

                self.subscribeToRequests { result in
                    guard case .success(_) = result else {
                        return
                    }

                    self.connectToDApp { result in
                        guard case .success(_) = result else {
                            return
                        }
                    }
                }
        })(appName)
        }

    func createBeaconWallet(appName: String, completion: @escaping (Result<(), Error>) -> ()) {
            do {
                Beacon.WalletClient.create(
                    with: .init(
                        name: appName,
                        blockchains: [Substrate.factory, Tezos.factory],
                        connections: [try Transport.P2P.Matrix.connection()]
                    )
                ) { result in
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

        func subscribeToRequests(completion: @escaping (Result<(), Error>) -> ()) {
            beaconWallet.connect { result in
                switch result {
                case .success(_):
                    self.beaconWallet.listen(onRequest: self.onSubstrateRequest)
                    self.beaconWallet.listen(onRequest: self.onTezosRequest)
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        func connectToDApp(completion: @escaping (Result<(), Error>) -> ()) {
            beaconWallet.add([.p2p(dApp)]) { result in
                switch result {
                case .success(_):
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        func onSubstrateRequest(_ request: Result<BeaconRequest<Substrate>, Beacon.Error>) {
            do {
                let request = try request.get()
                let response = try response(from: request)

                beaconWallet.respond(with: response) { result in
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

        func response(from request: BeaconRequest<Substrate>) throws -> BeaconResponse<Substrate> {
            switch request {
            case let .permission(content):
                let accounts = try content.networks.map { try substrateAccount(network: $0) }
                return .permission(PermissionSubstrateResponse(from: content, accounts: accounts))
            case let .blockchain(blockchain):
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }

        func onTezosRequest(_ request: Result<BeaconRequest<Tezos>, Beacon.Error>) {
            do {
                let request = try request.get()
                let response = try response(from: request)

                beaconWallet.respond(with: response) { result in
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

        func response(from request: BeaconRequest<Tezos>) throws -> BeaconResponse<Tezos> {
            switch request {
            case let .permission(content):
                let account = try tezosAccount(network: content.network)
                return .permission(PermissionTezosResponse(from: content, account: account))
            case let .blockchain(blockchain):
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }
}
