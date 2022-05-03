import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_routes.dart';
import 'package:notes_app/create_note_view.dart';
import 'package:notes_app/login_view.dart';
import 'package:notes_app/register_view.dart';
import 'package:notes_app/verify_auth.dart';
import 'package:notes_app/verify_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    routes: {
      //'/home/': (context) => const Home(),
      initialRoute: (context) => const VerifyAuth(),
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const RegisterView(),
      verifyEmailRoute: (context) => const VerifyEmail(),
      createNoteRoute : (context) => const CreateNewNoteView(),
    },
    title: 'Notes App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        body: Column(
          children: [
            Center(
              child:
                  Text('Welcome ${FirebaseAuth.instance.currentUser?.email}'),
            )
          ],
        ));
  }
}
