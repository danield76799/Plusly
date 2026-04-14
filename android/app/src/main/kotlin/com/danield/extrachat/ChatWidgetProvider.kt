package com.danield.extrachat

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.view.View

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
        private const val MAX_CHARS = 40
        private const val MAX_CHATS = 4

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.chat_widget)
            
            // Show test data - 4 chats
            val testChats = listOf(
                Pair("Chat 1", "Last message here"),
                Pair("Chat 2", "Last message here"),
                Pair("Chat 3", "Last message here"),
                Pair("Chat 4", "Last message here")
            )
            
            for ((i, chat) in testChats.withIndex()) {
                val rowId = getChatRowId(i + 1)
                views.setViewVisibility(rowId, View.VISIBLE)
                views.setTextViewText(getNameId(i + 1), chat.first)
                views.setTextViewText(getMessageId(i + 1), chat.second)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getChatRowId(index: Int): Int {
            return when (index) {
                1 -> R.id.chat_row_1
                2 -> R.id.chat_row_2
                3 -> R.id.chat_row_3
                4 -> R.id.chat_row_4
                else -> 0
            }
        }

        private fun getNameId(index: Int): Int {
            return when (index) {
                1 -> R.id.chat_name_1
                2 -> R.id.chat_name_2
                3 -> R.id.chat_name_3
                4 -> R.id.chat_name_4
                else -> 0
            }
        }

        private fun getMessageId(index: Int): Int {
            return when (index) {
                1 -> R.id.chat_message_1
                2 -> R.id.chat_message_2
                3 -> R.id.chat_message_3
                4 -> R.id.chat_message_4
                else -> 0
            }
        }
    }
}
