# beacondart

This project implements tezos beacon (tzip-10) https://docs.walletbeacon.io/ in dart.

This is done using flutter method channels https://docs.flutter.dev/development/platform-integration/platform-channels to link the respective kotlin https://github.com/airgap-it/beacon-android-sdk  and swift https://github.com/airgap-it/beacon-ios-sdk  implementations to dart.

## Scope

The beacon protocol allows dapps on tezos to connect to user wallets. As such, defined in the protocol is a set of actions that the dapp can perform and those that the wallet can perform. This project focuses on the wallet part of the beacon protocol https://docs.walletbeacon.io/wallet/getting-started/web/getting-started .

### Functionalites

Since it implements only the wallet part of the beacon here is a list of functionalities;

- Connect to dApp
    - Qrcode
    - Copy Paste
    - Deep Link

Note that the library itself does not include qrcode, deeplink, etc ... it only takes the input its given from an external lib.
For example you can use a qrcode flutter lib to get the contents of the qrcode and send those params to beacondart.

- Listen for incoming messages from dApp
    - Permission Request/Response
    - SignPayload Request/Response
    - Operation Request/Response
    - Broadcast Request/Response

Note that the library communicates with dart using purely json. 


### Implementation

Ultimately one dart singleton class `BeaconWalletClient` is exposed with the following interface;

```dart
BeaconWalletClient {
    addPeer(Map<String, dynamic> dApp)
    removePeer(Map<String, dynamic> dApp)
    getPeers()
    onBeaconRequest(Callback callback)
    BeaconWalletClient() {
        // create beacon wallet client
        // subscribe to requests
    }

}
```