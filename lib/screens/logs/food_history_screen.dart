import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
            calendarFormat: CalendarFormat.month, // Default to month view
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
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
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);
    final mealTypes = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks'];
    final mealIcons = [
      Icons.free_breakfast,
      Icons.lunch_dining,
      Icons.dinner_dining,
      Icons.fastfood,
    ];
    final meals = {
      for (var type in mealTypes)
        type: mealPlanProvider.getMealTextForDay(date, type),
    };
    final hasAnyMeal = meals.values.any((text) => text.isNotEmpty);

    if (!hasAnyMeal) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Sin comidas planificadas',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No hay registro de comidas para este día.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mealTypes.length,
      itemBuilder: (context, index) {
        final mealType = mealTypes[index];
        final mealText = meals[mealType]!;
        if (mealText.isEmpty) {
          return const SizedBox.shrink(); // Don't show empty cards
        }

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
                      mealIcons[index],
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mealType,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  mealText,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
