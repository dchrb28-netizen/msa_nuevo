import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/user_recipe.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatefulWidget {
  final UserRecipe? recipeToEdit;
  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  Uint8List? _imageBytes;
  bool get _isEditing => widget.recipeToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadRecipeData();
    } else {
      // Start with one empty field for new recipes
      _addIngredientField();
      _addInstructionField();
    }
  }

  void _loadRecipeData() {
    final recipe = widget.recipeToEdit!;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description ?? '';
    _categoryController.text = recipe.category ?? '';
    _cookingTimeController.text = recipe.cookingTime?.toString() ?? '';
    _servingsController.text = recipe.servings?.toString() ?? '';
    
    if (recipe.imageBytes != null) {
      _imageBytes = Uint8List.fromList(recipe.imageBytes!);
    }

    _ingredientControllers.clear();
    for (var ingredient in recipe.ingredients) {
      _ingredientControllers.add(TextEditingController(text: ingredient));
    }
    if (_ingredientControllers.isEmpty) _addIngredientField();

    _instructionControllers.clear();
    for (var instruction in recipe.instructions) {
      _instructionControllers.add(TextEditingController(text: instruction));
    }
    if (_instructionControllers.isEmpty) _addInstructionField();

  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final userRecipesBox = Hive.box<UserRecipe>('user_recipes');

    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (_isEditing) {
      final originalRecipe = widget.recipeToEdit!;

      // Create a new recipe instance with the updated data
      final updatedRecipe = UserRecipe(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        cookingTime: double.tryParse(_cookingTimeController.text),
        servings: double.tryParse(_servingsController.text),
        ingredients: ingredients,
        instructions: instructions,
        imageBytes: _imageBytes?.toList(),
        isFavorite: originalRecipe.isFavorite, // Preserve favorite status
      );

      // Manually set the ID to the original ID to ensure we overwrite the correct object.
      updatedRecipe.id = originalRecipe.id; 

      // Put the updated object into the box, overwriting the old one.
      await userRecipesBox.put(updatedRecipe.id, updatedRecipe);

      messenger.showSnackBar(
        const SnackBar(content: Text('Receta actualizada con éxito')),
      );
      navigator.pop(updatedRecipe); // Return updated recipe

    } else {
      // Create new recipe
      final achievementService =
          Provider.of<AchievementService>(context, listen: false);

      final newRecipe = UserRecipe(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        cookingTime: double.tryParse(_cookingTimeController.text),
        servings: double.tryParse(_servingsController.text),
        ingredients: ingredients,
        instructions: instructions,
        imageBytes: _imageBytes?.toList(),
      );

      await userRecipesBox.put(newRecipe.id, newRecipe);

      achievementService.updateProgress('create_recipe', 1);

      messenger.showSnackBar(
        const SnackBar(content: Text('Receta guardada con éxito')),
      );
      navigator.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRecipe, tooltip: 'Guardar'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce un título';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookingTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo (min)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(labelText: 'Porciones'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                     inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 20),
            _buildDynamicList(
              'Ingredientes',
              _ingredientControllers,
              _addIngredientField,
              _removeIngredientField,
            ),
            const SizedBox(height: 20),
            _buildDynamicList(
              'Instrucciones',
              _instructionControllers,
              _addInstructionField,
              _removeInstructionField,
            ),
            const SizedBox(height: 20),
            _imageBytes == null
                ? OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar Imagen'),
                  )
                : Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!, height: 200, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha((255 * 0.4).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 32),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicList(
    String title,
    List<TextEditingController> controllers,
    VoidCallback onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        ...controllers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText:
                        '${title.singularize()} ${idx + 1}',
                  ),
                ),
              ),
              if (controllers.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => onRemove(idx),
                  tooltip: 'Eliminar campo',
                ),
            ],
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('Añadir ${title.singularize()}'),
        ),
      ],
    );
  }
}

// Simple extension to get singular form for button labels
extension StringExtension on String {
  String singularize() {
    if (endsWith('es')) {
      return substring(0, length - 2);
    }
    if (endsWith('s')) {
      return substring(0, length - 1);
    }
    return this;
  }
}
