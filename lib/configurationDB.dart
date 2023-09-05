import 'package:estoi_clock/dbConnection.dart';

class AppConfiguration extends DatabaseService {
  AppConfiguration() : super(databaseName: "configurations"); // Llama al constructor de la clase padre
}