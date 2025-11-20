import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CaloricGoalsScreen extends StatefulWidget {
  const CaloricGoalsScreen({super.key});

  @override
  State<CaloricGoalsScreen> createState() => _CaloricGoalsScreenState();
}

class _CaloricGoalsScreenState extends State<CaloricGoalsScreen> {
  double _tdee = 0;
  late int _selectedPlanIndex;
  final List<String> _plans = const [
    'Perder',
    'Mantener',
    'Ganar',
    'Personalizado',
  ];
  final TextEditingController _customGoalController = TextEditingController();

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
    _selectedPlanIndex = _plans.indexOf(user?.dietPlan ?? 'Mantener');
    if (_selectedPlanIndex == 3) {
      _customGoalController.text = user?.calorieGoal?.toStringAsFixed(0) ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTDEE();
    });
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTDEE();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _selectedPlanIndex = _plans.indexOf(user?.dietPlan ?? 'Mantener');
  }

  void _calculateTDEE() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user.age > 0 && user.height > 0 && user.weight > 0) {
      double bmr;
      if (user.gender.toLowerCase() == 'male') {
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
          _tdee = 0;
        });
      }
    }
  }

  void _updateDietPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
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
      SnackBar(
        content: Text(
          '¡Nueva meta de ${calorieGoal.toStringAsFixed(0)} kcal aplicada!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = Provider.of<UserProvider>(context).user;

    if (user == null || user.weight <= 0 || user.height <= 0 || user.age <= 0) {
      return _buildProfileCompletionMessage(context);
    }

    if (_tdee == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige tu Plan Nutricional',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Tu gasto diario estimado es de ${_tdee.toStringAsFixed(0)} kcal. Selecciona un plan y aplica la meta.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          _buildPlanSelectionGrid(),
          const SizedBox(height: 24),
          if (_plans[_selectedPlanIndex] != 'Personalizado')
            _buildGoalCard(
              plan: _plans[_selectedPlanIndex],
              calories:
                  (_tdee +
                  (_plans[_selectedPlanIndex] == 'Perder'
                      ? -500
                      : _plans[_selectedPlanIndex] == 'Ganar'
                      ? 500
                      : 0)),
            )
          else
            _buildCustomGoalCard(),
        ],
      ),
    );
  }

  Widget _buildPlanSelectionGrid() {
    final Map<String, IconData> planIcons = {
      'Perder': Icons.trending_down,
      'Mantener': Icons.sync,
      'Ganar': Icons.trending_up,
      'Personalizado': Icons.edit,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        final isSelected = _selectedPlanIndex == index;
        final colorScheme = Theme.of(context).colorScheme;

        return GestureDetector(
          onTap: () => _updateDietPlan(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withAlpha(51)
                  : colorScheme.surfaceContainerHighest.withAlpha(128),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(77),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  planIcons[plan],
                  size: 40,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  plan,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        'darkColor': Colors.orange.shade900,
      },
      'Mantener': {
        'title': 'Mantenimiento de Peso',
        'subtitle': 'Equilibra tu ingesta para mantener tu peso actual.',
        'icon': Icons.sync,
        'color': Colors.green.shade300,
        'darkColor': Colors.green.shade900,
      },
      'Ganar': {
        'title': 'Aumento de Masa Muscular',
        'subtitle': 'Superávit calórico para fomentar el crecimiento.',
        'icon': Icons.trending_up,
        'color': Colors.blue.shade300,
        'darkColor': Colors.blue.shade900,
      },
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
                      Text(
                        details['title'],
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: details['darkColor'],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(details['subtitle'], style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Meta Sugerida', style: textTheme.labelLarge),
            Text(
              '${calories.toStringAsFixed(0)} kcal',
              style: textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: details['darkColor'],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _applyCalorieGoal(calories),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aplicar esta Meta Calórica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: details['darkColor'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomGoalCard() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHighest.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.edit, size: 40, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta Personalizada',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define tu propio objetivo calórico diario.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tu Meta de Calorías (kcal)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'kcal',
              ),
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final customGoal = double.tryParse(_customGoalController.text);
                if (customGoal != null && customGoal > 0) {
                  _applyCalorieGoal(customGoal);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, introduce un número válido para las calorías.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aplicar Meta Personalizada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              'Faltan datos en tu perfil',
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Por favor, completa tu peso, altura y edad en la sección de Perfil para poder calcular tus metas calóricas.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                try {
                  DefaultTabController.of(context).animateTo(1);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Navega a la pestaña de Perfil para completar tus datos.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Ir a mi Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
