package com.danield.extrachat

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import org.json.JSONArray
import java.io.File

class ChatWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            Companion.updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget is added for the first time
    }

    override fun onDisabled(context: Context) {
        // Widget is removed
    }

    companion object {
        private const val CHAT_DATA_FILE = "chat_widget_data.json"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.extrachat_widget)
            views.setTextViewText(R.id.widget_header, "Chats")
            
            // Try to read real chat data from file
            val chatData = readChatData(context)
            
            if (chatData.isNotEmpty()) {
                // Update with real data
                for (i in chatData.indices) {
                    if (i >= 4) break // Max 4 rows
                    val chat = chatData[i]
                    val nameId = when (i) {
                        0 -> R.id.chat_name_1
                        1 -> R.id.chat_name_2
                        2 -> R.id.chat_name_3
                        3 -> R.id.chat_name_4
                        else -> 0
                    }
                    val messageId = when (i) {
                        0 -> R.id.chat_message_1
                        1 -> R.id.chat_message_2
                        2 -> R.id.chat_message_3
                        3 -> R.id.chat_message_4
                        else -> 0
                    }
                    if (nameId != 0) {
                        views.setTextViewText(nameId, chat.first)
                        views.setTextViewText(messageId, chat.second)
                    }
                }
            } else {
                // Fallback to test data if no real data
                views.setTextViewText(R.id.chat_name_1, "Alice")
                views.setTextViewText(R.id.chat_message_1, "Hey, how are you?")
                views.setTextViewText(R.id.chat_name_2, "Bob")
                views.setTextViewText(R.id.chat_message_2, "See you tomorrow!")
                views.setTextViewText(R.id.chat_name_3, "Charlie")
                views.setTextViewText(R.id.chat_message_3, "Thanks for the help")
                views.setTextViewText(R.id.chat_name_4, "Diana")
                views.setTextViewText(R.id.chat_message_4, "Meeting at 3pm")
            }
            
            // Make entire widget clickable to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun readChatData(context: Context): List<Pair<String, String>> {
            return try {
                val file = File(context.filesDir, CHAT_DATA_FILE)
                if (!file.exists()) return emptyList()
                
                val json = file.readText()
                val jsonArray = JSONArray(json)
                val result = mutableListOf<Pair<String, String>>()
                
                for (i in 0 until jsonArray.length()) {
                    val chat = jsonArray.getJSONObject(i)
                    val name = chat.optString("name", "")
                    val message = chat.optString("lastMessage", "")
                    if (name.isNotEmpty()) {
                        result.add(Pair(name, message))
                    }
                }
                result
            } catch (e: Exception) {
                emptyList()
            }
        }
    }
}
