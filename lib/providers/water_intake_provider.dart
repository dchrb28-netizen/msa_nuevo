import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/water_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeProvider with ChangeNotifier {
  final Box<WaterLog> _waterLogBox = Hive.box<WaterLog>('water_logs');
  DateTime _selectedDate = DateTime.now();
  double _dailyGoal = 2000.0;

  WaterIntakeProvider() {
    _loadDailyGoal();
  }

  // Getters
  DateTime get selectedDate => _selectedDate;
  double get dailyGoal => _dailyGoal;
  Box<WaterLog> get waterLogBox => _waterLogBox;

  // Methods
  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = prefs.getDouble('dailyWaterGoal') ?? 2000.0;
    notifyListeners();
  }

  Future<void> saveDailyGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('dailyWaterGoal', goal);
    _dailyGoal = goal;
    notifyListeners();
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void goToPreviousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  double getWaterIntakeForDate(User? currentUser, DateTime date) {
    if (currentUser == null) return 0;
    return _waterLogBox.values
        .where(
          (log) =>
              log.userId == currentUser.id &&
              log.timestamp.year == date.year &&
              log.timestamp.month == date.month &&
              log.timestamp.day == date.day,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  List<WaterLog> getLogsForSelectedDate(User? currentUser) {
    if (currentUser == null) return [];
    return _waterLogBox.values
        .where(
          (log) =>
              log.userId == currentUser.id &&
              log.timestamp.year == _selectedDate.year &&
              log.timestamp.month == _selectedDate.month &&
              log.timestamp.day == _selectedDate.day,
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void addWaterLog(double amount, User currentUser) {
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      amount: amount,
      timestamp: _selectedDate,
    );
    _waterLogBox.add(log);
  }

  void editWaterLog(WaterLog log, double newAmount) {
    log.amount = newAmount;
    log.save();
  }

  void deleteWaterLog(WaterLog log) {
    log.delete();
  }

  void showEditGoalDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: _dailyGoal.toString(),
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
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                saveDailyGoal(amount);
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
