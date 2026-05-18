import 'package:flutter/material.dart';

class SessionResult {
  final String id;
  final DateTime date;
  final int totalCards;
  final int correctAnswers;
  final Duration duration;
  final String category;

  SessionResult({
    required this.id,
    required this.date,
    required this.totalCards,
    required this.correctAnswers,
    required this.duration,
    this.category = 'Toutes',
  });

  double get score => totalCards == 0 ? 0 : correctAnswers / totalCards;

  String get scorePercent => '${(score * 100).round()}%';

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedDuration {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}
