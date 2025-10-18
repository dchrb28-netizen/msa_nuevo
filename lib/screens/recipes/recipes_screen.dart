
import 'package:flutter/material.dart';
import 'package:myapp/screens/recipes/add_recipe_screen.dart';
import 'package:myapp/screens/recipes/favorite_recipes_screen.dart';
import 'package:myapp/screens/recipes/recipe_list_screen.dart';

class RecipesScreen extends StatefulWidget {
  final int initialTabIndex;
  const RecipesScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

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
        title: const Text('Mis Recetas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recetas'),
            Tab(text: 'Favoritas'),
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
        child: const Icon(Icons.add),
        tooltip: 'Añadir Receta',
      ),
    );
  }
}
