import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/data/meal_plan_templates.dart';

void main() {
  group('MealPlanTemplates - Descriptions', () {
    test('Base plans have descriptions', () {
      expect(MealPlanTemplates.getPlanDetailedDescription('Pérdida de Peso'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Ganancia Muscular'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Equilibrado'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Vegano'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Cetogénico'), isNotEmpty);
    });

    test('Variant plans have descriptions', () {
      // Variantes de Pérdida de Peso
      expect(MealPlanTemplates.getPlanDetailedDescription('Pérdida de Peso - Vegano'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Pérdida de Peso - Sin Azúcar'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDetailedDescription('Pérdida de Peso - Cetogénico'), isNotEmpty);
    });

    test('Variant descriptions contain base plan info', () {
      final veganoVariant = MealPlanTemplates.getPlanDetailedDescription('Pérdida de Peso - Vegano');
      
      // Verifica que contiene la descripción base
      expect(veganoVariant, contains('🎯 PLAN PÉRDIDA DE PESO'));
      expect(veganoVariant, contains('1500-1800 kcal/día'));
      
      // Verifica que contiene la información de la variante
      expect(veganoVariant, contains('VARIANTE: VEGANO'));
      expect(veganoVariant, contains('Legumbres'));
    });

    test('Variant short descriptions work', () {
      // Short description for variant should return base plan description
      final shortDesc = MealPlanTemplates.getPlanDescription('Pérdida de Peso - Vegano');
      final basePlanDesc = MealPlanTemplates.getPlanDescription('Pérdida de Peso');
      
      // Should return the base plan description
      expect(shortDesc, equals(basePlanDesc));
    });

    test('All base plans have short descriptions', () {
      expect(MealPlanTemplates.getPlanDescription('Pérdida de Peso'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDescription('Ganancia Muscular'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDescription('Equilibrado'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDescription('Vegano'), isNotEmpty);
      expect(MealPlanTemplates.getPlanDescription('Cetogénico'), isNotEmpty);
    });
  });
}
