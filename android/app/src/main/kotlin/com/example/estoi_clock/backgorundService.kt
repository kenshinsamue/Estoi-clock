package com.example.estoi_clock
import android.app.ActivityManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.widget.Toast
import java.util.*
import android.os.Handler

class backgorundService : Service() {
	private var bannedApps: ArrayList<String> = arrayListOf<String>()
	private var isServiceRunning = true
	private val handler = Handler()
	private val appForegroundTimer = Timer()
	private var currentTimeRegistered = mutableMapOf<String,Double>()    // Tiempo total de ejeccucion en Segundos del
	private var currentApp:String="com.example.estoi_clock"
	override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
		bannedApps = intent?.getStringArrayListExtra("bannedApps") as ArrayList<String>
		initAppsTime()
		handler.postDelayed(periodicTask, 1000)
		appForegroundTimer.scheduleAtFixedRate(AppForegroundTask(), 0, 1000)
		return START_STICKY
	}
	
	
	override fun onBind(intent: Intent?): IBinder? {
		return null
	}
	
	private val periodicTask = object : Runnable {
		override fun run() {
			startBackgroundService(bannedApps)
			if (isServiceRunning) {
				handler.postDelayed(this, 1000)
			}
		}
	}
	
	override fun onDestroy() {
		super.onDestroy()
		isServiceRunning = false
		handler.removeCallbacks(periodicTask)
		// Detener el temporizador del seguimiento del tiempo en primer plano
		appForegroundTimer.cancel()
	}
	
	private fun initAppsTime(){
		val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
		val calendar = Calendar.getInstance()
		calendar.set(Calendar.HOUR_OF_DAY, 0)
		calendar.set(Calendar.MINUTE, 0)
		calendar.set(Calendar.SECOND, 0)
		calendar.set(Calendar.MILLISECOND, 0)
		val usageStats = usageStatsManager.queryAndAggregateUsageStats( calendar.timeInMillis, System.currentTimeMillis());
		for(app in bannedApps){
			if(!currentTimeRegistered.containsKey(app)){
				if(usageStats[app]!=null){
					currentTimeRegistered[app] = (usageStats[app]!!.totalTimeInForeground.toDouble()/1000)
				}
				else{
					currentTimeRegistered[app] = 0.0
				}
			}
		}
	}
	
	private fun startBackgroundService(blackList: ArrayList<String>) {
		var foregroundPackage: String = appInForeground()
		if (blackList.contains(foregroundPackage)) {
			AppForegroundTask()
			println("el tiempo guardado de la app: $foregroundPackage ha estado un tiempo de ${currentTimeRegistered[foregroundPackage]}")
			if (currentTimeRegistered[foregroundPackage]!! > 1.0) {
				Toast.makeText(this, "Tiempo Excedido", Toast.LENGTH_SHORT).show()
			}
		}
	}
	
	private fun appInForeground(): String {

		val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
		val endTime = System.currentTimeMillis()
		val beginTime = endTime - 1000  // Consulta los eventos de los últimos 1 segundo
		val usageEvents = usageStatsManager.queryEvents(beginTime, endTime)
		val event = UsageEvents.Event()
		var foregroundPackage = ""
		while (usageEvents.hasNextEvent()) {
			usageEvents.getNextEvent(event)
			if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
				foregroundPackage = event.packageName
				currentApp = foregroundPackage
			}
		}
		return if(foregroundPackage==""){
			currentApp
		} else{
			foregroundPackage
		}
	}
	
	inner class AppForegroundTask : TimerTask() {
		private var actualSesion :Double =0.0    // tiempo de la sesion actual del app
		private var initSesionTime :Long = 0L
		private var actualApp = ""
		
		
		override fun run() {
			if(actualApp=="" || !bannedApps.contains(actualApp) || actualApp!=appInForeground()){
				actualApp = appInForeground()
				initSesionTime = System.currentTimeMillis()
				actualSesion =0.0
			}
			
			else if(actualApp == appInForeground()){
				actualSesion = ((System.currentTimeMillis() - initSesionTime).toDouble()/1000)
				currentTimeRegistered[actualApp] = currentTimeRegistered[actualApp]!! + actualSesion
			}
		}
	}
}
