class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final List<String> ownersOf;
  final List<String> workersOf;
  String photoUrl = "";
  bool isDeleted = false;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.ownersOf,
    required this.workersOf,
    required this.photoUrl,
    this.isDeleted = false,
  });

  // TODO: localization
  UserModel.deletedUser()
      : uid = "",
        displayName = "Silinmiş Kullanıcı",
        email = "",
        ownersOf = [],
        workersOf = [],
        photoUrl = "",
        isDeleted = true;

  toJson() {
    return {
      "uid": uid,
      "name": displayName,
      "email": email,
      "ownersOf": ownersOf,
      "workersOf": workersOf,
      "photoUrl": photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      displayName: json["name"],
      email: json["email"],
      ownersOf: List<String>.from(json["ownersOf"]),
      workersOf: List<String>.from(json["workersOf"]),
      photoUrl: json["photoUrl"],
    );
  }

  @override
  String toString() => toJson().toString();
}
