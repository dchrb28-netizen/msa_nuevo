import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

      // Update achievements
      achievementService.updateProgress('create_recipe', 1);
      achievementService.grantExperience(15); // Grant XP for creating recipe
      
      // Update cumulative achievements
      final totalRecipes = userRecipesBox.length;
      achievementService.updateProgress('cum_recipes_25', totalRecipes, cumulative: true);
      achievementService.updateProgress('cum_recipes_100', totalRecipes, cumulative: true);

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 24),
            onPressed: _saveRecipe,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                filled: true,
                fillColor: colors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                filled: true,
                fillColor: colors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
              style: GoogleFonts.lato(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookingTimeController,
                    decoration: InputDecoration(
                      labelText: 'Tiempo (min)',
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    style: GoogleFonts.lato(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: InputDecoration(
                      labelText: 'Porciones',
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    style: GoogleFonts.lato(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: colors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: GoogleFonts.lato(),
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
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.primary,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: colors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Seleccionar Imagen',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Toca para seleccionar una imagen',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
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
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...controllers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextEditingController controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: '${title.singularize()} ${idx + 1}',
                      filled: true,
                      fillColor: colors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    maxLines: 2,
                    style: GoogleFonts.lato(),
                  ),
                ),
                if (controllers.length > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: colors.error, size: 20),
                      onPressed: () => onRemove(idx),
                      tooltip: 'Eliminar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'Añadir ${title.singularize()}',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
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
