class Users {
  final int userID;
  final String nickname;
  final String email;
  final String mobileNumber;
  final double registrationFee;
  final DateTime registrationDate;

  const Users(
      {required this.userID,
      required this.nickname,
      required this.email,
      required this.mobileNumber,
      required this.registrationFee,
      required this.registrationDate});

  // Convert a Student into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'userID': userID,
      'nickname': nickname,
      'email': email,
      'mobileNumber': mobileNumber,
      'registrationFee': registrationFee,
      'registrationDate': registrationDate,
    };
  }

  // Implement toString to make it easier to see information about
  // each student when using the print statement.
  @override
  String toString() {
    return 'Users{userID: $userID, nickname: $nickname, email: $email,  mobileNumber: $mobileNumber, registrationFee: $registrationFee, registrationDate: $registrationDate}';
  }
}
