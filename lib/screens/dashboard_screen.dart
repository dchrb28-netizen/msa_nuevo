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
    debugPrint('[Dashboard] _buildWelcomeHeader');
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        backgroundImage: user?.profileImageBytes != null
                            ? MemoryImage(user!.profileImageBytes!)
                            : null,
                        child: user?.profileImageBytes == null
                            ? Icon(PhosphorIcons.user(PhosphorIconsStyle.duotone),
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

    debugPrint('[Dashboard] _buildTrainingCard');
    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        final todayRoutines = routineProvider.routines
            .where((r) => r.activeDays.any((d) => d.toLowerCase() == dayOfWeek.toLowerCase()))
            .toList();
        final isRestDay = todayRoutines.isEmpty;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isRestDay ? Colors.grey[800] : Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isRestDay ? PhosphorIcons.bed(PhosphorIconsStyle.duotone) : PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                  size: 32,
                  color: isRestDay ? Colors.white : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRestDay ? '¡A recargar energías!' : (todayRoutines.length == 1 ? 'Tu Reto de Hoy' : 'Rutinas para Hoy'),
                        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: isRestDay ? Colors.white70 : Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 4),
                      if (isRestDay)
                        Text(
                          'Día de Descanso',
                          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (todayRoutines.length == 1)
                        Text(
                          todayRoutines.first.name,
                          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimaryContainer),
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
                                      style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimaryContainer),
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
                    label: const Text('Comenzar', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutScreen(routine: todayRoutines.first)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    debugPrint('[Dashboard] _buildDailyProgressRings');
    return Consumer2<RoutineProvider, WaterIntakeProvider>(
      builder: (context, routineProvider, waterProvider, child) {
        // routines for today (not required for this card)
        final double waterGoal = waterProvider.dailyGoal;
        final double totalWater = waterProvider.getWaterIntakeForDate(DateTime.now());
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
            color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.fire(PhosphorIconsStyle.duotone),
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Progreso Diario',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      ),
                      Builder(builder: (ctx) {
                        final user = Provider.of<UserProvider>(ctx, listen: false).user;
                        final planLabel = (user?.dietPlan ?? 'Mantener');
                        Color chipColor = Theme.of(context).colorScheme.secondaryContainer;
                        Color textColor = Theme.of(context).colorScheme.onSecondaryContainer;
                        IconData planIcon = PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill);
                        final lower = planLabel.toLowerCase();
                        if (lower.contains('mantener')) {
                          chipColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                          planIcon = PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill);
                        } else if (lower.contains('déficit') || lower.contains('deficit') || lower.contains('perder')) {
                          chipColor = Colors.orange.shade100;
                          textColor = Colors.orange.shade800;
                          planIcon = PhosphorIcons.arrowDown(PhosphorIconsStyle.fill);
                        } else if (lower.contains('superávit') || lower.contains('superavit') || lower.contains('ganar') || lower.contains('aument')) {
                          chipColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                          planIcon = PhosphorIcons.arrowUp(PhosphorIconsStyle.fill);
                        }
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const CaloricGoalsScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: chipColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              Text(planLabel, style: GoogleFonts.lato(fontSize: 12, color: textColor)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Calorías',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Builder(builder: (ctx) {
                              final user = Provider.of<UserProvider>(ctx, listen: false).user;
                              final caloricGoal = user?.calorieGoal ?? 0.0;
                              final foodBox = Hive.box<FoodLog>('food_logs');
                              final today = DateTime.now();
                              final totalCalories = foodBox.values
                                  .where((log) => log.date.year == today.year && log.date.month == today.month && log.date.day == today.day)
                                  .fold<double>(0, (sum, log) => sum + log.calories);
                              final caloriePercent = caloricGoal > 0 ? (totalCalories / caloricGoal).clamp(0.0, 1.0) : 0.0;
                              return Column(
                                children: [
                                  CircularPercentIndicator(
                                    radius: 40.0,
                                    lineWidth: 8.0,
                                    percent: caloriePercent,
                                    center: Icon(PhosphorIcons.fire(PhosphorIconsStyle.fill), color: Colors.orange, size: 28),
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.orange.shade100,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                  const SizedBox(height: 8),
                                  if (caloricGoal > 0)
                                    Text('${totalCalories.toInt()} / ${caloricGoal.toInt()}', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12))
                                  else
                                    Text('Sin definir', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                                  Text('kcal', style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Progreso de Agua',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            CircularPercentIndicator(
                              radius: 40.0,
                              lineWidth: 8.0,
                              percent: waterGoal > 0 ? (totalWater / waterGoal).clamp(0.0, 1.0) : 0.0,
                              center: Icon(PhosphorIcons.drop(PhosphorIconsStyle.fill), color: Colors.blue, size: 28),
                              progressColor: Colors.blue,
                              backgroundColor: Colors.blue.shade100,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            const SizedBox(height: 8),
                            if (waterGoal > 0)
                              Text('${totalWater.toInt()} / ${waterGoal.toInt()}', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12))
                            else
                              Text('Sin definir', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                            Text('ml', style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Entrenamiento',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildTrainingRing(),
                          ],
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

  Widget _buildTrainingRing() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<RoutineLog>('routine_logs').listenable(),
      builder: (context, Box<RoutineLog> box, _) {
        final now = DateTime.now();
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year &&
              d1.month == d2.month &&
              d1.day == d2.day;
        }

        final trainedToday =
            box.values.any((log) => isSameDay(log.date, now));
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
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold, fontSize: 12),
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
