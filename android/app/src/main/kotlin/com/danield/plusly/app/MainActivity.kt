package com.danield.plusly.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.content.Intent
import android.os.Bundle

import org.unifiedpush.android.connector.UnifiedPush as UpConnector

class MainActivity : FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }
    private fun handleWidgetIntent(intent: Intent) {
        if (intent.action == "com.danield.plusly.app.OPEN_CHAT") {
            val chatId = intent.getStringExtra("chatId")
            if (chatId != null && engine != null) {
                val channel = io.flutter.plugin.common.MethodChannel(engine!!.dartExecutor.binaryMessenger, "com.danield.plusly.app/widget")
                channel.invokeMethod("openChat", chatId)
            }
        }
    }
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return provideEngine(this)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.danield.plusly.app/widget_data").setMethodCallHandler { call, result ->
            when (call.method) {
                "getWidgetDataPath" -> {
                    val path = filesDir.resolve("chat_widget_data.json").absolutePath
                    result.success(path)
                }
                else -> result.notImplemented()
            }
        }
        // Brug naar de UnifiedPush-connector voor een echte "alles wissen"-reset.
        // De Flutter-plugin (unifiedpush_android) stelt alleen `unregister(instance)`
        // bloot, maar dat verwijdert de distributeur NIET zolang er oude
        // wees-instanties in de opslag staan (bijv. de clientName-instanties van
        // vóór de `default`-fix). removeDistributor() wist álle instanties én de
        // opgeslagen distributeur, zodat getDistributor() weer null geeft en het
        // keuzemenu (ntfy / Sunup / ...) opnieuw verschijnt.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.danield.plusly.app/unifiedpush").setMethodCallHandler { call, result ->
            when (call.method) {
                "removeDistributor" -> {
                    try {
                        UpConnector.removeDistributor(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("remove_distributor_failed", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    companion object {
        var engine: FlutterEngine? = null
        fun provideEngine(context: Context): FlutterEngine {
            val eng = engine ?: FlutterEngine(context, emptyArray(), true, false)
            engine = eng
            return eng
        }
    }
}
