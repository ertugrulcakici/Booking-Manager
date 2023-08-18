// ignore_for_file: unused_element

part of "auth_service.dart";

interface class IAuthService {
  UserModel? userModel;
  UserCredential? userCredential;
  Future<bool> get isLoggedIn => throw UnimplementedError();

  User? get firebaseCurrentUser => throw UnimplementedError();
  bool get didEmailVerified => throw UnimplementedError();

  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  Future<void> register(
          {required String displayName,
          String? photoUrl,
          required String email,
          required String password}) =>
      throw UnimplementedError();
  Future<void> loginWithGoogle() => throw UnimplementedError();
  Future<void> signOut() => throw UnimplementedError();

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userDocStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      userDocChangeStreamSubscription;

  /// This subscription required a [userModel] instance to be set
  /// This should be set when user logged via [loginWithGoogle], [login] or [isLoggedIn]
  /// and should be cleared when user logged out via [_deleteUserDocStream] when user logged out via [signOut]
  void initAllServicesAndListeners() => throw UnimplementedError();

  void _startListeningUserDocStream() => throw UnimplementedError();

  Future<void> _deleteUserDocStream() async => throw UnimplementedError();
  Future<void> reloadCurrentUser() => throw UnimplementedError();
  Future<void> deleteAccount() => throw UnimplementedError();
}
