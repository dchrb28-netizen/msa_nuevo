import 'package:flutter/material.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';

class EditMealScreen extends StatefulWidget {
  final String mealType;
  final DateTime date;

  const EditMealScreen({super.key, required this.mealType, required this.date});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    final mealText = provider.getMealTextForDay(widget.date, widget.mealType);
    _textController = TextEditingController(text: mealText);
  }

  void _saveMeal() {
    if (!mounted) return;
    Provider.of<MealPlanProvider>(
      context,
      listen: false,
    ).updateMealText(widget.date, widget.mealType, _textController.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Menú guardado!')));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Planificar ${widget.mealType}')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Detalles del Menú',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Planifica aquí los alimentos para el ${widget.mealType.toLowerCase()}.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _textController,
                autofocus: true,
                maxLines: 8,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Describe el menú',
                  hintText:
                      'Ej: Pechuga de pollo a la plancha, arroz integral y brócoli al vapor.',
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Guardar Menú'),
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
