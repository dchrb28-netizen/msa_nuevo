import 'package:flutter/material.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/screens/menus/edit_meal_screen.dart';
import 'package:provider/provider.dart';

class TodayMenuScreen extends StatelessWidget {
  const TodayMenuScreen({super.key});

  IconData _getIconForMealType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Icons.free_breakfast_outlined;
      case 'almuerzo':
        return Icons.lunch_dining_outlined;
      case 'cena':
        return Icons.dinner_dining_outlined;
      case 'snacks':
        return Icons.fastfood_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<MealPlanProvider>(
      builder: (context, mealPlanProvider, child) {
        final today = DateTime.now();
        final dailyMenu = mealPlanProvider.getPlanForDay(today);
        // Filter to show only meals that have a description
        final activeMealTypes = dailyMenu.keys
            .where((mealType) => dailyMenu[mealType]!.description.isNotEmpty)
            .toList();

        if (activeMealTypes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No has planificado comidas para hoy',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ve al planificador semanal para añadir tus menús.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          itemCount: activeMealTypes.length,
          itemBuilder: (context, index) {
            final mealType = activeMealTypes[index];
            final meal = dailyMenu[mealType]!;
            final isCompleted = meal.isCompleted;

            // Define styles based on completion status
            final textStyle = theme.textTheme.bodyMedium?.copyWith(
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: isCompleted
                  ? Colors.grey
                  : theme.textTheme.bodyMedium?.color,
            );
            final titleStyle = theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: isCompleted
                  ? Colors.grey
                  : theme.textTheme.titleLarge?.color,
            );

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isCompleted ? 0.7 : 1.0,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 16,
                    right: 0,
                    top: 8,
                    bottom: 8,
                  ),
                  leading: Icon(
                    _getIconForMealType(mealType),
                    color: isCompleted ? Colors.grey : colorScheme.primary,
                    size: 40,
                  ),
                  title: Text(mealType, style: titleStyle),
                  subtitle: Text(
                    meal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  trailing: Checkbox(
                    value: isCompleted,
                    onChanged: (bool? value) {
                      mealPlanProvider.toggleMealCompletion(today, mealType);
                    },
                    activeColor: colorScheme.primary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMealScreen(mealType: mealType, date: today),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
