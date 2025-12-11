import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final favoriteRecipes = userProvider.user?.favoriteRecipes ?? [];

        if (favoriteRecipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.star(), size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'No tienes recetas favoritas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Busca recetas y guárdalas para verlas aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: favoriteRecipes.length,
          itemBuilder: (context, index) {
            final recipe = favoriteRecipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(recipe.snippet),
                trailing: IconButton(
                  icon: Icon(PhosphorIcons.trash(), color: Colors.redAccent),
                  onPressed: () {
                    userProvider.removeFavoriteRecipe(recipe);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receta eliminada de favoritos')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
