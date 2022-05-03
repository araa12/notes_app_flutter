import 'dart:async';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'crud_expections.dart';

const dbName = 'notes.db';
const notesTableName = 'notes';
const userTableName = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const userIdColumn = 'user_id';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" ((
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "users"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
)  ''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "users" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
)''';

class NotesService {
  static final _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  

  Database? _db;

  List<DatabaseNotes> _notes = [];
  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      ///
    }
  }

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFoundUserException catch (e) {
      final createdUser = await createDatabaseUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    } else {
      try {
        final docsPath = await getApplicationDocumentsDirectory();
        final dbPath = join(docsPath.path, notesTableName);
        final db = await openDatabase(dbPath);
        _db = db;

        ///[Create UserTable]///
        await db.execute(createUserTable);

        ///[Create Note Table]///
        await db.execute(createNoteTable);

        await _cachedNotes();
      } on MissingPlatformDirectoryException catch (e) {}
    }
  }

  Database _getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  ///[CRUD Operations on UserTable]///
  ///
  Future<DatabaseUser> createDatabaseUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabase();

    final result = await db.query(
      userTableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    } else {
      final id = await db.insert(userTableName, {
        emailColumn: email.toLowerCase(),
      });

      return DatabaseUser(
        id: id,
        email: email,
      );
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabase();

    final result = await db.query(
      userTableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFoundUserException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<void> deletUser({required String email}) async {
    await _ensureDbIsOpen();

    final deletedCount = await _getDatabase().delete(
      userTableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  ///[Crud Operations on Notes]///
  Future<DatabaseNotes> createNote({required DatabaseUser user}) async {
    await _ensureDbIsOpen();

    final dbUser = await getUser(email: user.email);
    if (dbUser != user) {
      throw CouldNotFoundUserException();
    }

    const text = '';

    final db = _getDatabase();
    final noteID = await db.insert(notesTableName,
        {userIdColumn: user.id, textColumn: text, isSyncedWithCloudColumn: 1});

    final note = DatabaseNotes(
      id: noteID,
      text: text,
      userId: user.id,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();

    final deletedCount = await _getDatabase().delete(
      userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);

      if (_notes.length != countBefore) {
        _notesStreamController.add(_notes);
      }
    }
  }

  Future<int> deleteAllNote() async {
    await _ensureDbIsOpen();

    final db = _getDatabase();

    int deletedCount = await db.delete(notesTableName);

    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCount;
  }

  Future<DatabaseNotes> updateNote(
      {required DatabaseNotes note, required String text}) async {
    await _ensureDbIsOpen();

    final db = _getDatabase();

    await getNote(id: note.id);

    final updateCount = await db.update(notesTableName, {
      textColumn: note.text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabase();

    final notes = await db.query(
      notesTableName,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNoteFoundNoteException();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabase();

    final notes = await db.query(
      notesTableName,
    );
    return notes.map((note) => DatabaseNotes.fromRow(note));
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person  ID =  $id and Email is = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNotes {
  final int id;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  const DatabaseNotes({
    required this.id,
    required this.text,
    required this.userId,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        text = map[textColumn] as String,
        userId = map[userIdColumn] as int,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'This is Simpe Note its ID = $id userID = $userId and text = $text';
  }

  @override
  bool operator ==(covariant DatabaseNotes other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}
