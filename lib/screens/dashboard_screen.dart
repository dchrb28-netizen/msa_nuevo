import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/providers/water_intake_provider.dart';
import 'package:myapp/screens/meditation_screen.dart';
import 'package:myapp/screens/training/workout_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:myapp/data/motivational_quotes.dart';
import 'package:myapp/widgets/dashboard/pending_reminders_widget.dart';
import 'package:myapp/widgets/routine_status_button.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    }
    if (hour < 20) {
      return 'Buenas tardes';
    }
    return 'Buenas noches';
  }

  String _getMotivationalQuote() {
    final random = Random();
    return motivationalQuotes[random.nextInt(motivationalQuotes.length)];
  }

  String getFrameForTitle(String? title) {
    if (title == null) return 'assets/marcos/marco_bienvenido.png';
    return 'assets/marcos/marco_${title.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 14),
            const PendingRemindersWidget(),
            const SizedBox(height: 14),
            _buildTrainingCard(context),
            const SizedBox(height: 14),
            _buildDailyProgressRings(context),
            const SizedBox(height: 14),
            _buildMeditationCard(context),
            const SizedBox(height: 14),
            _buildMotivationalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    debugPrint('[Dashboard] _buildWelcomeHeader');
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;

        final selectedTitle = achievementService.userProfile.selectedTitle;
        final frameAsset = getFrameForTitle(selectedTitle);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo decorativo
                  if (user?.showProfileFrame ?? true)
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.5),
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  // Marco del perfil
                  if (user?.showProfileFrame ?? true)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          frameAsset,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    backgroundImage: user?.profileImageBytes != null
                        ? MemoryImage(user!.profileImageBytes!)
                        : null,
                    child: user?.profileImageBytes == null
                        ? Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.duotone),
                            size: 26,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer)
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Invitado',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingCard(BuildContext context) {
    final String dayOfWeek = DateFormat('EEEE', 'es_ES').format(DateTime.now());

    debugPrint('[Dashboard] _buildTrainingCard');
    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        final todayRoutines = routineProvider.routines
            .where((r) => r.activeDays
                .any((d) => d.toLowerCase() == dayOfWeek.toLowerCase()))
            .toList();
        final isRestDay = todayRoutines.isEmpty;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isRestDay ? Colors.grey[800] : const Color(0xFFB3E5FC),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isRestDay
                      ? PhosphorIcons.bed(PhosphorIconsStyle.duotone)
                      : PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                  size: 28,
                  color: isRestDay ? Colors.white : const Color(0xFF1976D2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRestDay
                            ? '¡A recargar energías!'
                            : (todayRoutines.length == 1
                                ? 'Tu Reto de Hoy'
                                : 'Rutinas para Hoy'),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isRestDay
                              ? Colors.white70
                              : const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isRestDay)
                        Text(
                          'Día de Descanso',
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (todayRoutines.length == 1)
                        Text(
                          todayRoutines.first.name,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D47A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: todayRoutines.map((routine) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.fitness_center, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      routine.name,
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0D47A1),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  RoutineStatusButton(routine: routine),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                if (!isRestDay && todayRoutines.length == 1)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label:
                        const Text('Comenzar', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WorkoutScreen(routine: todayRoutines.first)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeditationCard(BuildContext context) {
    debugPrint('[Dashboard] _buildMeditationCard');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeditationScreen()),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade200.withOpacity(0.5),
                  ),
                  child: Icon(
                    PhosphorIcons.leaf(PhosphorIconsStyle.duotone),
                    size: 28,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meditación',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Encuentra tu paz interior',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.purple.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade100,
            ],
          ),
          border: Border.all(
            color: Colors.amber.shade200,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Consejo del Día',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Text(
                  _getMotivationalQuote(),
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyProgressRings(BuildContext context) {
    debugPrint('[Dashboard] _buildDailyProgressRings');
    return Consumer2<RoutineProvider, WaterIntakeProvider>(
      builder: (context, routineProvider, waterProvider, child) {
        // routines for today (not required for this card)
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.fire(PhosphorIconsStyle.duotone),
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Progreso Diario',
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                    ),
                    Builder(builder: (ctx) {
                      final user =
                          Provider.of<UserProvider>(ctx, listen: false).user;
                      final planLabel = (user?.dietPlan ?? 'Mantener');
                      Color chipColor =
                          Theme.of(context).colorScheme.secondaryContainer;
                      Color textColor =
                          Theme.of(context).colorScheme.onSecondaryContainer;
                      IconData planIcon = PhosphorIcons.clockCounterClockwise(
                          PhosphorIconsStyle.fill);
                      final lower = planLabel.toLowerCase();
                      if (lower.contains('mantener')) {
                        chipColor = Colors.green.shade100;
                        textColor = Colors.green.shade800;
                        planIcon = PhosphorIcons.clockCounterClockwise(
                            PhosphorIconsStyle.fill);
                      } else if (lower.contains('déficit') ||
                          lower.contains('deficit') ||
                          lower.contains('perder')) {
                        chipColor = Colors.orange.shade100;
                        textColor = Colors.orange.shade800;
                        planIcon =
                            PhosphorIcons.arrowDown(PhosphorIconsStyle.fill);
                      } else if (lower.contains('superávit') ||
                          lower.contains('superavit') ||
                          lower.contains('ganar') ||
                          lower.contains('aument')) {
                        chipColor = Colors.red.shade100;
                        textColor = Colors.red.shade800;
                        planIcon =
                            PhosphorIcons.arrowUp(PhosphorIconsStyle.fill);
                      }
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).push(MaterialPageRoute(
                              builder: (_) => const CaloricGoalsScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: chipColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(planIcon, size: 16, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Text(planLabel,
                                style: GoogleFonts.lato(
                                    fontSize: 12, color: textColor)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Calorías
                    Expanded(
                      child: _buildProgressIndicator(
                        context,
                        title: 'Calorías',
                        builder: (ctx) {
                          return ValueListenableBuilder(
                            valueListenable:
                                Hive.box<FoodLog>('food_logs').listenable(),
                            builder: (context, Box<FoodLog> box, _) {
                              final user =
                                  Provider.of<UserProvider>(ctx, listen: false)
                                      .user;
                              final caloricGoal = user?.calorieGoal ?? 0.0;
                              final today = DateTime.now();
                              final totalCalories = box.values
                                  .where((log) =>
                                      log.date.year == today.year &&
                                      log.date.month == today.month &&
                                      log.date.day == today.day)
                                  .fold<double>(
                                      0, (sum, log) => sum + log.calories);
                              final caloriePercent = caloricGoal > 0
                                  ? (totalCalories / caloricGoal)
                                      .clamp(0.0, 1.0)
                                  : 0.0;
                              final displayValue = caloricGoal > 0
                                  ? '${totalCalories.toInt()} / ${caloricGoal.toInt()}'
                                  : 'Sin definir';
                              return _ProgressData(
                                percent: caloriePercent,
                                icon: Icon(
                                    PhosphorIcons.fire(PhosphorIconsStyle.fill),
                                    color: Colors.orange,
                                    size: 24),
                                progressColor: Colors.orange,
                                value: displayValue,
                                unit: 'kcal',
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Agua
                    Expanded(
                      child: _buildProgressIndicator(
                        context,
                        title: 'Agua',
                        builder: (ctx) {
                          return ValueListenableBuilder(
                            valueListenable:
                                Hive.box<WaterLog>('water_logs').listenable(),
                            builder: (context, Box<WaterLog> box, _) {
                              final waterProvider =
                                  Provider.of<WaterIntakeProvider>(ctx,
                                      listen: false);
                              final waterGoal = waterProvider.dailyGoal;
                              final totalWater = waterProvider
                                  .getWaterIntakeForDate(DateTime.now());
                              final waterPercent = waterGoal > 0
                                  ? (totalWater / waterGoal).clamp(0.0, 1.0)
                                  : 0.0;
                              final displayValue =
                                  '${totalWater.toInt()} / ${waterGoal.toInt()}';
                              return _ProgressData(
                                percent: waterPercent,
                                icon: Icon(
                                    PhosphorIcons.drop(PhosphorIconsStyle.fill),
                                    color: Colors.blue,
                                    size: 24),
                                progressColor: Colors.blue,
                                value: displayValue,
                                unit: 'ml',
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Entrenamiento
                    Expanded(
                      child: _buildProgressIndicator(
                        context,
                        title: 'Entrenamiento',
                        builder: (ctx) {
                          return ValueListenableBuilder(
                            valueListenable:
                                Hive.box<RoutineLog>('routine_logs')
                                    .listenable(),
                            builder: (context, Box<RoutineLog> box, _) {
                              final now = DateTime.now();
                              final trainedToday = box.values.any((log) =>
                                  log.date.year == now.year &&
                                  log.date.month == now.month &&
                                  log.date.day == now.day);
                              return _ProgressData(
                                percent: trainedToday ? 1.0 : 0.0,
                                icon: Icon(
                                    PhosphorIcons.barbell(
                                        PhosphorIconsStyle.duotone),
                                    color: Colors.green,
                                    size: 24),
                                progressColor: Colors.green,
                                value: trainedToday ? '¡Hecho!' : 'Pendiente',
                                unit: 'Hoy',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context, {
    required String title,
    required Widget Function(BuildContext) builder,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer
                .withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Builder(builder: builder),
      ],
    );
  }
}

class _ProgressData extends StatelessWidget {
  final double percent;
  final Widget icon;
  final Color progressColor;
  final String value;
  final String unit;

  const _ProgressData({
    required this.percent,
    required this.icon,
    required this.progressColor,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 92,
          width: 92,
          child: CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 6.0,
            percent: percent,
            center: icon,
            progressColor: progressColor,
            backgroundColor: progressColor.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          unit,
          style: GoogleFonts.lato(color: Colors.grey, fontSize: 9),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
