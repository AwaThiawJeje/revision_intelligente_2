import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/session_result.dart';

class AppState extends ChangeNotifier {
  final List<Flashcard> _cards = [];
  final List<SessionResult> _history = [];

  List<Flashcard> get cards => List.unmodifiable(_cards);
  List<SessionResult> get history => List.unmodifiable(_history);

  int get totalCards => _cards.length;
  int get masteredCards =>
      _cards.where((c) => c.successRate >= 0.8 && c.totalAttempts > 0).length;

  AppState() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final samples = [
      Flashcard(
        id: '1',
        question: 'Quelle est la complexité temporelle d\'un tri rapide (QuickSort) en cas moyen ?',
        answer: 'O(n log n)',
        category: 'Algorithmique',
      ),
      Flashcard(
        id: '2',
        question: 'Qu\'est-ce que le polymorphisme en POO ?',
        answer: 'Capacité d\'un objet à prendre plusieurs formes. Une même méthode peut avoir différents comportements selon l\'objet qui l\'appelle.',
        category: 'POO',
      ),
      Flashcard(
        id: '3',
        question: 'Que signifie HTTP ?',
        answer: 'HyperText Transfer Protocol — protocole de communication client-serveur pour le Web.',
        category: 'Réseaux',
      ),
      Flashcard(
        id: '4',
        question: 'Quelle est la différence entre Stack et Heap ?',
        answer: 'La Stack stocke les variables locales (LIFO, taille fixe). Le Heap stocke les allocations dynamiques (taille variable, accès plus lent).',
        category: 'Systèmes',
      ),
      Flashcard(
        id: '5',
        question: 'Qu\'est-ce qu\'une clé étrangère (Foreign Key) ?',
        answer: 'Colonne qui référence la clé primaire d\'une autre table, pour établir une relation entre les tables.',
        category: 'Bases de données',
      ),
    ];
    _cards.addAll(samples);
  }

  // ─── Générer des cartes automatiquement ───────────────────────────────────
  void generateCards(int count, String category) {
    final templates = _getTemplates(category);
    for (int i = 0; i < count; i++) {
      final template = templates[i % templates.length];
      final id = DateTime.now().millisecondsSinceEpoch.toString() + '_$i';
      _cards.add(Flashcard(
        id: id,
        question: template['question']!,
        answer: template['answer']!,
        category: category,
      ));
    }
    notifyListeners();
  }

  List<Map<String, String>> _getTemplates(String category) {
    final Map<String, List<Map<String, String>>> bank = {
      'Flutter': [
        {'question': 'Qu\'est-ce qu\'un Widget en Flutter ?', 'answer': 'Un Widget est la brique de base de l\'interface Flutter. Tout est Widget : texte, bouton, mise en page, etc.'},
        {'question': 'Quelle est la différence entre StatelessWidget et StatefulWidget ?', 'answer': 'StatelessWidget est immuable (pas d\'état interne). StatefulWidget peut changer d\'état via setState().'},
        {'question': 'À quoi sert le Widget Scaffold ?', 'answer': 'Scaffold fournit la structure de base d\'un écran : AppBar, body, FloatingActionButton, BottomNavigationBar, etc.'},
        {'question': 'Qu\'est-ce que le Hot Reload en Flutter ?', 'answer': 'Le Hot Reload injecte les modifications de code dans l\'app en cours d\'exécution sans la redémarrer, conservant l\'état actuel.'},
        {'question': 'À quoi sert pubspec.yaml ?', 'answer': 'pubspec.yaml définit les métadonnées du projet, les dépendances (packages), les assets (images, polices) et la version de l\'app.'},
        {'question': 'Qu\'est-ce que Provider en Flutter ?', 'answer': 'Provider est un package de gestion d\'état qui permet de partager des données entre widgets sans les passer manuellement.'},
        {'question': 'Qu\'est-ce que BuildContext ?', 'answer': 'BuildContext est un handle vers l\'emplacement d\'un widget dans l\'arbre de widgets. Il permet d\'accéder aux données héritées.'},
        {'question': 'Comment naviguer vers un nouvel écran en Flutter ?', 'answer': 'Navigator.push(context, MaterialPageRoute(builder: (_) => NouvelEcran()))'},
        {'question': 'Qu\'est-ce que Column et Row ?', 'answer': 'Column dispose ses enfants verticalement, Row les dispose horizontalement. Ce sont les widgets de mise en page de base.'},
        {'question': 'À quoi sert setState() ?', 'answer': 'setState() notifie Flutter qu\'une variable d\'état a changé et déclenche la reconstruction (rebuild) du widget.'},
      ],
      'Dart': [
        {'question': 'Qu\'est-ce qu\'une variable nullable en Dart ?', 'answer': 'Une variable nullable peut contenir null. On la déclare avec ? : String? nom; Par défaut les variables sont non-nullables.'},
        {'question': 'Quelle est la différence entre final et const en Dart ?', 'answer': 'final est évalué à l\'exécution (runtime), const est évalué à la compilation. Les deux sont immuables après assignation.'},
        {'question': 'Qu\'est-ce qu\'un Future en Dart ?', 'answer': 'Un Future représente une valeur qui sera disponible plus tard (opération asynchrone). On l\'utilise avec async/await.'},
        {'question': 'Qu\'est-ce qu\'un Stream en Dart ?', 'answer': 'Un Stream est une séquence asynchrone de données. Contrairement à Future (une valeur), il peut émettre plusieurs valeurs dans le temps.'},
        {'question': 'Qu\'est-ce que le null safety en Dart ?', 'answer': 'Le null safety garantit qu\'une variable non-nullable ne peut jamais être null, évitant les NullPointerException à l\'exécution.'},
        {'question': 'Comment déclarer une liste en Dart ?', 'answer': 'List<String> noms = []; ou var noms = <String>[]; ou final noms = [\'Alice\', \'Bob\'];'},
        {'question': 'Qu\'est-ce qu\'une fonction arrow en Dart ?', 'answer': 'Une fonction arrow utilise => pour retourner directement une expression : int double(int n) => n * 2;'},
        {'question': 'Qu\'est-ce que le spread operator ... en Dart ?', 'answer': 'L\'opérateur ... insère tous les éléments d\'une liste dans une autre : var c = [...a, ...b];'},
        {'question': 'Qu\'est-ce qu\'une Map en Dart ?', 'answer': 'Une Map est une collection clé-valeur : Map<String, int> ages = {\'Alice\': 25, \'Bob\': 30};'},
        {'question': 'Comment gérer les exceptions en Dart ?', 'answer': 'Avec try/catch/finally : try { ... } catch (e) { print(e); } finally { ... }'},
      ],
      'Algorithmique': [
        {'question': 'Qu\'est-ce qu\'un algorithme O(n²) ?', 'answer': 'Un algorithme O(n²) a un temps d\'exécution proportionnel au carré de la taille de l\'entrée. Ex: Bubble Sort.'},
        {'question': 'Qu\'est-ce qu\'une recherche binaire ?', 'answer': 'Algorithme qui cherche un élément dans un tableau trié en divisant l\'espace de recherche par 2 à chaque étape. Complexité : O(log n).'},
        {'question': 'Qu\'est-ce qu\'une pile (Stack) ?', 'answer': 'Structure de données LIFO (Last In First Out). Le dernier élément ajouté est le premier retiré. Opérations : push, pop, peek.'},
        {'question': 'Qu\'est-ce qu\'une file (Queue) ?', 'answer': 'Structure FIFO (First In First Out). Le premier élément ajouté est le premier retiré. Opérations : enqueue, dequeue.'},
        {'question': 'Quelle est la complexité du tri fusion (Merge Sort) ?', 'answer': 'O(n log n) dans tous les cas. C\'est un algorithme de tri stable basé sur la stratégie diviser pour régner.'},
        {'question': 'Qu\'est-ce qu\'un graphe ?', 'answer': 'Un graphe est un ensemble de nœuds (sommets) reliés par des arêtes. Il peut être orienté ou non orienté, pondéré ou non.'},
        {'question': 'Qu\'est-ce que la récursivité ?', 'answer': 'Une fonction récursive s\'appelle elle-même avec un cas de base pour arrêter. Ex: factorielle(n) = n * factorielle(n-1).'},
        {'question': 'Qu\'est-ce qu\'une liste chaînée ?', 'answer': 'Structure où chaque élément (nœud) contient une valeur et un pointeur vers le nœud suivant. Insertion O(1), accès O(n).'},
        {'question': 'Qu\'est-ce qu\'un arbre binaire de recherche ?', 'answer': 'Arbre où chaque nœud a au plus 2 enfants. Nœuds gauches < nœud courant < nœuds droits. Recherche O(log n) en moyenne.'},
        {'question': 'Qu\'est-ce que la programmation dynamique ?', 'answer': 'Technique qui résout des problèmes en les décomposant en sous-problèmes et en mémorisant leurs résultats pour éviter les recalculs.'},
      ],
      'POO': [
        {'question': 'Qu\'est-ce que l\'encapsulation ?', 'answer': 'L\'encapsulation regroupe les données et méthodes dans une classe et contrôle l\'accès via des modificateurs (public, private, protected).'},
        {'question': 'Qu\'est-ce que l\'héritage ?', 'answer': 'L\'héritage permet à une classe enfant de réutiliser les attributs et méthodes d\'une classe parent, en les étendant ou les modifiant.'},
        {'question': 'Qu\'est-ce que le polymorphisme ?', 'answer': 'Le polymorphisme permet à des objets de types différents de répondre à la même interface. Une même méthode peut avoir des comportements différents.'},
        {'question': 'Qu\'est-ce qu\'une interface ?', 'answer': 'Une interface définit un contrat : une liste de méthodes qu\'une classe doit implémenter, sans fournir d\'implémentation.'},
        {'question': 'Qu\'est-ce qu\'une classe abstraite ?', 'answer': 'Une classe abstraite ne peut pas être instanciée directement. Elle peut contenir des méthodes abstraites (sans corps) et des méthodes concrètes.'},
        {'question': 'Qu\'est-ce qu\'un constructeur ?', 'answer': 'Un constructeur est une méthode spéciale appelée lors de la création d\'un objet. Il initialise les attributs de l\'instance.'},
        {'question': 'Qu\'est-ce que le principe SOLID ?', 'answer': 'SOLID : Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion. 5 principes de conception OO.'},
        {'question': 'Qu\'est-ce qu\'un design pattern ?', 'answer': 'Un design pattern est une solution réutilisable à un problème courant de conception logicielle. Ex: Singleton, Factory, Observer.'},
        {'question': 'Qu\'est-ce que le pattern Singleton ?', 'answer': 'Le Singleton garantit qu\'une classe n\'a qu\'une seule instance et fournit un point d\'accès global à cette instance.'},
        {'question': 'Qu\'est-ce que la composition vs l\'héritage ?', 'answer': 'La composition ("has-a") est souvent préférée à l\'héritage ("is-a") car elle offre plus de flexibilité et évite le couplage fort.'},
      ],
      'Général': [
        {'question': 'Qu\'est-ce que le contrôle de version Git ?', 'answer': 'Git est un système de contrôle de version distribué qui permet de suivre les modifications du code, collaborer et revenir à des versions précédentes.'},
        {'question': 'Qu\'est-ce qu\'une API REST ?', 'answer': 'Une API REST utilise HTTP pour exposer des ressources via des URLs. Elle utilise GET, POST, PUT, DELETE pour les opérations CRUD.'},
        {'question': 'Qu\'est-ce que JSON ?', 'answer': 'JSON (JavaScript Object Notation) est un format léger d\'échange de données, lisible par l\'humain et facile à parser par les machines.'},
        {'question': 'Qu\'est-ce que le CSS Flexbox ?', 'answer': 'Flexbox est un modèle de mise en page CSS qui permet d\'aligner et distribuer l\'espace entre les éléments d\'un conteneur de manière flexible.'},
        {'question': 'Qu\'est-ce qu\'une base de données relationnelle ?', 'answer': 'Une BDD relationnelle organise les données en tables liées entre elles par des relations. Elle utilise SQL pour les requêtes.'},
        {'question': 'Qu\'est-ce que le cloud computing ?', 'answer': 'Le cloud computing fournit des ressources informatiques (serveurs, stockage, logiciels) via Internet à la demande, sans infrastructure locale.'},
        {'question': 'Qu\'est-ce que CI/CD ?', 'answer': 'CI (Intégration Continue) automatise les tests. CD (Déploiement Continu) automatise la mise en production. Ensemble ils accélèrent le développement.'},
        {'question': 'Qu\'est-ce qu\'un framework ?', 'answer': 'Un framework est une structure préconçue qui fournit des outils, bibliothèques et conventions pour développer des applications plus rapidement.'},
        {'question': 'Qu\'est-ce que le responsive design ?', 'answer': 'Le responsive design adapte l\'interface d\'une application à différentes tailles d\'écran (mobile, tablette, desktop) via des media queries CSS.'},
        {'question': 'Qu\'est-ce que l\'authentification JWT ?', 'answer': 'JWT (JSON Web Token) est un standard pour transmettre des informations de manière sécurisée entre parties sous forme de token signé.'},
      ],
    };

    return bank[category] ?? bank['Général']!;
  }

  void addCard(Flashcard card) {
    _cards.add(card);
    notifyListeners();
  }

  void updateCard(Flashcard updatedCard) {
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _cards[index] = updatedCard;
      notifyListeners();
    }
  }

  void deleteCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void recordAnswer(String cardId, bool isCorrect) {
    final card = _cards.firstWhere((c) => c.id == cardId);
    card.recordAnswer(isCorrect);
    notifyListeners();
  }

  void addSessionResult(SessionResult result) {
    _history.insert(0, result);
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
}