import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mein_organizer/database/database.dart';
import 'package:mein_organizer/features/notes/notes_provider.dart';
import 'package:mein_organizer/features/notes/note_editor_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<({int? id, String name})> _folderStack = [
    (id: null, name: 'Notizen'),
  ];

  String? _searchQuery;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  NoteSort _sort = NoteSort.updatedDesc;

  int? get _currentFolderId => _folderStack.last.id;
  String get _currentFolderName => _folderStack.last.name;

  static const _sortLabels = {
    NoteSort.updatedDesc: 'Bearbeitet (neueste)',
    NoteSort.updatedAsc: 'Bearbeitet (aelteste)',
    NoteSort.createdDesc: 'Erstellt (neueste)',
    NoteSort.createdAsc: 'Erstellt (aelteste)',
    NoteSort.titleAsc: 'Titel A → Z',
    NoteSort.titleDesc: 'Titel Z → A',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(foldersProvider(_currentFolderId));
    final notesAsync = ref.watch(notesInFolderProvider(
      (folderId: _currentFolderId, search: _searchQuery, sort: _sort),
    ));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: _folderStack.length > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _folderStack.removeLast()),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Notizen durchsuchen...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.isEmpty ? null : value);
                },
              )
            : Text(_currentFolderName),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = null;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new_folder') _createFolder();
              if (value == 'sort') _showSortDialog();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'new_folder',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Neuer Ordner'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 20),
                    const SizedBox(width: 8),
                    Text('Sortieren: ${_sortLabels[_sort]}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults(notesAsync, theme)
          : _buildFolderView(foldersAsync, notesAsync, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Note>> notesAsync, ThemeData theme) {
    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Text('Keine Treffer',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: notes.length,
          itemBuilder: (_, i) => _NoteCard(
            note: notes[i],
            onTap: () => _openNote(notes[i]),
            onDelete: () => _deleteNote(notes[i]),
            onMove: () => _moveNote(notes[i]),
          ),
        );
      },
    );
  }

  Widget _buildFolderView(
    AsyncValue<List<NoteFolder>> foldersAsync,
    AsyncValue<List<Note>> notesAsync,
    ThemeData theme,
  ) {
    return foldersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
      data: (folders) => notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (notes) {
          if (folders.isEmpty && notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded,
                      size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('Noch leer',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Tippe + fuer eine neue Notiz',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              ...folders.map((folder) => _FolderCard(
                    folder: folder,
                    onTap: () => _openFolder(folder),
                    onRename: () => _renameFolder(folder),
                    onDelete: () => _deleteFolder(folder),
                    onMove: () => _moveFolder(folder),
                  )),
              ...notes.map((note) => _NoteCard(
                    note: note,
                    onTap: () => _openNote(note),
                    onDelete: () => _deleteNote(note),
                    onMove: () => _moveNote(note),
                  )),
            ],
          );
        },
      ),
    );
  }

  // --- Sortierung ---

  Future<void> _showSortDialog() async {
    final result = await showDialog<NoteSort>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sortieren nach'),
        children: _sortLabels.entries
            .map((e) => ListTile(
                  title: Text(e.value),
                  leading: Icon(
                    _sort == e.key ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  ),
                  onTap: () => Navigator.pop(ctx, e.key),
                ))
            .toList(),
      ),
    );
    if (result != null) {
      setState(() => _sort = result);
    }
  }

  // --- Verschieben ---

  Future<void> _moveNote(Note note) async {
    final targetFolderId = await _showFolderPicker(
      title: 'Notiz verschieben',
      excludeFolderId: null,
      currentParentId: note.folderId,
    );
    if (targetFolderId == null) return;
    final actualId = targetFolderId == -1 ? null : targetFolderId;
    await AppDatabase.instance.moveNote(note.id, actualId);
  }

  Future<void> _moveFolder(NoteFolder folder) async {
    final targetFolderId = await _showFolderPicker(
      title: 'Ordner verschieben',
      excludeFolderId: folder.id,
      currentParentId: folder.parentId,
    );
    if (targetFolderId == null) return;
    final actualId = targetFolderId == -1 ? null : targetFolderId;
    await AppDatabase.instance.moveFolder(folder.id, actualId);
  }

  /// Zeigt einen Dialog zum Auswaehlen des Zielordners.
  /// Gibt die Ziel-Folder-ID zurueck, oder -1 fuer Root, oder null bei Abbruch.
  Future<int?> _showFolderPicker({
    required String title,
    required int? excludeFolderId,
    required int? currentParentId,
  }) async {
    final allFolders = await AppDatabase.instance.getAllFolders();

    // Ordner filtern: sich selbst und Unterordner ausschliessen
    final excluded = <int>{};
    if (excludeFolderId != null) {
      excluded.add(excludeFolderId);
      void collectChildren(int parentId) {
        for (final f in allFolders.where((f) => f.parentId == parentId)) {
          excluded.add(f.id);
          collectChildren(f.id);
        }
      }
      collectChildren(excludeFolderId);
    }

    final validFolders = allFolders.where((f) => !excluded.contains(f.id)).toList();

    // Ordner-Baum aufbauen fuer Einrueckung
    List<({NoteFolder? folder, int depth})> buildTree(int? parentId, int depth) {
      final items = <({NoteFolder? folder, int depth})>[];
      for (final f in validFolders.where((f) => f.parentId == parentId)) {
        items.add((folder: f, depth: depth));
        items.addAll(buildTree(f.id, depth + 1));
      }
      return items;
    }

    final tree = buildTree(null, 0);

    if (!mounted) return null;
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Notizen (Root)'),
                selected: currentParentId == null,
                onTap: () => Navigator.pop(ctx, -1),
              ),
              ...tree.map((item) => ListTile(
                    contentPadding: EdgeInsets.only(left: 16.0 + item.depth * 24.0),
                    leading: const Icon(Icons.folder_rounded),
                    title: Text(item.folder!.name),
                    selected: currentParentId == item.folder!.id,
                    onTap: () => Navigator.pop(ctx, item.folder!.id),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  // --- Navigation ---

  void _openFolder(NoteFolder folder) {
    setState(() {
      _folderStack.add((id: folder.id, name: folder.name));
    });
  }

  void _createNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(folderId: _currentFolderId),
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: note.id)),
    );
  }

  // --- CRUD Dialoge ---

  Future<void> _createFolder() async {
    final name = await _showNameDialog('Neuer Ordner', '');
    if (name == null || name.isEmpty) return;
    await AppDatabase.instance.insertFolder(NoteFoldersCompanion(
      name: Value(name),
      parentId: Value(_currentFolderId),
    ));
  }

  Future<void> _renameFolder(NoteFolder folder) async {
    final name = await _showNameDialog('Ordner umbenennen', folder.name);
    if (name == null || name.isEmpty) return;
    await AppDatabase.instance.updateFolder(NoteFoldersCompanion(
      id: Value(folder.id),
      name: Value(name),
      parentId: Value(folder.parentId),
      createdAt: Value(folder.createdAt),
    ));
  }

  Future<void> _deleteFolder(NoteFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordner loeschen?'),
        content: Text(
            '"${folder.name}" und alle Inhalte werden unwiderruflich geloescht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AppDatabase.instance.deleteFolder(folder.id);
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notiz loeschen?'),
        content: Text(
            '"${note.title.isEmpty ? "Ohne Titel" : note.title}" wird unwiderruflich geloescht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AppDatabase.instance.deleteNote(note.id);
    }
  }

  Future<String?> _showNameDialog(String title, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// --- Widgets ---

class _FolderCard extends StatelessWidget {
  final NoteFolder folder;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const _FolderCard({
    required this.folder,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.folder_rounded,
                  color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  folder.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') onRename();
                  if (value == 'move') onMove();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Umbenennen')),
                  PopupMenuItem(value: 'move', child: Text('Verschieben')),
                  PopupMenuItem(value: 'delete', child: Text('Loeschen')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDrawing = note.drawingData.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (hasDrawing)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.brush,
                                size: 16, color: theme.colorScheme.primary),
                          ),
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Ohne Titel' : note.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: note.title.isEmpty
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(note.updatedAt),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'move') onMove();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'move', child: Text('Verschieben')),
                  PopupMenuItem(value: 'delete', child: Text('Loeschen')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Gerade eben';
    if (diff.inHours < 1) return 'Vor ${diff.inMinutes} Min.';
    if (diff.inDays < 1) return 'Vor ${diff.inHours} Std.';
    if (diff.inDays < 7) return 'Vor ${diff.inDays} Tagen';
    return '${date.day}.${date.month}.${date.year}';
  }
}
