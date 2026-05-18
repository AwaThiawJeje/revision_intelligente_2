import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'study_screen.dart';
// StudySetupScreen est dans study_screen.dart
import 'generate_cards_screen.dart';
import 'history_screen.dart';
import 'add_card_screen.dart';
import 'import_pdf_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Révision Intelligente',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Générer des cartes',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GenerateCardsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une carte',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddCardScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Importer un PDF',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ImportPdfScreen())),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(state: state),
                  const SizedBox(height: 24),
                  _StartStudyCard(state: state),
                  const SizedBox(height: 24),
                  Text('Mes Cartes (${state.totalCards})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final card = state.cards[i];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _CardTile(card: card, state: state),
                );
              },
              childCount: state.totalCards,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '${state.totalCards}',
            icon: Icons.style,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Maîtrisées',
            value: '${state.masteredCards}',
            icon: Icons.check_circle,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Sessions',
            value: '${state.history.length}',
            icon: Icons.bar_chart,
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

class _StartStudyCard extends StatelessWidget {
  final AppState state;
  const _StartStudyCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: state.totalCards == 0
            ? null
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StudySetupScreen())),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill,
                  size: 48, color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commencer la révision',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(
                      state.totalCards == 0
                          ? 'Ajoutez des cartes pour commencer'
                          : '${state.totalCards} cartes disponibles',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.8),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final dynamic card;
  final AppState state;
  const _CardTile({required this.card, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(card.question,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: card.difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(card.difficultyLabel,
                    style:
                        TextStyle(fontSize: 11, color: card.difficultyColor)),
              ),
              const SizedBox(width: 8),
              Text(card.category,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6))),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.error, size: 20),
          onPressed: () => state.deleteCard(card.id),
        ),
      ),
    );
  }
}
