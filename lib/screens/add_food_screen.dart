import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/screens/register_food_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchController = TextEditingController();
  List<Food> _searchResults = [];
  final _foodBox = Hive.box<Food>('foods');

  // State for the confirmation dialog
  final _quantityController = TextEditingController();
  String _selectedMealType = 'Desayuno';

  @override
  void initState() {
    super.initState();
    _searchResults = _foodBox.values.toList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = _foodBox.values.toList();
      } else {
        _searchResults = _foodBox.values
            .where((food) => food.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _navigateAndRegisterFood() async {
    final newFood = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterFoodScreen()),
    );

    if (newFood != null) {
      setState(() {
        _searchResults = _foodBox.values.toList();
      });
    }
  }

  void _showAddFoodDialog(Food food) {
    _quantityController.text = '100'; // Default to 100g
    _selectedMealType = 'Desayuno'; // Default to breakfast

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Añadir ${food.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (g)',
                  suffixText: 'g',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Comida',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMealType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = double.tryParse(_quantityController.text);
                if (quantity != null && quantity > 0) {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context, {
                    'food': food,
                    'quantity': quantity,
                    'mealType': _selectedMealType,
                  });
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Alimento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final food = _searchResults[index];
                return ListTile(
                  title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${food.calories} kcal por cada 100g'),
                  onTap: () {
                    _showAddFoodDialog(food);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndRegisterFood,
        label: const Text('Registrar Nuevo Alimento'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
