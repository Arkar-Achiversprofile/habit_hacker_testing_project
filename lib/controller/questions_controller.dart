import 'package:habit_hacker_testing_project/controller/open_database.dart';
import 'package:habit_hacker_testing_project/model/questions.dart';
import 'package:sqflite/sqflite.dart';

class QuestionsController {
  static Future<void> questionsInsert(List<Questions> questions) async {
    final db = await OpenDatabase.instance.database;

    for (var question in questions) {
      await db.insert(
        "Questions",
        question.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> questionsRetrieveAll() async {
    final db = await OpenDatabase.instance.database;
    return await db.query('Questions');
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