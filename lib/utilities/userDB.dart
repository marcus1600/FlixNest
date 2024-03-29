import 'package:flixnest_v001/utilities/databaseservice.dart';
import 'package:flixnest_v001/utilities/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDB{
  final tableName = 'Users';

  Future<void> createTable(Database database) async{
    await database.execute(
      """CREATE TABLE IF NOT EXISTS $tableName(
        "userID" TEXT NOT NULL,
        "userName" TEXT NOT NULL,
        "fullName" TEXT NOT NULL,
        "password" TEXT NOT NULL);"""
    );
  }

  Future<int> create({required String userID,required String fullName,required String userName,required String password,}) async{
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName(userID,fullName,userName,password) VALUES(?,?,?,?)''',
      [userID,fullName,userName,password]
    );
  }

  Future<List<UserData>> fetchAll() async{
    final database = await DatabaseService().database;
    final users = await database.rawQuery('''SELECT * from $tableName''');
    return users.map((user) => UserData.fromSqfliteDatabase(user)).toList();
  }

  Future<UserData> fetchById(String id) async{
    final database = await DatabaseService().database;
    final user = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''',[id]);
    return UserData.fromSqfliteDatabase(user.first);
  }

  Future<UserData> fetchByUserName(String userName) async{
    final database = await DatabaseService().database;
    final user = await database.rawQuery('''SELECT * from $tableName WHERE userName = ?''',[userName]);
    return UserData.fromSqfliteDatabase(user.first);
  }
}