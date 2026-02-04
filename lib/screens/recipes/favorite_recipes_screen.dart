import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final favoriteRecipes = userProvider.user?.favoriteRecipes ?? [];

        if (favoriteRecipes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.favorite_border,
            title: 'Sin recetas favoritas',
            subtitle: 'Busca recetas y guárdalas para verlas aquí.',
            iconColor: Colors.red[400],
          );
        }

        final colors = Theme.of(context).colorScheme;
        
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
                  icon: Icon(Icons.delete_outline, color: colors.error),
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
