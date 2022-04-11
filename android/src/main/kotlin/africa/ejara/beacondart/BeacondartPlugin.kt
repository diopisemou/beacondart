package africa.ejara.beacondart

import africa.ejara.beacondart.utils.toJson
import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.lifecycle.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import it.airgap.beaconsdk.blockchain.substrate.message.request.PermissionSubstrateRequest
import it.airgap.beaconsdk.blockchain.substrate.message.response.PermissionSubstrateResponse
import it.airgap.beaconsdk.blockchain.tezos.data.TezosError
import it.airgap.beaconsdk.blockchain.tezos.extension.from
import it.airgap.beaconsdk.blockchain.tezos.message.request.BroadcastTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.OperationTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.PermissionTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.SignPayloadTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.response.BroadcastTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.message.response.OperationTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.message.response.PermissionTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.message.response.SignPayloadTezosResponse
import it.airgap.beaconsdk.core.data.BeaconError
import it.airgap.beaconsdk.core.data.SigningType
import it.airgap.beaconsdk.core.internal.utils.logInfo
import it.airgap.beaconsdk.core.message.BeaconRequest
import it.airgap.beaconsdk.core.message.ErrorBeaconResponse
import kotlin.reflect.KMutableProperty
import kotlinx.coroutines.launch
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/** BeacondartPlugin */
// @OptIn(ExperimentalSerializationApi::class)
class BeacondartPlugin :
    MethodCallHandler,
    PluginRegistry.ActivityResultListener,
    EventChannel.StreamHandler,
    FlutterPlugin,
    ActivityAware,
    ViewModelStore(),
    LifecycleOwner {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private val CHANNEL: String = "beacondart"
  private val CHANNEL_EVENT: String = "beacondart_receiver"
  // private val CHANNEL_REQ_EVENT: String = "beacondart_request_receiver"
  // private val CHANNEL_RESP_EVENT: String = "beacondart_response_receiver"
  private lateinit var channel: MethodChannel

  // private val viewModel by viewModels<BeacondartViewModel>()
  private lateinit var viewModel: BeacondartViewModel
  private lateinit var viewModelFactory: BeaconFactory
  private val json: Json by lazy { Json { prettyPrint = true } }

  private var pendingResult: Result? = null
  private var arguments: Map<String, Any>? = null

  private val TAG: String = BeacondartPlugin::class.java.getSimpleName()

  private var beaconOperationStream: EventSink? = null

  private var eventChannel: EventChannel? = null
  // private var eventReqChannel: EventChannel? = null
  // private var eventRespChannel: EventChannel? = null

  /**
   * V2 embedding
   *
   * @param activity
   * @param registrar
   */
  private var pluginBinding: FlutterPluginBinding? = null
  private var activityBinding: ActivityPluginBinding? = null
  private var applicationContext: Application? = null

  // This is null when not using v2 embedding;
  private var lifecycle: Lifecycle? = null
  private var observer: LifeCycleObserver? = null
  // kotlin("android.extensions")

  private fun BeacondartPlugin(activity: FlutterActivity, registrar: Registrar) {
    BeacondartPlugin.activity = activity
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
    viewModelFactory = BeaconFactory()
    viewModel = ViewModelProvider(this, viewModelFactory).get(BeacondartViewModel::class.java)
    pluginBinding = flutterPluginBinding

    if (applicationContext != null && pluginBinding != null) {
      createPluginSetup(
          pluginBinding!!.binaryMessenger,
          pluginBinding!!.applicationContext as Application,
          activityBinding!!.getActivity(),
          null,
          activityBinding!!
      )
    } else {
      eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, CHANNEL_EVENT)
      eventChannel!!.setStreamHandler(this)
//      eventReqChannel = EventChannel(flutterPluginBinding.binaryMessenger, CHANNEL_REQ_EVENT)
//      eventRespChannel = EventChannel(flutterPluginBinding.binaryMessenger, CHANNEL_RESP_EVENT)
//      eventReqChannel!!.setStreamHandler(this)
//      eventRespChannel!!.setStreamHandler(this)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    pendingResult = result
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "onInit" -> {
        try {
          viewModel.onInit().runCatching {}
          result.success("beacon Created ${viewModel.beaconClient}")
          //          BeacondartViewModel.tezosAccount(
          //            "edpkvL3FNBYHdDohfVu6XdtHiRGxmzymR7bKo4J1dAeAs23V8PkkKu",
          //            "tz1ajkyd4hg6gExtVHBUAD269T9VpxfR74om",
          //            null,
          //          )
        } catch (e: Exception) {
          result.error("exception", e.message, e.stackTrace)
          // onError(e)
        }
      }
      "addPeer" -> {
        try {
          val peer = call.arguments as Map<String, Any>

          val id: String? = call.argument("id")
          val name: String? = call.argument("name")
          val publicKey: String? = call.argument("publicKey")
          val relayServer: String? = call.argument("relayServer")
          val version: String? = call.argument("version")

          if (id != null &&
                  name != null &&
                  publicKey != null &&
                  relayServer != null &&
                  version != null
          ) {
            viewModel.addPeer(id, name, publicKey, relayServer, version)
            result.success("Peer Successfully added ${android.os.Build.VERSION.RELEASE}")
          } else {
            result.error("error", "Please set id, name, publicKey, relayServer and version", null)
            return
          }
        } catch (e: Exception) {
          result.error("exception", e.message, e.stackTrace)
          // onError(e)
        }
      }
      "removePeer" -> {
        try {

          val id: String? = call.argument("id")
          if (id != null) {
            viewModel.removePeer(id)
          } else {
            result.error("error", "Please set id", null)
            return
          }
          result.success("peer removed $id")
        } catch (e: Exception) {
          result.error("exception", e.message, e.stackTrace)
          // onError(e)
        }
      }
      "removePeers" -> {
        try {
          viewModel.removePeers()
          result.success("all peers removed")
        } catch (e: Exception) {
          result.error("exception", e.message, e.stackTrace)
          // onError(e)
        }
      }
      "onConnectToDApp" -> {
        try {
          viewModel.onInit()
          viewModel.beginBeacon().observe(this) { result ->
            result.getOrNull()?.let { onBeaconRequest(it)  }
            result.exceptionOrNull()?.let { onError(it) }
          }
        } catch (e: Exception) {
          // result.error("exception", e.message, e.stackTrace)
          onError(e)
        }
      }
      "onConfirmConnectToDApp" -> {
        try {
          viewModel.beginBeacon().observe(this) { result ->
            result.getOrNull()?.let { onAcceptBeaconRequest(it) /*onBeaconRequest(it)*/ }
            result.exceptionOrNull()?.let { onError(it) }
          }
        } catch (e: Exception) {

          onError(e)
        }
      }"onRejectConnectToDApp" -> {
        try {
          viewModel.beginBeacon().observe(this) { result ->
            result.getOrNull()?.let { onRejectBeaconRequest(it) }
            result.exceptionOrNull()?.let { onError(it) }
          }
        } catch (e: Exception) {

          onError(e)
        }
      }
      "onSubscribeToRequest" -> {
        try {
          if (viewModel.beaconClient != null) {
            this.subscribeToRequests()
            result.success("subscribe to all request")
          } else {
            viewModel.onInit()

            viewModel.beaconClient?.connect()?.asLiveData()?.observe(this) { result ->
              result.getOrNull()?.let { onBeaconRequest(it) }
              result.exceptionOrNull()?.let { onError(it) }
            }

            viewModel.beginBeacon().observe(this) { result ->
              result.getOrNull()?.let { onBeaconRequest(it) }
              result.exceptionOrNull()?.let { onError(it) }
            }

            if (viewModel.beaconClient == null) {
              result.error("Error subscription", "beacon client is null", null)
            }
          }
        } catch (e: Exception) {
          // result.error("exception", e.message, e.stackTrace)
          onError(e)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    pluginBinding = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  /**
   * Setup method Created after Embedding V2 API release
   *
   * @param messenger
   * @param applicationContext
   * @param activity
   * @param registrar
   * @param activityBinding
   */
  private fun createPluginSetup(
      messenger: BinaryMessenger,
      applicationContext: Application,
      activity: Activity,
      registrar: Registrar?,
      activityBinding: ActivityPluginBinding?
  ) {

    if (activity is KMutableProperty<*>) {
      activity.setter.call(this, activity as FlutterActivity)
    }

    // activity = activity as FlutterActivity
    eventChannel = EventChannel(messenger, CHANNEL_EVENT)
    eventChannel!!.setStreamHandler(this)
    //eventReqChannel = EventChannel(messenger, CHANNEL_REQ_EVENT)
    //eventRespChannel = EventChannel(messenger, CHANNEL_RESP_EVENT)
    //eventReqChannel!!.setStreamHandler(this)
    //eventRespChannel!!.setStreamHandler(this)
    this.applicationContext = applicationContext
    channel = MethodChannel(messenger, CHANNEL)
    channel.setMethodCallHandler(this)
    if (registrar != null) {
      // V1 embedding setup for activity listeners.
      observer = LifeCycleObserver(activity)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
        applicationContext.registerActivityLifecycleCallbacks(observer)
      } // Use getApplicationContext() to avoid casting failures.
      registrar.addActivityResultListener(this)
    } else {
      // V2 embedding setup for activity listeners.
      activityBinding?.addActivityResultListener(this)
      lifecycle = activityBinding?.let { FlutterLifecycleAdapter.getActivityLifecycle(it) }
      observer = LifeCycleObserver(activity)
      lifecycle!!.addObserver(observer!!)
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    createPluginSetup(
        pluginBinding!!.binaryMessenger,
        pluginBinding!!.applicationContext as Application,
        activityBinding!!.getActivity(),
        null,
        activityBinding!!
    )
  }

  override fun onDetachedFromActivity() {
    clearPluginSetup()
  }

  /** Clear plugin setup */
  private fun clearPluginSetup() {
    activity = null
    activityBinding!!.removeActivityResultListener(this)
    activityBinding = null
    lifecycle!!.removeObserver(observer!!)
    lifecycle = null
    channel.setMethodCallHandler(null)
    eventChannel!!.setStreamHandler(null)
    //eventReqChannel!!.setStreamHandler(null)
    //eventRespChannel!!.setStreamHandler(null)
    channel = MethodChannel(null, "")
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
      applicationContext!!.unregisterActivityLifecycleCallbacks(observer)
    }
    applicationContext = null
  }

  // private fun onBeaconRequest(beaconRequest: BeaconRequest) {
  //     messageTextView.text = json.encodeToString(beaconRequest.toJson(json))
  // }

  private fun onBeaconRequest(request: BeaconRequest) {
    val jsonReq = json.encodeToString(request.toJson(json))

    logInfo("beaconRequest", jsonReq)

    // this.lifecycleScope.launch {
    viewModel.viewModelScope.launch {
      try {

        beaconOperationStream?.success(jsonReq)
      } catch (e: Exception) {
        // pendingResult?.error("error ", "Stream error", e)
        onError(e)
      }
    }
  }

  private fun onAcceptBeaconRequest(request: BeaconRequest) {
    val jsonReq = json.encodeToString(request.toJson(json))

    val response =
        when (request) {
          is PermissionSubstrateRequest ->
              PermissionSubstrateResponse.from(
                  request,
                  request.networks.map { BeacondartViewModel.exampleSubstrateAccount(it) }
              )
          is PermissionTezosRequest ->
              PermissionTezosResponse.from( request, BeacondartViewModel.exampleTezosAccount(request.network))
          is OperationTezosRequest -> OperationTezosResponse.from(request, "")
          is SignPayloadTezosRequest -> SignPayloadTezosResponse.from(request, SigningType.Raw, "")
          is BroadcastTezosRequest -> BroadcastTezosResponse.from(request, "")
          else -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
        }

    logInfo("beaconAccepptRequest", jsonReq)
    logInfo("beaconAcceptReponse", response.toJson().toString())

    // this.lifecycleScope.launch {
    viewModel.viewModelScope.launch {
      try {
        // activity!!.runOnUiThread { beaconOperationStream!!.success(response) }

        viewModel.beaconClient?.respond(response)
        // pendingResult?.success(response)
        beaconOperationStream?.success(json.encodeToString(response.toJson(json)))
      } catch (e: Exception) {
        // pendingResult?.error("error ", "Stream error", e)
        onError(e)
      }
    }
  }

  private fun onRejectBeaconRequest(request: BeaconRequest) {
    val jsonReq = json.encodeToString(request.toJson(json))

    val response =
        when (request) {
          is PermissionSubstrateRequest -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
          is PermissionTezosRequest -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
          is OperationTezosRequest -> ErrorBeaconResponse.from(request, TezosError.TransactionInvalid)
          is SignPayloadTezosRequest -> ErrorBeaconResponse.from(request, TezosError.SignatureTypeNotSupported)
          is BroadcastTezosRequest -> ErrorBeaconResponse.from(request, TezosError.BroadcastError)
          else -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
        }

    logInfo("beaconRejectRequest", jsonReq)
    logInfo("beaconRejectReponse", response.toJson().toString())

    // this.lifecycleScope.launch {
    viewModel.viewModelScope.launch {
      try {
        // activity!!.runOnUiThread { beaconOperationStream!!.success(response) }

        viewModel.beaconClient?.respond(response)
        // pendingResult?.success(response)
        beaconOperationStream?.error("Error ", "", json.encodeToString(response.toJson(json)))
      } catch (e: Exception) {
        // pendingResult?.error("error ", "Stream error", e)
        onError(e)
      }
    }
  }

  private fun subscribeToRequests() {
    if (viewModel.beaconClient != null) {
      viewModel.beaconClient?.connect()?.asLiveData()?.observe(this) { result ->
        result.getOrNull()?.let { onBeaconRequest(it) }
        result.exceptionOrNull()?.let { onError(it) }
      }
    }
  }

  private fun onError(exception: Throwable) {
    exception.printStackTrace()
    // pendingResult?.error("error", exception.message, null)
  }

  data class State(
      val hasPeers: Boolean = false,
      val hasAwaitingRequest: Boolean = false,
  )

  data class PeerInput(
      val id: String,
      val name: String,
      val publicKey: String,
      val relayServer: String,
      val version: String
  )

  companion object {
    private var activity: FlutterActivity? = null
  }

  //  override fun getViewModelStore(): ViewModelStore {
  //    return this.viewModelStore
  //  }

  /** Activity lifecycle observer */
  @SuppressLint("NewApi")
  private class LifeCycleObserver(activity: Activity) :
      Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    private val thisActivity: Activity = activity
    override fun onCreate(owner: LifecycleOwner) {}
    override fun onStart(owner: LifecycleOwner) {}
    override fun onResume(owner: LifecycleOwner) {}
    override fun onPause(owner: LifecycleOwner) {}
    override fun onStop(owner: LifecycleOwner) {
      onActivityStopped(thisActivity)
    }

    override fun onDestroy(owner: LifecycleOwner) {
      onActivityDestroyed(thisActivity)
    }

    override fun onActivityCreated(p0: Activity, p1: Bundle?) {}

    override fun onActivityStarted(p0: Activity) {}

    override fun onActivityResumed(p0: Activity) {}

    override fun onActivityPaused(p0: Activity) {}

    override fun onActivityStopped(p0: Activity) {}

    override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {}

    override fun onActivityDestroyed(p0: Activity) {
      if (thisActivity === p0 && p0.getApplicationContext() != null) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
          (p0.getApplicationContext() as Application).unregisterActivityLifecycleCallbacks(this)
        }
      }
    }
  }

  /**
   * Get the barcode scanning results in onActivityResult
   *
   * @param requestCode
   * @param resultCode
   * @param data
   * @return
   */
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

    return true
  }

  override fun onListen(o: Any?, eventSink: EventSink) {
    try {
      beaconOperationStream = eventSink
    } catch (e: Exception) {}
  }

  override fun onCancel(o: Any?) {
    try {
      beaconOperationStream = null
    } catch (e: Exception) {}
  }

  override fun getLifecycle(): Lifecycle {
    return this.lifecycle!!
  }
}
