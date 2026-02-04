import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/achievement.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;

  Box? _profileBox;
  late UserProfile _userProfile;

  final List<Achievement> _masterAchievements = [];
  
  Achievement? _lastUnlockedAchievement;
  Achievement? get lastUnlockedAchievement => _lastUnlockedAchievement;

  AchievementService._internal() {
    _initializeAchievements();
  }

  Future<void> init() async {
    _profileBox = Hive.box('profile_data');
    
    // Intentar cargar el perfil desde el nuevo formato (un solo objeto JSON)
    final userProfileJson = _profileBox!.get('userProfile');

    if (userProfileJson != null) {
      // Si existe, cárgalo usando el constructor fromJson
      _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(userProfileJson));
    } else {
      // Si no existe, es un usuario antiguo o uno nuevo. Intenta migrar los datos.
      await _migrateOldData();
    }
  }

  Future<void> _migrateOldData() async {
    // Lee los datos antiguos y fragmentados usando las claves anteriores.
    final experiencePoints = _profileBox!.get('experiencePoints', defaultValue: 0) as int;
    final level = _profileBox!.get('level', defaultValue: 1) as int;
    final unlockedAchievements = (_profileBox!.get('unlockedAchievements', defaultValue: <String, DateTime>{}) as Map).cast<String, DateTime>();
    final selectedTitle = _profileBox!.get('selectedTitle') as String?;
    final achievementProgress = (_profileBox!.get('achievementProgress', defaultValue: <String, int>{}) as Map).cast<String, int>();

    // Crea una instancia de UserProfile con los datos antiguos.
    _userProfile = UserProfile(
      experiencePoints: experiencePoints,
      level: level,
      unlockedAchievements: unlockedAchievements,
      selectedTitle: selectedTitle,
      achievementProgress: achievementProgress,
    );

    // Guarda el nuevo perfil unificado en la base de datos.
    await _commitChanges();

    // Elimina las claves antiguas para completar la migración.
    await _profileBox!.delete('experiencePoints');
    await _profileBox!.delete('level');
    await _profileBox!.delete('unlockedAchievements');
    await _profileBox!.delete('selectedTitle');
    await _profileBox!.delete('achievementProgress');

    if (kDebugMode) {
      print('✅ Perfil de usuario migrado al nuevo formato unificado.');
    }
  }
  
  // ======== PUBLIC GETTERS ========

  List<Achievement> getAchievements() {
    return _masterAchievements.map((masterAch) {
      final userProgress = _userProfile.achievementProgress[masterAch.id] ?? 0;
      final isUnlocked = _userProfile.unlockedAchievements.containsKey(masterAch.id);
      final unlockedDate = _userProfile.unlockedAchievements[masterAch.id];

      final achievement = Achievement.clone(masterAch);
      achievement.progress = userProgress;
      achievement.isUnlocked = isUnlocked;
      achievement.unlockedDate = unlockedDate;

      return achievement;
    }).toList();
  }

  Future<Map<String, List<Achievement>>> getGroupedAchievements() async {
    final achievements = getAchievements();
    final grouped = <String, List<Achievement>>{};
    for (var ach in achievements) {
        final categoryName = ach.category.displayName;
        (grouped[categoryName] ??= []).add(ach);
    }
    return grouped;
  }

  int getTotalXP() => _userProfile.experiencePoints;
  int calculateLevel() => _userProfile.level;
  int getXPForNextLevel(int level) => 100 * (level + 1);
  UserProfile get userProfile => _userProfile;

  // ======== PUBLIC ACTIONS ========

  void updateProgress(String achievementId, int progress, {bool cumulative = false}) {
    final achievement = _masterAchievements.firstWhere((a) => a.id == achievementId, orElse: () => throw Exception('Achievement with id $achievementId not found'));
    if (_userProfile.unlockedAchievements.containsKey(achievementId)) return;

    final currentProgress = _userProfile.achievementProgress[achievementId] ?? 0;
    
    int newProgress;
    if (cumulative) {
      newProgress = currentProgress + progress;
    } else {
      newProgress = progress;
    }

    if (!cumulative && newProgress <= currentProgress) return;

    _userProfile.achievementProgress[achievementId] = newProgress;

    bool unlocked = false;
    if (newProgress >= achievement.goal) {
      unlocked = _unlockAchievement(achievement);
    }

    if (unlocked) {
      _addExperience(50); // Grant XP for unlocking the achievement
    }

    _commitChanges();
  }

  Future<void> setSelectedTitle(String? title) async {
    _userProfile.selectedTitle = title;
    updateProgress('exp_frame_change', 1);
    await _commitChanges();
  }

  void grantExperience(int points) {
    _addExperience(points);
    _commitChanges();
  }

  void clearLastUnlockedAchievement() {
    _lastUnlockedAchievement = null;
  }

  // ======== PRIVATE HELPERS (STATE MODIFICATION) ========

  bool _unlockAchievement(Achievement achievement) {
    if (_userProfile.unlockedAchievements.containsKey(achievement.id)) return false;
      
    _userProfile.unlockedAchievements[achievement.id] = DateTime.now();
    _lastUnlockedAchievement = achievement;
    return true;
  }

  void _addExperience(int points) {
    _userProfile.experiencePoints += points;
    
    while (_userProfile.experiencePoints >= getXPForNextLevel(_userProfile.level)) {
      _userProfile.level += 1;
      _checkAndUnlockLevelAchievements(_userProfile.level);
    }
  }

  void _checkAndUnlockLevelAchievements(int newLevel) {
    final levelAchievements = {
      5: 'level_up_5',
      10: 'level_up_10',
      20: 'level_up_20',
      35: 'level_up_35',
      50: 'level_up_50',
    };

    levelAchievements.forEach((level, achievementId) {
      if (newLevel >= level) {
        final achievement = _masterAchievements.firstWhere((a) => a.id == achievementId);
        _unlockAchievement(achievement);
      }
    });
  }

  // ======== PRIVATE HELPERS (PERSISTENCE & NOTIFICATION) ========
  
  Future<void> _commitChanges() async {
    // Guarda el objeto UserProfile completo como un único JSON.
    await _profileBox!.put('userProfile', _userProfile.toJson());
    notifyListeners();
  }

  // ======== INITIALIZATION ========

  void _initializeAchievements() {
    _masterAchievements.clear();
    _masterAchievements.addAll([
       Achievement(id: 'welcome_frame', name: 'Bienvenido', description: 'Marco de bienvenida por defecto.', icon: PhosphorIcons.star(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones, isUnlocked: true),

      // --- First Steps ---
      Achievement(id: 'first_water_log', name: 'Primer Trago', description: 'Registra tu ingesta de agua por primera vez.', icon: PhosphorIcons.dropSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_workout', name: 'Primer Sudor', description: 'Completa tu primer entrenamiento.', icon: PhosphorIcons.barbell(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_meal', name: 'Bocado Inicial', description: 'Registra tu primera comida.', icon: PhosphorIcons.appleLogo(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_fast', name: 'Reloj Suizo', description: 'Completa tu primer ayuno intermitente.', icon: PhosphorIcons.timer(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_meditation', name: 'Mente Serena', description: 'Completa tu primera sesión de meditación.', icon: PhosphorIcons.leaf(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_weight_log', name: 'En la Balanza', description: 'Registra tu peso por primera vez.', icon: PhosphorIcons.scales(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_daily_task', name: 'Organizador', description: 'Completa tu primera tarea diaria.', icon: PhosphorIcons.listChecks(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'create_routine', name: 'Arquitecto Fitness', description: 'Crea tu primera rutina personalizada.', icon: PhosphorIcons.pencilRuler(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'create_recipe', name: 'Chef Creativo', description: 'Crea tu primera receta personalizada.', icon: PhosphorIcons.knife(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),

      // --- Streaks ---
      Achievement(id: 'streak_water_7', name: 'Río de Vida', description: 'Mantén una racha de 7 días de hidratación.', icon: PhosphorIcons.waveSine(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_water_30', name: 'Océano Interior', description: 'Alcanza una racha de 30 días de hidratación.', icon: PhosphorIcons.waves(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_fasting_7', name: 'Maestro Zen', description: 'Mantén una racha de 7 días de ayuno.', icon: PhosphorIcons.personSimpleRun(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_fasting_30', name: 'Gurú del Ayuno', description: 'Alcanza una racha de 30 días de ayuno.', icon: PhosphorIcons.moon(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_training_7', name: 'Fuego Constante', description: 'Completa entrenamientos durante 7 días seguidos.', icon: PhosphorIcons.fireSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_training_30', name: 'Infierno de Hierro', description: 'Completa entrenamientos durante 30 días seguidos.', icon: PhosphorIcons.flame(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_macros_7', name: 'Maestro de Macros', description: 'Cumple tus objetivos de macronutrientes durante 7 días seguidos.', icon: PhosphorIcons.chartPieSlice(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_planning_7', name: 'Planificador Semanal', description: 'Registra al menos una comida durante 7 días seguidos.', icon: PhosphorIcons.calendarDots(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_tasks_7', name: 'Hábito Constante', description: 'Completa tareas diarias durante 7 días seguidos.', icon: PhosphorIcons.listChecks(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_tasks_30', name: 'Disciplina Total', description: 'Completa tareas diarias durante 30 días seguidos.', icon: PhosphorIcons.medal(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_all_active', name: 'Imparable', description: 'Ten las 5 rachas principales activas al mismo tiempo.', icon: PhosphorIcons.star(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks),
      Achievement(id: 'streak_any_30', name: 'Llama Eterna', description: 'Alcanza una racha de 30 días en CUALQUIER categoría.', icon: PhosphorIcons.crownSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks),

      // --- Cumulative ---
      Achievement(id: 'cum_water_10', name: 'Pequeño Arroyo', description: 'Consume un total de 10 litros de agua.', icon: PhosphorIcons.drop(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 10000, unit: 'ml'),
      Achievement(id: 'cum_water_1000', name: 'Océano Vital', description: 'Consume un total de 1,000 litros de agua.', icon: PhosphorIcons.mountains(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 1000000, unit: 'ml'),
      Achievement(id: 'cum_train_25', name: 'Engranaje en Movimiento', description: 'Completa 25 rutinas en total.', icon: PhosphorIcons.gear(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 25, unit: 'rutinas'),
      Achievement(id: 'cum_train_100', name: 'Fábrica de Músculos', description: 'Completa 100 rutinas en total.', icon: PhosphorIcons.factory(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 100, unit: 'rutinas'),      Achievement(id: 'cum_tasks_50', name: 'Maestro de Hábitos', description: 'Completa 50 tareas diarias en total.', icon: PhosphorIcons.trophy(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50, unit: 'tareas'),
      Achievement(id: 'cum_tasks_200', name: 'Leyenda de Productividad', description: 'Completa 200 tareas diarias en total.', icon: PhosphorIcons.crown(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 200, unit: 'tareas'),      Achievement(id: 'cum_lift_50k', name: 'Fuerza Volcánica', description: 'Levanta un total de 50,000 kg.', icon: PhosphorIcons.mountains(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50000, unit: 'kg'),
      Achievement(id: 'cum_meals_500', name: 'Enciclopedia Gastronómica', description: 'Registra 500 comidas en total.', icon: PhosphorIcons.bookOpenText(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 500, unit: 'comidas'),
      Achievement(id: 'cum_recipes_25', name: 'Cocinero Experimentado', description: 'Crea 25 recetas personalizadas.', icon: PhosphorIcons.chefHat(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 25, unit: 'recetas'),
      Achievement(id: 'cum_recipes_100', name: 'Maestro Culinario', description: 'Crea 100 recetas personalizadas.', icon: PhosphorIcons.cookingPot(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 100, unit: 'recetas'),
      Achievement(id: 'cum_foods_50', name: 'Paladar Diverso', description: 'Registra 50 alimentos diferentes.', icon: PhosphorIcons.rainbow(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50, unit: 'alimentos'),
      Achievement(id: 'cum_fast_720h', name: 'Disciplina Mensual', description: 'Acumula 720 horas (30 días) de ayuno.', icon: PhosphorIcons.medal(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 720, unit: 'horas'),

      // --- Milestones ---
      Achievement(id: 'level_up_5', name: 'Aprendiz', description: 'Alcanza el Nivel 5.', icon: PhosphorIcons.lightbulb(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'level_up_10', name: 'Atleta', description: 'Alcanza el Nivel 10.', icon: PhosphorIcons.personSimpleRun(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'level_up_20', name: 'Competidor', description: 'Alcanza el Nivel 20.', icon: PhosphorIcons.trophy(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'level_up_35', name: 'Titán', description: 'Alcanza el Nivel 35.', icon: PhosphorIcons.mountains(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'level_up_50', name: 'Leyenda', description: 'Alcanza el Nivel 50.', icon: PhosphorIcons.crown(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'goal_weight_target', name: 'Meta Cumplida', description: '¡Has alcanzado tu peso objetivo!', icon: PhosphorIcons.flagCheckered(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),

      // --- Exploration ---
      Achievement(id: 'exp_profile_complete', name: 'Identidad Definida', description: 'Completa todos los campos de tu perfil.', icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_theme_change', name: 'Sastre Digital', description: 'Personaliza el tema de la aplicación.', icon: PhosphorIcons.paintBrush(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_frame_change', name: 'Artista del Perfil', description: 'Cambia tu marco de perfil por primera vez.', icon: PhosphorIcons.frameCorners(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_about_page', name: 'Curioso', description: 'Visita la pantalla "Acerca de".', icon: PhosphorIcons.question(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_add_favorite', name: 'Gourmet', description: 'Guarda 10 recetas en tus favoritos.', icon: PhosphorIcons.star(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration, goal: 10, unit: 'recetas'),
      Achievement(id: 'exp_filter_history', name: 'Analista de Datos', description: 'Usa los filtros del historial de entrenamiento.', icon: PhosphorIcons.funnel(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
    ]);
  }
}
