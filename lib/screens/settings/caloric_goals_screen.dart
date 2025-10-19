import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CaloricGoalsScreen extends StatefulWidget {
  const CaloricGoalsScreen({super.key});

  @override
  State<CaloricGoalsScreen> createState() => _CaloricGoalsScreenState();
}

class _CaloricGoalsScreenState extends State<CaloricGoalsScreen> {
  double? _tdee;
  late List<bool> _isSelected;
  final List<String> _plans = const ['Perder', 'Mantener', 'Ganar'];

  final Map<String, double> _activityMultipliers = const {
    'Sedentaria': 1.2,
    'Ligera': 1.375,
    'Moderada': 1.55,
    'Activa': 1.725,
    'Muy Activa': 1.9,
  };

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final planIndex = _plans.indexOf(user?.dietPlan ?? 'Mantener');
    _isSelected = List.generate(3, (index) => index == planIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTDEE();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTDEE();
     final user = Provider.of<UserProvider>(context, listen: false).user;
    final planIndex = _plans.indexOf(user?.dietPlan ?? 'Mantener');
    _isSelected = List.generate(3, (index) => index == planIndex);
  }

  void _calculateTDEE() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user.age > 0 && user.height > 0 && user.weight > 0) {
      double bmr;
      if (user.gender.toLowerCase() == 'masculino') {
        bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) + 5;
      } else {
        bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) - 161;
      }
      final multiplier = _activityMultipliers[user.activityLevel] ?? 1.2;
      if (mounted) {
        setState(() {
          _tdee = bmr * multiplier;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _tdee = null;
        });
      }
    }
  }

  void _updateDietPlan(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user!;
    final newPlan = _plans[index];

    if (currentUser.dietPlan != newPlan) {
      final updatedUser = currentUser.copyWith(dietPlan: newPlan);
      userProvider.updateUser(updatedUser);
    }
  }

  void _applyCalorieGoal(double calorieGoal) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user!;

    final proteinGrams = (calorieGoal * 0.30) / 4;
    final carbGrams = (calorieGoal * 0.40) / 4;
    final fatGrams = (calorieGoal * 0.30) / 9;

    final updatedUser = currentUser.copyWith(
      calorieGoal: calorieGoal,
      proteinGoal: proteinGrams,
      carbGoal: carbGrams,
      fatGoal: fatGrams,
    );

    userProvider.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Nueva meta de ${calorieGoal.toStringAsFixed(0)} kcal aplicada!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final user = Provider.of<UserProvider>(context).user;

    if (user == null || user.weight <= 0 || user.height <= 0 || user.age <= 0) {
      return _buildProfileCompletionMessage(context);
    }

    if (_tdee == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final goals = {
      'Perder': _tdee! - 500,
      'Mantener': _tdee!,
      'Ganar': _tdee! + 500,
    };
    final selectedPlan = _plans[_isSelected.indexOf(true)];
    final selectedCalorieGoal = goals[selectedPlan]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige tu Plan Nutricional',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Tu meta calórica se ajustará según el plan que elijas. Tu gasto diario estimado es de ${_tdee!.toStringAsFixed(0)} kcal.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ToggleButtons(
              isSelected: _isSelected,
              onPressed: _updateDietPlan,
              borderRadius: BorderRadius.circular(12.0),
              selectedBorderColor: colorScheme.primary,
              selectedColor: colorScheme.onPrimary,
              fillColor: colorScheme.primary,
              color: colorScheme.onSurfaceVariant,
              constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 48) / 3, minHeight: 50),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Perder')),
                Padding(padding: EdgeInsets.all(8), child: Text('Mantener')),
                Padding(padding: EdgeInsets.all(8), child: Text('Ganar')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildGoalCard(
            plan: selectedPlan,
            calories: selectedCalorieGoal,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({required String plan, required double calories}) {
    final textTheme = Theme.of(context).textTheme;
    
    final Map<String, dynamic> planDetails = {
      'Perder': {
        'title': 'Pérdida de Peso',
        'subtitle': 'Déficit calórico para reducir grasa corporal.',
        'icon': Icons.trending_down,
        'color': Colors.orange.shade300,
        'darkColor': Colors.orange.shade900
      },
      'Mantener': {
        'title': 'Mantenimiento de Peso',
        'subtitle': 'Equilibra tu ingesta para mantener tu peso actual.',
        'icon': Icons.sync,
        'color': Colors.green.shade300,
        'darkColor': Colors.green.shade900
      },
      'Ganar': {
        'title': 'Aumento de Masa Muscular',
        'subtitle': 'Superávit calórico para fomentar el crecimiento.',
        'icon': Icons.trending_up,
        'color': Colors.blue.shade300,
        'darkColor': Colors.blue.shade900
      }
    };

    final details = planDetails[plan]!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       color: details['color'].withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(details['icon'], size: 40, color: details['darkColor']), 
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details['title'], style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: details['darkColor'])),
                      const SizedBox(height: 4),
                      Text(details['subtitle'], style: textTheme.bodyMedium),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text('Meta Sugerida', style: textTheme.labelLarge),
            Text(
              '${calories.toStringAsFixed(0)} kcal',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: details['darkColor']),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _applyCalorieGoal(calories),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aplicar esta Meta Calórica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: details['darkColor'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildProfileCompletionMessage(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                'Faltan datos en tu perfil',
                style: textTheme.headlineSmall, textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Por favor, completa tu peso, altura y edad en la sección "Mis Datos Corporales" para poder calcular tus metas calóricas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                   DefaultTabController.of(context).animateTo(0);
                },
                child: const Text('Completar mi Perfil'),
              )
            ],
          ),
        ),
      );
    }
}
