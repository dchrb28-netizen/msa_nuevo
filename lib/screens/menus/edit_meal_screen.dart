import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/screens/register_food_screen.dart';
import 'package:provider/provider.dart';

class EditMealScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const EditMealScreen({super.key, required this.mealType, required this.date});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  late List<Food> _plannedFoods;

  @override
  void initState() {
    super.initState();
    _plannedFoods = List<Food>.from(
      Provider.of<MealPlanProvider>(context, listen: false).getMealsForDay(widget.date, widget.mealType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.mealType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Cambios',
            onPressed: () {
              Provider.of<MealPlanProvider>(context, listen: false).updateMeal(
                widget.date,
                widget.mealType,
                _plannedFoods,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan de comidas actualizado')),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_plannedFoods.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No hay alimentos en esta comida. \n¡Añade uno para empezar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _plannedFoods.length,
                  itemBuilder: (context, index) {
                    final food = _plannedFoods[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(food.name, style: GoogleFonts.lato()),
                        subtitle: Text('${(food.calories ?? 0).toStringAsFixed(0)} kcal'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Eliminar Alimento',
                          onPressed: () {
                            setState(() {
                              _plannedFoods.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Añadir Plato'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final newFood = await Navigator.push<Food>(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterFoodScreen()),
                );
                if (newFood != null) {
                  setState(() {
                    _plannedFoods.add(newFood);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
