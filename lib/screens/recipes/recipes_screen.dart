
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/user_recipe.dart';
import 'package:myapp/screens/recipes/add_recipe_screen.dart';
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

class _CategoryInfo {
  final String label;
  final IconData icon;

  _CategoryInfo({required this.label, required this.icon});
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
  String _message = 'Selecciona una categoría o busca algo delicioso';

  final List<_CategoryInfo> _categories = [
    _CategoryInfo(label: 'Vegetariano', icon: Icons.eco_outlined),
    _CategoryInfo(label: 'Vegano', icon: Icons.energy_savings_leaf_outlined),
    _CategoryInfo(label: 'Keto', icon: Icons.egg_alt_outlined),
    _CategoryInfo(label: 'Postres', icon: Icons.cake_outlined),
    _CategoryInfo(label: 'Desayuno', icon: Icons.free_breakfast_outlined),
    _CategoryInfo(label: 'Almuerzo', icon: Icons.lunch_dining_outlined),
    _CategoryInfo(label: 'Cenas', icon: Icons.dinner_dining_outlined),
    _CategoryInfo(label: 'Sin Azúcar', icon: Icons.do_not_disturb_on_outlined),
    _CategoryInfo(label: 'Sin Gluten', icon: Icons.no_meals_outlined),
    _CategoryInfo(label: 'Alta Proteína', icon: Icons.fitness_center_outlined),
    _CategoryInfo(label: 'Rápido y Fácil', icon: Icons.timer_outlined),
    _CategoryInfo(label: 'Ensaladas', icon: Icons.grass_outlined),
    _CategoryInfo(label: 'Sopas', icon: Icons.ramen_dining_outlined),
  ];
  int? _selectedCategoryIndex;


