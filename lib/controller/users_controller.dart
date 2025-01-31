import 'package:habit_hacker_testing_project/controller/open_database.dart';
import 'package:habit_hacker_testing_project/model/users.dart';
import 'package:sqflite/sqflite.dart';

class UsersController {
  static Future<void> usersInsert(List<Users> users) async {
    final db = await OpenDatabase.instance.database;

    for (var user in users) {
      await db.insert(
        "Users",
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> userRetrieveAll() async {
    final db = await OpenDatabase.instance.database;
    return await db.query('Users');
  }

  // static Future<List<Map<String, dynamic>>> studentDataByClassRoomId() async {
  //   final db = await OpenDatabase.instance.database;
  //   return await db.rawQuery('''
  //     SELECT * FROM Student
  //       LEFT JOIN ClassRoom ON Student.classRoomID = ClassRoom.classRoomID
  //       WHERE Student.studentAge > 24
  //   ''');
  // }
}