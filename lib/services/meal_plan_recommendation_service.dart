import 'package:myapp/data/meal_plan_templates.dart';
import 'package:myapp/models/user.dart';

/// Servicio que proporciona recomendaciones de planes de comidas según el usuario
class MealPlanRecommendationService {
  /// Obtener el plan principal según el objetivo del usuario
  static String _getMainPlanByObjective(User? user) {
    if (user == null) {
      return 'Equilibrado';
    }

    final dietPlan = user.dietPlan?.toLowerCase() ?? '';
    if (dietPlan.contains('perder') || dietPlan.contains('pérdida')) {
      return 'Pérdida de Peso';
    } else if (dietPlan.contains('ganar') || dietPlan.contains('ganancia')) {
      return 'Ganancia Muscular';
    } else if (dietPlan.contains('mantener')) {
      return 'Equilibrado';
    }
    return 'Equilibrado';
  }

  /// Obtener variantes de plan según preferencias del usuario
  static List<String> _getPlanVariants(User? user, String basePlan) {
    final variants = <String>['Vegano', 'Sin Azúcar', 'Cetogénico'];
    
    if (user == null) {
      return variants;
    }

    // Si el usuario tiene preferencias dietéticas, poner esas primero
    final preferences = (user.dietaryPreferences ?? '').toLowerCase();
    final preferredVariants = <String>[];
    
    if (preferences.contains('vegano')) {
      preferredVariants.add('Vegano');
      variants.remove('Vegano');
    }
    if (preferences.contains('vegetariano')) {
      // Nota: vegetariano podría agregarse como variante en futuro
    }
    if (preferences.contains('sin azucar') || preferences.contains('sin azúcar')) {
      preferredVariants.add('Sin Azúcar');
      variants.remove('Sin Azúcar');
    }
    if (preferences.contains('keto') || preferences.contains('cetogénico')) {
      preferredVariants.add('Cetogénico');
      variants.remove('Cetogénico');
    }

    // Combinar preferencias con resto
    preferredVariants.addAll(variants);
    return preferredVariants;
  }

  /// Obtener recomendaciones de planes de comida según los objetivos del usuario
  /// Retorna múltiples variantes del mismo objetivo
  static List<String> getRecommendedPlans(User? user) {
    if (user == null) {
      return ['Equilibrado']; // Plan por defecto
    }

    final basePlan = _getMainPlanByObjective(user);
    final variants = _getPlanVariants(user, basePlan);
    
    final recommendedPlans = <String>[basePlan];
    
    // Agregar variantes con el plan base
    for (final variant in variants) {
      recommendedPlans.add('$basePlan - $variant');
    }

    return recommendedPlans;
  }

  /// Obtener todos los planes disponibles
  /// Retorna solo los planes del objetivo actual con sus variantes
  static List<String> getAllAvailablePlans(User? user) {
    // Obtener los planes recomendados (que incluyen variantes del mismo objetivo)
    return getRecommendedPlans(user);
  }

  /// Obtener descripción de un plan
  static String getPlanDescription(String planName) {
    return MealPlanTemplates.getPlanDescription(planName);
  }

  /// Obtener datos del plan semanal completo
  static Map<String, Map<String, String>>? getPlanData(String planName) {
    // Si es una variante (ej: "Equilibrado - Vegano"), obtener el plan base
    final parts = planName.split(RegExp(r'\s-\s'));
    final base = parts.first;
    return MealPlanTemplates.allPlans[base];
  }
}
