package com.danield.plusly.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ChatWidgetBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            ChatWidgetProvider.scheduleNextUpdate(context)
        }
    }
}
