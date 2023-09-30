package com.example.estoi_clock


import android.annotation.SuppressLint
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import java.util.*
import androidx.annotation.RequiresApi

//
class MainActivity: FlutterActivity() {
	private val CHANNEL = "background"
	
	@RequiresApi(Build.VERSION_CODES.M)
	@SuppressLint("ServiceCast")
	override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
				call, result ->
			
			// Solicita los permisos para acceder a datos de ejecucion de las aplicaciones
			Settings.ACTION_USAGE_ACCESS_SETTINGS
			
			// Solicita los permisos para ignorar la optimizacion de bateria para ejecucion en segundo plano
			val packageName = packageName
			val intent = Intent()
			val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
			if (!pm.isIgnoringBatteryOptimizations(packageName)) {
				intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
				intent.data = Uri.parse("package:${context.packageName}")
				context.startActivity(intent)
			}
			
			if (call.method == "startService"){
				val  bannedApps =  call.argument<ArrayList<String>>("bannedApps")
				if(bannedApps!=null)
					startService(
						Intent(applicationContext,backgorundService::class.java)
							.putExtra("bannedApps",bannedApps)
					)
			}
			else if(call.method == "stopService") {
				val serviceIntent = Intent(applicationContext, backgorundService::class.java)
				applicationContext.stopService(serviceIntent)
			
			}
		}
	}

}


