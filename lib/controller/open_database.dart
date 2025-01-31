import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OpenDatabase {
  static final OpenDatabase instance =
      OpenDatabase._privateConstructor();
  static Database? _database;

  OpenDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'habit_hacker_database.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async =>  {
      await db.execute('''
          CREATE TABLE Users (
              UserID INT AUTO_INCREMENT PRIMARY KEY,
              Nickname VARCHAR(50) NOT NULL,
              Email VARCHAR(100) UNIQUE NOT NULL,
              MobileNumber VARCHAR(15),
              RegistrationFee DECIMAL(10, 2) NOT NULL,
              RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP
          );

          CREATE TABLE Questions (
              QuestionID INT AUTO_INCREMENT PRIMARY KEY,
              QuestionText TEXT NOT NULL,
              QuestionType ENUM('rating', 'choice', 'short_text', 'long_text') NOT NULL,
              Category VARCHAR(50) NOT NULL,
              IsActive BOOLEAN DEFAULT TRUE
          );

          CREATE TABLE QuestionOptions (
              OptionID INT AUTO_INCREMENT PRIMARY KEY,
              QuestionID INT NOT NULL,
              OptionText VARCHAR(100) NOT NULL,
              FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE
          );

          CREATE TABLE UserResponses (
              ResponseID INT AUTO_INCREMENT PRIMARY KEY,
              UserID INT NOT NULL,
              QuestionID INT NOT NULL,
              ResponseText TEXT,
              FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
              FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE
          );

          CREATE TABLE LifeDomains (
              DomainID INT AUTO_INCREMENT PRIMARY KEY,
              DomainName VARCHAR(50) UNIQUE NOT NULL
          );

          CREATE TABLE UserLifeDomains (
              UserLifeDomainID INT AUTO_INCREMENT PRIMARY KEY,
              UserID INT NOT NULL,
              DomainID INT NOT NULL,
              PriorityOrder INT NOT NULL,
              FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
              FOREIGN KEY (DomainID) REFERENCES LifeDomains(DomainID) ON DELETE CASCADE
          );

          CREATE TABLE UserValues (
              ValueID INT AUTO_INCREMENT PRIMARY KEY,
              UserID INT NOT NULL,
              ValueText VARCHAR(50) NOT NULL,
              FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
          );

          CREATE TABLE UserObstacles (
              ObstacleID INT AUTO_INCREMENT PRIMARY KEY,
              UserID INT NOT NULL,
              ObstacleText VARCHAR(50) NOT NULL,
              FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
          );

          CREATE TABLE Goals (
              GoalID INT AUTO_INCREMENT PRIMARY KEY,
              UserID INT NOT NULL,
              GoalDescription TEXT NOT NULL,
              StartDate DATE NOT NULL,
              EndDate DATE NOT NULL,
              IsCompleted BOOLEAN DEFAULT FALSE,
              FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
          );

          CREATE TABLE Habits (
              HabitID INT AUTO_INCREMENT PRIMARY KEY,
              GoalID INT NOT NULL,
              HabitDescription TEXT NOT NULL,
              HabitType ENUM('develop', 'shed') NOT NULL,
              StartDate DATE NOT NULL,
              EndDate DATE NOT NULL,
              IsCompleted BOOLEAN DEFAULT FALSE,
              FOREIGN KEY (GoalID) REFERENCES Goals(GoalID) ON DELETE CASCADE
          );

          CREATE TABLE Milestones (
              MilestoneID INT AUTO_INCREMENT PRIMARY KEY,
              HabitID INT NOT NULL,
              MilestoneDescription TEXT NOT NULL,
              DueDate DATE NOT NULL,
              IsCompleted BOOLEAN DEFAULT FALSE,
              FOREIGN KEY (HabitID) REFERENCES Habits(HabitID) ON DELETE CASCADE
          );

          CREATE TABLE DailyCheckIns (
              CheckInID INT AUTO_INCREMENT PRIMARY KEY,
              MilestoneID INT NOT NULL,
              CheckInDate DATE NOT NULL,
              AIQuestion TEXT NOT NULL,
              UserResponse  NOT NULL,
              FOREIGN KEY (MilestoneID) REFERENCES Milestones(MilestoneID) ON DELETE CASCADE
          );
        ''')
    },);
  }
}