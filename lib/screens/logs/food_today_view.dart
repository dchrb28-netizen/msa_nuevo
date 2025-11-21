import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/screens/food/food_log_list_view.dart';

class FoodTodayView extends StatefulWidget {
  const FoodTodayView({super.key});

  @override
  State<FoodTodayView> createState() => _FoodTodayViewState();
}

class _FoodTodayViewState extends State<FoodTodayView> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDate(-1),
              ),
              Text(
                DateFormat.yMMMd('es').format(_selectedDate),
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: DateUtils.isSameDay(_selectedDate, DateTime.now())
                    ? null
                    : () => _changeDate(1),
              ),
            ],
          ),
        ),
        _buildCaloriesSummaryCard(context),
        const SizedBox(height: 16),
        Expanded(child: FoodLogListView(date: _selectedDate)),
        const SizedBox(height: 80), // Padding for the FAB
      ],
    );
  }

  Widget _buildCaloriesSummaryCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final caloricGoal = user?.calorieGoal;
    final dietPlan = user?.dietPlan ?? 'Mantener';

    if (caloricGoal == null || caloricGoal == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        elevation: 2,
        color: const Color(0xFFFFF0F5), // Lavender blush like color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Define tu objetivo calórico',
                style: GoogleFonts.lato(
                  color: const Color(0xFFE57373),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aún no has establecido una meta de calorías. ¡Defínela para un mejor seguimiento!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Ir a Ajustes'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaloricGoalsScreen(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final dailyLogs = box.values.where(
          (log) => isSameDay(log.date, _selectedDate),
        );
        final totalCalories = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.calories,
        );
        final totalProteins = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.protein,
        );
        final totalCarbs = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.carbohydrates,
        );
        final totalFats = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.fat,
        );
        final remainingCalories = caloricGoal - totalCalories;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          elevation: 2,
          color: const Color(0xFFFFF0F5), // Lavender blush like color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Plan: ${dietPlan.replaceAll('Peso', '').trim()}',
                  style: GoogleFonts.lato(
                    color: const Color(0xFFE57373),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildCalorieInfo(
                        'Meta',
                        caloricGoal.toInt(),
                        const Color(0xFFFFA726),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '-',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildCalorieInfo(
                        'Consumidas',
                        totalCalories.toInt(),
                        Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '=',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildCalorieInfo(
                        'Restantes',
                        remainingCalories.toInt(),
                        const Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: _buildMacroInfo(
                            'Proteínas', totalProteins, Colors.green)),
                    Expanded(
                        child: _buildMacroInfo(
                            'Carbs', totalCarbs, Colors.orange)),
                    Expanded(
                        child: _buildMacroInfo(
                            'Grasas', totalFats, Colors.redAccent)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalorieInfo(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMacroInfo(String title, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} g',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
