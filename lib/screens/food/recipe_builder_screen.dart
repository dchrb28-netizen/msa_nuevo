import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/edamam_service.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/widgets/empty_state_widget.dart';

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
    
    // Mostrar confirmación simple
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '✓ $recipeName guardado',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[700],
      ),
    );
    
    // Cerrar después de mostrar confirmación
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
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
    final colors = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.2), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear ${_getMealTypeName()}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Busca y combina ingredientes',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Search and Name Input
          Container(
            padding: const EdgeInsets.all(14),
            color: colors.surface,
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
                    fillColor: colors.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: _searchFood,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                if (_selectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _recipeNameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre de la comida (opcional)',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _searchResults.isNotEmpty
                ? _buildSearchResults(theme, colors)
                : _selectedIngredients.isNotEmpty
                    ? _buildSelectedIngredients(theme, colors)
                    : _buildEmptyState(theme, colors),
          ),

          // Nutrition Summary
          if (_selectedIngredients.isNotEmpty)
            _buildNutritionSummary(theme, colors),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        final nutrients = food['nutrients'] as Map<String, dynamic>;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _addIngredient(food),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: food['image'] != null
                          ? Image.network(
                              food['image'],
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.fastfood, color: colors.primary),
                              ),
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fastfood, color: colors.primary),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['label'] ?? 'Desconocido',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${nutrients['calories']?.toStringAsFixed(0) ?? '0'} kcal • '
                            '${nutrients['protein']?.toStringAsFixed(1) ?? '0'}g P',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.add_circle, color: colors.primary, size: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedIngredients(ThemeData theme, ColorScheme colors) {
    return ListView.builder(
      itemCount: _selectedIngredients.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final ingredient = _selectedIngredients[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ingredient['image'] != null
                      ? Image.network(
                          ingredient['image'],
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.fastfood, color: colors.primary),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.fastfood, color: colors.primary),
                        ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient['name'],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ingredient['servings'].toStringAsFixed(0)}g • '
                        '${ingredient['calories'].toStringAsFixed(0)} kcal',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.error, size: 22),
                  onPressed: () => _removeIngredient(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return EmptyStateWidget(
      icon: Icons.restaurant,
      title: 'Busca ingredientes',
      subtitle: 'Los ingredientes se sumarán automáticamente',
      iconColor: colors.primary,
      iconSize: 64,
    );
  }

  Widget _buildNutritionSummary(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientBadge('${_totalCalories.toStringAsFixed(0)}', 'kcal', Colors.orange, colors),
              _buildNutrientBadge('${_totalProtein.toStringAsFixed(1)}', 'g P', Colors.red, colors),
              _buildNutrientBadge('${_totalCarbs.toStringAsFixed(1)}', 'g C', Colors.amber, colors),
              _buildNutrientBadge('${_totalFat.toStringAsFixed(1)}', 'g G', Colors.yellow, colors),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.check, size: 20),
              label: Text(
                'Guardar ${_getMealTypeName()}',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(String value, String label, Color color, ColorScheme colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: colors.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
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
  double _grams = 100.0;

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
            'Gramos: ${_grams.toStringAsFixed(0)}g',
            style: theme.textTheme.titleMedium,
          ),
          Slider(
            value: _grams,
            min: 10,
            max: 500,
            divisions: 49,
            label: '${_grams.toStringAsFixed(0)}g',
            onChanged: (value) {
              setState(() {
                _grams = value;
              });
            },
          ),
          const Divider(),
          _buildNutrientRow('Calorías', (nutrients['calories'] ?? 0.0) * _grams / 100, 'kcal'),
          _buildNutrientRow('Proteína', (nutrients['protein'] ?? 0.0) * _grams / 100, 'g'),
          _buildNutrientRow('Carbohidratos', (nutrients['carbs'] ?? 0.0) * _grams / 100, 'g'),
          _buildNutrientRow('Grasa', (nutrients['fat'] ?? 0.0) * _grams / 100, 'g'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.onConfirm(_grams / 100);
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
