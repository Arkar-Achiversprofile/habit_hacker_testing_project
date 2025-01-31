import 'package:habit_hacker_testing_project/controller/open_database.dart';
import 'package:habit_hacker_testing_project/model/user_responses.dart';
import 'package:sqflite/sqflite.dart';

class UserResponsesController {
  static Future<void> userResponsesInsert(List<UserResponses> userResponses) async {
    final db = await OpenDatabase.instance.database;

    for (var userResponse in userResponses) {
      await db.insert(
        "UserResponses",
        userResponse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> userResponsesRetrieveAll() async {
    final db = await OpenDatabase.instance.database;
    return await db.query('UserResponses');
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