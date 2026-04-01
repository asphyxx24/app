import 'package:drift/drift.dart';

class NoteFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // null = Root-Ebene, sonst ID des Elternordners
  IntColumn get parentId => integer().nullable().references(NoteFolders, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get drawingData => text().withDefault(const Constant(''))();
  // null = Root-Ebene, sonst in einem Ordner
  IntColumn get folderId => integer().nullable().references(NoteFolders, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
