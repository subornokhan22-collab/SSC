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
                    "scannerModuleStatus" -> {
                        // The Google scanner's UI + models live in an
                        // installable Play services "module".
                        // Returns {status, error}: 1 = ready, 0 =
                        // downloadable, -1 = query failed, -2 = the
                        // scanner client could not even be constructed.
                        // error carries the underlying exception so the
                        // app can show exactly what failed.
                        // Errors included: a missing class throws
                        // NoClassDefFoundError (an Error, not Exception).
                        try {
                            val scanner = com.google.mlkit.vision.documentscanner.GmsDocumentScanning
                                .getClient(com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.Builder().build())
                            com.google.android.gms.common.moduleinstall.ModuleInstall.getClient(this)
                                .areModulesAvailable(scanner)
                                .addOnSuccessListener { response ->
                                    result.success(
                                        mapOf(
                                            "status" to (if (response.areModulesAvailable()) 1 else 0),
                                            "error" to null
                                        )
                                    )
                                }
                                .addOnFailureListener { e ->
                                    result.success(mapOf("status" to -1, "error" to e.toString()))
                                }
                        } catch (t: Throwable) {
                            result.success(mapOf("status" to -2, "error" to t.toString()))
                        }
                    }
                    "installScannerModule" -> {
                        // One-time download of the scanner module from
                        // Play services. 1 = downloaded, 0 = already
                        // installed; error if the download fails.
                        try {
                            val scanner = com.google.mlkit.vision.documentscanner.GmsDocumentScanning
                                .getClient(com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.Builder().build())
                            val request = com.google.android.gms.common.moduleinstall.ModuleInstallRequest.newBuilder()
                                .addApi(scanner)
                                .build()
                            com.google.android.gms.common.moduleinstall.ModuleInstall.getClient(this)
                                .installModules(request)
                                .addOnSuccessListener { response ->
                                    result.success(if (response.areModulesAlreadyInstalled()) 0 else 1)
                                }
                                .addOnFailureListener { e ->
                                    result.error("ScannerModuleInstall", e.message ?: "download failed", null)
                                }
                        } catch (t: Throwable) {
                            result.error("ScannerModuleInstall", t.toString(), null)
                        }
                    }
                    "gmsVersion" -> {
                        // Installed Play services version code (0 = no
                        // Play services package at all), for the
                        // diagnostics dialog.
                        try {
                            val info = packageManager.getPackageInfo("com.google.android.gms", 0)
                            // versionCode (not longVersionCode): works on
                            // every API level this app supports.
                            result.success(info.versionCode)
                        } catch (t: Throwable) {
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
                        } catch (e: Throwable) {
                            try {
                                startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.gms")
                                    )
                                )
                            } catch (e2: Throwable) {
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
