import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:estoi_clock/appList.dart';
import 'package:estoi_clock/dbConnection.dart';
import 'package:estoi_clock/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,      // <=----------- Modo noche
        primaryColor: Colors.lightBlue[800],
        useMaterial3: true,
      ),
      home:  const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseService _blackList = DatabaseService(databaseName: "bannedApps");
  final fetchBackground = "fetchBackground";
  MethodChannel platform = const MethodChannel('background');
  final ReceivePort  receivePort = ReceivePort();
  late Isolate isolate;
  Capability? capability;
  int result = 0;
  late dynamic status;
  bool settingState = false;

  @override
  void initState() {
    super.initState();
    UsageStats.grantUsagePermission();

  }

  _MyHomePageState(){
    _blackList = DatabaseService(databaseName: "bannedApps");
    _blackList.initDatabase();
  }

  Future init() async {
    status =  Permission.notification.request();
    UsageStats.grantUsagePermission();
  }

  startService() async{
    DatabaseService bannedApps = DatabaseService(databaseName: "bannedApps");
    await bannedApps.initDatabase();
    List<Map<String, Object?>> appBlackList = await bannedApps.selectAll();
    List<String> packagesBanned = [];
    for (var element in appBlackList) {
      dynamic jsonFixed = element.toString().replaceAllMapped(RegExp(r'([a-zA-Z0-9.]+)'), (match) {
        return '"${match.group(0)}"';
      });
      Map<String, dynamic> object =  jsonDecode(jsonFixed);
      if(object["package"] != null){
        String name = object["package"]!;
        packagesBanned.add(name);
      }
    }
    await platform.invokeListMethod('startService',{'bannedApps':packagesBanned});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("EstoiClock"),
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: const Text("Habilitar EstoiClock para que me ayude a gestionar mi tiempo"),
                    ),

                    Switch(
                      value:settingState,
                      onChanged: (value) async  {
                        if(mounted){
                          hideNotification();
                          if(value == false){
                            hideNotification();
                          }
                          if (value == true){
                            showNotification();
                          }
                          setState(()  {
                            settingState = value;
                            if(settingState) {
                              startService();
                            }
                            else{
                              platform.invokeListMethod('stopService');
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListTile(
                    title: const Text("Aplicaciones Instaladas"),
                    subtitle:const  Text(
                        "Seleccione las aplicaciones que van a ser monitorizadas"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstalledAppsScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) //
    );
  }
}
