import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mein_organizer/database/tables/notes.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Notes, NoteFolders])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(noteFolders);
            await m.addColumn(notes, notes.folderId);
          }
        },
      );

  // --- Folders CRUD ---

  Stream<List<NoteFolder>> watchFolders({int? parentId}) {
    final query = select(noteFolders);
    if (parentId == null) {
      query.where((f) => f.parentId.isNull());
    } else {
      query.where((f) => f.parentId.equals(parentId));
    }
    query.orderBy([(f) => OrderingTerm.asc(f.name)]);
    return query.watch();
  }

  Future<NoteFolder> getFolder(int id) {
    return (select(noteFolders)..where((f) => f.id.equals(id))).getSingle();
  }

  Future<int> insertFolder(NoteFoldersCompanion folder) {
    return into(noteFolders).insert(folder);
  }

  Future<bool> updateFolder(NoteFoldersCompanion folder) {
    return update(noteFolders).replace(folder);
  }

  Future<void> deleteFolder(int id) async {
    // Rekursiv: Unterordner und deren Notizen loeschen
    final subFolders = await (select(noteFolders)..where((f) => f.parentId.equals(id))).get();
    for (final sub in subFolders) {
      await deleteFolder(sub.id);
    }
    // Notizen im Ordner loeschen
    await (delete(notes)..where((n) => n.folderId.equals(id))).go();
    // Ordner selbst loeschen
    await (delete(noteFolders)..where((f) => f.id.equals(id))).go();
  }

  Future<int> getFolderCount(int? parentId) async {
    final count = noteFolders.id.count();
    final query = selectOnly(noteFolders)..addColumns([count]);
    if (parentId == null) {
      query.where(noteFolders.parentId.isNull());
    } else {
      query.where(noteFolders.parentId.equals(parentId));
    }
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // --- Notes CRUD ---

  Future<void> moveFolder(int folderId, int? targetParentId) {
    return (update(noteFolders)..where((f) => f.id.equals(folderId)))
        .write(NoteFoldersCompanion(parentId: Value(targetParentId)));
  }

  /// Alle Ordner laden (fuer Ordner-Picker)
  Future<List<NoteFolder>> getAllFolders() {
    return (select(noteFolders)..orderBy([(f) => OrderingTerm.asc(f.name)])).get();
  }

  Stream<List<Note>> watchNotes({
    int? folderId,
    String? searchQuery,
    NoteSort sort = NoteSort.updatedDesc,
  }) {
    final query = select(notes);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((n) =>
          n.title.like('%$searchQuery%') | n.content.like('%$searchQuery%'));
    } else {
      if (folderId == null) {
        query.where((n) => n.folderId.isNull());
      } else {
        query.where((n) => n.folderId.equals(folderId));
      }
    }

    query.orderBy([
      (n) {
        switch (sort) {
          case NoteSort.updatedDesc:
            return OrderingTerm.desc(n.updatedAt);
          case NoteSort.updatedAsc:
            return OrderingTerm.asc(n.updatedAt);
          case NoteSort.createdDesc:
            return OrderingTerm.desc(n.createdAt);
          case NoteSort.createdAsc:
            return OrderingTerm.asc(n.createdAt);
          case NoteSort.titleAsc:
            return OrderingTerm.asc(n.title);
          case NoteSort.titleDesc:
            return OrderingTerm.desc(n.title);
        }
      },
    ]);
    return query.watch();
  }

  Future<Note> getNote(int id) {
    return (select(notes)..where((n) => n.id.equals(id))).getSingle();
  }

  Future<int> insertNote(NotesCompanion note) {
    return into(notes).insert(note);
  }

  Future<bool> updateNote(NotesCompanion note) {
    return update(notes).replace(note);
  }

  Future<int> deleteNote(int id) {
    return (delete(notes)..where((n) => n.id.equals(id))).go();
  }

  Future<void> moveNote(int noteId, int? targetFolderId) {
    return (update(notes)..where((n) => n.id.equals(noteId)))
        .write(NotesCompanion(folderId: Value(targetFolderId)));
  }

  Future<int> getNoteCount() async {
    final count = notes.id.count();
    final query = selectOnly(notes)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}

enum NoteSort {
  updatedDesc, // Zuletzt bearbeitet (neueste zuerst)
  updatedAsc,  // Zuletzt bearbeitet (aelteste zuerst)
  createdDesc, // Erstellt (neueste zuerst)
  createdAsc,  // Erstellt (aelteste zuerst)
  titleAsc,    // Titel A-Z
  titleDesc,   // Titel Z-A
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mein_organizer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
