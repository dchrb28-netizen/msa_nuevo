import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/food/recipe_builder_screen.dart';
import 'package:myapp/services/meal_nutrition_service.dart';
import 'package:uuid/uuid.dart';

class RegisterFoodScreen extends StatefulWidget {
  const RegisterFoodScreen({super.key});

  @override
  State<RegisterFoodScreen> createState() => _RegisterFoodScreenState();
}

class _RegisterFoodScreenState extends State<RegisterFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String _mealType = 'Desayuno';
  bool _isSearching = false;

  Future<void> _searchNutrition() async {
    final foodName = _nameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce una descripción primero')),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final nutrition = await MealNutritionService.getNutritionForMeal(foodName);
      
      if (nutrition != null && mounted) {
        setState(() {
          _caloriesController.text = nutrition.calories.toStringAsFixed(0);
          _proteinController.text = nutrition.protein.toStringAsFixed(1);
          _carbsController.text = nutrition.carbs.toStringAsFixed(1);
          _fatController.text = nutrition.fat.toStringAsFixed(1);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nutrition.isFromApi
                  ? 'Datos obtenidos de la API'
                  : 'Datos obtenidos de la base de datos',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró información nutricional')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _saveFoodLog() {
    if (_formKey.currentState!.validate()) {
      final newLog = FoodLog(
        id: const Uuid().v4(),
        foodName: _nameController.text,
        date: DateTime.now(),
        calories: double.tryParse(_caloriesController.text) ?? 0.0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        carbohydrates: double.tryParse(_carbsController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        mealType: _mealType,
      );
      Navigator.pop(context, newLog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: IconButton(
          icon: const Icon(Icons.menu_book_outlined, size: 32),
          tooltip: 'Crear receta con múltiples ingredientes',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecipeBuilderScreen(
                  onRecipeCreated: (foodLog) {
                    Navigator.pop(context, foodLog);
                  },
                  mealType: _mealType,
                  date: DateTime.now(),
                ),
              ),
            ).then((value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header mejorado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva Comida',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra lo que consumiste hoy',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildMealTypeCard(),
              const SizedBox(height: 12),
              _buildInputCardWithSearch(
                icon: Icons.fastfood,
                label: 'Descripción de la Comida',
                controller: _nameController,
                isRequired: true,
                onSearch: _searchNutrition,
                isSearching: _isSearching,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Tarjeta de macronutrientes
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Nutricional',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputCard(
                        icon: Icons.local_fire_department,
                        label: 'Calorías (kcal)',
                        controller: _caloriesController,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo no puede estar vacío';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Introduce un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildInputCard(
                                icon: Icons.fitness_center,
                                label: 'Proteínas (g)',
                                controller: _proteinController,
                                keyboardType: TextInputType.number,
                                iconColor: Colors.green,
                                emoji: '🥩',
                              ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildInputCard(
                                icon: Icons.bakery_dining,
                                label: 'Carbs (g)',
                                controller: _carbsController,
                                keyboardType: TextInputType.number,
                                iconColor: Colors.orange,
                                emoji: '🍞',
                              ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildInputCard(
                                icon: Icons.opacity,
                                label: 'Grasas (g)',
                                controller: _fatController,
                                keyboardType: TextInputType.number,
                                iconColor: Colors.redAccent,
                                emoji: '🧈',
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveFoodLog,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeCard() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _mealType,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Tipo de Comida',
          border: InputBorder.none,
          prefixIcon: null,
          labelStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
        dropdownColor: theme.colorScheme.surface,
        selectedItemBuilder: (context) {
          return ['Desayuno', 'Almuerzo', 'Cena', 'Snack'].map((label) {
            return Row(
              children: [
                Icon(
                  _getMealIcon(label),
                  size: 20,
                  color: _getMealColor(label),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack']
            .map((label) => DropdownMenuItem(
                  value: label,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getMealIcon(label),
                          size: 20,
                          color: _getMealColor(label),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _mealType = value;
            });
          }
        },
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
      case 'Snack':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInputCardWithSearch({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required VoidCallback onSearch,
    required bool isSearching,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                prefixIcon: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                labelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
              validator: validator,
            ),
          ),
          IconButton(
            icon: isSearching
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
            onPressed: isSearching ? null : onSearch,
            tooltip: 'Buscar por API',
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Color? iconColor,
    String? emoji,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: emoji != null
              ? SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      emoji!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
          labelStyle: TextStyle(
            color: theme.colorScheme.primary,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
