package com.danield.extrachat

import android.app.Application
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import io.flutter.app.FlutterApplication

class ExteraChatApplication : FlutterApplication() {
    
    override fun onCreate() {
        super.onCreate()
        
        // Register Glance widgets
        GlanceAppWidgetManager.registerGlanceAppWidget<ChatGlanceWidget>()
    }
}