  void _searchRecipes(String query) async {
    String finalQuery = query.trim();

    if (_selectedCategoryIndex != null) {
      final selectedCategory = _categories[_selectedCategoryIndex!].label;
      finalQuery = '$finalQuery $selectedCategory'.trim();
    }

    if (finalQuery.isEmpty) {
      setState(() {
        _recipes = [];
        _message = 'Selecciona una categoría o busca algo delicioso';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _recipes = [];
    });

    try {
      final recipes = await _recipeService.searchRecipes(finalQuery);
      setState(() {
        _recipes = recipes;
        if (_recipes.isEmpty) {
          _message = 'No se encontraron recetas para "$finalQuery"';
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
    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        const launchMode = kIsWeb ? LaunchMode.externalApplication : LaunchMode.platformDefault;
        if (!await launchUrl(uri, mode: launchMode)) {
           throw 'No se pudo abrir el enlace.';
        }
      } else {
        throw 'No se puede gestionar esta URL: $url';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _onCategorySelected(int? index) {
    Navigator.of(context).pop(); // Close the modal
    setState(() {
      _selectedCategoryIndex = (_selectedCategoryIndex == index) ? null : index;
    });

    String currentSearchText = _searchController.text;
    if (_selectedCategoryIndex != null || currentSearchText.isNotEmpty) {
      final categoryQuery = _selectedCategoryIndex != null ? _categories[_selectedCategoryIndex!].label : '';
      _searchRecipes('$currentSearchText $categoryQuery'.trim());
    }
  }

  void _showCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter modalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Elige una Categoría', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: List<Widget>.generate(_categories.length, (int index) {
                            return _CategoryButton(
                              label: _categories[index].label,
                              icon: _categories[index].icon,
                              isSelected: _selectedCategoryIndex == index,
                              onTap: () {
                                setState(() { // Use setState from the main screen
                                  _selectedCategoryIndex = (_selectedCategoryIndex == index) ? null : index;
                                });
                                modalState(() {}); // Rebuild the modal to show selection
                                 Future.delayed(const Duration(milliseconds: 300), () {
                                  _onCategorySelected(_selectedCategoryIndex);
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descubre tu Próxima Comida',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '¿Qué quieres cocinar hoy?',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onSubmitted: (value) => _searchRecipes(value),
          ),
           const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: _showCategoryModal,
            icon: const Icon(Icons.category_outlined),
            label: Text(_selectedCategoryIndex == null ? 'Elegir Categorías' : _categories[_selectedCategoryIndex!].label),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchPanel(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recipes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _message,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                          padding: const EdgeInsets.only(top: 0),
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
                                            child: const Icon(Icons.restaurant_menu, color: Colors.grey, size: 50),
                                          );
                                        },
                                      )
                                    else
                                      Container(
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

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        splashColor: colorScheme.primary.withAlpha(51),
        highlightColor: colorScheme.primary.withAlpha(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Theme.of(context).dividerColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface, size: 18),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteRecipesTab extends StatefulWidget {
  const FavoriteRecipesTab({super.key});

  @override
  State<FavoriteRecipesTab> createState() => _FavoriteRecipesTabState();
}

class _FavoriteRecipesTabState extends State<FavoriteRecipesTab> with SingleTickerProviderStateMixin {
  late TabController _innerTabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
    _innerTabController.addListener(() {
      if (_innerTabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _innerTabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TabBar(
          controller: _innerTabController,
          tabs: const [
            Tab(icon: Icon(Icons.public), text: 'De la Web'),
            Tab(icon: Icon(Icons.my_library_books), text: 'Creadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _innerTabController,
        children: const [
          WebFavoritesTab(),
          CreatedRecipesTab(),
        ],
      ),
      floatingActionButton: _currentTabIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipeScreen()));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class WebFavoritesTab extends StatelessWidget {
  const WebFavoritesTab({super.key});

 @override
  Widget build(BuildContext context) {
    final favoritesBox = Hive.box<Recipe>('favorite_recipes');

    return ValueListenableBuilder(
      valueListenable: favoritesBox.listenable(),
      builder: (context, Box<Recipe> box, _) {
        final favoriteRecipes = box.values.toList().cast<Recipe>();

        if (favoriteRecipes.isEmpty) {
          return const Center(
            child: Text(
              'Aún no tienes recetas favoritas de la web.\n¡Anímate a guardar una!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: favoriteRecipes.length,
          itemBuilder: (context, index) {
            final recipe = favoriteRecipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  final Uri uri = Uri.parse(recipe.link);
                    try {
                      final bool canLaunch = await canLaunchUrl(uri);
                      if (canLaunch) {
                        const launchMode = kIsWeb ? LaunchMode.externalApplication : LaunchMode.platformDefault;
                        if (!await launchUrl(uri, mode: launchMode)) {
                          throw 'No se pudo abrir el enlace.';
                        }
                      } else {
                        throw 'No se puede gestionar esta URL: ${recipe.link}';
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Stack(
                      alignment: Alignment.topRight,
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
                                child: const Icon(Icons.restaurant_menu, color: Colors.grey, size: 50),
                              );
                            },
                          )
                        else
                          Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.restaurant_menu, size: 50, color: Colors.grey),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
                          onPressed: () => favoritesBox.delete(recipe.link),
                        ),
                      ],
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
        );
      },
    );
  }
}

class CreatedRecipesTab extends StatelessWidget {
  const CreatedRecipesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userRecipesBox = Hive.box<UserRecipe>('user_recipes');

    return ValueListenableBuilder(
      valueListenable: userRecipesBox.listenable(),
      builder: (context, Box<UserRecipe> box, _) {
        final userRecipes = box.values.toList().cast<UserRecipe>();

        if (userRecipes.isEmpty) {
          return const Center(
            child: Text(
              'Aún no has creado ninguna receta.\n¡Usa el botón + para añadir una!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: userRecipes.length,
          itemBuilder: (context, index) {
            final recipe = userRecipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.imageBytes != null)
                      Image.memory(
                        recipe.imageBytes!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
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
                          if (recipe.description != null && recipe.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text(
                              recipe.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
  }
}
