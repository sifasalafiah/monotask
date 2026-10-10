package com.sekala.monotask

import java.util.concurrent.CopyOnWriteArraySet

object FocusSessionBridge {
    @Volatile
    var isSessionActive: Boolean = false

    val blacklistedPackages: MutableSet<String> = CopyOnWriteArraySet()

    @Volatile
    var emergencyPassesRemaining: Int = 1

    @Volatile
    var interruptionsCount: Int = 0

    @Volatile
    var shieldedNotificationsCount: Int = 0

    var onAppBlockedCallback: ((String) -> Unit)? = null
    var onNotificationShieldedCallback: ((String) -> Unit)? = null

    fun reset() {
        isSessionActive = false
        blacklistedPackages.clear()
        emergencyPassesRemaining = 1
        interruptionsCount = 0
        shieldedNotificationsCount = 0
    }
}
