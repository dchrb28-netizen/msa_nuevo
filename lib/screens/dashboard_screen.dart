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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),
            _buildTrainingCard(context),
            const SizedBox(height: 24),
            _buildDailyProgressRings(context),
            const SizedBox(height: 24),
            _buildMeditationCard(context),
            const SizedBox(height: 24),
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
        final imageProvider = (user?.profileImageBytes != null)
            ? MemoryImage(user!.profileImageBytes!)
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (user?.showProfileFrame ?? true)
                        Image.asset(
                          frameAsset,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        backgroundImage: imageProvider as ImageProvider?,
                        child: imageProvider == null
                            ? Icon(PhosphorIcons.user(PhosphorIconsStyle.duotone),
                                size: 50,
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
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Invitado',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
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
        final Routine? todayRoutine = routineProvider.getRoutineForDay(
          dayOfWeek,
        );
        final bool isRestDay = todayRoutine == null;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isRestDay
              ? Colors.grey[800]
              : Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  isRestDay ? '¡A recargar energías!' : 'Tu Reto de Hoy',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isRestDay
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isRestDay ? 'Día de Descanso' : todayRoutine.name,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isRestDay
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (!isRestDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton.icon(
                      icon: Icon(PhosphorIcons.play(PhosphorIconsStyle.duotone)),
                      label: const Text('Comenzar'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutScreen(routine: todayRoutine),
                          ),
                        );
                      },
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeditationScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.leaf(PhosphorIconsStyle.duotone),
                size: 40,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditación',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
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
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Consejo del Día',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getMotivationalQuote(),
              style: GoogleFonts.lato(
                fontSize: 14,
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final dietPlan = user?.dietPlan ?? 'Mantener';

    final Map<String, dynamic> planDetails = {
      'Perder': {
        'icon': PhosphorIcons.trendDown(PhosphorIconsStyle.duotone),
        'color': Colors.orange.shade300
      },
      'Mantener': {
        'icon': PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.duotone),
        'color': Colors.green.shade300
      },
      'Ganar': {
        'icon': PhosphorIcons.trendUp(PhosphorIconsStyle.duotone),
        'color': Colors.blue.shade300
      },
      'Personalizado': {
        'icon': PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone),
        'color': Colors.purple.shade300
      },
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Progreso Diario',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user != null && !user.isGuest)
                  Chip(
                    avatar: Icon(
                      planDetails[dietPlan]?['icon'] ??
                          PhosphorIcons.question(PhosphorIconsStyle.duotone),
                      color: Colors.black87,
                      size: 18,
                    ),
                    label: Text(
                      dietPlan,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    backgroundColor:
                        planDetails[dietPlan]?['color'] ?? Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(child: _buildCaloriesRing(context)),
                Flexible(child: _buildWaterRing(context)),
                Flexible(child: _buildTrainingRing()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesRing(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final caloricGoal = userProvider.user?.calorieGoal ?? 0;

        return ValueListenableBuilder(
          valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
          builder: (context, Box<FoodLog> box, _) {
            final now = DateTime.now();
            bool isSameDay(DateTime d1, DateTime d2) {
              return d1.year == d2.year &&
                  d1.month == d2.month &&
                  d1.day == d2.day;
            }

            final dailyLogs =
                box.values.where((log) => isSameDay(log.date, now));
            final totalCalories = dailyLogs.fold<double>(
              0,
              (sum, log) => sum + log.calories,
            );
            final percent = caloricGoal > 0
                ? (totalCalories / caloricGoal).clamp(0.0, 1.0)
                : 0.0;

            return Column(
              children: [
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 10.0,
                  percent: percent,
                  center: Icon(
                    PhosphorIcons.fire(PhosphorIconsStyle.duotone),
                    color: Colors.orange,
                    size: 30,
                  ),
                  progressColor: Colors.orange,
                  backgroundColor: Colors.orange.shade100,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 8),
                if (caloricGoal > 0)
                  Text(
                    '${totalCalories.toInt()} / ${caloricGoal.toInt()}',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                if (caloricGoal <= 0)
                  Text(
                    'Sin definir',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                Text(
                  'kcal',
                  style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWaterRing(BuildContext context) {
    return Consumer<WaterIntakeProvider>(
      builder: (context, waterProvider, child) {
        final waterGoal = waterProvider.dailyGoal;
        final totalWater = waterProvider.getWaterIntakeForDate(DateTime.now());
        final percent =
            waterGoal > 0 ? (totalWater / waterGoal).clamp(0.0, 1.0) : 0.0;

        return Column(
          children: [
            CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 10.0,
              percent: percent,
              center: Icon(PhosphorIcons.drop(PhosphorIconsStyle.duotone),
                  color: Colors.blue, size: 30),
              progressColor: Colors.blue,
              backgroundColor: Colors.blue.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            if (waterGoal > 0)
              Text(
                '${totalWater.toInt()} / ${waterGoal.toInt()}',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            if (waterGoal <= 0)
              Text(
                'Sin definir',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            Text(
              'ml',
              style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
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
              radius: 50.0,
              lineWidth: 10.0,
              percent: percent,
              center: Icon(PhosphorIcons.barbell(PhosphorIconsStyle.duotone),
                  color: Colors.green, size: 30),
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
