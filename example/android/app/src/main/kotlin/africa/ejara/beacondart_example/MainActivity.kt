package africa.ejara.beacondart_example

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    private fun getFlutterView(@NonNull flutterEngine: FlutterEngine): BinaryMessenger {
        return flutterEngine.dartExecutor.binaryMessenger
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        // super.configureFlutterEngine(flutterEngine)
        // flutterEngine.plugins.add(SharedPreferencesPlugin())
        // flutterEngine.plugins.add(PackageInfoPlugin())
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.let { getFlutterView(it) }, "going.native.for.userdata")
                .setMethodCallHandler(callHandler)
    }

    private val callHandler: MethodChannel.MethodCallHandler =
        MethodChannel.MethodCallHandler { call, result ->
            MainActivity.result = result
        }

    companion object {
        private var result: MethodChannel.Result? = null
    }
    
}
