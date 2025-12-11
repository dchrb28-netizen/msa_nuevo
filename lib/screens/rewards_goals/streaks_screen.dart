import 'package:flutter/material.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Modelo para combinar datos del servicio con datos estáticos de la UI
class StreakInfo {
  final String title;
  final String description;
  final IconData icon;
  final StreakData data;

  StreakInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.data,
  });
}

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  final StreaksService _streaksService = StreaksService();
  late Future<List<StreakInfo>> _streaksFuture;

  @override
  void initState() {
    super.initState();
    _streaksFuture = _loadStreaks();
  }

  Future<List<StreakInfo>> _loadStreaks() async {
    final hydrationData = await _streaksService.getHydrationStreak();
    final mealData = await _streaksService.getMealStreak();
    final workoutData = await _streaksService.getWorkoutStreak();
    final calorieData = await _streaksService.getCalorieStreak();
    final fastingData = await _streaksService.getFastingStreak();
    final meditationData = await _streaksService.getMeditationStreak();

    return [
      StreakInfo(
        title: 'Racha de Hidratación',
        description: 'Días seguidos alcanzando tu meta de agua.',
        icon: PhosphorIcons.drop(),
        data: hydrationData,
      ),
      StreakInfo(
        title: 'Racha de Registro de Comidas',
        description: 'Días seguidos registrando al menos una comida.',
        icon: PhosphorIcons.notebook(),
        data: mealData,
      ),
      StreakInfo(
        title: 'Racha de Entrenamiento',
        description: 'Días seguidos completando una rutina.',
        icon: PhosphorIcons.barbell(),
        data: workoutData,
      ),
      StreakInfo(
        title: 'Racha de Calorías Objetivo',
        description: 'Días seguidos dentro de tu rango de calorías.',
        icon: PhosphorIcons.target(),
        data: calorieData,
      ),
      StreakInfo(
        title: 'Racha de Ayuno Intermitente',
        description: 'Días seguidos completando tu ayuno con éxito.',
        icon: PhosphorIcons.timer(),
        data: fastingData,
      ),
      StreakInfo(
        title: 'Racha de Meditación',
        description: 'Días seguidos completando una sesión de meditación.',
        icon: PhosphorIcons.brain(),
        data: meditationData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<StreakInfo>>(
        future: _streaksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las rachas'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay rachas para mostrar'));
          }

          final streaks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: streaks.length,
            itemBuilder: (context, index) {
              return StreakCard(streak: streaks[index]);
            },
          );
        },
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  final StreakInfo streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(streak.icon, size: 32, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(streak.title,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(streak.description,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStreakCounter(context, 'Racha Actual',
                    streak.data.currentStreak, colorScheme.primary),
                _buildStreakCounter(
                    context, 'Récord', streak.data.recordStreak, colorScheme.secondary),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            _buildMilestoneTracker(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCounter(
      BuildContext context, String label, int count, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '🔥 $count ${count == 1 ? "día" : "días"}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }

  Widget _buildMilestoneTracker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMilestone(context, '3 Días', streak.data.currentStreak >= 3),
        _buildMilestone(context, '7 Días', streak.data.currentStreak >= 7),
        _buildMilestone(context, '30 Días', streak.data.currentStreak >= 30),
      ],
    );
  }

  Widget _buildMilestone(BuildContext context, String label, bool achieved) {
    final theme = Theme.of(context);
    final color = achieved ? theme.colorScheme.primary : theme.disabledColor;
    final icon = achieved ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle();

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
