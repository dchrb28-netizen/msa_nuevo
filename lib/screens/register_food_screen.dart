
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/food.dart';
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

  final _foodBox = Hive.box<Food>('foods');

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final newFood = Food(
        id: const Uuid().v4(),
        name: _nameController.text,
        calories: double.tryParse(_caloriesController.text) ?? 0.0,
        proteins: double.tryParse(_proteinController.text) ?? 0.0,
        carbohydrates: double.tryParse(_carbsController.text) ?? 0.0,
        fats: double.tryParse(_fatController.text) ?? 0.0,
      );

      _foodBox.add(newFood);
      Navigator.pop(context, newFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                onPressed: _saveFood,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Comida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
