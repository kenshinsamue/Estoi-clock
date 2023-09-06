import 'package:estoi_clock/dbConnection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'AppsPackagesDB.dart';


class InstalledAppsScreen extends StatefulWidget {
  @override
  _InstalledAppsScreenState createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  late DatabaseService _blackList ;

  _InstalledAppsScreenState(){
    _blackList = AppsPackages();
  }

  @override
  void initState() {
    super.initState();
    _blackList = AppsPackages();
  }
  Future<List<Map<String, dynamic>>> checkStatus () async {
    List<AppInfo> appsList = await InstalledApps.getInstalledApps(true, true);
    List<Map<String, dynamic>> result = [];
    for (var app in appsList) {
      dynamic query = await _blackList.selectWhere('package = "${app.packageName}"');
      bool valueStatus = query.toString() != "[]";
      result.add({
        "appInfo": app,
        "value": valueStatus,
      });
    }
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aplicaciones Instaladas")),
      body: FutureBuilder<List<Map<String, dynamic>>> (
        future: checkStatus(),
        builder:
            (BuildContext buildContext, AsyncSnapshot snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
              ? ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              AppInfo app = snapshot.data![index]["appInfo"];
              bool? valueStatus = snapshot.data![index]["value"];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.memory(app.icon!),
                  ),
                  title: Text(app.name!),
                  subtitle: Text(app.packageName.toString()),
                  trailing: Checkbox(
                    value: valueStatus?? false,
                    onChanged: (value) async {
                      valueStatus = value;
                      if (snapshot.hasData) {
                        if(value == null){
                          value=false;
                        }
                        else{
                          value ?
                            await _blackList.insertData({"name":app.name!,"package":app.packageName!}):
                            await _blackList.deleteItem("package = '${app.packageName!}'");
                        }
                      }
                      setState(() {});
                    },
                  ),

                  onTap: () =>
                      InstalledApps.startApp(app.packageName!),
                  onLongPress: () =>
                      InstalledApps.openSettings(app.packageName!),
                ),
              );
            },
          )
              : const Center(
              child: Text(
                  "Error al momento de cargar las aplicaciones ...."))
              : const Center(child: Text("Cargando informacion de las aplicaciones ...."));
        },
      ),
    );
  }
}