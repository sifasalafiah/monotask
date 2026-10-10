package com.sekala.monotask

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class MonotaskNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null || !FocusSessionBridge.isSessionActive) return

        val packageName = sbn.packageName ?: return

        // Never silence Monotask or essential system services/calls
        if (packageName == applicationContext.packageName || 
            packageName == "android" || 
            packageName == "com.android.server.telecom") {
            return
        }

        val notification = sbn.notification ?: return
        // Don't cancel incoming calls or critical alarms
        val category = notification.category
        if (category == Notification.CATEGORY_CALL || category == Notification.CATEGORY_ALARM) {
            return
        }

        // If package is blacklisted or general notifications are silenced during focus
        if (FocusSessionBridge.blacklistedPackages.contains(packageName)) {
            try {
                // Cancel notification to prevent distraction
                cancelNotification(sbn.key)
                FocusSessionBridge.shieldedNotificationsCount++
                FocusSessionBridge.onNotificationShieldedCallback?.invoke(packageName)
            } catch (e: Exception) {
                // Ignore any security/IPC exceptions
            }
        }
    }
}
