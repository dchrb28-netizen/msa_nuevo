import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/personalized_meal_plan_service.dart';
import 'package:myapp/screens/menus/food_preferences_screen.dart';

/// Card para mostrar un resumen de restricciones alimentarias
class FoodRestrictionsCard extends StatelessWidget {
  const FoodRestrictionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final restrictions = PersonalizedMealPlanService.getRestrictionsDescription(user);
        
        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.restaurant_menu,
              size: 32,
            ),
            title: const Text('Preferencias Alimentarias'),
            subtitle: Text(
              restrictions,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodPreferencesScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
