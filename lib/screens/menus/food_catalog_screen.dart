import 'package:flutter/material.dart';

class FoodCatalogScreen extends StatefulWidget {
  final String category; // 'favorites', 'disliked', 'allergens'
  final List<String> selectedItems;

  const FoodCatalogScreen({
    required this.category,
    required this.selectedItems,
    super.key,
  });

  @override
  State<FoodCatalogScreen> createState() => _FoodCatalogScreenState();
}

class _FoodCatalogScreenState extends State<FoodCatalogScreen> {
  late TextEditingController _searchController;
  late List<String> _filteredFoods;
  late Set<String> _selectedFoods;
  String _selectedSubcategory = 'Todos';

  // Catálogo completo organizado por subcategorías
  static const Map<String, List<String>> allFoods = {
    'Proteínas - Carnes': [
      'Pollo', 'Pechuga de pollo', 'Muslo de pollo', 'Alitas de pollo',
      'Pavo', 'Pechuga de pavo', 'Res', 'Filete de res', 'Carne molida',
      'Cerdo', 'Lomo de cerdo', 'Costillas de cerdo', 'Jamón',
      'Cordero', 'Conejo', 'Hígado', 'Riñones',
    ],
    'Proteínas - Pescados y Mariscos': [
      'Salmón', 'Atún', 'Trucha', 'Bacalao', 'Merluza', 'Tilapia',
      'Sardinas', 'Anchoas', 'Camarones', 'Langosta', 'Cangrejo',
      'Mejillones', 'Ostras', 'Almejas', 'Calamar', 'Pulpo',
    ],
    'Proteínas - Huevos y Derivados': [
      'Huevos', 'Claras de huevo', 'Yema de huevo', 'Huevo cocido',
    ],
    'Proteínas - Soya y Alternativas': [
      'Tofu', 'Tempeh', 'Soya', 'Edamame', 'Proteína de soya',
    ],
    'Proteínas - Legumbres': [
      'Lentejas', 'Lentejas rojas', 'Lentejas verdes', 'Lentejas negras',
      'Frijoles', 'Frijoles negros', 'Frijoles rojos', 'Frijoles pintos',
      'Garbanzos', 'Habas', 'Arvejas', 'Guisantes',
    ],
    'Proteínas - Lácteos': [
      'Yogur natural', 'Yogur griego', 'Yogur de soja',
      'Queso fresco', 'Queso cheddar', 'Queso azul', 'Queso mozzarella',
      'Leche desnatada', 'Leche entera', 'Leche de almendra',
      'Leche de coco', 'Requesón', 'Ricota',
    ],
    'Vegetales - Verdes': [
      'Espinaca', 'Lechuga', 'Lechuga romana', 'Lechuga iceberg',
      'Kale', 'Acelga', 'Rúcula', 'Berza', 'Col rizada',
    ],
    'Vegetales - Crucíferas': [
      'Brócoli', 'Coliflor', 'Col', 'Repollo', 'Repollo rojo',
      'Brotes de Bruselas', 'Bimi',
    ],
    'Vegetales - Raíces y Tubérculos': [
      'Zanahoria', 'Papa', 'Papa blanca', 'Papa roja',
      'Papa dulce', 'Camote', 'Remolacha', 'Nabo', 'Cebolla',
      'Cebolla roja', 'Puerro', 'Ajo', 'Jengibre',
    ],
    'Vegetales - Tomates y Cucurbitáceas': [
      'Tomate', 'Tomate cherry', 'Pepino', 'Calabaza', 'Calabacín',
      'Pimiento rojo', 'Pimiento verde', 'Pimiento amarillo', 'Aguacate',
      'Chayote',
    ],
    'Vegetales - Otros': [
      'Champiñones', 'Espárragos', 'Judías verdes', 'Alcachofas',
      'Maíz', 'Choclo', 'Okra', 'Calabaza italiana',
    ],
    'Frutas - Cítricas': [
      'Naranja', 'Mandarina', 'Limón', 'Pomelo', 'Toronja',
      'Lima', 'Tangelo',
    ],
    'Frutas - Berries': [
      'Fresas', 'Arándanos', 'Frambuesas', 'Moras',
      'Grosellas', 'Arándanos rojos',
    ],
    'Frutas - Tropicales': [
      'Plátano', 'Mango', 'Piña', 'Papaya', 'Coco',
      'Guanabana', 'Chirimoya', 'Guayaba',
    ],
    'Frutas - Otras': [
      'Manzana', 'Pera', 'Durazno', 'Cereza', 'Ciruela',
      'Kiwi', 'Higo', 'Uva', 'Melón', 'Sandía',
      'Melocotón', 'Nectarina', 'Albaricoque',
    ],
    'Granos y Cereales': [
      'Arroz blanco', 'Arroz integral', 'Arroz salvaje',
      'Avena', 'Avena integral', 'Avena rápida',
      'Quínoa', 'Cebada', 'Centeno', 'Triticale',
      'Pasta integral', 'Pasta blanca', 'Pan integral', 'Pan blanco',
      'Tortilla integral', 'Tortilla de maíz', 'Cuscús',
    ],
    'Grasas Saludables': [
      'Almendras', 'Avellanas', 'Nueces', 'Pistacho', 'Cacahuetes',
      'Maní', 'Pecanas', 'Nueces de macadamia', 'Anacardos',
      'Semillas de girasol', 'Semillas de calabaza', 'Semillas de lino',
      'Semillas de chía', 'Semillas de sésamo', 'Tahini',
      'Aceite de oliva', 'Aceite de coco', 'Mantequilla',
      'Mantequilla de almendra', 'Mantequilla de cacahuete',
    ],
    'Bebidas': [
      'Agua', 'Agua con gas', 'Té verde', 'Té negro',
      'Café', 'Leche', 'Batido de proteína', 'Smoothie',
      'Zumo natural', 'Jugo de naranja',
    ],
    'Condimentos y Especias': [
      'Sal', 'Pimienta', 'Comino', 'Cilantro', 'Perejil',
      'Tomillo', 'Orégano', 'Romero', 'Ajo en polvo',
      'Cebolla en polvo', 'Paprika', 'Mostaza', 'Vinagre',
      'Salsa de soya', 'Caldo casero', 'Miel',
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedFoods = Set.from(widget.selectedItems);
    _filteredFoods = _getAllFoodsFlat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getAllFoodsFlat() {
    final foods = <String>[];
    allFoods.forEach((category, items) {
      foods.addAll(items);
    });
    return foods.toSet().toList()..sort();
  }

  List<String> _getSubcategories() {
    return ['Todos', ...allFoods.keys];
  }

  List<String> _getFoodsForCategory(String category) {
    if (category == 'Todos') {
      return _getAllFoodsFlat();
    }
    return allFoods[category] ?? [];
  }

  void _filterFoods(String query) {
    final foods = _getFoodsForCategory(_selectedSubcategory);
    if (query.isEmpty) {
      setState(() => _filteredFoods = foods);
    } else {
      setState(() {
        _filteredFoods = foods
            .where((food) => food.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _toggleFood(String food) {
    setState(() {
      if (_selectedFoods.contains(food)) {
        _selectedFoods.remove(food);
      } else {
        _selectedFoods.add(food);
      }
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedFoods.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getCategoryTitle()),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSelection,
            child: Text(
              'Guardar (${_selectedFoods.length})',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar alimentos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterFoods,
            ),
          ),
          // Filtro de subcategorías
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _getSubcategories().length,
              itemBuilder: (context, index) {
                final category = _getSubcategories()[index];
                final isSelected = _selectedSubcategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubcategory = category;
                        _searchController.clear();
                        _filteredFoods =
                            _getFoodsForCategory(category).toList();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // Lista de alimentos
          Expanded(
            child: _filteredFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron alimentos',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 0.6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = _filteredFoods[index];
                      final isSelected = _selectedFoods.contains(food);

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                                .withAlpha(102)
                            : null,
                        child: InkWell(
                          onTap: () => _toggleFood(food),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  )
                                else
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  food,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle() {
    switch (widget.category) {
      case 'favorites':
        return 'Alimentos Favoritos';
      case 'disliked':
        return 'Alimentos No Deseados';
      case 'allergens':
        return 'Alergias e Intolerancias';
      default:
        return 'Seleccionar Alimentos';
    }
  }
}
