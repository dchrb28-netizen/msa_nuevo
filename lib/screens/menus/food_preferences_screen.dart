import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/menus/food_catalog_screen.dart';

class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  final TextEditingController _favoriteController = TextEditingController();
  final TextEditingController _dislikedController = TextEditingController();
  final TextEditingController _allergenController = TextEditingController();

  // Sugerencias predefinidas - PROTEÍNAS
  final List<String> commonFavorites = [
    // Carnes y Aves
    'Pollo', 'Pechuga de pollo', 'Pavo', 'Res', 'Cerdo', 'Cordero', 'Conejo',
    // Pescados y Mariscos
    'Salmón', 'Atún', 'Trucha', 'Bacalao', 'Tilapia', 'Camarones', 'Calamar', 'Mejillones',
    // Huevos y Derivados
    'Huevos', 'Clara de huevo',
    // Productos de Soya
    'Tofu', 'Tempeh', 'Soya',
    // Legumbres
    'Lentejas', 'Frijoles negros', 'Frijoles rojos', 'Habas', 'Arvejas',
    // Lácteos
    'Yogur griego', 'Queso bajo en grasa', 'Leche desnatada',
    
    // VEGETALES Y FRUTAS
    // Vegetales verdes
    'Espinaca', 'Lechuga', 'Kale', 'Acelga', 'Rúcula', 'Berza',
    // Crucíferas
    'Brócoli', 'Coliflor', 'Col', 'Repollo',
    // Raíces
    'Zanahoria', 'Papa dulce', 'Remolacha', 'Nabo', 'Cebolla',
    // Tomates y Cucurbitáceas
    'Tomate', 'Pepino', 'Calabaza', 'Pimiento rojo', 'Pimiento verde', 'Aguacate',
    // Frutas
    'Manzana', 'Plátano', 'Naranja', 'Fresas', 'Arándanos', 'Frambuesas', 'Sandía', 'Piña', 'Kiwi',
    'Pera', 'Durazno', 'Cereza', 'Papaya', 'Mango', 'Uva', 'Limón',
    
    // GRANOS Y CARBOHIDRATOS
    'Arroz integral', 'Arroz blanco', 'Avena', 'Quínoa', 'Cebada', 'Pasta integral',
    'Pan integral', 'Batata', 'Maíz', 'Garbanzos cocidos',
    
    // GRASAS SALUDABLES
    'Almendras', 'Avellanas', 'Semillas de girasol', 'Semillas de calabaza', 'Semillas de lino',
    'Aceite de oliva', 'Aceite de coco', 'Mantequilla de almendra',
    
    // OTROS
    'Ajo', 'Jengibre', 'Champiñones', 'Puerro', 'Espárragos', 'Judías verdes',
  ];

  final List<String> commonDisliked = [
    // Vegetales
    'Champiñones', 'Cebolla', 'Ajo', 'Remolacha', 'Repollo', 'Coliflor', 'Berenjenas',
    'Calabaza', 'Alcachofas', 'Espárragos', 'Puerro', 'Nabo', 'Rúcula',
    
    // Legumbres
    'Garbanzos', 'Frijoles', 'Lentejas', 'Guisantes', 'Habas', 'Arvejas',
    
    // Carnes
    'Hígado', 'Riñones', 'Lengua', 'Vísceras', 'Cerdo graso', 'Carnes procesadas',
    
    // Frutas
    'Piña', 'Plátano verde', 'Coco', 'Dátiles',
    
    // Pescados
    'Anchoveta', 'Sardinas', 'Arenque', 'Caballa', 'Atún enlatado',
    
    // Lácteos
    'Leche entera', 'Crema', 'Queso azul', 'Yogur azucarado',
    
    // Otros
    'Mostaza', 'Vinagre', 'Picante', 'Espinaca cocida', 'Huevo crudo', 'Aguacate maduro',
  ];

  final List<String> commonAllergens = [
    // Frutos Secos
    'Cacahuetes', 'Maní', 'Nueces', 'Almendras', 'Avellanas', 'Pistacho', 'Castaña',
    'Semillas de sésamo', 'Mantequilla de cacahuete', 'Mantequilla de almendra',
    
    // Lácteos
    'Leche de vaca', 'Queso', 'Yogur', 'Mantequilla', 'Lactosuero', 'Caseína',
    
    // Huevo
    'Huevo', 'Clara de huevo', 'Yema de huevo',
    
    // Gluten y Cereales
    'Trigo', 'Cebada', 'Centeno', 'Avena', 'Triticale', 'Gluten',
    
    // Pescado y Mariscos
    'Pescado blanco', 'Salmón', 'Atún', 'Bacalao', 'Trucha', 'Camarones', 'Langosta',
    'Mejillones', 'Ostras', 'Almejas', 'Calamar', 'Cangrejo',
    
    // Soya
    'Soya', 'Tofu', 'Tempeh', 'Salsa de soya', 'Edamame',
    
    // Semillas
    'Semillas de sésamo', 'Semillas de girasol', 'Semillas de calabaza', 'Semillas de lino',
    
    // Otros
    'Mostaza', 'Apio', 'Sulfitos', 'Látex', 'Níquel', 'Histamina',
  ];

  late User? _currentUser;
  late List<String> _favorites;
  late List<String> _disliked;
  late List<String> _allergens;
  late Set<String> _dietFilters;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<UserProvider>(context, listen: false).user;
    _favorites = List.from(_currentUser?.favoriteRawFoods ?? []);
    _disliked = List.from(_currentUser?.dislikedFoods ?? []);
    _allergens = List.from(_currentUser?.allergens ?? []);
    final prefs = _currentUser?.dietaryPreferences ?? '';
    _dietFilters = prefs.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty).toSet();
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _dislikedController.dispose();
    _allergenController.dispose();
    super.dispose();
  }

  void _addFavorite(String food) {
    if (food.isNotEmpty && !_favorites.contains(food)) {
      setState(() => _favorites.add(food));
      _favoriteController.clear();
    }
  }

  void _removeFavorite(String food) {
    setState(() => _favorites.remove(food));
  }

  void _addDisliked(String food) {
    if (food.isNotEmpty && !_disliked.contains(food)) {
      setState(() => _disliked.add(food));
      _dislikedController.clear();
    }
  }

  void _removeDisliked(String food) {
    setState(() => _disliked.remove(food));
  }

  void _addAllergen(String allergen) {
    if (allergen.isNotEmpty && !_allergens.contains(allergen)) {
      setState(() => _allergens.add(allergen));
      _allergenController.clear();
    }
  }

  void _removeAllergen(String allergen) {
    setState(() => _allergens.remove(allergen));
  }

  void _openFoodCatalog(
    String category,
    List<String> currentItems,
    Function(List<String>) onSave,
  ) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FoodCatalogScreen(
          category: category,
          selectedItems: currentItems,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (category == 'favorites') {
          _favorites = result;
        } else if (category == 'disliked') {
          _disliked = result;
        } else if (category == 'allergens') {
          _allergens = result;
        }
      });
    }
  }

  void _savePreferences() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = _currentUser!.copyWith(
      favoriteRawFoods: _favorites,
      dislikedFoods: _disliked,
      allergens: _allergens,
      dietaryPreferences: _dietFilters.isNotEmpty ? _dietFilters.join(',') : null,
    );
    userProvider.updateUser(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencias guardadas exitosamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias Alimentarias'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alimentos Favoritos
            _buildPreferenceSection(
              title: 'Alimentos Favoritos ❤️',
              controller: _favoriteController,
              items: _favorites,
              suggestions: commonFavorites,
              onAdd: _addFavorite,
              onRemove: _removeFavorite,
              color: Colors.green,
              category: 'favorites',
            ),
            const SizedBox(height: 24),

            // Alimentos No Deseados
            _buildPreferenceSection(
              title: 'Alimentos No Deseados ❌',
              controller: _dislikedController,
              items: _disliked,
              suggestions: commonDisliked,
              onAdd: _addDisliked,
              onRemove: _removeDisliked,
              color: Colors.orange,
              category: 'disliked',
            ),
            const SizedBox(height: 24),

            // Alergias e Intolerancias
            _buildPreferenceSection(
              title: 'Alergias e Intolerancias ⚠️',
              controller: _allergenController,
              items: _allergens,
              suggestions: commonAllergens,
              onAdd: _addAllergen,
              onRemove: _removeAllergen,
              color: Colors.red,
              category: 'allergens',
            ),
            const SizedBox(height: 32),

            // Filtros dietéticos
            Text(
              'Filtros dietéticos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Vegano'),
                  selected: _dietFilters.contains('vegano'),
                  onSelected: (s) {
                    setState(() {
                      if (s) _dietFilters.add('vegano'); else _dietFilters.remove('vegano');
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Vegetariano'),
                  selected: _dietFilters.contains('vegetariano'),
                  onSelected: (s) {
                    setState(() {
                      if (s) _dietFilters.add('vegetariano'); else _dietFilters.remove('vegetariano');
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Sin Azúcar'),
                  selected: _dietFilters.contains('sin azucar') || _dietFilters.contains('sin azúcar'),
                  onSelected: (s) {
                    setState(() {
                      if (s) _dietFilters.add('sin azucar'); else {
                        _dietFilters.remove('sin azucar');
                        _dietFilters.remove('sin azúcar');
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePreferences,
                icon: const Icon(Icons.check),
                label: const Text('Guardar Preferencias'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required TextEditingController controller,
    required List<String> items,
    required List<String> suggestions,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required Color color,
    required String category,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openFoodCatalog(
                category,
                items,
                (selected) {
                  setState(() {
                    if (category == 'favorites') {
                      _favorites = selected;
                    } else if (category == 'disliked') {
                      _disliked = selected;
                    } else if (category == 'allergens') {
                      _allergens = selected;
                    }
                  });
                },
              ),
              icon: const Icon(Icons.library_add, size: 18),
              label: const Text('Ver Todo', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Agregar alimento...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onAdd(controller.text),
              icon: const Icon(Icons.add_circle),
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Items seleccionados
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => Chip(
              label: Text(item),
              onDeleted: () => onRemove(item),
              backgroundColor: color.withOpacity(0.2),
              deleteIcon: Icon(Icons.close, color: color),
            ))
                .toList(),
          )
        else
          Text(
            'Sin elementos agregados',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),

        const SizedBox(height: 16),

        // Sugerencias
        Text(
          'Sugerencias:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .where((s) => !items.contains(s))
              .take(6)
              .map((suggestion) => ActionChip(
            label: Text(suggestion),
            onPressed: () => onAdd(suggestion),
            backgroundColor: color.withOpacity(0.1),
            side: BorderSide(color: color.withOpacity(0.3)),
          ))
              .toList(),
        ),
      ],
    );
  }
}

