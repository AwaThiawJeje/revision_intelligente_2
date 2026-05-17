import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/session_result.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('Aucune session pour le moment',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Commencez une révision !',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (ctx, i) => _SessionCard(session: history[i]),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionResult session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final score = session.score;
    final scoreColor = score >= 0.8
        ? const Color(0xFF4CAF50)
        : score >= 0.5
            ? const Color(0xFFFF9800)
            : const Color(0xFFF44336);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.15),
                border: Border.all(color: scoreColor, width: 2),
              ),
              child: Center(
                child: Text(
                  session.scorePercent,
                  style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.formattedDate,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    '${session.correctAnswers}/${session.totalCards} correctes · ${session.formattedDuration}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
            // Mini bar chart
            _MiniBar(score: score, color: scoreColor),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double score;
  final Color color;
  const _MiniBar({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 8,
          height: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: (score * 100).round(),
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}