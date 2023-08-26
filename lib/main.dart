import 'package:estoi_clock/appList.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,      // <=-----------Modo noche
        primaryColor: Colors.lightBlue[800],
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSwitched = false;
  Future<void> printAllAppNames() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps();
    for (AppInfo a in apps) {
      print(a.name);
    }
  }
  @override
  Widget build(BuildContext context) {
    // printAllAppNames();
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: const Text("Habilitar EstoiClock para que me ayude a gestionar mi tiempo"),
                  ),
                  Container(
                    child: Switch(
                      value:_isSwitched,
                      onChanged: (value){
                        setState(() {
                          _isSwitched = value;
                        });
                      },
                    ),
                  )
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
}
