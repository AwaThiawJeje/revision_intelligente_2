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
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 14)),
            const SizedBox(height: 24),
            const Text('Nombre de questions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
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
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: available
                              ? (selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
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
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_useCustom && _selectedCount == max
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 13)),
              ],
            ),
            const Spacer(),
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

  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

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

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
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
    _feedbackController.dispose();
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
    if (_showFeedback) return;

    final state = context.read<AppState>();
    state.recordAnswer(_deck[_currentIndex].id, correct);

    setState(() {
      if (correct) _correct++;
      else _incorrect++;
      _showFeedback = true;
      _lastAnswerCorrect = correct;
    });

    _feedbackController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= _deck.length) {
        _endSession();
      } else {
        _flipController.reset();
        _feedbackController.reset();
        setState(() {
          _currentIndex++;
          _isFlipped = false;
          _showFeedback = false;
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
          // ── Barre de progression ────────────────────────────────────
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),

          // ── Score + catégorie ───────────────────────────────────────
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 13)),
                _ScorePill(
                    count: _incorrect,
                    label: 'Incorrect',
                    color: const Color(0xFFF44336)),
              ],
            ),
          ),

          // ── Carte ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: !_showFeedback ? _flip : null,
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
                              child: _buildCardWithFeedback(
                                text: card.answer,
                                label: 'RÉPONSE',
                                accent:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          : _buildCardWithFeedback(
                              text: card.question,
                              label: 'QUESTION',
                              accent: Theme.of(context).colorScheme.primary,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Hint ───────────────────────────────────────────────────
          if (!_isFlipped)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Appuyez sur la carte pour voir la réponse',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 13),
              ),
            ),

          // ── Boutons ronds ✗ / ✓ ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
                top: 16, bottom: 32, left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✗ Incorrect
                _RoundButton(
                  size: 68,
                  color: _isFlipped && !_showFeedback
                      ? const Color(0xFFFFEBEE)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.06),
                  borderColor: _isFlipped && !_showFeedback
                      ? const Color(0xFFF44336)
                      : Colors.transparent,
                  onTap: _isFlipped && !_showFeedback
                      ? () => _answer(false)
                      : null,
                  child: Icon(
                    Icons.close_rounded,
                    size: 30,
                    color: _isFlipped && !_showFeedback
                        ? const Color(0xFFF44336)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.25),
                  ),
                ),

                const SizedBox(width: 40),

                // ✓ Correct
                _RoundButton(
                  size: 68,
                  color: _isFlipped && !_showFeedback
                      ? const Color(0xFFE8F5E9)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.06),
                  borderColor: _isFlipped && !_showFeedback
                      ? const Color(0xFF4CAF50)
                      : Colors.transparent,
                  onTap: _isFlipped && !_showFeedback
                      ? () => _answer(true)
                      : null,
                  child: Icon(
                    Icons.check_rounded,
                    size: 30,
                    color: _isFlipped && !_showFeedback
                        ? const Color(0xFF4CAF50)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte avec overlay feedback ──────────────────────────────────────────
  Widget _buildCardWithFeedback({
    required String text,
    required String label,
    required Color accent,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _CardFace(
          text: text,
          label: label,
          color: Colors.white,
          accent: accent,
        ),
        if (_showFeedback)
          ScaleTransition(
            scale: _feedbackAnimation,
            child: Transform.rotate(
              angle: -0.15,
              child: Text(
                _lastAnswerCorrect ? 'Got it ✓' : "You'll see it\nnext time ✗",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _lastAnswerCorrect ? 38 : 26,
                  fontWeight: FontWeight.bold,
                  color: _lastAnswerCorrect
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  shadows: [
                    Shadow(
                      color: (_lastAnswerCorrect
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828))
                          .withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Écran résultats ──────────────────────────────────────────────────────
  Widget _buildSummary(BuildContext context) {
    final score = _deck.isEmpty ? 0.0 : _correct / _deck.length;
    final emoji = score >= 0.8 ? '🎉' : score >= 0.5 ? '👍' : '💪';
    final message = score >= 0.8
        ? 'Excellent travail !'
        : score >= 0.5
            ? 'Bonne progression !'
            : 'Continue à pratiquer !';

    return Scaffold(
      appBar: AppBar(title: const Text('Résultats'), centerTitle: true),
      body: SingleChildScrollView(
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
                label: Text('Rejouer (${widget.questionCount} questions)'),
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface),
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

// ─── Widgets partagés ─────────────────────────────────────────────────────────
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
        border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.15),
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
              color: accent.withOpacity(0.2),
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
            color: color.withOpacity(0.2),
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
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12)),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double size;

  const _RoundButton({
    required this.child,
    required this.color,
    required this.borderColor,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Center(child: child),
      ),
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
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 16)),
        Text(value,
            style: TextStyle(
                color: color ?? Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}