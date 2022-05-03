import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'auth_exceptions.dart';
import 'auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      throw GenricAuthException();
    }
  }

  @override
  Future<AuthUser> registerUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final AuthUser? user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw UnkownFirebaseAuthException();
      }
    } catch (_) {
      throw GenricAuthException();
    }
  }

  @override
  Future<AuthUser> signInUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final AuthUser? user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else {
        throw UnkownFirebaseAuthException();
      }
    } catch (e) {
      throw GenricAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final authUser = AuthUser.fromFirebase(user);
      return authUser;
    } else {
      return null;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
  }

  @override
  Future<void> initizalize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
