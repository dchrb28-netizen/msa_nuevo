import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_log.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 16),
            const PendingRemindersWidget(),
            _buildTrainingCard(context),
            const SizedBox(height: 16),
            _buildDailyProgressRings(context),
            const SizedBox(height: 16),
            _buildMeditationCard(context),
            const SizedBox(height: 16),
            _buildMotivationalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;

        final selectedTitle = achievementService.userProfile.selectedTitle;
        final frameAsset = getFrameForTitle(selectedTitle);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (user?.showProfileFrame ?? true)
                        Image.asset(
                          frameAsset,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        backgroundImage: user?.profileImageBytes != null
                            ? MemoryImage(user!.profileImageBytes!)
                            : null,
                        child: user?.profileImageBytes == null
                            ? Icon(
                                PhosphorIcons.user(PhosphorIconsStyle.duotone),
                                size: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Invitado',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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

    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        final todayRoutines = routineProvider.routines
            .where((r) => r.activeDays
                .any((d) => d.toLowerCase() == dayOfWeek.toLowerCase()))
            .toList();
        final isRestDay = todayRoutines.isEmpty;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isRestDay
              ? Colors.grey[800]
              : Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isRestDay
                      ? PhosphorIcons.bed(PhosphorIconsStyle.duotone)
                      : PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                  size: 32,
                  color: isRestDay
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
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
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8)),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer),
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MeditationScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.leaf(PhosphorIconsStyle.duotone),
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditación',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encuentra tu paz interior.',
                      style: GoogleFonts.lato(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            Text(
              'Consejo del Día',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getMotivationalQuote(),
              style: GoogleFonts.lato(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgressRings(BuildContext context) {
    return Consumer3<UserProvider, WaterIntakeProvider, RoutineProvider>(
      builder: (context, userProvider, waterProvider, routineProvider, child) {
        // Calorías
        final caloricGoal = userProvider.user?.caloricGoal?.toInt() ?? 1520;
        final caloriesToday = (userProvider.user != null && userProvider.user!.caloriesToday != null)
            ? userProvider.user!.caloriesToday.toInt()
            : 0;
        final plan = userProvider.user?.dietPlan?.toLowerCase() ?? 'mantener';
        IconData planIcon;
        Color planColor;
        String planText;
        switch (plan) {
          case 'perder':
            planIcon = Icons.arrow_downward_rounded;
            planColor = Colors.blueAccent;
            planText = 'Perder';
            break;
          case 'mantener':
            planIcon = Icons.remove_rounded;
            planColor = Colors.amber;
            planText = 'Mantener';
            break;
          case 'ganar':
            planIcon = Icons.arrow_upward_rounded;
            planColor = Colors.green;
            planText = 'Ganar';
            break;
          default:
            planIcon = Icons.remove_rounded;
            planColor = Colors.amber;
            planText = plan[0].toUpperCase() + plan.substring(1);
        }
        // Agua
        final int waterGoal = waterProvider.dailyGoal > 0 ? waterProvider.dailyGoal.toInt() : 2000;
        final int totalWater = waterProvider.getWaterIntakeForDate(DateTime.now()).toInt();
        // Entrenamiento
        final String dayOfWeek = DateFormat('EEEE', 'es_ES').format(DateTime.now());
        final List<Routine> todayRoutines = routineProvider.routines
            .where((r) => r.activeDays.any((d) => d.toLowerCase() == dayOfWeek.toLowerCase()))
            .toList();
        final bool trainedToday = false; // Aquí deberías consultar tu base de datos de logs
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Theme.of(context).colorScheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Progreso Diario',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(planIcon, color: planColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            planText,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: planColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Calorías
                    _buildRing(
                      context,
                      color: Colors.amber,
                      icon: Icons.local_fire_department,
                      label: 'Calorías',
                      value: caloriesToday,
                      goal: caloricGoal,
                      unit: 'kcal',
                    ),
                    // Agua
                    _buildRing(
                      context,
                      color: Colors.blue,
                      icon: PhosphorIcons.drop(PhosphorIconsStyle.fill),
                      label: 'Progreso de Agua',
                      value: totalWater,
                      goal: waterGoal,
                      unit: 'ml',
                    ),
                    // Entrenamiento
                    _buildRing(
                      context,
                      color: Colors.green,
                      icon: PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                      label: 'Entrenamiento',
                      value: trainedToday ? 1 : 0,
                      goal: 1,
                      unit: 'Hoy',
                      isTraining: true,
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

  Widget _buildRing(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required int value,
    required int goal,
    required String unit,
    bool isTraining = false,
  }) {
    final percent = isTraining ? (value == 1 ? 1.0 : 0.0) : (goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percent,
            center: Icon(icon, color: color, size: 28),
            progressColor: color,
            backgroundColor: color.withOpacity(0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(
            isTraining ? (value == 1 ? 'Hecho' : 'Pendiente') : '$value / $goal',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingRing() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<RoutineLog>('routine_logs').listenable(),
      builder: (context, Box<RoutineLog> box, _) {
        final now = DateTime.now();
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final trainedToday = box.values.any((log) => isSameDay(log.date, now));
        final percent = trainedToday ? 1.0 : 0.0;

        return Column(
          children: [
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 8.0,
              percent: percent,
              center: Icon(PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                  color: Colors.green, size: 28),
              progressColor: Colors.green,
              backgroundColor: Colors.green.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              trainedToday ? '¡Hecho!' : 'Pendiente',
              style:
                  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              'Hoy',
              style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
