import 'package:notes_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  
  Future<void> initizalize();
  AuthUser? get currentUser;
  Future<AuthUser> signInUser({
    required String email,
    required String password,
  });

  Future<AuthUser> registerUser({
    required String email,
    required String password,
  });

  Future<void> sendEmailVerification();

  Future<void> logoutUser();
}
