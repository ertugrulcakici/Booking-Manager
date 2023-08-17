class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final List<String> ownersOf;
  final List<String> workersOf;
  String photoUrl = "";

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.ownersOf,
    required this.workersOf,
    required this.photoUrl,
  });

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
      // ownersOf:
      //     json["ownersOf"] != null ? List<String>.from(json["ownersOf"]) : [],
      // workersOf:
      //     json["workersOf"] != null ? List<String>.f
      photoUrl: json["photoUrl"],
    );
  }

  @override
  String toString() => toJson().toString();
}
