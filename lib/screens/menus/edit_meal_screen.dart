import 'package:flutter/material.dart';
import 'package:myapp/models/food.dart';

class EditMealScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const EditMealScreen({super.key, required this.mealType, required this.date});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  // Dummy data for demonstration
  final List<Food> _foods = [
    Food(id: '1', name: 'Tostada con Aguacate', calories: 250, proteins: 8, carbohydrates: 25, fats: 15),
    Food(id: '2', name: 'Huevo Cocido', calories: 78, proteins: 6, carbohydrates: 0.6, fats: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.mealType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save), 
            onPressed: () {
              // TODO: Implement save logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cambios guardados (simulado)')),
              );
              Navigator.of(context).pop();
            }
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _foods.length,
                itemBuilder: (context, index) {
                  final food = _foods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(food.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _foods.removeAt(index);
                          });
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alimento eliminado (simulado)')),
                          );
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
              label: const Text('Añadir Alimento'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                  // TODO: Implement add food functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de añadir próximamente')),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
