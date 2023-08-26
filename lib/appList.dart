import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aplicaciones Instaladas")),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<AppInfo>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
              ? ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              AppInfo app = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.memory(app.icon!),
                  ),
                  title: Text(app.name!),
                  subtitle: Text(app.packageName.toString()),
                  trailing: Checkbox(
                    value: true,
                    onChanged: (value) {
                      print(value);
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