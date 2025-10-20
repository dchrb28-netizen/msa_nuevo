
import 'package:flutter/material.dart';
import 'package:myapp/services/recipe_service.dart';
import 'package:myapp/models/recipe.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Mis Recetas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Buscar'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SearchRecipesTab(),
          FavoriteRecipesTab(),
        ],
      ),
    );
  }
}

class SearchRecipesTab extends StatefulWidget {
  const SearchRecipesTab({super.key});

  @override
  State<SearchRecipesTab> createState() => _SearchRecipesTabState();
}

class _SearchRecipesTabState extends State<SearchRecipesTab> {
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _message = 'Busca tus recetas favoritas en español';

  void _searchRecipes(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final recipes = await _recipeService.searchRecipes(query);
      setState(() {
        _recipes = recipes;
        if (_recipes.isEmpty) {
          _message = 'No se encontraron recetas para "$query"';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Error al buscar: ${e.toString()}';
        _recipes = [];
      });
    } finally {
       if (mounted) {
          setState(() {
            _isLoading = false;
          });
       }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: '¿Qué quieres cocinar hoy?',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchRecipes(_searchController.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: (value) => _searchRecipes(value),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recipes.isEmpty
                  ? Center(
                      child: Text(
                        _message,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _launchURL(recipe.link),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipe.imageUrl != null)
                                    Image.network(
                                      recipe.imageUrl!,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                           height: 180,
                                           width: double.infinity,
                                           color: Colors.grey[300],
                                           child: const Icon(Icons.restaurant_menu, color: Colors.grey, size: 50)
                                        );
                                      },
                                    ) else Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.restaurant_menu, size: 50, color: Colors.grey),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.title,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        recipe.snippet,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class FavoriteRecipesTab extends StatelessWidget {
  const FavoriteRecipesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar la lista de recetas favoritas
    return const Center(
      child: Text('Aquí se mostrarán tus recetas favoritas.'),
    );
  }
}
