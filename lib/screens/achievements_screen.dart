import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
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
    setState(() {
      _userLevel = _achievementService.calculateLevel();
      _userXP = _achievementService.getTotalXP();
      _xpForNextLevel = _achievementService.getXPForNextLevel(_userLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat xpFormat = NumberFormat('#,##0', 'es_ES');
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withAlpha(150),
                ],
              ),
            ),
            child: FutureBuilder<Map<String, List<Achievement>>>(
          future: _groupedAchievementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay logros disponibles.'));
            }

            final groupedAchievements = snapshot.data!;
            final sortedCategories = groupedAchievements.keys.toList()..sort();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildLevelCard(xpFormat, theme),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = sortedCategories[index];
                      final achievements = groupedAchievements[category]!;
                      return _AchievementCategoryCard(
                        category: category,
                        achievements: achievements,
                      );
                    },
                    childCount: sortedCategories.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(NumberFormat xpFormat, ThemeData theme) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel $_userLevel',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
                shadows: [const Shadow(blurRadius: 2, color: Colors.black26)],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _userXP / _xpForNextLevel,
                minHeight: 18,
                backgroundColor: Colors.white.withAlpha(77),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${xpFormat.format(_userXP)} / ${xpFormat.format(_xpForNextLevel)} XP',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCategoryCard extends StatelessWidget {
  final String category;
  final List<Achievement> achievements;

  const _AchievementCategoryCard({
    required this.category,
    required this.achievements,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Exploración y Curiosidad':
        return PhosphorIcons.compass(PhosphorIconsStyle.duotone);
      case 'Hitos Acumulativos':
        return PhosphorIcons.trophy(PhosphorIconsStyle.duotone);
      case 'Metas Personales':
        return PhosphorIcons.target(PhosphorIconsStyle.duotone);
      case 'Primeros Pasos':
        return PhosphorIcons.sneaker(PhosphorIconsStyle.duotone);
      case 'Rachas Legendarias':
        return PhosphorIcons.crown(PhosphorIconsStyle.duotone);
      default:
        return PhosphorIcons.star(PhosphorIconsStyle.duotone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(
          _getIconForCategory(category),
          size: 32,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          category,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: achievements.map((ach) => _AchievementTile(achievement: ach)).toList(),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = achievement.isUnlocked;
    final theme = Theme.of(context);
    final Color progressColor = isUnlocked ? theme.colorScheme.primary : Colors.grey.shade400;

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? progressColor.withAlpha(128) : Colors.grey.shade300,
          ),
          color: isUnlocked ? progressColor.withAlpha(26) : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isUnlocked ? progressColor.withAlpha(51) : Colors.grey.shade200,
              child: Icon(
                achievement.icon,
                size: 28,
                color: isUnlocked ? progressColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isUnlocked ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(204),
                    ),
                  ),
                  if (achievement.goal > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: achievement.progress / achievement.goal,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,##0', 'es_ES').format(achievement.progress)} / ${NumberFormat('#,##0', 'es_ES').format(achievement.goal)} ${achievement.unit}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
