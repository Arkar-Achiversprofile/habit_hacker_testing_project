class Questions {
  final int questionID;
  final String questionText;
  final Enum questionType;
  final String category;
  final bool isActive;

  const Questions(
      {required this.questionID,
      required this.questionText,
      required this.questionType,
      required this.category,
      required this.isActive});

  // Convert a Student into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'questionID': questionID,
      'questionText': questionText,
      'questionType': questionType,
      'category': category,
      'isActive': isActive,
    };
  }

  // Implement toString to make it easier to see information about
  // each student when using the print statement.
  @override
  String toString() {
    return 'Questions{questionID: $questionID, questionText: $questionText, questionType: $questionType,  category: $category, isActive: $isActive}';
  }
}