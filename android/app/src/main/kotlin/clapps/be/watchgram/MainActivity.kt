package clapps.be.watchgram

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import clapps.be.watchgram.chat.ChatListViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val VIEW_TYPE = "chat_list_view"
        private const val CHANNEL = "clapps.be.watchgram/natives"
    }

    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "Configuring Flutter Engine")
        super.configureFlutterEngine(flutterEngine)
        
        try {
            // Register platform view factory
            Log.d(TAG, "Registering platform view: $VIEW_TYPE")
            val messenger = flutterEngine.dartExecutor.binaryMessenger
            val factory = ChatListViewFactory(messenger)
            
            // Register the factory with the correct view type
            flutterEngine
                .platformViewsController
                .registry
                .registerViewFactory(VIEW_TYPE, factory)
            
            Log.d(TAG, "Successfully registered platform view factory")
            
            // Set up method channel for native functionality
            methodChannel = MethodChannel(messenger, CHANNEL)
            methodChannel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isRoamingEnabled" -> {
                        result.success(isRoamingEnabled())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
            
            Log.d(TAG, "Successfully set up method channel")
        } catch (e: Exception) {
            Log.e(TAG, "Error configuring Flutter Engine", e)
        }
    }

    private fun isRoamingEnabled(): Boolean {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return telephonyManager.isNetworkRoaming
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        super.onDestroy()
    }
}
