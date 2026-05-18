import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/session_result.dart';
import '../database/database_helper.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Flashcard> _cards = [];
  List<SessionResult> _history = [];
  bool _isLoading = true;

  List<Flashcard> get cards => List.unmodifiable(_cards);
  List<SessionResult> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  int get totalCards => _cards.length;
  int get masteredCards =>
      _cards.where((c) => c.successRate >= 0.8 && c.totalAttempts > 0).length;

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    await _loadCards();
    await _loadHistory();
    print('📦 Cartes chargées : ${_cards.length}');
    print('📋 Sessions chargées : ${_history.length}');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCards() async {
    _cards = await _db.getAllFlashcards();
    if (_cards.isEmpty) {
      await _loadSampleData();
    }
  }

  Future<void> _loadSampleData() async {
    final samples = [
      Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question:
            'Quelle est la complexité temporelle du tri rapide (QuickSort) en cas moyen ?',
        answer: 'O(n log n)',
        category: 'Algorithmique',
      ),
      Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '1',
        question: "Qu'est-ce que le polymorphisme en POO ?",
        answer:
            "Capacité d'un objet à prendre plusieurs formes. Une même méthode peut avoir différents comportements selon l'objet qui l'appelle.",
        category: 'POO',
      ),
      Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '2',
        question: 'Que signifie HTTP ?',
        answer:
            'HyperText Transfer Protocol — protocole de communication client-serveur pour le Web.',
        category: 'Réseaux',
      ),
      Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '3',
        question: 'Quelle est la différence entre Stack et Heap ?',
        answer:
            'La Stack stocke les variables locales (LIFO, taille fixe). Le Heap stocke les allocations dynamiques (taille variable, accès plus lent).',
        category: 'Systèmes',
      ),
      Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '4',
        question: "Qu'est-ce qu'une clé étrangère (Foreign Key) ?",
        answer:
            "Colonne qui référence la clé primaire d'une autre table, pour établir une relation entre les tables.",
        category: 'Bases de données',
      ),
    ];

    await _db.insertFlashcards(samples);
    _cards = await _db.getAllFlashcards();
  }

  Future<void> _loadHistory() async {
    _history = await _db.getAllSessions();
  }

  Future<void> addCard(Flashcard card) async {
    await _db.insertFlashcard(card);
    _cards = await _db.getAllFlashcards();
    notifyListeners();
  }

  Future<void> generateCards(int count, String category) async {
    final templates = _getTemplates(category);
    final newCards = <Flashcard>[];

    for (int i = 0; i < count && i < templates.length; i++) {
      final template = templates[i % templates.length];
      final card = Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
        question: template['question']!,
        answer: template['answer']!,
        category: category,
      );
      newCards.add(card);
    }

    await _db.insertFlashcards(newCards);
    _cards = await _db.getAllFlashcards();
    notifyListeners();
  }

  Future<void> updateCard(Flashcard updatedCard) async {
    await _db.updateFlashcard(updatedCard);
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _cards[index] = updatedCard;
      notifyListeners();
    }
  }

  Future<void> deleteCard(String id) async {
    await _db.deleteFlashcard(id);
    _cards = await _db.getAllFlashcards();
    notifyListeners();
  }

  Future<void> recordAnswer(String cardId, bool isCorrect) async {
    final card = _cards.firstWhere((c) => c.id == cardId);
    card.recordAnswer(isCorrect);
    await _db.updateFlashcard(card);
    notifyListeners();
  }

  Future<void> addSessionResult(SessionResult result) async {
    await _db.insertSession(result);
    _history = await _db.getAllSessions();
    notifyListeners();
  }

  List<String> get categories {
    final cats = _cards.map((c) => c.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Flashcard> cardsByCategory(String? category) {
    if (category == null || category == 'Toutes') return _cards;
    return _cards.where((c) => c.category == category).toList();
  }

  // ── Une seule version de _getTemplates ───────────────────────────────────
  List<Map<String, String>> _getTemplates(String category) {
    final Map<String, List<Map<String, String>>> bank = {
      'Flutter': [
        {
          'question': "Qu'est-ce qu'un Widget en Flutter ?",
          'answer':
              "Un Widget est la brique de base de l'interface Flutter. Tout est Widget."
        },
        {
          'question': 'Différence entre StatelessWidget et StatefulWidget ?',
          'answer':
              "StatelessWidget est immuable, StatefulWidget peut changer d'état via setState()."
        },
        {
          'question': 'À quoi sert le Widget Scaffold ?',
          'answer':
              'Scaffold fournit la structure de base d\'un écran : AppBar, body, FAB, etc.'
        },
        {
          'question': "Qu'est-ce que le Hot Reload ?",
          'answer':
              "Le Hot Reload injecte les modifications de code sans redémarrer l'app."
        },
        {
          'question': 'À quoi sert pubspec.yaml ?',
          'answer':
              'Fichier de configuration qui définit les dépendances et assets.'
        },
        {
          'question': "Qu'est-ce que Provider ?",
          'answer':
              "Package de gestion d'état pour partager des données entre widgets."
        },
      ],
      'Dart': [
        {
          'question': 'Différence entre final et const ?',
          'answer': "final est évalué à l'exécution, const à la compilation."
        },
        {
          'question': "Qu'est-ce qu'un Future ?",
          'answer':
              'Représente une valeur qui sera disponible plus tard (asynchrone).'
        },
        {
          'question': "Qu'est-ce qu'un Stream ?",
          'answer':
              'Séquence asynchrone de données qui peut émettre plusieurs valeurs.'
        },
        {
          'question': "Qu'est-ce que null safety ?",
          'answer':
              "Garantit qu'une variable non-nullable ne peut jamais être null."
        },
      ],
      'Algorithmique': [
        {
          'question': "Qu'est-ce qu'une recherche binaire ?",
          'answer':
              'Algorithme O(log n) qui cherche dans un tableau trié en divisant par 2.'
        },
        {
          'question': 'Complexité du tri fusion ?',
          'answer': 'O(n log n) dans tous les cas.'
        },
        {
          'question': "Qu'est-ce qu'une pile (Stack) ?",
          'answer': 'Structure LIFO (Last In First Out).'
        },
        {
          'question': "Qu'est-ce qu'une file (Queue) ?",
          'answer': 'Structure FIFO (First In First Out).'
        },
      ],
      'POO': [
        {
          'question': "Qu'est-ce que l'encapsulation ?",
          'answer':
              "Principe qui cache les détails d'implémentation et protège les données."
        },
        {
          'question': "Qu'est-ce que l'héritage ?",
          'answer':
              'Mécanisme qui permet à une classe de dériver d\'une autre classe.'
        },
        {
          'question': "Qu'est-ce que l'abstraction ?",
          'answer':
              'Principe qui permet de définir des classes abstraites avec des méthodes à implémenter.'
        },
      ],
      'Général': [
        {'question': 'Exemple de question ?', 'answer': 'Exemple de réponse.'},
      ],
    };

    return bank[category] ?? bank['Général']!;
  }
}
