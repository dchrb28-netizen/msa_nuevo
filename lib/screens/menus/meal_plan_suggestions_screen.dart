import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/meal_nutrition_service.dart';
import 'package:myapp/services/meal_plan_recommendation_service.dart';
import 'package:myapp/services/personalized_meal_plan_service.dart';
import 'package:myapp/screens/menus/food_preferences_screen.dart';
import 'package:myapp/data/meal_plan_templates.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MealPlanSuggestionsScreen extends StatefulWidget {
  const MealPlanSuggestionsScreen({super.key});

  @override
  State<MealPlanSuggestionsScreen> createState() => _MealPlanSuggestionsScreenState();
}

class _MealPlanSuggestionsScreenState extends State<MealPlanSuggestionsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);

    // Obtener el plan seleccionado en metas calóricas
    final recommendedPlans =
        MealPlanRecommendationService.getRecommendedPlans(userProvider.user);

    // Si no hay plan configurado
    if (recommendedPlans.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Planes de Comidas Sugeridos'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Configura tu plan nutricional',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ve a Metas Calóricas para elegir tu plan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Comidas Sugeridos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodPreferencesScreen(),
                ),
              );
            },
            tooltip: 'Preferencias alimentarias',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de planes recomendados
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planes disponibles para tu objetivo',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige el que mejor se adapte a tus preferencias',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Plan base destacado como recomendado
              if (recommendedPlans.isNotEmpty)
                _buildPlanCard(
                  context,
                  recommendedPlans[0],
                  isRecommended: true,
                  mealPlanProvider: mealPlanProvider,
                ),
              // Variantes del plan
              if (recommendedPlans.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                  'Variantes disponibles',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                ...recommendedPlans.skip(1).map((planName) {
                  return _buildPlanCard(
                    context,
                    planName,
                    isRecommended: false,
                    mealPlanProvider: mealPlanProvider,
                  );
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String planName, {
    required bool isRecommended,
    required MealPlanProvider mealPlanProvider,
  }) {
    final theme = Theme.of(context);
    final description = MealPlanRecommendationService.getPlanDescription(planName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRecommended ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isRecommended
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withAlpha(26),
                    theme.colorScheme.secondary.withAlpha(13),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      planName,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recomendado',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(204),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.preview),
                    label: const Text('Ver'),
                    onPressed: () {
                      _showPlanPreview(context, planName);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Aplicar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      _applyPlanToWeek(context, planName, mealPlanProvider);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanPreview(BuildContext context, String planName) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Obtener plan personalizado
    final customizedPlan = PersonalizedMealPlanService.customizePlan(
      planName,
      userProvider.user,
    );
    
    final theme = Theme.of(context);

    // Mostrar descripción detallada primero
    _showPlanDetailsModal(context, planName, customizedPlan, theme, userProvider);
  }

  void _showPlanDetailsModal(
    BuildContext context,
    String planName,
    Map<String, Map<String, String>>? customizedPlan,
    ThemeData theme,
    UserProvider userProvider,
  ) {
    final detailedDescription = MealPlanTemplates.getPlanDetailedDescription(planName);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        planName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(102),
                        ),
                      ),
                      child: Text(
                        detailedDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Comidas'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showMealPreview(context, planName, customizedPlan, theme, userProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMealPreview(
    BuildContext context,
    String planName,
    Map<String, Map<String, String>>? customizedPlan,
    ThemeData theme,
    UserProvider userProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _PlanPreviewContent(
          planName: planName,
          planData: customizedPlan,
          theme: theme,
          hasRestrictions: (userProvider.user?.dislikedFoods.isNotEmpty ?? false) ||
              (userProvider.user?.allergens.isNotEmpty ?? false),
        );
      },
    );
  }

  void _applyPlanToWeek(
    BuildContext context,
    String planName,
    MealPlanProvider mealPlanProvider,
  ) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Obtener plan personalizado según preferencias del usuario
    final customizedPlan = PersonalizedMealPlanService.customizePlan(
      planName,
      userProvider.user,
    );

    if (customizedPlan.isNotEmpty) {
      // Mapear nombres de días en español a números de semana
      final dayMap = {
        'Lunes': 1,
        'Martes': 2,
        'Miércoles': 3,
        'Jueves': 4,
        'Viernes': 5,
        'Sábado': 6,
        'Domingo': 7,
      };

      // Aplicar el plan a cada día de la semana actual (lunes..domingo)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // lunes de la semana actual

      customizedPlan.forEach((dayName, meals) {
        final weekday = dayMap[dayName] ?? 1;
        final targetDate = startOfWeek.add(Duration(days: weekday - 1));

        meals.forEach((mealType, mealContent) {
          mealPlanProvider.updateMealText(
            targetDate,
            mealType,
            mealContent,
          );
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan "$planName" aplicado y personalizado'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

/// Widget para mostrar la previsualización del plan con micronutrientes
class _PlanPreviewContent extends StatefulWidget {
  final String planName;
  final Map<String, Map<String, String>>? planData;
  final ThemeData theme;
  final bool hasRestrictions;

  const _PlanPreviewContent({
    required this.planName,
    required this.planData,
    required this.theme,
    this.hasRestrictions = false,
  });

  @override
  State<_PlanPreviewContent> createState() => _PlanPreviewContentState();
}

class _PlanPreviewContentState extends State<_PlanPreviewContent> {
  late Map<String, Map<String, MealNutritionInfo?>> _nutritionData;
  bool _isLoading = true;
  String? _selectedDay;

  @override
  void initState() {
    super.initState();
    _nutritionData = {};
    _selectedDay = widget.planData?.keys.first ?? 'Lunes';
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    if (widget.planData == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      for (final dayEntry in widget.planData!.entries) {
        final dayName = dayEntry.key;
        final meals = dayEntry.value;
        final dayNutrition = <String, MealNutritionInfo?>{};

        for (final mealEntry in meals.entries) {
          final mealContent = mealEntry.value;
          final nutrition = await MealNutritionService.getNutritionForMeal(mealContent);
          dayNutrition[mealEntry.key] = nutrition;
        }

        setState(() {
          _nutritionData[dayName] = dayNutrition;
        });
      }
    } catch (e) {
      // Silenciosamente ignorar errores de API
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.planName,
                        style: widget.theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.hasRestrictions)
                    Tooltip(
                      message: 'Plan personalizado según tus restricciones',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Personalizado',
                              style: widget.theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.planData != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.planData!.keys.map((day) {
                      final isSelected = _selectedDay == day;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedDay = day);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedDay != null && widget.planData != null
                        ? _buildDayMeals(widget.planData![_selectedDay]!, _selectedDay!)
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayMeals(Map<String, String> dayMeals, String dayName) {
    final dayNutrition = _nutritionData[dayName] ?? {};

    return ListView(
      children: dayMeals.entries.map((mealEntry) {
        final mealType = mealEntry.key;
        final mealContent = mealEntry.value;
        final nutrition = dayNutrition[mealType];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mealContent,
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (nutrition != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildNutritionInfo(nutrition),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Información nutricional no disponible',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNutritionInfo(MealNutritionInfo nutrition) {
    final calories = nutrition.calories.toStringAsFixed(0);
    final protein = nutrition.protein.toStringAsFixed(1);
    final carbs = nutrition.carbs.toStringAsFixed(1);
    final fat = nutrition.fat.toStringAsFixed(1);
    final fiber = nutrition.fiber.toStringAsFixed(1);
    final sodium = nutrition.sodium.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calorías
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '⚡ Calorías',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            Text('$calories kcal', style: GoogleFonts.lato()),
          ],
        ),
        const SizedBox(height: 8),
        // Macronutrientes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacroCard('🥩 Proteína', '$protein g'),
            _buildMacroCard('🍞 Carbos', '$carbs g'),
            _buildMacroCard('🧈 Grasa', '$fat g'),
          ],
        ),
        const SizedBox(height: 8),
        // Micronutrientes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMicroCard('🌾 Fibra', '$fiber g'),
            _buildMicroCard('🧂 Sodio', '$sodium mg'),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.primaryContainer.withAlpha(102),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: GoogleFonts.lato(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.secondaryContainer.withAlpha(102),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: GoogleFonts.lato(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
