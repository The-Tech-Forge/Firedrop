package com.example.shareapp

import android.content.Context
import android.net.wifi.WifiManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "hotspot_control"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isHotspotOn") {
                result.success(isHotspotOn())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isHotspotOn(): Boolean {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        return try {
            val method = wifiManager.javaClass.getMethod("getWifiApState")
            val hotspotState = method.invoke(wifiManager) as Int
            hotspotState == 13 // 13 corresponds to WifiManager.WIFI_AP_STATE_ENABLED
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

