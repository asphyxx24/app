import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mein_organizer/app.dart';
import 'package:mein_organizer/features/notes/notes_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final noteCount = ref.watch(noteCountProvider);
    final noteSubtitle = noteCount.when(
      data: (count) => count > 0 ? '$count Notizen' : 'Texte & Zeichnungen',
      loading: () => 'Texte & Zeichnungen',
      error: (_, _) => 'Texte & Zeichnungen',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Organizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Willkommen!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Was moechtest du tun?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _FeatureTile(
                    icon: Icons.edit_note_rounded,
                    label: 'Notizen',
                    subtitle: noteSubtitle,
                    color: const Color(0xFF4A6CF7),
                    onTap: () => _navigateToTab(context, 1),
                  ),
                  _FeatureTile(
                    icon: Icons.style_rounded,
                    label: 'Karteikarten',
                    subtitle: 'Lernen mit FSRS',
                    color: const Color(0xFFE85D75),
                    onTap: () => _navigateToTab(context, 2),
                  ),
                  _FeatureTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Kalender',
                    subtitle: 'Termine & Erinnerungen',
                    color: const Color(0xFF2ECC71),
                    onTap: () => _navigateToTab(context, 3),
                  ),
                  _FeatureTile(
                    icon: Icons.smart_toy_rounded,
                    label: 'Claude',
                    subtitle: 'KI-Assistent',
                    color: const Color(0xFFD4A574),
                    onTap: () => _navigateToTab(context, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    final scaffold = context.findAncestorStateOfType<AppShellState>();
    scaffold?.setTab(index);
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

