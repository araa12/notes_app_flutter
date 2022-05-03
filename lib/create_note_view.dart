import 'package:flutter/material.dart';
import 'package:notes_app/anim/fade_animation.dart';
import 'package:notes_app/services/auth/firebase_auth_service.dart';
import 'package:notes_app/services/crud/note_service.dart';

class CreateNewNoteView extends StatefulWidget {
  const CreateNewNoteView({Key? key}) : super(key: key);

  @override
  State<CreateNewNoteView> createState() => _CreateNewNoteViewState();
}

class _CreateNewNoteViewState extends State<CreateNewNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _noteController;

  @override
  void initState() {
    _noteController = TextEditingController();
    _notesService = NotesService();

    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _deleteNoteIfTextIsEmpty();
    super.dispose();
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_noteController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() {
    final note = _note;
    if (_noteController.text.isNotEmpty && note != null) {
      _notesService.updateNote(
        note: note,
        text: 'text',
      );
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _noteController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextController() {
    _noteController.removeListener(_textControllerListener);
    _noteController.addListener(_textControllerListener);
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(user: owner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          FadeAnimation(
            delay: 1,
            child: IconButton(
                padding: const EdgeInsets.only(right: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                )),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: FadeAnimation(
          delay: 0.5,
          child: FutureBuilder(
              future: createNewNote(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    _note = snapshot.data as DatabaseNotes;
                    _setupTextController();
                    return TextField(
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type a Note ',

                      ),
                    );

                  default:
                    return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }
}
