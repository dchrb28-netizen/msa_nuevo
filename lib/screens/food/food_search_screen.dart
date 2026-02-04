import 'package:flutter/material.dart';
import 'package:myapp/services/edamam_service.dart';
import 'package:myapp/models/food_log.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:myapp/widgets/empty_state_widget.dart';

class FoodSearchScreen extends StatefulWidget {
  final Function(FoodLog) onFoodSelected;
  final String mealType;
  final DateTime date;

  const FoodSearchScreen({
    super.key,
    required this.onFoodSelected,
    required this.mealType,
    required this.date,
  });

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EdamamService _edamamService = EdamamService();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _edamamService.searchFood(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar: ${e.toString()}';
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  void _selectFood(Map<String, dynamic> food) {
    // Mostrar diálogo para ingresar cantidad
    showDialog(
      context: context,
      builder: (context) => _FoodQuantityDialog(
        food: food,
        onConfirm: (servings) async {
          final nutrients = food['nutrients'] as Map<String, dynamic>;
          
          final foodLog = FoodLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            foodName: food['label'],
            calories: (nutrients['calories'] ?? 0.0) * servings,
            protein: (nutrients['protein'] ?? 0.0) * servings,
            carbohydrates: (nutrients['carbs'] ?? 0.0) * servings,
            fat: (nutrients['fat'] ?? 0.0) * servings,
            date: widget.date,
            mealType: widget.mealType,
          );

          // Cerrar diálogo primero
          Navigator.of(context).pop();
          
          // Llamar callback para guardar
          widget.onFoodSelected(foodLog);
          
          // Mostrar confirmación simple
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✓ ${food['label']} guardado',
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
          
          // Cerrar la pantalla de búsqueda inmediatamente
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
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
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchFood,
              onChanged: (value) {
                setState(() {}); // Para actualizar el botón clear
              },
            ),
          ),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando alimentos...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error en la búsqueda',
        subtitle: _errorMessage,
        action: ElevatedButton(
          onPressed: () => _searchFood(_searchController.text),
          child: const Text('Reintentar'),
        ),
        iconColor: Colors.red[400],
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.restaurant_menu,
        title: 'Busca un alimento para comenzar',
        subtitle: 'Ejemplo: "manzana", "pollo", "arroz"',
        iconColor: Colors.orange[400],
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        final nutrients = food['nutrients'] as Map<String, dynamic>;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: food['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: theme.colorScheme.secondary,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
            title: Text(
              food['label'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  food['categoryLabel'] ?? 'Alimento',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${nutrients['calories'].toStringAsFixed(0)} kcal | 🥩 ${nutrients['protein'].toStringAsFixed(1)}g | 🍞 ${nutrients['carbs'].toStringAsFixed(1)}g | 🧈 ${nutrients['fat'].toStringAsFixed(1)}g',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
            onTap: () => _selectFood(food),
          ),
        );
      },
    );
  }
}

class _FoodQuantityDialog extends StatefulWidget {
  final Map<String, dynamic> food;
  final Future<void> Function(double servings) onConfirm;

  const _FoodQuantityDialog({
    required this.food,
    required this.onConfirm,
  });

  @override
  State<_FoodQuantityDialog> createState() => _FoodQuantityDialogState();
}

class _FoodQuantityDialogState extends State<_FoodQuantityDialog> {
  final TextEditingController _gramsController = TextEditingController(text: '100');
  double _grams = 100.0;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _updateGrams(String value) {
    setState(() {
      _grams = double.tryParse(value) ?? 100.0;
      if (_grams <= 0) _grams = 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutrients = widget.food['nutrients'] as Map<String, dynamic>;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.food['label']),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuántos gramos consumiste?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gramsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                suffixText: 'gramos',
                helperText: 'Los valores nutricionales son por 100g',
              ),
              onChanged: _updateGrams,
            ),
            const SizedBox(height: 24),
            const Text(
              'Información nutricional total:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNutrientRow('Calorías', (nutrients['calories'] * _grams / 100).toStringAsFixed(0), 'kcal', theme),
            _buildNutrientRow('Proteínas', (nutrients['protein'] * _grams / 100).toStringAsFixed(1), 'g', theme),
            _buildNutrientRow('Carbohidratos', (nutrients['carbs'] * _grams / 100).toStringAsFixed(1), 'g', theme),
            _buildNutrientRow('Grasas', (nutrients['fat'] * _grams / 100).toStringAsFixed(1), 'g', theme),
            if (nutrients['fiber'] > 0)
              _buildNutrientRow('Fibra', (nutrients['fiber'] * _grams / 100).toStringAsFixed(1), 'g', theme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.onConfirm(_grams / 100);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value, String unit, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value $unit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
