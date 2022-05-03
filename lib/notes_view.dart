import 'package:flutter/material.dart';
import 'package:notes_app/app_routes.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';
import 'package:notes_app/services/crud/note_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        heroTag: 'float1',
        onPressed: () {
          Navigator.of(context).pushNamed(createNoteRoute);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Your Notes',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.black,
              ),
              color: Colors.grey[200],
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      onTap: () async {
                        await AuthService.firebase().logoutUser();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          initialRoute,
                          (route) => false,
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.login,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text('Logout'),
                        ],
                      )),
                ];
              })
        ],
      ),
      body: FutureBuilder(
          future: notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Text(
                              'Waiting to get notes from the notes services');
                        default:
                          return const CircularProgressIndicator();
                      }
                    });

              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
