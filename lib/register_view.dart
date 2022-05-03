import 'package:flutter/material.dart';
import 'package:notes_app/alert_dialog.dart';
import 'package:notes_app/app_routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
                    padding: EdgeInsets.only(top: 20.0),
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
                          await AuthService.firebase().registerUser(
                            email: email,
                            password: password,
                          );
                         await AuthService.firebase().sendEmailVerification();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyEmailRoute, (route) => false);
                        } on WeakPasswordException {
                          dismisLoading();
                          await showAlert(context,
                              'Weak Password \n Please choose strong password');
                        } on EmailAlreadyInUseException {
                          // dismisLoading();
                          await showAlert(context, 'Email already Registred');
                        } on InvalidEmailException {
                          // dismisLoading();
                          await showAlert(context, 'Invalid Email Entered');
                        } on GenricAuthException {
                          // dismisLoading();
                          await showAlert(context, 'Unkown Error Ocuured');
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already Registered ? Go To Login'))
          ],
        ),
      ),
    );
  }

  dismisLoading() {
    setState(() {
      loading = false;
    });
  }
}
