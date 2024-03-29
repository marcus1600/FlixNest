

class UserData{
  final String userID;
  final String userName;
  final String fullName;
  final String password;


UserData({
  required this.userID,
  required this.userName,
  required this.fullName,
  required this.password,
});

factory UserData.fromSqfliteDatabase(Map<String, dynamic> map) =>
UserData(
  userID: map['userID']??"",
  userName: map['userName']??"",
  fullName: map['fullName']??"",
  password: map['password']??"");
}