package com.omedacore.notelytask

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val widgetChannel = "com.omedacore.notelytask/widget"

    override fun onNewIntent(intent: Intent) {
        val noteId = intent.getStringExtra("note_id")

        if(!noteId.isNullOrEmpty()) {
            val channel = MethodChannel(
                flutterEngine?.dartExecutor?.binaryMessenger,
                widgetChannel
            )

            channel.invokeMethod(
                "widgetClicked",
                hashMapOf("note_id" to noteId)
            )
        }
        super.onNewIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getIntentArgs" -> {
                        val noteId = intent.getStringExtra("note_id")
                        result.success(hashMapOf("note_id" to noteId))
                    }
                }
            }
    }
}
