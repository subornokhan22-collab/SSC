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
                    "playServicesVersion" -> {
                        // 1 = Google Play services present, 0 = missing or
                        // out of date (the ML Kit scanner runs inside it
                        // and NPEs without it). The status code 0 is the
                        // stable "available" value in Google's contract;
                        // the named constants were removed from newer
                        // play-services-base releases, so compare with 0.
                        try {
                            val gms = com.google.android.gms.common.GoogleApiAvailability.getInstance()
                            val status = gms.isGooglePlayServicesAvailable(this)
                            result.success(if (status == 0) 1 else 0)
                        } catch (e: Exception) {
                            result.success(0)
                        }
                    }
                    "openPlayServices" -> {
                        // Deep-link to the Play services entry in the
                        // Play Store (browser fallback if no store app).
                        try {
                            startActivity(
                                Intent(
                                    Intent.ACTION_VIEW,
                                    Uri.parse("market://details?id=com.google.android.gms")
                                )
                            )
                        } catch (e: Exception) {
                            try {
                                startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.gms")
                                    )
                                )
                            } catch (e2: Exception) {
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
