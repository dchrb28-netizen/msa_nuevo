import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/services/achievement_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final AchievementService _achievementService = AchievementService();
  late Future<Map<String, List<Achievement>>> _groupedAchievementsFuture;
  int _userLevel = 1;
  int _userXP = 0;
  int _xpForNextLevel = 100;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _groupedAchievementsFuture = _achievementService.getGroupedAchievements();
    // Simulación de datos de nivel y XP del usuario
    // En un futuro, esto debería venir de un servicio de usuario
    _userLevel = _achievementService.calculateLevel();
    _userXP = _achievementService.getTotalXP();
    _xpForNextLevel = _achievementService.getXPForNextLevel(_userLevel);
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat xpFormat = NumberFormat('#,##0', 'es_ES');

    return Scaffold(
      body: FutureBuilder<Map<String, List<Achievement>>>(
        future: _groupedAchievementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los logros: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay logros para mostrar.'));
          }

          final groupedAchievements = snapshot.data!;
          final sortedCategories = groupedAchievements.keys.toList()..sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Level and XP Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nivel $_userLevel',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _userXP / _xpForNextLevel,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${xpFormat.format(_userXP)} / ${xpFormat.format(_xpForNextLevel)} XP',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Achievements List
                ...sortedCategories.map((category) {
                  final achievements = groupedAchievements[category]!;
                  return _AchievementCategory(
                    category: category,
                    achievements: achievements,
                  );
                }), // FIX: Removed .toList()
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AchievementCategory extends StatelessWidget {
  final String category;
  final List<Achievement> achievements;

  const _AchievementCategory({
    required this.category,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        category,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      children: achievements.map((achievement) {
        return _AchievementTile(achievement: achievement);
      }).toList(),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = achievement.isUnlocked;
    final Color progressColor = isUnlocked ? Theme.of(context).colorScheme.primary : Colors.grey.shade400;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isUnlocked ? progressColor.withAlpha((255 * 0.2).round()) : Colors.grey.shade200, // FIX: withOpacity -> withAlpha
        child: Icon(
          achievement.icon,
          color: isUnlocked ? progressColor : Colors.grey.shade600,
        ),
      ),
      title: Text(
        achievement.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decoration: isUnlocked ? TextDecoration.none : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(achievement.description),
          if (achievement.goal > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: achievement.progress / achievement.goal,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress} / ${achievement.goal} ${achievement.unit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
