import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/screens/training/workout_screen.dart';
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
    if (hour < 18) {
      return 'Buenas tardes';
    }
    return 'Buenas noches';
  }

  String _getMotivationalQuote() {
    final random = Random();
    return motivationalQuotes[random.nextInt(motivationalQuotes.length)];
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
            _buildMotivationalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white70,
                backgroundImage: (user?.profileImageBytes != null)
                    ? MemoryImage(user!.profileImageBytes!)
                    : null,
                child: (user?.profileImageBytes == null)
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ${user?.name ?? 'Invitado'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
    // 1. Obtener el día de la semana actual en español.
    final String dayOfWeek = DateFormat('EEEE', 'es_ES').format(DateTime.now());

    // 2. Usar el Consumer para escuchar cambios en RoutineProvider.
    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, child) {
        // 3. Obtener la rutina del proveedor.
        final Routine? todayRoutine = routineProvider.getRoutineForDay(
          dayOfWeek,
        );
        final bool isRestDay = todayRoutine == null;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // 4. Cambiar el color y el contenido según si es día de descanso.
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
                // 5. Mostrar el botón solo si hay una rutina.
                if (!isRestDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Comenzar'),
                      onPressed: () {
                        // Navegar a la pantalla de entrenamiento con la rutina obtenida.
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
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final dietPlan = user?.dietPlan ?? 'Mantener';

    final Map<String, dynamic> planDetails = {
      'Perder': {'icon': Icons.trending_down, 'color': Colors.orange.shade300},
      'Mantener': {'icon': Icons.sync, 'color': Colors.green.shade300},
      'Ganar': {'icon': Icons.trending_up, 'color': Colors.blue.shade300},
      'Personalizado': {'icon': Icons.edit, 'color': Colors.purple.shade300},
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
                Text(
                  'Progreso Diario',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user != null && !user.isGuest)
                  Chip(
                    avatar: Icon(
                      planDetails[dietPlan]?['icon'] ?? Icons.help,
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
                _buildCaloriesRing(context),
                _buildWaterRing(context),
                _buildTrainingRing(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesRing(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final caloricGoal = userProvider.user?.calorieGoal ?? 0;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final now = DateTime.now();
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final dailyLogs = box.values.where((log) => isSameDay(log.date, now));
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
              radius: 45.0,
              lineWidth: 10.0,
              percent: percent,
              center: Icon(
                Icons.local_fire_department,
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
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
            if (caloricGoal <= 0)
              Text(
                'Sin meta',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            Text('kcal', style: GoogleFonts.lato(color: Colors.grey)),
          ],
        );
      },
    );
  }

  Widget _buildWaterRing(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final waterGoal = userProvider.user?.waterGoal ?? 0;

    return ValueListenableBuilder(
      valueListenable: Hive.box<WaterLog>('water_logs').listenable(),
      builder: (context, Box<WaterLog> box, _) {
        final now = DateTime.now();
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final dailyLogs = box.values.where(
          (log) => isSameDay(log.timestamp, now),
        );
        final totalWater = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.amount,
        );
        final percent = waterGoal > 0
            ? (totalWater / waterGoal).clamp(0.0, 1.0)
            : 0.0;

        return Column(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: percent,
              center: Icon(Icons.water_drop, color: Colors.blue, size: 30),
              progressColor: Colors.blue,
              backgroundColor: Colors.blue.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            if (waterGoal > 0)
              Text(
                '${totalWater.toInt()} / $waterGoal',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
            if (waterGoal <= 0)
              Text(
                'Sin meta',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            Text('ml', style: GoogleFonts.lato(color: Colors.grey)),
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
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final trainedToday = box.values.any((log) => isSameDay(log.date, now));
        final percent = trainedToday ? 1.0 : 0.0;

        return Column(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: percent,
              center: Icon(Icons.fitness_center, color: Colors.green, size: 30),
              progressColor: Colors.green,
              backgroundColor: Colors.green.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              trainedToday ? '¡Hecho!' : 'Pendiente',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            Text('Hoy', style: GoogleFonts.lato(color: Colors.grey)),
          ],
        );
      },
    );
  }
}
