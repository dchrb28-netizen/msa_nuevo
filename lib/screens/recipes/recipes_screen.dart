import 'package:flutter/material.dart';
import 'package:myapp/screens/recipes/add_recipe_screen.dart';
import 'package:myapp/screens/recipes/favorite_recipes_screen.dart';
import 'package:myapp/screens/recipes/recipe_list_screen.dart';

class RecipesScreen extends StatefulWidget {
  final int initialTabIndex;
  const RecipesScreen({super.key, this.initialTabIndex = 0});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Recetas'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RecipeListScreen(),
          FavoriteRecipesScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
        },
        tooltip: 'Añadir Receta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
