package com.danield.extrachat

import androidx.glance.appwidget.GlanceAppWidgetReceiver

class ChatGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = ChatGlanceWidget()
}
