
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user_recipe.dart';
import 'package:myapp/screens/recipes/add_recipe_screen.dart';

class UserRecipeDetailScreen extends StatefulWidget {
  final UserRecipe recipe;

  const UserRecipeDetailScreen({super.key, required this.recipe});

  @override
  State<UserRecipeDetailScreen> createState() => _UserRecipeDetailScreenState();
}

class _UserRecipeDetailScreenState extends State<UserRecipeDetailScreen> {
  late UserRecipe _currentRecipe;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(recipeToEdit: _currentRecipe),
      ),
    ).then((updatedRecipe) {
      if (updatedRecipe != null && updatedRecipe is UserRecipe) {
        setState(() {
          _currentRecipe = updatedRecipe;
        });
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Borrado'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar la receta "${_currentRecipe.title}"?'),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                final userRecipesBox = Hive.box<UserRecipe>('user_recipes');
                userRecipesBox.delete(_currentRecipe.id);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back from detail screen
              },
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditScreen,
            tooltip: 'Editar Receta',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmationDialog,
            tooltip: 'Eliminar Receta',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentRecipe.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(_currentRecipe.imageBytes!),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _currentRecipe.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_currentRecipe.description != null && _currentRecipe.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _currentRecipe.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Ingredientes'),
            ..._currentRecipe.ingredients.map((ingredient) => Text('• $ingredient')),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Instrucciones'),
            ..._currentRecipe.instructions
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('${entry.key + 1}. ${entry.value}'),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
