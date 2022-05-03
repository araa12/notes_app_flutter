import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
              child:
                  Text('Email is Sent Please Check your account and verify..')),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text('Send Verification email')),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logoutUser();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login/', (route) => false);
              },
              child: const Text('Restart'))
        ],
      ),
    );
  }
}
