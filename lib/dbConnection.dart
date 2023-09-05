

import 'dart:core';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  DatabaseService ({String? databaseName}){
    database = databaseName ?? "";
    _initDatabase();
  }
  Future<void> _initDatabase() async {
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
    database="configurations";
    dynamic result = await  selectAll();
    if(result.toString()=="[]"){
      await insertData({
        'configurations':'habilitado',
        'valor':'false'
      });
    }
  }

  /// Seleccciona todos los valores dentro de la tabla
  Future<List<Map<String, Object?>>> selectAll() async {
    return await _database.query(database);
  }

  /// Selecciona bajo una condicion
  Future<List<Map<String, Object?>>> selectWhere(String condition) async {
    return await _database.query(database,where: condition);
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
