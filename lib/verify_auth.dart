import 'package:flutter/material.dart';
import 'package:notes_app/login_view.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';
import 'package:notes_app/verify_email.dart';

import 'notes_view.dart';

class VerifyAuth extends StatelessWidget {
  const VerifyAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initizalize(),
        builder: (contex, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmail();
                }
              } else {
                return const LoginView();
              }
            default:
              return const Material(child: CircularProgressIndicator());
          }
        });
  }
}
