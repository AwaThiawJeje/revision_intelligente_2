import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class GenerateCardsScreen extends StatefulWidget {
  const GenerateCardsScreen({super.key});

  @override
  State<GenerateCardsScreen> createState() => _GenerateCardsScreenState();
}

class _GenerateCardsScreenState extends State<GenerateCardsScreen> {
  String _selectedCategory = 'Flutter';
  int _selectedCount = 10;
  final _customController = TextEditingController();
  bool _useCustom = false;
  bool _generated = false;

  final List<String> _categories = [
    'Flutter',
    'Dart',
    'Algorithmique',
    'POO',
    'Général',
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer des cartes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Génère automatiquement des flashcards prêtes à l\'emploi selon la catégorie choisie.',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Catégorie
            const Text('Catégorie',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Nombre de cartes
            const Text('Nombre de cartes à générer',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [5, 10, 15, 20, 25, 30].map((n) {
                final selected =
                    !_useCustom && _selectedCount == n;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCount = n;
                    _useCustom = false;
                  }),
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
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
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Nombre personnalisé
            Row(
              children: [
                Checkbox(
                  value: _useCustom,
                  onChanged: (v) =>
                      setState(() => _useCustom = v ?? false),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Text('Personnalisé : '),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    enabled: _useCustom,
                    decoration: const InputDecoration(
                      hintText: 'ex: 50',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Text('cartes',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 32),

            // Bouton générer
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  int count = _useCustom
                      ? (int.tryParse(_customController.text) ?? 10)
                      : _selectedCount;
                  count = count.clamp(1, 100);

                  context
                      .read<AppState>()
                      .generateCards(count, _selectedCategory);

                  setState(() => _generated = true);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '$count cartes $_selectedCategory générées ! ✅'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  'Générer ${_useCustom ? (_customController.text.isEmpty ? "?" : _customController.text) : _selectedCount} cartes $_selectedCategory',
                ),
              ),
            ),

            if (_generated) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _generated = false);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Générer encore'),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // Total cartes
            Consumer<AppState>(
              builder: (_, state, __) => Center(
                child: Text(
                  'Total dans l\'app : ${state.totalCards} cartes',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}