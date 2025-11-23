import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:provider/provider.dart';

class WaterIntakeProvider with ChangeNotifier {
  final Box<WaterLog> waterLogBox = Hive.box<WaterLog>('water_logs');
  final StreaksService _streaksService = StreaksService();
  final AchievementService _achievementService = AchievementService(); // Instancia del servicio de logros
  double _dailyGoal = 2000; // Default goal
  DateTime _selectedDate = DateTime.now();
  User? _currentUser;

  WaterIntakeProvider(UserProvider? userProvider) {
    if (userProvider != null) {
      _updateUser(userProvider.user);
    }
  }

  DateTime get selectedDate => _selectedDate;
  double get dailyGoal => _dailyGoal;

  void updateUser(UserProvider userProvider) {
    _updateUser(userProvider.user);
  }

  void _updateUser(User? user) {
    _currentUser = user;
    if (user?.waterGoal != null && user!.waterGoal! > 0) {
      _dailyGoal = user.waterGoal!;
    } else {
      _dailyGoal = 2000; // Default goal
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void goToPreviousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  Future<void> addWaterLog(double amount) async {
    if (_currentUser == null) return;
    final log = WaterLog(
      id: DateTime.now().toString(),
      userId: _currentUser!.id,
      amount: amount,
      timestamp: _selectedDate,
    );
    await waterLogBox.add(log);

    // Otorga XP por registrar agua
    _achievementService.grantExperience(5); 

    // Actualiza logros relevantes
    _achievementService.updateProgress('first_water_log', 1);

    // CORRECTED: Pass the incremental amount, not the total.
    _achievementService.updateProgress('cum_water_10', amount.toInt(), cumulative: true);
    _achievementService.updateProgress('cum_water_1000', amount.toInt(), cumulative: true);

    notifyListeners();

    // Actualiza la racha de hidratación si se cumple la meta
    final totalTodayForStreak = getWaterIntakeForDate(_selectedDate);
    if (totalTodayForStreak >= _dailyGoal) {
      await _streaksService.updateHydrationStreak();
    }
  }

  void editWaterLog(WaterLog log, double newAmount) {
    log.amount = newAmount;
    log.save();
    notifyListeners();
  }

  void deleteWaterLog(WaterLog log) {
    log.delete();
    notifyListeners(); 
  }

  double getWaterIntakeForDate(DateTime date) {
    if (_currentUser == null) return 0;
    final logs = waterLogBox.values.where((log) {
      return log.userId == _currentUser!.id &&
          log.timestamp.year == date.year &&
          log.timestamp.month == date.month &&
          log.timestamp.day == date.day;
    });
    return logs.fold(0, (sum, log) => sum + log.amount);
  }

  List<WaterLog> getLogsForSelectedDate() {
    if (_currentUser == null) return [];
    final logs = waterLogBox.values.where((log) {
      return log.userId == _currentUser!.id &&
          log.timestamp.year == _selectedDate.year &&
          log.timestamp.month == _selectedDate.month &&
          log.timestamp.day == _selectedDate.day;
    }).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  void showEditGoalDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    if (currentUser == null) return;

    final TextEditingController controller = TextEditingController(
      text: _dailyGoal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta Diaria'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Meta (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                final updatedUser = currentUser.copyWith(waterGoal: newGoal);
                userProvider.updateUser(updatedUser);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
