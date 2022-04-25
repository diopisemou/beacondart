package africa.ejara.beacondart

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.os.Bundle
import androidx.lifecycle.asLiveData
import androidx.lifecycle.lifecycleScope
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateAccount
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateNetwork
import it.airgap.beaconsdk.blockchain.substrate.message.request.PermissionSubstrateRequest
import it.airgap.beaconsdk.blockchain.substrate.message.response.PermissionSubstrateResponse
import it.airgap.beaconsdk.blockchain.substrate.substrate
import it.airgap.beaconsdk.blockchain.tezos.data.TezosAccount
import it.airgap.beaconsdk.blockchain.tezos.data.TezosNetwork
import it.airgap.beaconsdk.blockchain.tezos.message.request.PermissionTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.response.PermissionTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.tezos
import it.airgap.beaconsdk.client.wallet.BeaconWalletClient
import it.airgap.beaconsdk.client.wallet.compat.respond
import it.airgap.beaconsdk.core.data.BeaconError
import it.airgap.beaconsdk.core.data.P2pPeer
import it.airgap.beaconsdk.core.message.BeaconRequest
import it.airgap.beaconsdk.core.message.ErrorBeaconResponse
import it.airgap.beaconsdk.transport.p2p.matrix.p2pMatrix
import kotlinx.coroutines.launch

/** BeacondartPlugin */
class BeacondartPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "beacondart")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "addPeer" -> {

      }
      "removePeer" -> {

      }
      "removePeers" -> {

      }
      "getPeers" -> {

      }
      "onBeaconRequest" -> {

      }
      "cancelListening" -> {

      }
      "startBeacon" -> {

      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  lateinit var beaconWallet: BeaconWalletClient

  val dApp = P2pPeer(
    "0b02d44c-de33-b5ab-7730-ff8e62f61869" /* TODO: change me */,
    "My dApp",
    "6c7870aa1e42477fd7c2baaf4763bd826971e470772f71a0a388c1763de3ea1e" /* TODO: change me */,
    "beacon-node-1.sky.papers.tech" /* TODO: change me */,
    "2" /* TODO: change me */,
  )

  fun tezosAccount(network: TezosNetwork, publicKey: String, address: String) = TezosAccount(
    publicKey ,
    address,
    network,
  )

  fun startBeacon(appName: String, publicKey: String, address: String) {

    lifecycleScope.launch {
      createWalletClient()
      subscribeToRequests()
      connectToDApp()
    }
  }

  suspend fun createWalletClient(appName: String) {
    beaconWallet = BeaconWalletClient(appName) {
      support(tezos())
      use(p2pMatrix())
    }
  }

  fun subscribeToRequests() {
    beaconWallet.connect().asLiveData().observe(this) { result ->
      result.getOrNull()?.let { onBeaconRequest(it) }
      result.exceptionOrNull()?.let { onError(it) }
    }
  }

  suspend fun connectToDApp() {
    try {
      beaconWallet.addPeers(dApp)
    } catch (e: Exception) {
      onError(e)
    }
  }
  fun onBeaconRequest(publicKey: String, address: String) {
    fun beaconRequest(request: BeaconRequest) {
      val response = when (request) {
        is PermissionTezosRequest -> PermissionTezosResponse.from(
          request,
          tezosAccount(request.network, publicKey, address)
        )
        else -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
      }

      lifecycleScope.launch {
        try {
          beaconWallet.respond(response)
        } catch (e: Exception) {
          onError(e)
        }
      }
    }

  }

  fun onError(e: Throwable) {
    e.printStackTrace()
  }

}
