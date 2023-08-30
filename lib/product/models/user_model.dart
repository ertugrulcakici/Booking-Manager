import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final List<String> ownersOf;
  final List<String> workersOf;
  String photoUrl = "";
  bool isDeleted = false;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.ownersOf,
    required this.workersOf,
    required this.photoUrl,
    this.isDeleted = false,
    this.fcmToken,
  });

  UserModel.deletedUser()
      : uid = "",
        displayName = LocaleKeys.user_model_deleted_user.tr(),
        email = "",
        ownersOf = [],
        workersOf = [],
        photoUrl = "",
        isDeleted = true,
        fcmToken = "";

  toJson() {
    return {
      "uid": uid,
      "name": displayName,
      "email": email,
      "ownersOf": ownersOf,
      "workersOf": workersOf,
      "photoUrl": photoUrl,
      "fcmToken": fcmToken
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
      fcmToken: json["fcmToken"],
    );
  }

  @override
  String toString() => toJson().toString();

  Future<void> updateFcmToken(String? fcmToken) async {
    if (fcmToken == this.fcmToken) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"fcmToken": fcmToken});
    } catch (e) {
      // TODO: handle exception
    }
  }
}
