import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/widgets/empty_state_widget.dart';

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final Box<FoodLog> _foodLogBox;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _foodLogBox = Hive.box<FoodLog>('food_logs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              formatButtonVisible: true,
              formatButtonTextStyle: const TextStyle().copyWith(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            calendarStyle: CalendarStyle(
              cellPadding: const EdgeInsets.all(4),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('Selecciona un día para ver el detalle'),
                  )
                : _buildDailyMealDetails(context, _selectedDay!),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMealDetails(BuildContext context, DateTime date) {
    return ValueListenableBuilder<Box<FoodLog>>(
      valueListenable: _foodLogBox.listenable(),
      builder: (context, box, _) {
        final dailyLogs = _getLogsForDay(date);

        if (dailyLogs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.calendar_month_outlined,
            title: 'Sin comidas registradas',
            subtitle: 'No hay comidas consumidas para este día.',
            iconColor: Colors.orange[400],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: dailyLogs.length,
          itemBuilder: (context, index) {
            final log = dailyLogs[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getMealIcon(log.mealType),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          log.mealType,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      log.foodName,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${log.calories.toStringAsFixed(0)} kcal | 🥩 ${log.protein.toStringAsFixed(0)}g, 🍞 ${log.carbohydrates.toStringAsFixed(0)}g, 🧈 ${log.fat.toStringAsFixed(0)}g',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        iconSize: 20,
                        onPressed: () => _confirmDelete(context, log),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<FoodLog> _getLogsForDay(DateTime day) {
    return _foodLogBox.values.where((log) {
      return log.date.year == day.year &&
          log.date.month == day.month &&
          log.date.day == day.day;
    }).toList();
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Desayuno':
        return Icons.free_breakfast;
      case 'Almuerzo':
        return Icons.lunch_dining;
      case 'Cena':
        return Icons.dinner_dining;
      case 'Snack':
      case 'Snacks':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  void _confirmDelete(BuildContext context, FoodLog log) {
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
                _foodLogBox.delete(log.key);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
