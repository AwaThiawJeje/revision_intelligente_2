import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/flashcard.dart';
import '../models/session_result.dart';
import '../providers/app_state.dart';

// ─── Écran de choix du nombre de questions ───────────────────────────────────
class StudySetupScreen extends StatefulWidget {
  const StudySetupScreen({super.key});

  @override
  State<StudySetupScreen> createState() => _StudySetupScreenState();
}

class _StudySetupScreenState extends State<StudySetupScreen> {
  int _selectedCount = 10;
  final _customController = TextEditingController();
  bool _useCustom = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final max = state.totalCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du quiz',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cartes disponibles : $max',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
            const SizedBox(height: 24),
            const Text('Nombre de questions',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            // Boutons rapides
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 15, 20, 25, 30].map((n) {
                final available = n <= max;
                final selected = !_useCustom && _selectedCount == n;
                return GestureDetector(
                  onTap: available
                      ? () => setState(() {
                            _selectedCount = n;
                            _useCustom = false;
                          })
                      : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: available 
                            ? (selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Toutes les cartes
            GestureDetector(
              onTap: () => setState(() {
                _selectedCount = max;
                _useCustom = false;
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_useCustom && _selectedCount == max
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_useCustom && _selectedCount == max
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Toutes les cartes ($max)',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nombre personnalisé
            Row(
              children: [
                Checkbox(
                  value: _useCustom,
                  onChanged: (v) => setState(() => _useCustom = v ?? false),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Text('Nombre personnalisé : '),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    enabled: _useCustom,
                    decoration: const InputDecoration(
                      hintText: 'ex: 25',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Text('/ $max max',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
              ],
            ),
            const Spacer(),
            // Bouton démarrer
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: max == 0
                    ? null
                    : () {
                        int count = _selectedCount;
                        if (_useCustom) {
                          count = int.tryParse(_customController.text) ?? 10;
                        }
                        count = count.clamp(1, max);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudyScreen(questionCount: count),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  max == 0
                      ? 'Aucune carte disponible'
                      : 'Démarrer (${_useCustom ? (_customController.text.isEmpty ? "?" : _customController.text) : _selectedCount} questions)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Écran de révision ────────────────────────────────────────────────────────
class StudyScreen extends StatefulWidget {
  final int questionCount;
  const StudyScreen({super.key, this.questionCount = 10});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with TickerProviderStateMixin {
  List<Flashcard> _deck = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correct = 0;
  int _incorrect = 0;
  bool _sessionDone = false;
  DateTime _startTime = DateTime.now();

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deck.isEmpty) {
      final state = context.read<AppState>();
      final shuffled = List<Flashcard>.from(state.cards)..shuffle();
      _deck = shuffled.take(widget.questionCount).toList();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _answer(bool correct) {
    final state = context.read<AppState>();
    state.recordAnswer(_deck[_currentIndex].id, correct);

    setState(() {
      if (correct) _correct++;
      else _incorrect++;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_currentIndex + 1 >= _deck.length) {
        _endSession();
      } else {
        _flipController.reset();
        setState(() {
          _currentIndex++;
          _isFlipped = false;
        });
      }
    });
  }

  void _endSession() {
    final state = context.read<AppState>();
    final duration = DateTime.now().difference(_startTime);
    final result = SessionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      totalCards: _deck.length,
      correctAnswers: _correct,
      duration: duration,
    );
    state.addSessionResult(result);
    setState(() => _sessionDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionDone) return _buildSummary(context);
    if (_deck.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = _deck[_currentIndex];
    final progress = (_currentIndex + 1) / _deck.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_deck.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ScorePill(
                    count: _correct,
                    label: 'Correct',
                    color: const Color(0xFF4CAF50)),
                Text(card.category,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                _ScorePill(
                    count: _incorrect,
                    label: 'Incorrect',
                    color: const Color(0xFFF44336)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final isShowingBack = angle > pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isShowingBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: _CardFace(
                                text: card.answer,
                                label: 'RÉPONSE',
                                color: Colors.white,
                                accent: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          : _CardFace(
                              text: card.question,
                              label: 'QUESTION',
                              color: Colors.white,
                              accent: Theme.of(context).colorScheme.primary,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (!_isFlipped)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Appuyez sur la carte pour voir la réponse',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 13)),
            ),
          if (_isFlipped)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _answer(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Incorrect'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _answer(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Correct'),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 78),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final score = _deck.isEmpty ? 0 : _correct / _deck.length;
    final emoji = score >= 0.8 ? '🎉' : score >= 0.5 ? '👍' : '💪';
    final message = score >= 0.8
        ? 'Excellent travail !'
        : score >= 0.5
            ? 'Bonne progression !'
            : 'Continue à pratiquer !';

    return Scaffold(
      appBar: AppBar(title: const Text('Résultats'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _SummaryRow(
                  label: 'Score',
                  value: '${(_correct / _deck.length * 100).round()}%'),
              const Divider(height: 24),
              _SummaryRow(
                  label: 'Bonnes réponses',
                  value: '$_correct',
                  color: const Color(0xFF4CAF50)),
              const Divider(height: 24),
              _SummaryRow(
                  label: 'Mauvaises réponses',
                  value: '$_incorrect',
                  color: const Color(0xFFF44336)),
              const Divider(height: 24),
              _SummaryRow(
                  label: 'Cartes révisées', value: '${_deck.length}'),
              const SizedBox(height: 40),
              // Rejouer même nombre
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StudyScreen(questionCount: widget.questionCount),
                  ),
                ),
                icon: const Icon(Icons.replay),
                label: Text(
                    'Rejouer (${widget.questionCount} questions)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudySetupScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.tune),
                      label: const Text('Changer'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          foregroundColor: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home),
                      label: const Text('Accueil'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text, label;
  final Color color, accent;

  const _CardFace({
    required this.text,
    required this.label,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _ScorePill(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$count',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _SummaryRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 16)),
        Text(value,
            style: TextStyle(
                color: color ?? Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}