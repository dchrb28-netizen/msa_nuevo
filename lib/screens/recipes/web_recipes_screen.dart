import 'package:flutter/material.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class WebRecipesScreen extends StatefulWidget {
  const WebRecipesScreen({super.key});

  @override
  State<WebRecipesScreen> createState() => _WebRecipesScreenState();
}

class _WebRecipesScreenState extends State<WebRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];
  bool _isLoading = false;

  // --- SIMULATED RECIPE SERVICE ---
  final List<Recipe> _allWebRecipes = [
    Recipe(title: 'Ensalada César de Pollo', link: 'google.com', snippet: 'Una clásica ensalada César con pollo a la parrilla, perfecta para un almuerzo ligero.'),
    Recipe(title: 'Salmón al Horno con Espárragos', link: 'google.com', snippet: 'Salmón tierno horneado con espárragos frescos, limón y aceite de oliva. Una cena saludable y rápida.'),
    Recipe(title: 'Batido de Proteínas y Frutos Rojos', link: 'google.com', snippet: 'Un batido energizante y delicioso, ideal para después del entrenamiento.'),
    Recipe(title: 'Avena Nocturna', link: 'google.com', snippet: 'Prepara el desayuno la noche anterior con esta receta fácil y nutritiva de avena.'),
  ];

  void _searchRecipes(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);

    // Simulate a network call
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = _allWebRecipes
          .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    });
  }
  // --- END OF SIMULATED SERVICE ---

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchRecipes,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResultsList(userProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(UserProvider userProvider) {
    if (_searchController.text.isEmpty) {
      return const Center(child: Text('Escribe algo para buscar recetas.'));
    }
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No se encontraron recetas.'));
    }

    final favoriteTitles = userProvider.user?.favoriteRecipes.map((r) => r.title).toSet() ?? {};

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        final isFavorite = favoriteTitles.contains(recipe.title);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(recipe.snippet),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? PhosphorIcons.star(PhosphorIconsStyle.fill) : PhosphorIcons.star(),
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () async {
                // Capture the messenger before the async gap
                final messenger = ScaffoldMessenger.of(context);
                
                if (isFavorite) {
                  userProvider.removeFavoriteRecipe(recipe);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Receta eliminada de favoritos')),
                    );
                  }
                } else {
                  final success = await userProvider.addFavoriteRecipe(recipe);
                  if (mounted) {
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('¡Receta añadida a favoritos!')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Necesitas un perfil para guardar recetas.')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}