import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:myapp/services/edamam_service.dart';
import 'package:myapp/models/food_log.dart';

/// Pantalla para crear una comida combinando múltiples ingredientes
class RecipeBuilderScreen extends StatefulWidget {
  final Function(FoodLog) onRecipeCreated;
  final String mealType;
  final DateTime date;

  const RecipeBuilderScreen({
    super.key,
    required this.onRecipeCreated,
    required this.mealType,
    required this.date,
  });

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _recipeNameController = TextEditingController();
  final EdamamService _edamamService = EdamamService();
  
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selectedIngredients = [];
  bool _isLoading = false;

  double get _totalCalories => _selectedIngredients.fold(0, (sum, ing) => sum + (ing['calories'] as double));
  double get _totalProtein => _selectedIngredients.fold(0, (sum, ing) => sum + (ing['protein'] as double));
  double get _totalCarbs => _selectedIngredients.fold(0, (sum, ing) => sum + (ing['carbs'] as double));
  double get _totalFat => _selectedIngredients.fold(0, (sum, ing) => sum + (ing['fat'] as double));

  @override
  void dispose() {
    _searchController.dispose();
    _recipeNameController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _edamamService.searchFood(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  void _addIngredient(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) => _IngredientQuantityDialog(
        food: food,
        onConfirm: (servings) {
          final nutrients = food['nutrients'] as Map<String, dynamic>;
          
          setState(() {
            _selectedIngredients.add({
              'name': food['label'],
              'servings': servings,
              'calories': (nutrients['calories'] ?? 0.0) * servings,
              'protein': (nutrients['protein'] ?? 0.0) * servings,
              'carbs': (nutrients['carbs'] ?? 0.0) * servings,
              'fat': (nutrients['fat'] ?? 0.0) * servings,
              'image': food['image'],
            });
            _searchResults = [];
            _searchController.clear();
          });
        },
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _selectedIngredients.removeAt(index);
    });
  }

  void _saveRecipe() async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ingrediente')),
      );
      return;
    }

    String recipeName = _recipeNameController.text.trim();
    if (recipeName.isEmpty) {
      // Nombre por defecto
      recipeName = '${_getMealTypeName()} (${_selectedIngredients.length} ingredientes)';
    }

    final foodLog = FoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: recipeName,
      calories: _totalCalories,
      protein: _totalProtein,
      carbohydrates: _totalCarbs,
      fat: _totalFat,
      date: widget.date,
      mealType: widget.mealType,
    );

    // Llamar callback para guardar
    widget.onRecipeCreated(foodLog);
    
    // Programar el cierre para el próximo frame
    // Esto evita el error "_debugLocked is not true" del Navigator
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar solo recipe_builder_screen
      }
    });
  }

  String _getMealTypeName() {
    switch (widget.mealType.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Merienda';
      default:
        return 'Comida';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Receta'),
        actions: [
          if (_selectedIngredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Guardar',
              onPressed: _saveRecipe,
            ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ingrediente...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchFood('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _searchFood,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                if (_selectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recipeNameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre de la comida (opcional)',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Resultados de búsqueda o ingredientes seleccionados
          Expanded(
            child: _searchResults.isNotEmpty
                ? _buildSearchResults(theme)
                : _selectedIngredients.isNotEmpty
                    ? _buildSelectedIngredients(theme)
                    : _buildEmptyState(theme),
          ),

          // Resumen nutricional
          if (_selectedIngredients.isNotEmpty)
            _buildNutritionSummary(theme),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        final nutrients = food['nutrients'] as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: food['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                    ),
                  )
                : const Icon(Icons.fastfood, size: 50),
            title: Text(
              food['label'] ?? 'Desconocido',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${nutrients['calories']?.toStringAsFixed(0) ?? '0'} kcal • '
              '${nutrients['protein']?.toStringAsFixed(1) ?? '0'}g proteína',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _addIngredient(food),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedIngredients(ThemeData theme) {
    return ListView.builder(
      itemCount: _selectedIngredients.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final ingredient = _selectedIngredients[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: ingredient['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ingredient['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                    ),
                  )
                : const Icon(Icons.fastfood, size: 50),
            title: Text(
              ingredient['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${ingredient['servings'].toStringAsFixed(1)} porción(es) • '
              '${ingredient['calories'].toStringAsFixed(0)} kcal',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeIngredient(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Busca ingredientes para crear tu comida',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los ingredientes se sumarán automáticamente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Nutricional',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientChip('${_totalCalories.toStringAsFixed(0)} kcal', Icons.local_fire_department, Colors.orange),
              _buildNutrientChip('${_totalProtein.toStringAsFixed(1)}g P', Icons.fitness_center, Colors.red),
              _buildNutrientChip('${_totalCarbs.toStringAsFixed(1)}g C', Icons.grain, Colors.brown),
              _buildNutrientChip('${_totalFat.toStringAsFixed(1)}g G', Icons.opacity, Colors.yellow[700]!),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveRecipe,
            icon: const Icon(Icons.check),
            label: Text('Guardar ${_getMealTypeName()}'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// Diálogo para ingresar cantidad de ingrediente
class _IngredientQuantityDialog extends StatefulWidget {
  final Map<String, dynamic> food;
  final Function(double) onConfirm;

  const _IngredientQuantityDialog({
    required this.food,
    required this.onConfirm,
  });

  @override
  State<_IngredientQuantityDialog> createState() => _IngredientQuantityDialogState();
}

class _IngredientQuantityDialogState extends State<_IngredientQuantityDialog> {
  double _servings = 1.0;

  @override
  Widget build(BuildContext context) {
    final nutrients = widget.food['nutrients'] as Map<String, dynamic>;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.food['label'] ?? 'Ingrediente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Porciones: ${_servings.toStringAsFixed(1)}',
            style: theme.textTheme.titleMedium,
          ),
          Slider(
            value: _servings,
            min: 0.1,
            max: 10.0,
            divisions: 99,
            label: _servings.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _servings = value;
              });
            },
          ),
          const Divider(),
          _buildNutrientRow('Calorías', (nutrients['calories'] ?? 0.0) * _servings, 'kcal'),
          _buildNutrientRow('Proteína', (nutrients['protein'] ?? 0.0) * _servings, 'g'),
          _buildNutrientRow('Carbohidratos', (nutrients['carbs'] ?? 0.0) * _servings, 'g'),
          _buildNutrientRow('Grasa', (nutrients['fat'] ?? 0.0) * _servings, 'g'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.onConfirm(_servings);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
