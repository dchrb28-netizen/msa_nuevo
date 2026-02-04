import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/food/recipe_builder_screen.dart';
import 'package:myapp/screens/settings/caloric_goals_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodLogScreen extends StatefulWidget {
  final Function(FoodLog) onAddFoodLog;

  const FoodLogScreen({super.key, required this.onAddFoodLog});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fatController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Desayuno';

  final List<String> _mealTypes = [
    'Desayuno',
    'Almuerzo',
    'Cena',
    'Snack (Mañana)',
    'Snack (Tarde)',
    'Snack (Noche)',
    'Otro',
  ];

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newFoodLog = FoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodName: _foodNameController.text,
        calories: double.tryParse(_caloriesController.text) ?? 0.0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        carbohydrates: double.tryParse(_carbohydratesController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        date: _selectedDate,
        mealType: _selectedMealType,
      );
      widget.onAddFoodLog(newFoodLog);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Botón para crear receta (múltiples ingredientes)
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Crear Receta (varios ingredientes)',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecipeBuilderScreen(
                    onRecipeCreated: widget.onAddFoodLog,
                    mealType: _selectedMealType,
                    date: _selectedDate,
                  ),
                ),
              );
              // Cerrar food_log_screen para volver a la pantalla principal
              // donde se verá la receta agregada
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner informativo sobre el botón de receta
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Usa el ícono de menú arriba para crear una receta con varios ingredientes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCaloriesHeader(context),
                const SizedBox(height: 24),
                _buildTextField(_foodNameController, 'Nombre de la Comida'),
                _buildTextField(
                  _caloriesController,
                  'Calorías',
                  isNumber: true,
                ),
                _buildTextFieldWithIcon(
                  _proteinController,
                  'Proteínas (g)',
                  Icons.egg_alt_outlined,
                  Colors.green,
                  isNumber: true,
                  emoji: '🥩',
                ),
                _buildTextFieldWithIcon(
                  _carbohydratesController,
                  'Carbohidratos (g)',
                  Icons.grain,
                  Colors.orange,
                  isNumber: true,
                  emoji: '🍞',
                ),
                _buildTextFieldWithIcon(
                  _fatController,
                  'Grasas (g)',
                  Icons.opacity,
                  Colors.redAccent,
                  isNumber: true,
                  emoji: '🧈',
                ),
                const SizedBox(height: 24),
                _buildMealTypeDropdown(),
                const SizedBox(height: 24),
                _buildDatePicker(context),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Guardar Registro'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesHeader(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final caloricGoal = user?.calorieGoal;
    final dietPlan = user?.dietPlan ?? 'Mantener';
    final textTheme = Theme.of(context).textTheme;

    if (caloricGoal == null || caloricGoal <= 0) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'No has establecido tus metas calóricas',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaloricGoalsScreen(),
                    ),
                  );
                },
                child: const Text('Establecer Metas'),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, dynamic> planDetails = {
      'Perder': {'icon': Icons.trending_down, 'color': Colors.orange.shade300},
      'Mantener': {'icon': Icons.sync, 'color': Colors.green.shade300},
      'Ganar': {'icon': Icons.trending_up, 'color': Colors.blue.shade300},
      'Personalizado': {'icon': Icons.edit, 'color': Colors.purple.shade300},
    };

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final now = DateTime.now();
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final dailyLogs = box.values.where((log) => isSameDay(log.date, now));
        final totalCalories = dailyLogs.fold<double>(
          0,
          (sum, log) => sum + log.calories,
        );
        final remainingCalories = caloricGoal - totalCalories;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (user != null && !user.isGuest)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Chip(
                      avatar: Icon(
                        planDetails[dietPlan]?['icon'] ?? Icons.help,
                        color: Colors.black87,
                        size: 18,
                      ),
                      label: Text(
                        'Plan: $dietPlan',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      backgroundColor:
                          planDetails[dietPlan]?['color'] ??
                          Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCalorieInfo('Meta', caloricGoal.toInt(), Colors.blue),
                    _buildCalorieInfo(
                      'Consumido',
                      totalCalories.toInt(),
                      Colors.orange,
                    ),
                    _buildCalorieInfo(
                      'Restante',
                      remainingCalories.toInt(),
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalorieInfo(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese un valor';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Por favor, ingrese un número válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextFieldWithIcon(
    TextEditingController controller,
    String label,
    IconData icon,
    Color iconColor, {
    bool isNumber = false,
    String? emoji,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: emoji != null
              ? SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Icon(icon, color: iconColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese un valor';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Por favor, ingrese un número válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMealTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedMealType,
        decoration: InputDecoration(
          labelText: 'Tipo de Comida',
          prefixIcon: Icon(
            _getMealIcon(_selectedMealType),
            color: _getMealColor(_selectedMealType),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: _mealTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Row(
              children: [
                Icon(
                  _getMealIcon(type),
                  size: 20,
                  color: _getMealColor(type),
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              _selectedMealType = newValue;
            });
          }
        },
        isExpanded: true,
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Desayuno':
        return Icons.free_breakfast;
      case 'Almuerzo':
        return Icons.lunch_dining;
      case 'Cena':
        return Icons.dinner_dining;
      case 'Snack (Mañana)':
      case 'Snack (Tarde)':
      case 'Snack (Noche)':
      case 'Snack':
        return Icons.fastfood;
      default:
        return Icons.food_bank_outlined;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'Desayuno':
        return Colors.orange;
      case 'Almuerzo':
        return Colors.green;
      case 'Cena':
        return Colors.indigo;
      case 'Snack (Mañana)':
      case 'Snack (Tarde)':
      case 'Snack (Noche)':
      case 'Snack':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDatePicker(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fecha: ${DateFormat.yMMMEd('es').format(_selectedDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () => _selectDate(context),
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}
