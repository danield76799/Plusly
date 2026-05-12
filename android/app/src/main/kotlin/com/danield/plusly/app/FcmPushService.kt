package com.danield.plusly.app

import com.famedly.fcm_shared_isolate.FcmSharedIsolateService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import android.content.Context

class FcmPushService : FcmSharedIsolateService() {
    override fun getEngine(): FlutterEngine = provideEngine(getApplicationContext())
    companion object {
        fun provideEngine(context: Context): FlutterEngine {
            var engine = MainActivity.engine
            if (engine == null) {
                engine = MainActivity.provideEngine(context)
                engine.getLocalizationPlugin().sendLocalesToFlutter(context.getResources().getConfiguration())
                engine.getDartExecutor().executeDartEntrypoint(DartEntrypoint.createDefault())
            }
            return engine
        }
    }
}
