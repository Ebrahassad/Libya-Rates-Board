package com.hassadi.libyaratesboard

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName =
        "com.hassadi.libyaratesboard/device"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openCastSettings" -> {
                    result.success(openCastSettings())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openCastSettings(): Boolean {
        val intents = listOf(
            Intent(Settings.ACTION_CAST_SETTINGS),
            Intent(Settings.ACTION_WIRELESS_DISPLAY_SETTINGS),
            Intent(Settings.ACTION_SETTINGS),
        )

        for (intent in intents) {
            try {
                startActivity(intent)
                return true
            } catch (_: Exception) {
                // Try the next supported settings screen.
            }
        }

        return false
    }
}
