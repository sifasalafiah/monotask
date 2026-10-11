package com.sekala.monotask

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.view.WindowManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import androidx.annotation.NonNull
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sekala.monotask/blocker"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityPermissionGranted" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isNotificationListenerGranted" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isUsageStatsPermissionGranted" -> {
                    result.success(isUsageStatsPermissionGranted())
                }
                "openUsageStatsSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isOverlayPermissionGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                "startFocusSession" -> {
                    val blacklist = call.argument<List<String>>("blacklist") ?: emptyList()
                    val emergencyPasses = call.argument<Int>("emergencyPasses") ?: 1
                    
                    runOnUiThread {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }

                    FocusSessionBridge.reset()
                    FocusSessionBridge.isSessionActive = true
                    FocusSessionBridge.blacklistedPackages.addAll(blacklist)
                    FocusSessionBridge.emergencyPassesRemaining = emergencyPasses
                    result.success(true)
                }
                "stopFocusSession" -> {
                    runOnUiThread {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    val interruptions = FocusSessionBridge.interruptionsCount
                    val shielded = FocusSessionBridge.shieldedNotificationsCount
                    FocusSessionBridge.reset()
                    result.success(mapOf(
                        "interruptions" to interruptions,
                        "shieldedNotifications" to shielded
                    ))
                }
                "setKeepScreenOn" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                    }
                    result.success(true)
                }
                "updateBlacklist" -> {
                    val blacklist = call.argument<List<String>>("blacklist") ?: emptyList()
                    FocusSessionBridge.blacklistedPackages.clear()
                    FocusSessionBridge.blacklistedPackages.addAll(blacklist)
                    result.success(true)
                }
                "getInterruptionStats" -> {
                    result.success(mapOf(
                        "interruptions" to FocusSessionBridge.interruptionsCount,
                        "shieldedNotifications" to FocusSessionBridge.shieldedNotificationsCount
                    ))
                }
                "getAppVersion" -> {
                    try {
                        val pInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
                        } else {
                            @Suppress("DEPRECATION")
                            packageManager.getPackageInfo(packageName, 0)
                        }
                        val vName = pInfo.versionName ?: "0.1.0"
                        val vCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            pInfo.longVersionCode
                        } else {
                            @Suppress("DEPRECATION")
                            pInfo.versionCode.toLong()
                        }
                        result.success("$vName+$vCode")
                    } catch (e: Exception) {
                        result.success("0.1.0+1")
                    }
                }
                "getAppIcon" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg != null) {
                        try {
                            val drawable = packageManager.getApplicationIcon(pkg)
                            result.success(drawableToByteArray(drawable))
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        FocusSessionBridge.onAppBlockedCallback = { blockedPackage ->
            runOnUiThread {
                methodChannel?.invokeMethod("onAppBlocked", mapOf("packageName" to blockedPackage))
            }
        }

        FocusSessionBridge.onNotificationShieldedCallback = { pkg ->
            runOnUiThread {
                methodChannel?.invokeMethod("onNotificationShielded", mapOf("packageName" to pkg))
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedServiceName = "$packageName/${MonotaskAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabledServices.contains(packageName)
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val listeners = NotificationManagerCompat.getEnabledListenerPackages(this)
        return listeners.contains(packageName)
    }

    private fun isUsageStatsPermissionGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0L))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(mainIntent, 0)
        }

        val appList = mutableListOf<Map<String, String>>()
        for (info in resolveInfos) {
            val pkg = info.activityInfo.packageName
            if (pkg != packageName) {
                val label = info.loadLabel(pm).toString()
                appList.add(mapOf("packageName" to pkg, "appName" to label))
            }
        }
        return appList.sortedBy { it["appName"]?.lowercase() }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        return try {
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth.coerceAtMost(144) else 96
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight.coerceAtMost(144) else 96
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            val bytes = stream.toByteArray()
            bitmap.recycle()
            bytes
        } catch (e: Exception) {
            null
        }
    }
}

