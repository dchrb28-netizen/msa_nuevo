import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/menus/edit_meal_screen.dart';
import 'package:myapp/screens/menus/meal_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18),
              formatButtonDecoration: BoxDecoration(
                color: themeProvider.seedColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: themeProvider.seedColor.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: themeProvider.seedColor,
                shape: BoxShape.circle,
              ),
            ),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.repeat),
              label: const Text('Repetir Semana'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40), 
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan de la semana copiado a la siguiente.')),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 7, 
              itemBuilder: (context, index) {
                // Calculate the day of the week based on the focused day
                final firstDayOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
                final day = firstDayOfWeek.add(Duration(days: index));
                final formattedDay = DateFormat('EEEE, d MMMM', 'es_ES').format(day);
                final isSelected = isSameDay(day, _selectedDay);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: isSelected ? 6 : 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: isSelected ? themeProvider.seedColor.withAlpha(26) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDay,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: themeProvider.seedColor
                          ),
                        ),
                        const Divider(height: 20),
                        _buildMealRow(context, 'Desayuno', Icons.free_breakfast, day),
                        _buildMealRow(context, 'Almuerzo', Icons.lunch_dining, day),
                        _buildMealRow(context, 'Cena', Icons.dinner_dining, day),
                        _buildMealRow(context, 'Snacks', Icons.fastfood, day),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(BuildContext context, String meal, IconData icon, DateTime day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary.withAlpha(204), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(meal, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            tooltip: 'Ver',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailScreen(mealType: meal, date: day),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Editar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMealScreen(mealType: meal, date: day),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
