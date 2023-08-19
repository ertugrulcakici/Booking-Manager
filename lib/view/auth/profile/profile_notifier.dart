import 'dart:io';

import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/popup_helper.dart';

class ProfileNotifier extends ChangeNotifier {
  final ImagePicker picker = ImagePicker();

  ProfileNotifier();

  bool _profilePhotoChange = false;
  bool get profilePhotoChanging => _profilePhotoChange;
  set profilePhotoChanging(bool value) {
    _profilePhotoChange = value;
    notifyListeners();
  }

  Future<void> changePhoto(ImageSource source) async {
    // TODO: localization
    try {
      final pickedFile = await picker.pickImage(
          source: source,
          maxHeight: 250,
          maxWidth: 250,
          preferredCameraDevice: CameraDevice.front);
      if (pickedFile == null) return;
      profilePhotoChanging = true;
      final File file = File(pickedFile.path);
      final userUid = AuthService.instance.userModel!.uid;
      final UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userUid)
          .putFile(file);
      await uploadTask.whenComplete(() async {
        final String url = await uploadTask.snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .update({'photoUrl': url});
        profilePhotoChanging = false;
      }).onError((error, stackTrace) => throw Exception(error));
      PopupHelper.showSnackBar(
          message: "Profil fotoğrafı başarıyla değiştirildi");
    } catch (e) {
      PopupHelper.showAnimatedInfoDialog(
          title: "Profil fotoğrafı değiştirme başarısız: $e",
          isSuccessful: false);
    }
  }
}
