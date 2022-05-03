import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should Not Initialized to Begin with', () {
      expect(provider.isInitiazlized, false);
    });

    test('Can not log out without sign in', () async {
      await provider.initizalize();
      expect(provider.logoutUser(),
          throwsA(const TypeMatcher<UserNotFoundException>()));
    });

    test('Should be Able to initialize', () async {
      await provider.initizalize();
      expect(provider.isInitiazlized, true);
    });

    test('User should null on initialize', () {
      expect(provider.currentUser, null);
    });

    test('Should be Able to initialize in less than 2 second', () async {
      await provider.initizalize();
      expect(provider.isInitiazlized, true);
    }, timeout: const Timeout(Duration(seconds: 3)));

    test('Register should delegate to login', () async {
      await provider.initizalize();

      final badUserEmail = await provider.registerUser(
        email: 'foo@bar.com',
        password: 'anypass',
      );

      expect(badUserEmail, throwsA(const TypeMatcher<UserNotFoundException>()));

      final badUserPass = await provider.registerUser(
        email: 'anyone@.com',
        password: 'foobar',
      );
      expect(badUserPass, throwsA(const TypeMatcher<WrongPasswordException>()));

      final user = await provider.registerUser(
        email: 'anyone@.com',
        password: '1234567',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in User should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Log out and login again', () async {
      await provider.logoutUser();

      await provider.signInUser(email: 'email', password: 'pass');

      final user = provider.currentUser;

      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;

  AuthUser? _user;

  bool get isInitiazlized => _isInitialized;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initizalize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logoutUser() async {
    if (!isInitiazlized) throw NotInitializedException();

    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));

    _user = null;
  }

  @override
  Future<AuthUser> registerUser({
    required String email,
    required String password,
  }) async {
    if (!isInitiazlized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 2));
    return signInUser(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitiazlized) throw NotInitializedException();
    final user = _user;

    if (user == null) throw UserNotFoundException();

    const newUser = AuthUser(isEmailVerified: true,  email: '');
    _user = newUser;
  }

  @override
  Future<AuthUser> signInUser({
    required String email,
    required String password,
  }) {
    if (!isInitiazlized) throw NotInitializedException();

    if (email == 'foo@bar.com') throw UserNotFoundException();
    if (password == 'foobar') throw WrongPasswordException();

    const user = AuthUser(isEmailVerified: false,email: '');
    _user = user;
    return Future.value(user);
  }
}
