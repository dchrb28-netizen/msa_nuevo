import 'package:flutter/material.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Para groupBy

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementService = Provider.of<AchievementService>(context);
    final userProfile = achievementService.userProfile;
    final achievements = achievementService.getAchievements();

    // Agrupar logros por categoría
    final achievementsByCategory = groupBy(achievements, (ach) => ach.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recompensas'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLevelProgressCard(context, userProfile),
          const SizedBox(height: 24),
          ...AchievementCategory.values.map((category) {
            final categoryAchievements = achievementsByCategory[category] ?? [];
            if (categoryAchievements.isEmpty) return const SizedBox.shrink();
            
            return _buildCategorySection(context, category, categoryAchievements);
          }),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(BuildContext context, UserProfile userProfile) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel ${userProfile.level}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              percent: userProfile.levelProgressPercentage,
              lineHeight: 12,
              barRadius: const Radius.circular(6),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              progressColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${userProfile.experiencePoints} / ${userProfile.nextLevelXp} XP',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, AchievementCategory category, List<Achievement> achievements) {
     return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(category.displayName, style: Theme.of(context).textTheme.titleLarge),
        children: achievements.map((ach) => _buildAchievementTile(context, ach)).toList(),
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, Achievement achievement) {
    final bool isUnlocked = achievement.isUnlocked;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isUnlocked ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        foregroundColor: isUnlocked ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        child: Icon(achievement.icon, size: 24),
      ),
      title: Text(achievement.name, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(178))),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(achievement.description, style: TextStyle(color: isUnlocked ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withAlpha(178))),
          if (!isUnlocked && achievement.totalSteps > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LinearPercentIndicator(
                padding: EdgeInsets.zero,
                percent: achievement.progressPercentage,
                lineHeight: 8,
                barRadius: const Radius.circular(4),
                backgroundColor: colorScheme.surfaceContainerHighest,
                progressColor: colorScheme.secondary,
                center: Text(
                  '${achievement.userProgress} / ${achievement.totalSteps} ${achievement.metric}',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      trailing: isUnlocked ? Icon(Icons.check_circle, color: Colors.green[600]) : null,
    );
  }
}
