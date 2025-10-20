import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 10) // Unique ID for the Recipe adapter
class Recipe extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String snippet;

  @HiveField(3)
  final String? imageUrl;

  Recipe({
    required this.title,
    required this.link,
    required this.snippet,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json.containsKey('pagemap') &&
        json['pagemap'].containsKey('cse_thumbnail') &&
        json['pagemap']['cse_thumbnail'] is List &&
        (json['pagemap']['cse_thumbnail'] as List).isNotEmpty) {
      imageUrl = json['pagemap']['cse_thumbnail'][0]['src'];
    } else if (json.containsKey('pagemap') &&
               json['pagemap'].containsKey('metatags') &&
               json['pagemap']['metatags'] is List &&
               (json['pagemap']['metatags'] as List).isNotEmpty &&
               json['pagemap']['metatags'][0].containsKey('og:image')) {
      imageUrl = json['pagemap']['metatags'][0]['og:image'];
    }

    return Recipe(
      title: json['title'] ?? 'Sin título',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? 'No hay descripción disponible.',
      imageUrl: imageUrl,
    );
  }
}
