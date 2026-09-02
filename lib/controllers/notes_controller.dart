import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/models/note_item.dart';

class NotesController extends ChangeNotifier {
  final LocalPersistentCache localCache;

  List<NoteItem> _notes = [];

  NotesController({required this.localCache}) {
    loadNotes();
  }

  List<NoteItem> get notes => _notes;

  void loadNotes() {
    _notes = localCache.getNotes();
    notifyListeners();
  }

  Future<void> addOrUpdateNote({
    String? id,
    required String userId,
    required String examId,
    required String questionId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    if (id != null && id.isNotEmpty) {
      final idx = _notes.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notes[idx] = _notes[idx].copyWith(
          title: title,
          content: content,
          updatedAt: now,
        );
      }
    } else {
      final newNote = NoteItem(
        id: 'note_${const Uuid().v4().substring(0, 8)}',
        userId: userId,
        examId: examId,
        questionId: questionId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      _notes.insert(0, newNote);
    }
    await localCache.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await localCache.saveNotes(_notes);
    notifyListeners();
  }

  NoteItem? getNoteForQuestion(String questionId) {
    try {
      return _notes.firstWhere((n) => n.questionId == questionId);
    } catch (_) {
      return null;
    }
  }
}
