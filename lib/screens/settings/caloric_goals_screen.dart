import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CaloricGoalsScreen extends StatelessWidget {
  const CaloricGoalsScreen({super.key});

  // Calculates maintenance calories
  double _calculateMaintenanceCalories(User user) {
    double bmr;
    if (user.gender == 'male') {
      bmr = 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * user.age);
    } else {
      bmr = 447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.330 * user.age);
    }

    double activityMultiplier;
    switch (user.activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    return bmr * activityMultiplier;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null || user.isGuest || user.height <= 0 || user.weight <= 0 || user.age <= 0) {
        return Scaffold(
            appBar: AppBar(title: const Text('Metas Calóricas')),
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.amber),
                        const SizedBox(height: 16),
                        const Text(
                            '¡Perfil Incompleto!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'Para calcular tus metas calóricas, por favor, ve a tu perfil y asegúrate de haber completado los campos de género, edad, peso, altura y nivel de actividad.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('Ir a mi Perfil'),
                          onPressed: () => Navigator.of(context).pushNamed('/profile'),
                        )
                      ],
                    ),
                ),
            ),
        );
    }

    final maintenanceCalories = _calculateMaintenanceCalories(user);
    final loseWeightCalories = (maintenanceCalories - 500).round();
    final gainWeightCalories = (maintenanceCalories + 500).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Tus Metas Calóricas Diarias')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildGoalCard(
                context,
                title: 'Perder Peso',
                subtitle: 'Déficit de ~500 kcal/día',
                calories: loseWeightCalories,
                icon: Icons.trending_down,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                context,
                title: 'Mantener Peso',
                subtitle: 'Calorías de mantenimiento',
                calories: maintenanceCalories.round(),
                icon: Icons.sync,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                context,
                title: 'Ganar Peso',
                subtitle: 'Superávit de ~500 kcal/día',
                calories: gainWeightCalories,
                icon: Icons.trending_up,
                color: Colors.blue.shade700,
              ),
               const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Basado en tu perfil:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text('• Género: ${user.gender == 'male' ? 'Masculino' : 'Femenino'}'),
                      Text('• Edad: ${user.age} años'),
                      Text('• Peso: ${user.weight} kg'),
                      Text('• Altura: ${user.height} cm'),
                      Text('• Nivel de Actividad: ${user.activityLevel}')
                    ],
                  ),
                )
              ),
              const SizedBox(height: 16),
              Text(
                'Estos valores son una estimación. Consulta a un profesional de la salud para obtener recomendaciones personalizadas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildGoalCard(BuildContext context, {required String title, required String subtitle, required int calories, required IconData icon, required Color color}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
                Icon(icon, size: 30, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(
              '$calories kcal',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
