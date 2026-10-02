package com.danield.plusly.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.unifiedpush.android.connector.UnifiedPush as UpConnector

/**
 * Vernieuwt periodiek de UnifiedPush-registratie (elk ~6 uur).
 *
 * WAAROM. Gemeten op Android 17 bèta (caiman_beta, 2026-09/10): het
 * push-kanaal van de distributeur (Sunup #75, ntfy zelfde klasse) valt na
 * enkele uren stilletjes stil — verbinding weg, geen reconnect, geen
 * onNewEndpoint, geen push tot de gebruiker handmatig herregistreert.
 * Sunup heeft dit gefixt in 1.2.3 (netwerk-callback die VPN's uitsloot),
 * maar de bèta dooft kanaal óók zonder VPN: procesdiefstal op het niveau
 * van de distributeur.
 *
 * Een periodieke register() van de app zelf dwingt bij elke poging een
 * verse NEW_ENDPOINT af. Is de koppeling nog intact, dan is dit een no-op
 * (distributor geeft hetzelfde endpoint; onNewEndpoint triggert een
 * idempotente pusher-check). Is hij doodgevallen, dan herstelt dit hem,
 * uiterlijk 6 uur na de breuk — met pijnlijke stilte als limiet, want
 * berichten blijven óók in de Matrix-sync staan.
 *
 * Dit is de app-kant ván de koppeling; de distributeur-kant zelf kunnen we
 * niet bereiken zonder zijn coöperatie (REGISTER-broadcast is precies die
 * coöperatie).
 */
class PushKeepAliveReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_KEEPALIVE) return
        try {
            val distributor = UpConnector.getAckDistributor(context)
            if (distributor == null) {
                Log.d(TAG, "keepalive: geen distributeur (geack); niets te herkoppelen")
                return
            }
            // register() op de default-instantie: idempotent als alles werkt,
            // herstellend als de koppeling doodgevallen is.
            UpConnector.register(context, instance = INSTANCE_DEFAULT)
            Log.d(TAG, "keepalive: registratie vernieuwd bij $distributor")
        } catch (e: Exception) {
            Log.w(TAG, "keepalive mislukt", e)
        }
        planVolgende(context)
    }

    companion object {
        const val TAG = "PushKeepAlive"
        const val ACTION_KEEPALIVE = "com.danield.plusly.app.PUSH_KEEPALIVE"
        const val INSTANCE_DEFAULT = "default"
        private const val INTERVAL_MS = 2L * 60 * 60 * 1000 // 2 uur

        fun planVolgende(context: Context) {
            val pm = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val pi = android.app.PendingIntent.getBroadcast(
                context,
                0,
                Intent(ACTION_KEEPALIVE).setPackage(context.packageName),
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
            )
            // setExactAndAllowWhileIdle: op de bèta worden onexacte alarms
            // onbetrouwbaar gebatched; exacte mag i.v.m. SCHEDULE_EXACT_ALARM.
            // Eerste parameter = alarmtype (ELAPSED_REALTIME_WAKEUP: ook in
            // doze wekken).
            val alarmType = android.app.AlarmManager.ELAPSED_REALTIME_WAKEUP
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !pm.canScheduleExactAlarms()) {
                pm.setAndAllowWhileIdle(alarmType, android.os.SystemClock.elapsedRealtime() + INTERVAL_MS, pi)
            } else {
                pm.setExactAndAllowWhileIdle(
                    alarmType,
                    android.os.SystemClock.elapsedRealtime() + INTERVAL_MS,
                    pi,
                )
            }
        }
    }
}