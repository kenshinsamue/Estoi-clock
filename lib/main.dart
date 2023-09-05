import 'dart:ffi';

import 'package:estoi_clock/appList.dart';
import 'package:estoi_clock/configurationDB.dart';
import 'package:estoi_clock/dbConnection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  late DatabaseService _appSettings ;

  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState(){
    _appSettings = AppConfiguration();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _appSettings.selectWhere('configurations = "habilitado"'),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            bool settingState = (snapshot.data[0]["valor"]=="true")?true:false;
            // _isSwitched = settingState;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text("EstoiClock"),
              ),
              body: Center(
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
                            onChanged: (value){
                            setState(() {
                              print (value);
                              settingState = value;
                              if (snapshot.hasData) {
                                final int id = snapshot.data[0]["id"];
                                final String newValue = value ? "true" : "false";
                                _appSettings.updateData({'valor': newValue}, "id = $id");
                              }
                              // _appSettings.updateData({'value':"true"}, "id = ${snapshot.data[0]["id"]}");
                            });
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
              ), // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          else{
            return Container();
          }
        }
    );
  }
}

