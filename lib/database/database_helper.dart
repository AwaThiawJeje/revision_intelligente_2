import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/session_result.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _cardsKey = 'flashcards';
  static const _sessionsKey = 'sessions';

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ← AJOUTE CETTE LIGNE
    final raw = prefs.getString(key);
    print(
        '🔍 Lecture clé "$key" : ${raw == null ? "NULL" : "${raw.length} chars"}');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
  }

  // ── Flashcards ───────────────────────────────────────────────────────────

  Future<void> insertFlashcard(Flashcard card) async {
    final list = await _readList(_cardsKey);
    list.removeWhere((m) => m['id'] == card.id);
    list.add(card.toMap());
    await _writeList(_cardsKey, list);
  }

  Future<void> insertFlashcards(List<Flashcard> cards) async {
    final list = await _readList(_cardsKey);
    for (final card in cards) {
      list.removeWhere((m) => m['id'] == card.id);
      list.add(card.toMap());
    }
    await _writeList(_cardsKey, list);
  }

  Future<List<Flashcard>> getAllFlashcards() async {
    final list = await _readList(_cardsKey);
    final cards = list.map((m) => Flashcard.fromMap(m)).toList();
    cards.sort((a, b) => a.question.compareTo(b.question));
    return cards;
  }

  Future<void> updateFlashcard(Flashcard card) async {
    final list = await _readList(_cardsKey);
    final idx = list.indexWhere((m) => m['id'] == card.id);
    if (idx != -1) list[idx] = card.toMap();
    await _writeList(_cardsKey, list);
  }

  Future<void> deleteFlashcard(String id) async {
    final list = await _readList(_cardsKey);
    list.removeWhere((m) => m['id'] == id);
    await _writeList(_cardsKey, list);
  }

  Future<List<Flashcard>> getFlashcardsByCategory(String category) async {
    final all = await getAllFlashcards();
    return all.where((c) => c.category == category).toList();
  }

  Future<List<String>> getAllCategories() async {
    final all = await getAllFlashcards();
    final cats = all.map((c) => c.category).toSet().toList();
    cats.sort();
    return cats;
  }

  // ── Sessions ─────────────────────────────────────────────────────────────

  Future<void> insertSession(SessionResult session) async {
    final list = await _readList(_sessionsKey);
    list.removeWhere((m) => m['id'] == session.id);
    list.add({
      'id': session.id,
      'date': session.date.toIso8601String(),
      'totalCards': session.totalCards,
      'correctAnswers': session.correctAnswers,
      'duration': session.duration.inSeconds,
      'category': session.category,
    });
    await _writeList(_sessionsKey, list);

    // DEBUG — à retirer après
    print('✅ Session sauvegardée. Total sessions : ${list.length}');
    final check = await _readList(_sessionsKey);
    print('✅ Vérification lecture : ${check.length} sessions en mémoire');
  }

  Future<List<SessionResult>> getAllSessions() async {
    final list = await _readList(_sessionsKey);
    final sessions = list
        .map((m) => SessionResult(
              id: m['id'],
              date: DateTime.parse(m['date']),
              totalCards: m['totalCards'],
              correctAnswers: m['correctAnswers'],
              duration: Duration(seconds: m['duration']),
              category: m['category'] ?? 'Toutes',
            ))
        .toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  Future<int> getMasteredCount() async {
    final all = await getAllFlashcards();
    return all.where((c) => c.totalAttempts > 0 && c.successRate >= 0.8).length;
  }
}
