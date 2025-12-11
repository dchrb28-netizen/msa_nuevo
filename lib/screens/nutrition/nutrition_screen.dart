import 'package:flutter/material.dart';
import 'package:myapp/screens/recipes/favorite_recipes_screen.dart';
import 'package:myapp/screens/recipes/web_recipes_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  NutritionScreenState createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(text: 'Mis Favoritas'),
            Tab(text: 'Buscar Online'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FavoriteRecipesScreen(),
          WebRecipesScreen(),
        ],
      ),
    );
  }
}
