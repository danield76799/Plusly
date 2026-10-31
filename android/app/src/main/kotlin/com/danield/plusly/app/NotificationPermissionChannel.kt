package com.danield.plusly.app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Leest of Android het scherm mag aanzetten voor een volledig schermmelding
 * (full-screen intent) en opent de bijbehorende systeeminstelling.
 *
 * Vanaf Android 14 is USE_FULL_SCREEN_INTENT voor bericht-apps standaard
 * UIT: het systeem geeft de toestemming niet automatisch, de gebruiker moet
 * 'Volledige schermmeldingen' aanzetten in de app-instellingen. Zonder die
 * toestemming licht het scherm niet op bij een nieuwe melding.
 */
object NotificationPermissionChannel {
    const val CHANNEL = "com.danield.plusly.app/notification_permission"

    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent(context))
                "openFullScreenIntentSettings" -> {
                    openSettings(context)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Onder Android 14 is de toestemming automatisch gegeven. */
    fun canUseFullScreenIntent(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return false
        return manager.canUseFullScreenIntent()
    }

    /** Open de schermmelding-instellingen van deze app. */
    fun openSettings(context: Context) {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
                .setData(Uri.parse("package:" + context.packageName))
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.parse("package:" + context.packageName))
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}
