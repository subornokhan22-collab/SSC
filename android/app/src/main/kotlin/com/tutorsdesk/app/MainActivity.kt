package com.tutorsdesk.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.tutorsdesk.app/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canManageAllFiles" -> {
                        // The permission exists from Android 11 (API 30) up;
                        // on older devices the legacy write path is best-effort.
                        result.success(
                            if (Build.VERSION.SDK_INT >= 30)
                                Environment.isExternalStorageManager()
                            else true
                        )
                    }
                    "requestManageAllFiles" -> {
                        if (Build.VERSION.SDK_INT >= 30 &&
                            !Environment.isExternalStorageManager()
                        ) {
                            try {
                                startActivity(
                                    Intent(
                                        Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                                        Uri.parse("package:$packageName")
                                    )
                                )
                            } catch (e: Exception) {
                                try {
                                    startActivity(
                                        Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                                    )
                                } catch (e2: Exception) {
                                    // Some OEM settings pages are missing both intents.
                                }
                            }
                        }
                        result.success(true)
                    }
                    "externalStorageDir" -> {
                        result.success(Environment.getExternalStorageDirectory().absolutePath)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
