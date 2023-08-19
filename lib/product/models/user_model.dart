import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

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

  UserModel.deletedUser()
      : uid = "",
        displayName = LocaleKeys.user_model_deleted_user.tr(),
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
