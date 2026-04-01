import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mein_organizer/database/database.dart';

final notesInFolderProvider = StreamProvider
    .family<List<Note>, ({int? folderId, String? search, NoteSort sort})>((ref, params) {
  return AppDatabase.instance.watchNotes(
    folderId: params.folderId,
    searchQuery: params.search,
    sort: params.sort,
  );
});

final foldersProvider = StreamProvider.family<List<NoteFolder>, int?>((ref, parentId) {
  return AppDatabase.instance.watchFolders(parentId: parentId);
});

final noteCountProvider = FutureProvider<int>((ref) {
  return AppDatabase.instance.getNoteCount();
});
