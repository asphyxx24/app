import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:mein_organizer/database/database.dart';
import 'package:mein_organizer/features/notes/drawing_canvas.dart';

class NoteEditorScreen extends StatefulWidget {
  final int? noteId;
  final int? folderId;

  const NoteEditorScreen({super.key, this.noteId, this.folderId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();
  final _overlayKey = GlobalKey<DrawingOverlayState>();

  List<Stroke> _strokes = [];
  bool _isDrawing = false;
  bool _isLoading = true;
  bool _hasChanges = false;

  // Zeichen-Einstellungen
  Color _penColor = Colors.black;
  double _penWidth = 3.0;
  bool _isEraser = false;
  final List<Stroke> _undoneStrokes = [];

  bool get _isNew => widget.noteId == null;

  static const _colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  static const _widths = [1.5, 3.0, 5.0, 8.0];

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    if (_isNew) {
      setState(() => _isLoading = false);
      return;
    }
    final note = await AppDatabase.instance.getNote(widget.noteId!);
    _titleController.text = note.title;
    _contentController.text = note.content;
    _strokes = strokesFromJson(note.drawingData);
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final drawingData = strokesToJson(_strokes);

    if (title.isEmpty && content.isEmpty && _strokes.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();

    if (_isNew) {
      await AppDatabase.instance.insertNote(NotesCompanion(
        title: Value(title),
        content: Value(content),
        drawingData: Value(drawingData),
        folderId: Value(widget.folderId),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
    } else {
      await AppDatabase.instance.updateNote(NotesCompanion(
        id: Value(widget.noteId!),
        title: Value(title),
        content: Value(content),
        drawingData: Value(drawingData),
        updatedAt: Value(now),
      ));
    }
    _hasChanges = false;
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ungespeicherte Aenderungen'),
        content: const Text('Moechtest du die Notiz speichern?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verwerfen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              _save();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _toggleDrawingMode() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (_isDrawing) {
        _contentFocusNode.unfocus();
      }
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _undoneStrokes.add(_strokes.removeLast());
      _hasChanges = true;
    });
  }

  void _redo() {
    if (_undoneStrokes.isEmpty) return;
    setState(() {
      _strokes.add(_undoneStrokes.removeLast());
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            if (context.mounted) Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'Neue Notiz' : 'Notiz bearbeiten'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Speichern',
              onPressed: _save,
            ),
          ],
        ),
        body: Column(
          children: [
            // Titel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.headlineSmall,
                decoration: const InputDecoration(
                  hintText: 'Titel',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _hasChanges = true,
                onTap: () {
                  if (_isDrawing) setState(() => _isDrawing = false);
                },
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            // Kombinierter Bereich: Text + Zeichnung uebereinander
            Expanded(
              child: Stack(
                children: [
                  // Text-Editor
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Notiz schreiben...',
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => _hasChanges = true,
                        onTap: () {
                          if (_isDrawing) setState(() => _isDrawing = false);
                        },
                      ),
                    ),
                  ),
                  // Zeichnungs-Overlay
                  if (_strokes.isNotEmpty || _isDrawing)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: !_isDrawing,
                        child: DrawingOverlay(
                          key: _overlayKey,
                          strokes: _strokes,
                          isActive: _isDrawing,
                          penColor: _penColor,
                          penWidth: _penWidth,
                          isEraser: _isEraser,
                          onStrokesChanged: (strokes) {
                            setState(() {
                              _strokes = strokes;
                              _undoneStrokes.clear();
                              _hasChanges = true;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Zeichen-Toolbar
            if (_isDrawing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    ..._colors.map((c) => GestureDetector(
                          onTap: () => setState(() {
                            _penColor = c;
                            _isEraser = false;
                          }),
                          child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: !_isEraser && _penColor == c
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.auto_fix_normal, size: 20),
                      onPressed: () => setState(() => _isEraser = !_isEraser),
                      color: _isEraser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      visualDensity: VisualDensity.compact,
                    ),
                    PopupMenuButton<double>(
                      initialValue: _penWidth,
                      onSelected: (w) => setState(() => _penWidth = w),
                      itemBuilder: (_) => _widths
                          .map((w) => PopupMenuItem(
                                value: w,
                                child: Container(
                                  width: 40,
                                  height: w,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(w / 2),
                                  ),
                                ),
                              ))
                          .toList(),
                      child: const Icon(Icons.line_weight, size: 20),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.undo, size: 20),
                      onPressed: _strokes.isNotEmpty ? _undo : null,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo, size: 20),
                      onPressed: _undoneStrokes.isNotEmpty ? _redo : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Stift/Text Toggle-Button
        floatingActionButton: FloatingActionButton.small(
          onPressed: _toggleDrawingMode,
          backgroundColor: _isDrawing
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _isDrawing ? Icons.text_fields : Icons.brush,
            color: _isDrawing
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
