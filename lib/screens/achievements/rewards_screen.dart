import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

 @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Nivel 1',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 50 / 200,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.primary.withAlpha(51),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('50 / 200 XP', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCategoryTile(
            title: 'Primeros Pasos',
            children: const [
              ListTile(title: Text('Logro de ejemplo 1')),
              ListTile(title: Text('Logro de ejemplo 2')),
            ],
          ),
          _buildCategoryTile(
            title: 'Hitos Acumulativos',
            children: const [
              ListTile(title: Text('Logro de ejemplo 1')),
              ListTile(title: Text('Logro de ejemplo 2')),
            ],
          ),
          _buildCategoryTile(
            title: 'Metas Personales',
            children: const [
              ListTile(title: Text('Logro de ejemplo 1')),
              ListTile(title: Text('Logro de ejemplo 2')),
            ],
          ),
          _buildCategoryTile(
            title: 'Exploración y Curiosidad',
            children: const [
              ListTile(title: Text('Logro de ejemplo 1')),
              ListTile(title: Text('Logro de ejemplo 2')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }
}
