
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/food/food_log_screen.dart';
import 'package:myapp/screens/logs/food_today_view.dart';
import 'package:myapp/services/streaks_service.dart';
import 'package:provider/provider.dart';

class FoodTodayScreen extends StatefulWidget {
  const FoodTodayScreen({super.key});

  @override
  State<FoodTodayScreen> createState() => _FoodTodayScreenState();
}

class _FoodTodayScreenState extends State<FoodTodayScreen> {
  final PageController _pageController = PageController();
  final StreaksService _streaksService = StreaksService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkCalorieStreak() async {
    // 1. Obtener el proveedor de usuario y la caja de logs
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final foodLogBox = Hive.box<FoodLog>('food_logs');

    // 2. Verificar que hay un usuario y una meta calórica válida
    if (user == null || user.isGuest || (user.calorieGoal ?? 0) <= 0) {
      return;
    }

    final caloricGoal = user.calorieGoal!;

    // 3. Calcular el total de calorías para hoy
    final today = DateTime.now();
    final totalCaloriesToday = foodLogBox.values
        .where((log) =>
            log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day)
        .fold<double>(0, (sum, log) => sum + log.calories);

    // 4. Comprobar si se ha cumplido la meta y actualizar la racha
    if (totalCaloriesToday <= caloricGoal) {
      await _streaksService.updateCalorieStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          FoodTodayView(),
          // Se pueden añadir más vistas aquí en el futuro
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodLogScreen(
                onAddFoodLog: (foodLog) {
                  // Guardar el registro de comida
                  Hive.box<FoodLog>('food_logs').add(foodLog).then((_) {
                    // Después de guardar, comprobar la racha
                    _checkCalorieStreak();
                    // Forzar actualización de la UI
                    setState(() {});
                  });
                },
              ),
            ),
          );
          // Actualizar la UI después de cerrar la pantalla de registro
          if (result != null || mounted) {
            setState(() {});
          }
        },
        label: const Text('Registrar'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
