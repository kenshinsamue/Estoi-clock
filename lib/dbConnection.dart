import 'dart:core';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importa sqflite_common_ffi si lo estás utilizando

class BannedApps{
  final int id;
  final String name;
  final String package;
  const BannedApps( {required this.id, required this.name, required this.package,});
}
class Configurations{
  final int id;
  final String configuration;
  final dynamic value;
  Configurations( {required this.id, required this.configuration, required this.value,}){
    if (!(value is int || value is String || value is bool)) {
      print("tipo del valor: ${value.runtimeType}");
      throw ArgumentError("El tipo de package no es adecuado");
    }
  }
}

class DatabaseService {
  late Database _database;
  String database = "";
  String initialDatabaseName = "";
  DatabaseService ({String? databaseName}){
    initialDatabaseName = databaseName ?? "";
    database = databaseName ?? "";
  }

   Future<void> initDatabase() async {
     _database = await openDatabase(
      join(await getDatabasesPath(),'stoiclock.db'),
      onCreate: (db,version) async  {
         await db.execute(
            '''
              CREATE TABLE IF NOT EXISTS bannedApps (
                id INTEGER PRIMARY KEY AUTOINCREMENT, 
                name TEXT, 
                package TEXT UNIQUE)
            '''
         );
         await db.execute(
            '''
              CREATE TABLE IF NOT EXISTS configurations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                configurations TEXT UNIQUE,
                valor BOOLEAN )
            '''
         );
      },
      version: 1
    );
    database="bannedApps";
    dynamic result = await  selectAll();
    if(result.toString()=="[]"){
      await insertData({
        'name':'YouTube',
        'package':'com.google.android.youtube'
      });
    }
    database=initialDatabaseName;
  }

  /// Seleccciona todos los valores dentro de la tabla
  Future<List<Map<String, Object?>>> selectAll() async {
    return await _database.query(database);
  }

  /// Selecciona bajo una condicion
  Future<List<Map<String, Object?>>> selectWhere({List<String>? columns,String? condition}) async {
    return await _database.query(database,where: condition,columns: columns);
  }
  /// Inserta los datos dentro de la tabla
  Future<int> insertData(Map <String,Object> values) async {
    return await _database.insert( database,values);
  }

  /// Actualiza los datos de una tabla
  Future<int> updateData(Map <String,Object> values,String condition) async {
    return await _database.update(database,values,where: condition);
  }

  /// Elimina un elemento de la base de datos bajo una condicion
  Future<int> deleteItem(String condition) async {
    return await _database.delete(database, where: condition);
  }
}
