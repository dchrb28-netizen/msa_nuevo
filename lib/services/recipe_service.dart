import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:myapp/models/recipe.dart';

class RecipeService {
  // Claves para la nueva API de Búsqueda de Google
  final String _apiKey =
      'AIzaSyDQzJtJ1GxYt4QeB9rkkb7zyHfiuJpTOsw'; // Tu clave de API
  final String _searchEngineId =
      '45f4ba8a9274d4856'; // Tu ID de motor de búsqueda
  final String _baseUrl = 'https://www.googleapis.com/customsearch/v1';

  Future<List<Recipe>> searchRecipes(String query) async {
    // Imprimir la consulta para depuración
    developer.log(
      'Buscando recetas con la consulta: "$query"',
      name: 'RecipeService',
    );

    // Construir la URL para la API de Google Custom Search
    final url = Uri.parse(
      '$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=$query&lr=lang_es',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Asegurarse de que hay 'items' en la respuesta
      if (data.containsKey('items')) {
        final List<dynamic> results = data['items'];
        return results.map((json) => Recipe.fromJson(json)).toList();
      } else {
        // Si no hay resultados, devolver una lista vacía
        return [];
      }
    } else {
      // Lanzar una excepción si la API falla
      throw Exception('Error al buscar recetas en Google');
    }
  }
}
