package com.sekala.monotask

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class MonotaskAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || !FocusSessionBridge.isSessionActive) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Ignore own package, launchers/home screen, and system UI
            if (packageName == applicationContext.packageName || 
                packageName == "com.android.systemui" || 
                packageName.contains("launcher", ignoreCase = true)) {
                return
            }

            if (FocusSessionBridge.blacklistedPackages.contains(packageName)) {
                FocusSessionBridge.interruptionsCount++
                FocusSessionBridge.onAppBlockedCallback?.invoke(packageName)

                // Redirect user back to Monotask focus screen
                val intent = Intent(applicationContext, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or 
                            Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra("BLOCKED_APP_TRIGGERED", packageName)
                }
                startActivity(intent)
            }
        }
    }

    override fun onInterrupt() {
        // Handle accessibility interruption
    }
}
