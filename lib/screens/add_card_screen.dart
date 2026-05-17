import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/app_state.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'Général');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final card = Flashcard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionCtrl.text.trim(),
      answer: _answerCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'Général'
          : _categoryCtrl.text.trim(),
    );

    context.read<AppState>().addCard(card);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Carte ajoutée avec succès !'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );

    _questionCtrl.clear();
    _answerCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle carte',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Question',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Entrez votre question...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              const Text('Réponse',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Entrez la réponse...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              const Text('Catégorie',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryCtrl,
                decoration: InputDecoration(
                  hintText: 'ex: Maths, Langues, Informatique...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                ),
              ),
              if (state.categories.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: state.categories
                      .map((cat) => ActionChip(
                            label: Text(cat, style: const TextStyle(fontSize: 12)),
                            onPressed: () =>
                                setState(() => _categoryCtrl.text = cat),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.add_card),
                  label: const Text('Ajouter la carte',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}