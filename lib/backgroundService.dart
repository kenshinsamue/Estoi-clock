
import 'dart:convert';
import 'dart:isolate';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dbConnection.dart';
import 'package:flutter/services.dart';

isolateFunc (ReceivePort port,DatabaseService _blackList) async {
  DatabaseService bannedApps = DatabaseService(databaseName: "bannedApps");
  await bannedApps.initDatabase();
  List<Map<String, Object?>> appsList = await bannedApps.selectAll();
  await UsageStats.grantUsagePermission();




  // return await Isolate.spawn(runTask,[port.sendPort,appsList,UsageStats]);
}

Future<String> checkForegroundApp() async {
  const channel = MethodChannel('com.example.foreground_app_checker');
  String? isAppInForeground = await channel.invokeMethod<String>('getForegroundAppName');
  return isAppInForeground??"";
}

dynamic getDataFromDatabase (){
  DatabaseService bannedApps = DatabaseService(databaseName: "bannedApps");
  bannedApps.initDatabase();
  return bannedApps.selectAll();
}

Future<int> runTask(List<dynamic> arg,) async {
  SendPort resultPort = arg[0];
  List<Map<String, Object?>> appBlackList = arg[1];
  List<String> packagesBanned = [];


  dynamic UsageStats = arg[2];
  print(UsageStats);
  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(const Duration(days: 1));
  List<UsageInfo> t = await UsageStats.queryUsageStats(startDate, endDate);
  //
  // for (var element in appBlackList) {
  //   dynamic jsonFixed = element.toString().replaceAllMapped(RegExp(r'([a-zA-Z0-9.]+)'), (match) {
  //     return '"${match.group(0)}"';
  //   });
  //   Map<String, dynamic> object =  jsonDecode(jsonFixed);
  //   if(object["package"] != null){
  //     String name = object["package"]!;
  //     packagesBanned.add(name);
  //   }
  // }

  // for (var i in t) {
  //   if (double.parse(i.totalTimeInForeground!) > 0) {
  //     if( packagesBanned.contains(i.packageName.toString())){
  //       // print ("CONSEGUIDO!");
  //       // print (i.packageName.toString());
  //       // print(i.totalTimeInForeground);
  //       double actualTime = double.parse(i.totalTimeInForeground!);
  //       actualTime = actualTime/1000;
  //
  //       if(actualTime > 1){
  //         Fluttertoast.showToast(msg: "La aplicacion ha excedido el tiempo que le has permitido");
  //       }
  //     }
  //   }
  // }
  //
  // dynamic resultAppActive =  await checkForegroundApp();
  // Fluttertoast.showToast(msg: 'La aplicacion que esta viendo es :$resultAppActive',backgroundColor: Colors.green);

  Isolate.exit(resultPort,1);
}