
import 'package:flutter/material.dart';
class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  int correctCount;
  int totalAttempts;
  DateTime? lastReviewed;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'Général',
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.lastReviewed,
  });

  double get successRate =>
      totalAttempts == 0 ? 0 : correctCount / totalAttempts;

  String get difficultyLabel {
    if (totalAttempts == 0) return 'Nouvelle';
    if (successRate >= 0.8) return 'Maîtrisée';
    if (successRate >= 0.5) return 'En progrès';
    return 'Difficile';
  }

  Color get difficultyColor {
    if (totalAttempts == 0) return const Color(0xFF6C63FF);
    if (successRate >= 0.8) return const Color(0xFF4CAF50);
    if (successRate >= 0.5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  void recordAnswer(bool isCorrect) {
    totalAttempts++;
    if (isCorrect) correctCount++;
    lastReviewed = DateTime.now();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'answer': answer,
        'category': category,
        'correctCount': correctCount,
        'totalAttempts': totalAttempts,
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
        id: map['id'],
        question: map['question'],
        answer: map['answer'],
        category: map['category'] ?? 'Général',
        correctCount: map['correctCount'] ?? 0,
        totalAttempts: map['totalAttempts'] ?? 0,
        lastReviewed: map['lastReviewed'] != null
            ? DateTime.parse(map['lastReviewed'])
            : null,
      );
}
