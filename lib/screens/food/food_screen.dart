import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/food/food_today_screen.dart';
import 'package:myapp/screens/register_food_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:table_calendar/table_calendar.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Hoy'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
          labelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FoodTodayScreen(),
              FoodHistoryTab(), // Replaced with the new history widget
            ],
          ),
        ),
      ],
    );
  }
}

// New Stateful Widget for the "Historial" Tab
class FoodHistoryTab extends StatefulWidget {
  const FoodHistoryTab({super.key});

  @override
  State<FoodHistoryTab> createState() => _FoodHistoryTabState();
}

class _FoodHistoryTabState extends State<FoodHistoryTab> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late final Box<FoodLog> _foodLogBox;

  @override
  void initState() {
    super.initState();
    _foodLogBox = Hive.box<FoodLog>('food_logs');
  }

  List<FoodLog> _getLogsForDay(DateTime day) {
    return _foodLogBox.values.where((log) => isSameDay(log.date, day)).toList();
  }

  void _addFoodLog() async {
    final result = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterFoodScreen()),
    );

    if (result != null) {
      await _foodLogBox.add(result);
      final achievementService = AchievementService();
      achievementService.grantExperience(10);
      achievementService.updateProgress('first_meal', 1);
      achievementService.updateProgress('cum_meals_500', 1, cumulative: true);
      final distinctFoods = _foodLogBox.values.map((log) => log.foodName.toLowerCase()).toSet().length;
      achievementService.updateProgress('cum_foods_50', distinctFoods);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<FoodLog>(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            locale: 'es_ES',
            calendarFormat: _calendarFormat,
            eventLoader: _getLogsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonTextStyle: const TextStyle().copyWith(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withAlpha(204),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildLogList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFoodLog,
        label: const Text('Añadir Comida'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLogList() {
    return ValueListenableBuilder<Box<FoodLog>>(
      valueListenable: _foodLogBox.listenable(),
      builder: (context, box, _) {
        final dailyLogs = _getLogsForDay(_selectedDay);

        if (dailyLogs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No hay comidas registradas para esta fecha.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: dailyLogs.length,
          itemBuilder: (context, index) {
            final log = dailyLogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(log.foodName, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${log.calories.toStringAsFixed(0)} kcal | P: ${log.protein.toStringAsFixed(0)}g, C: ${log.carbohydrates.toStringAsFixed(0)}g, G: ${log.fat.toStringAsFixed(0)}g',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, box, log),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Box<FoodLog> box, FoodLog log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el registro de "${log.foodName}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                box.delete(log.key);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}