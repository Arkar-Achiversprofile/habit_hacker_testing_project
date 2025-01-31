class UserResponses {
  final int responseID;
  final int userID;
  final int questionID;
  final String responseText;

  const UserResponses(
      {required this.responseID,
      required this.userID,
      required this.questionID,
      required this.responseText});

  // Convert a Student into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'responseID': responseID,
      'userID': userID,
      'questionID': questionID,
      'responseText': responseText,
    };
  }

  // Implement toString to make it easier to see information about
  // each student when using the print statement.
  @override
  String toString() {
    return 'UserResponses{responseID: $responseID, userID: $userID, questionID: $questionID,  responseText: $responseText}';
  }
}