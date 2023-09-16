import 'dart:isolate';
import 'dart:ui';
import 'package:estoi_clock/appList.dart';
import 'package:estoi_clock/configurationDB.dart';
import 'package:estoi_clock/dbConnection.dart';
import 'package:estoi_clock/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

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
  DatabaseService _appSettings = AppConfiguration();
  final ReceivePort  receivePort = ReceivePort();
  late Isolate isolate;
  Capability? capability;
  int result = 0;
  late dynamic status;
  bool settingState = false;
  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState(){
    _appSettings = AppConfiguration();
  }

  Future init() async {
    status =  Permission.notification.request();
    dynamic result = await _appSettings.selectWhere("configurations = 'habilitado'");
    return result;
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
                          isolate = await isolateFunc(receivePort);

                          if(value == false){
                            if(capability == null) {
                              capability = isolate.pause(isolate.pauseCapability);
                            } else {
                              capability = isolate.pause(capability);
                            }
                          }
                          if (value == true){
                            if(capability != null) {
                              isolate.resume(capability!);
                            }
                            else{
                              isolate = await isolateFunc(receivePort);
                            }
                            showNotification();
                          }
                          setState(() {
                            settingState = value;
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

        // FutureBuilder(
        //   future: init(),
        //   initialData: const [{"id": 1, "configurations": "habilitado", "valor": false,"default":true}],
        //   builder: (BuildContext context, AsyncSnapshot snapshot){
        //       print (snapshot.data);
        //       if(snapshot.connectionState == ConnectionState.done ){
        //         print (snapshot.data);
        //         bool settingState = (snapshot.data[0]["valor"]=="true")?true:false;
        //         if(settingState){
        //           showNotification();
        //         }
        //         return Center(
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.start,
        //               children: [
        //                 Padding(
        //                   padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        //                   child: Row(
        //                     children: [
        //                       SizedBox(
        //                         width: MediaQuery.of(context).size.width * 0.75,
        //                         child: const Text("Habilitar EstoiClock para que me ayude a gestionar mi tiempo"),
        //                       ),
        //
        //                       Switch(
        //                         value:settingState,
        //                         onChanged: (value) async  {
        //
        //                           if(mounted){
        //                             hideNotification();
        //                             isolate = await isolateFunc(receivePort);
        //
        //                             if(value == false){
        //                               if(capability == null) {
        //                                 capability = isolate.pause(isolate.pauseCapability);
        //                               } else {
        //                                 capability = isolate.pause(capability);
        //                               }
        //                             }
        //                             if (value == true){
        //                               if(capability != null) {
        //                                 isolate.resume(capability!);
        //                               }
        //                               else{
        //                                 isolate = await isolateFunc(receivePort);
        //                               }
        //                               showNotification();
        //                             }
        //                             setState(() {
        //                               settingState = value;
        //                             });
        //                           }
        //                         },
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 Card(
        //                   child: Padding(
        //                     padding: const EdgeInsets.all(8),
        //                     child: ListTile(
        //                       title: const Text("Aplicaciones Instaladas"),
        //                       subtitle:const  Text(
        //                           "Seleccione las aplicaciones que van a ser monitorizadas"),
        //                       onTap: () => Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                           builder: (context) => InstalledAppsScreen(),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ); // This trailing comma makes auto-formatting nicer for build methods.
        //       }
        //
        //       else{
        //         return CircularProgressIndicator();
        //       }
        //     }
        // )
    );
  }
}

  isolateFunc (ReceivePort port) async {
    return  await Isolate.spawn(runTask,port.sendPort);
  }

  int runTask(SendPort arg){
    SendPort resultPort = arg;
    Isolate.exit(resultPort,1);
  }
