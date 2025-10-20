import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = List.generate(7, (index) => today.add(Duration(days: index)));

    return Scaffold(
      body: ListView.builder(
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final formattedDay = DateFormat('EEEE, d MMMM', 'es_ES').format(day);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDay,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
    );
  }

  Widget _buildMealRow(BuildContext context, String meal, IconData icon, DateTime day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Text(meal, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                tooltip: 'Ver',
                onPressed: () { 
                  // TODO: Implement view meal logic
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () {
                  // TODO: Implement edit meal logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
