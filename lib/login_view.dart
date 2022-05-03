import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/alert_dialog.dart';
import 'package:notes_app/app_routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool loading = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 30, left: 30, top: 50),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: true,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            loading
                ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        // setState(() {
                        //   loading = true;
                        // });
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          await AuthService.firebase().signInUser(
                            email: email,
                            password: password,
                          );

                          final user = AuthService.firebase().currentUser;

                          if (user?.isEmailVerified ?? false) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              initialRoute,
                              (route) => false,
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyEmailRoute,
                              (route) => false,
                            );
                          }
                        } on WrongPasswordException {
                          // dismissLoading();
                          await showAlert(
                              context, 'You have entered wrong password');
                        } on InvalidEmailException {
                          // dismissLoading();
                          await showAlert(context, 'Invalid Email Entered');
                        } on GenricAuthException {
                          // dismissLoading();
                          await showAlert(context, 'Unkown Error Ocuured');
                        } on UserNotFoundException {
                          await showAlert(context, 'User not found');
                        } on FirebaseAuthException catch (e) {
                          // dismissLoading();
                          await showAlert(context, e.code.toString());
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text(
                'Register',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                    decoration: TextDecoration.underline),
              ),
            )
          ],
        ),
      ),
    );
  }

  dismissLoading() {
    setState(() {
      loading = false;
    });
  }
}
