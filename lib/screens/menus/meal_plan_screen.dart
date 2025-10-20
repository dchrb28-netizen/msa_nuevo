import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/daily_meal_plan.dart';
import 'package:myapp/models/food.dart';
import 'package:myapp/models/meal_type.dart';

class MealPlanScreen extends StatefulWidget {
  final DateTime date;
  final MealType mealType;

  const MealPlanScreen({super.key, required this.date, required this.mealType});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final List<Food> _foods = [];
  late Box<DailyMealPlan> _mealPlanBox;

  @override
  void initState() {
    super.initState();
    _mealPlanBox = Hive.box<DailyMealPlan>('daily_meal_plans');
    _loadFoods();
  }

  void _loadFoods() {
    final mealPlan = _getMealPlanForDate(widget.date);
    if (mealPlan != null) {
      setState(() {
        _foods.clear();
        _foods.addAll(mealPlan.meals[widget.mealType] ?? []);
      });
    }
  }

  DailyMealPlan? _getMealPlanForDate(DateTime date) {
    for (var plan in _mealPlanBox.values) {
      if (plan.date.year == date.year &&
          plan.date.month == date.month &&
          plan.date.day == date.day) {
        return plan;
      }
    }
    return null;
  }

  Future<void> _saveFoods() async {
    final mealPlan = _getMealPlanForDate(widget.date);
    if (mealPlan != null) {
      mealPlan.meals[widget.mealType] = List<Food>.from(_foods);
      await mealPlan.save();
    } else {
      final newMealPlan = DailyMealPlan(
        date: widget.date,
        meals: {widget.mealType: List<Food>.from(_foods)},
      );
      await _mealPlanBox.add(newMealPlan);
    }
  }

  String _getMealTypeTitle(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snacks:
        return 'Snacks';
    }
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final foodBox = Hive.box<Food>('foods');
        final allFoods = foodBox.values.toList();
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final filteredFoods = allFoods
                .where((food) =>
                    food.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: const Text('Añadir Alimento'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar alimento',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredFoods.length,
                        itemBuilder: (context, index) {
                          final food = filteredFoods[index];
                          return ListTile(
                            title: Text(food.name),
                            subtitle: Text('${food.calories} kcal'),
                            onTap: () {
                              setState(() {
                                _foods.add(food);
                              });
                              _saveFoods();
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getMealTypeTitle(widget.mealType)} - ${DateFormat.yMMMMEEEEd().format(widget.date)}'),
      ),
      body: ListView.builder(
        itemCount: _foods.length,
        itemBuilder: (context, index) {
          final food = _foods[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text('${food.calories} kcal'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _foods.removeAt(index);
                  _saveFoods();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
