import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:notes_app/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logoutUser() => provider.logoutUser();

  @override
  Future<AuthUser> registerUser(
          {required String email, required String password}) =>
      provider.registerUser(email: email, password: password);

  @override
  Future<AuthUser> signInUser(
          {required String email, required String password}) =>
      provider.signInUser(email: email, password: password);

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initizalize() => provider.initizalize();
}
