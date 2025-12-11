import 'package:flutter/material.dart';
import 'package:myapp/models/food_log.dart';
import 'package:myapp/screens/food/recipe_builder_screen.dart';
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

  void _saveFoodLog() {
    if (_formKey.currentState!.validate()) {
      final newLog = FoodLog(
        id: const Uuid().v4(),
        foodName: _nameController.text,
        date: DateTime.now(), // Se usará la fecha actual al guardar
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
        actions: [
          // Botón para crear receta (múltiples ingredientes)
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Crear Receta',
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
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Banner informativo sobre opciones
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
                          'Usa el ícono de menú arriba para crear recetas con varios ingredientes',
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
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                initialValue: _mealType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Comida',
                  prefixIcon: Icon(Icons.food_bank_outlined),
                ),
                items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _mealType = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la Comida',
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorías (kcal)',
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Proteínas (g)',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbohidratos (g)',
                  prefixIcon: Icon(Icons.bakery_dining),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: 'Grasas (g)',
                  prefixIcon: Icon(Icons.opacity),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
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
}
