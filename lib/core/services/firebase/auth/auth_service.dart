import 'dart:async';

import 'package:bookingmanager/core/extensions/firebase_auth_exception_extensions.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../product/constants/app_keys.dart';
import '../../../../product/providers/provider_manager.dart';
import '../../../../view/auth/login/login_view.dart';
import '../../navigation/navigation_service.dart';

part 'auth_service_interface.dart';

final class AuthService implements IAuthService {
  static final AuthService _instance = AuthService._init();
  static AuthService get instance => _instance;
  AuthService._init();

  @override
  UserModel? userModel;

  @override
  UserCredential? userCredential;

  @override
  User? get firebaseCurrentUser => FirebaseAuth.instance.currentUser;

  @override
  bool get didEmailVerified => firebaseCurrentUser?.emailVerified ?? false;

  @override
  Future<bool> get isLoggedIn async {
    if (firebaseCurrentUser != null) {
      initAllServicesAndListeners();
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await userDocStream!.first;
        if (userDoc.exists) {
          userModel = UserModel.fromMap(userDoc.data()!);
          initAllServicesAndListeners();
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    // it executes the google sign in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
            clientId: AppKeys.googleClientId,
            serverClientId: AppKeys.serverClientId)
        .signIn();
    if (googleUser == null) {
      // if the user cancels the process
      throw ErrorDescription(
          LocaleKeys.auth_service_login_with_google_unsuccessful.tr());
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    userCredential =
        await FirebaseAuth.instance.signInWithCredential(googleCredential);

    if (userCredential!.user == null) {
      throw ErrorDescription(
          LocaleKeys.auth_service_login_with_google_unsuccessful.tr());
    }

    initAllServicesAndListeners();

    DocumentSnapshot<Map<String, dynamic>> userDoc = await userDocStream!.first;
    if (userDoc.exists) {
      userModel = UserModel.fromMap(userDoc.data()!);
    } else {
      userModel = UserModel(
          uid: userCredential!.user!.uid,
          email: userCredential!.user!.email!,
          ownersOf: [],
          workersOf: [],
          photoUrl: userCredential!.user!.photoURL!,
          displayName: userCredential!.user!.displayName!);
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel!.uid)
            .set(userModel!.toJson());
      } catch (e) {
        userCredential!.user?.delete();
        AuthService.instance.signOut();
        throw Exception(LocaleKeys.auth_service_user_could_not_created.tr());
      }
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final signInMethod =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethod.isEmpty) {
        throw ErrorDescription(
            LocaleKeys.auth_service_no_associated_account.tr());
      } else if (signInMethod.first != "password") {
        throw ErrorDescription(LocaleKeys.auth_service_logged_via_google.tr());
      }
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.localized;
    } catch (e) {
      throw ErrorDescription(LocaleKeys.auth_service_there_is_error_when_login
          .tr(args: [e.toString()]));
    }
    if (userCredential!.user == null) {
      throw ErrorDescription(LocaleKeys.commons_user_not_found.tr());
    }
    initAllServicesAndListeners();
    DocumentSnapshot<Map<String, dynamic>> userDoc = await userDocStream!.first;
    if (!userDoc.exists) {
      throw ErrorDescription(LocaleKeys.commons_user_not_found.tr());
    }
    userModel = UserModel.fromMap(userDoc.data()!);
  }

  @override
  Future<void> register(
      {required String email,
      required String password,
      required String displayName,
      String? photoUrl}) async {
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential!.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw e.localized;
    } catch (e) {
      throw ErrorDescription(
          LocaleKeys.auth_service_error_while_creating_user.tr(
        args: [e.toString()],
      ));
    }
    if (userCredential!.user == null) {
      throw ErrorDescription(
          LocaleKeys.auth_service_user_could_not_created.tr());
    }
    userModel = UserModel(
      uid: userCredential!.user!.uid,
      displayName: displayName,
      email: email,
      ownersOf: [],
      workersOf: [],
      photoUrl: photoUrl ?? "",
    );
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel!.uid)
          .set(userModel!.toJson());
    } catch (e) {
      userCredential!.user?.delete();
      throw Exception(LocaleKeys.auth_service_user_could_not_created.tr());
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userDocStream;

  @override
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      userDocChangeStreamSubscription;

  @override
  void initAllServicesAndListeners() {
    ProviderManager.initAll();
    _startListeningUserDocStream();
  }

  @override
  void _startListeningUserDocStream() {
    userDocStream = FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseCurrentUser!.uid)
        .snapshots();
    userDocChangeStreamSubscription = userDocStream!.listen((event) async {
      if (event.exists) {
        userModel = UserModel.fromMap(event.data()!);

        if (userModel!.workersOf.isNotEmpty || userModel!.ownersOf.isNotEmpty) {
          await ProviderManager.ref
              .read(ProviderManager.branchManagerProvider)
              .toggleListener();
        }
      } else {
        signOut();
      }
    });
  }

  @override
  Future<void> _deleteUserDocStream() async {
    await userDocChangeStreamSubscription?.cancel();
    userDocStream = null;
  }

  @override
  Future<void> reloadCurrentUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await NavigationService.toPageAndRemoveUntil(const LoginView());
    await _deleteUserDocStream();
    ProviderManager.disposeAll();
    userModel = null;
    userCredential = null;
  }

  @override
  Future<void> deleteAccount() async {
    final uid = userModel!.uid;
    await FirebaseAuth.instance.currentUser?.delete();
    await FirebaseFirestore.instance.collection("users").doc(uid).delete();
  }
}
