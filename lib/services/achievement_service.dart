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

  late final Box _profileBox;
  late UserProfile _userProfile;

  final List<Achievement> _masterAchievements = [];
  
  Achievement? _lastUnlockedAchievement;
  Achievement? get lastUnlockedAchievement => _lastUnlockedAchievement;

  AchievementService._internal() {
    _initializeAchievements();
  }

  Future<void> init() async {
    _profileBox = Hive.box('profile_data');

    final experiencePoints = _profileBox.get('experiencePoints', defaultValue: 0) as int;
    final level = _profileBox.get('level', defaultValue: 1) as int;
    final unlockedAchievements = (_profileBox.get('unlockedAchievements', defaultValue: <String, DateTime>{}) as Map).cast<String, DateTime>();
    final selectedTitle = _profileBox.get('selectedTitle') as String?;
    final achievementProgress = (_profileBox.get('achievementProgress', defaultValue: <String, int>{}) as Map).cast<String, int>();

    _userProfile = UserProfile(
      experiencePoints: experiencePoints,
      level: level,
      unlockedAchievements: unlockedAchievements,
      selectedTitle: selectedTitle,
      achievementProgress: achievementProgress,
    );
  }

  List<Achievement> getAchievements() {
    return _masterAchievements.map((masterAch) {
      final userProgress = _userProfile.achievementProgress[masterAch.id] ?? 0;
      final isUnlocked = _userProfile.unlockedAchievements.containsKey(masterAch.id);
      final unlockedDate = _userProfile.unlockedAchievements[masterAch.id];

      final achievement = Achievement.clone(masterAch);
      achievement.progress = userProgress; // FIX: userProgress -> progress
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

  int getTotalXP() {
    return _userProfile.experiencePoints;
  }

  int calculateLevel() {
    return _userProfile.level;
  }

  int getXPForNextLevel(int level) {
    // Simple XP formula, can be adjusted
    return 100 * (level + 1);
  }

  UserProfile get userProfile => _userProfile;

  Future<void> _saveProfile() async {
    await _profileBox.put('experiencePoints', _userProfile.experiencePoints);
    await _profileBox.put('level', _userProfile.level);
    await _profileBox.put('unlockedAchievements', _userProfile.unlockedAchievements);
    await _profileBox.put('selectedTitle', _userProfile.selectedTitle);
    await _profileBox.put('achievementProgress', _userProfile.achievementProgress);
    notifyListeners();
  }

  void addExperience(int points) {
    _userProfile.experiencePoints += points;
    
    bool leveledUp = false;
    while (_userProfile.experiencePoints >= getXPForNextLevel(_userProfile.level)) {
      _userProfile.level += 1;
      leveledUp = true;
    }

    if (leveledUp) {
       // Logic for unlocking titles by level if needed
    }

    _saveProfile();
  }

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

    if (newProgress >= achievement.goal) {
      _unlockAchievement(achievement);
    }

    _saveProfile();
  }

  void _unlockAchievement(Achievement achievement) {
    if (!_userProfile.unlockedAchievements.containsKey(achievement.id)) {
      _userProfile.unlockedAchievements[achievement.id] = DateTime.now();
      addExperience(50);

      _lastUnlockedAchievement = achievement;
      notifyListeners(); 
    }
  }

  void clearLastUnlockedAchievement() {
    _lastUnlockedAchievement = null;
  }

  void _initializeAchievements() {
    _masterAchievements.clear();
    _masterAchievements.addAll([
      Achievement(id: 'first_water_log', name: 'Primer Trago', description: 'Registra tu ingesta de agua por primera vez.', icon: PhosphorIcons.dropSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_workout', name: 'Primer Sudor', description: 'Completa tu primer entrenamiento.', icon: PhosphorIcons.barbell(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_meal', name: 'Bocado Inicial', description: 'Registra tu primera comida.', icon: PhosphorIcons.appleLogo(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_fast', name: 'Reloj Suizo', description: 'Completa tu primer ayuno intermitente.', icon: PhosphorIcons.timer(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'first_weight_log', name: 'En la Balanza', description: 'Registra tu peso por primera vez.', icon: PhosphorIcons.scales(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'create_routine', name: 'Arquitecto Fitness', description: 'Crea tu primera rutina personalizada.', icon: PhosphorIcons.pencilRuler(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),
      Achievement(id: 'create_recipe', name: 'Chef Creativo', description: 'Crea tu primera receta personalizada.', icon: PhosphorIcons.knife(PhosphorIconsStyle.duotone), category: AchievementCategory.firstSteps),

      Achievement(id: 'streak_water_7', name: 'Río de Vida', description: 'Mantén una racha de 7 días de hidratación.', icon: PhosphorIcons.waveSine(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_water_30', name: 'Océano Interior', description: 'Alcanza una racha de 30 días de hidratación.', icon: PhosphorIcons.waves(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_fasting_7', name: 'Maestro Zen', description: 'Mantén una racha de 7 días de ayuno.', icon: PhosphorIcons.personSimpleRun(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_fasting_30', name: 'Gurú del Ayuno', description: 'Alcanza una racha de 30 días de ayuno.', icon: PhosphorIcons.moon(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_training_7', name: 'Fuego Constante', description: 'Completa entrenamientos durante 7 días seguidos.', icon: PhosphorIcons.fireSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_training_30', name: 'Infierno de Hierro', description: 'Completa entrenamientos durante 30 días seguidos.', icon: PhosphorIcons.flame(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 30, unit: 'días'),
      Achievement(id: 'streak_macros_7', name: 'Maestro de Macros', description: 'Cumple tus objetivos de macronutrientes durante 7 días seguidos.', icon: PhosphorIcons.chartPieSlice(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_planning_7', name: 'Planificador Semanal', description: 'Registra al menos una comida durante 7 días seguidos.', icon: PhosphorIcons.calendarDots(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks, goal: 7, unit: 'días'),
      Achievement(id: 'streak_all_active', name: 'Imparable', description: 'Ten las 5 rachas principales activas al mismo tiempo.', icon: PhosphorIcons.star(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks),
      Achievement(id: 'streak_any_30', name: 'Llama Eterna', description: 'Alcanza una racha de 30 días en CUALQUIER categoría.', icon: PhosphorIcons.crownSimple(PhosphorIconsStyle.duotone), category: AchievementCategory.streaks),

      Achievement(id: 'cum_water_10', name: 'Pequeño Arroyo', description: 'Consume un total de 10 litros de agua.', icon: PhosphorIcons.drop(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 10000, unit: 'ml'),
      Achievement(id: 'cum_water_50', name: 'Río Fluido', description: 'Consume un total de 50 litros de agua.', icon: PhosphorIcons.drop(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50000, unit: 'ml'),
      Achievement(id: 'cum_water_250', name: 'Mar Profundo', description: 'Consume un total de 250 litros de agua.', icon: PhosphorIcons.waves(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 250000, unit: 'ml'),
      Achievement(id: 'cum_water_1000', name: 'Océano Vital', description: 'Consume un total de 1,000 litros de agua.', icon: PhosphorIcons.mountains(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 1000000, unit: 'ml'),
      Achievement(id: 'cum_train_25', name: 'Engranaje en Movimiento', description: 'Completa 25 rutinas en total.', icon: PhosphorIcons.gear(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 25, unit: 'rutinas'),
      Achievement(id: 'cum_train_100', name: 'Fábrica de Músculos', description: 'Completa 100 rutinas en total.', icon: PhosphorIcons.factory(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 100, unit: 'rutinas'),
      Achievement(id: 'cum_lift_1k', name: 'Levantador Aspirante', description: 'Levanta un total de 1,000 kg.', icon: PhosphorIcons.lineSegment(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 1000, unit: 'kg'),
      Achievement(id: 'cum_lift_10k', name: 'Potencia Pura', description: 'Levanta un total de 10,000 kg.', icon: PhosphorIcons.rocket(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 10000, unit: 'kg'),
      Achievement(id: 'cum_lift_50k', name: 'Fuerza Volcánica', description: 'Levanta un total de 50,000 kg.', icon: PhosphorIcons.mountains(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50000, unit: 'kg'),
      Achievement(id: 'cum_meals_100', name: 'Diarista Culinario', description: 'Registra 100 comidas en total.', icon: PhosphorIcons.notebook(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 100, unit: 'comidas'),
      Achievement(id: 'cum_meals_500', name: 'Enciclopedia Gastronómica', description: 'Registra 500 comidas en total.', icon: PhosphorIcons.bookOpenText(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 500, unit: 'comidas'),
      Achievement(id: 'cum_foods_50', name: 'Paladar Diverso', description: 'Registra 50 alimentos diferentes.', icon: PhosphorIcons.rainbow(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50, unit: 'alimentos'),
      Achievement(id: 'cum_fast_24h', name: 'Control del Tiempo', description: 'Acumula 24 horas de ayuno.', icon: PhosphorIcons.hourglass(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 24, unit: 'horas'),
      Achievement(id: 'cum_fast_168h', name: 'Dominio Semanal', description: 'Acumula 168 horas (7 días) de ayuno.', icon: PhosphorIcons.calendar(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 168, unit: 'horas'),
      Achievement(id: 'cum_fast_720h', name: 'Disciplina Mensual', description: 'Acumula 720 horas (30 días) de ayuno.', icon: PhosphorIcons.medal(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 720, unit: 'horas'),
       Achievement(id: 'novice', name: 'Novato del Hierro', description: 'Completa 10 entrenamientos.', icon: PhosphorIcons.student(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 10, unit: 'entrenamientos'),
       Achievement(id: 'veteran', name: 'Veterano del Gimnasio', description: 'Completa 50 entrenamientos.', icon: PhosphorIcons.trophy(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50, unit: 'entrenamientos'),
       Achievement(id: 'king', name: 'Rey/Reina del Gimnasio', description: 'Completa 150 entrenamientos.', icon: PhosphorIcons.crown(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 150, unit: 'entrenamientos'),
       Achievement(id: 'scholar', name: 'Erudito del Ejercicio', description: 'Completa 50 ejercicios diferentes.', icon: PhosphorIcons.books(PhosphorIconsStyle.duotone), category: AchievementCategory.cumulative, goal: 50, unit: 'ejercicios'),

      Achievement(id: 'goal_water_daily', name: 'Gota a Gota', description: 'Alcanza tu primer objetivo diario de agua.', icon: PhosphorIcons.dropHalf(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'goal_water_1L', name: 'Hidratación Esencial', description: 'Bebe tu primer litro de agua en un día.', icon: PhosphorIcons.plugs(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'goal_calories_daily', name: 'Equilibrio Energético', description: 'Completa tu objetivo diario de calorías.', icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'goal_trifecta', name: 'Trifecta Diaria', description: 'Completa los 3 objetivos diarios (agua, calorías, entreno).', icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),
      Achievement(id: 'goal_weight_1kg', name: 'Primer Kilo Menos', description: 'Pierde tu primer kilogramo de peso.', icon: PhosphorIcons.trendDown(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones, goal: 1000, unit: 'g'),
      Achievement(id: 'goal_weight_5kg', name: '5 Kilos Abajo', description: 'Pierde un total de 5 kilogramos.', icon: PhosphorIcons.numberCircleFive(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones, goal: 5000, unit: 'g'),
      Achievement(id: 'goal_weight_50pct', name: 'A Mitad de Camino', description: 'Pierde el 50% del peso para tu objetivo.', icon: PhosphorIcons.flag(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones, goal: 50, unit: '%'),
      Achievement(id: 'goal_weight_target', name: 'Meta Cumplida', description: '¡Has alcanzado tu peso objetivo!', icon: PhosphorIcons.flagCheckered(PhosphorIconsStyle.duotone), category: AchievementCategory.milestones),

      Achievement(id: 'exp_profile_complete', name: 'Identidad Definida', description: 'Completa todos los campos de tu perfil.', icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_theme_change', name: 'Sastre Digital', description: 'Personaliza el tema de la aplicación.', icon: PhosphorIcons.paintBrush(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_about_page', name: 'Curioso', description: 'Visita la pantalla "Acerca de".', icon: PhosphorIcons.question(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
      Achievement(id: 'exp_add_favorite', name: 'Gourmet', description: 'Guarda 10 recetas en tus favoritos.', icon: PhosphorIcons.star(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration, goal: 10, unit: 'recetas'),
      Achievement(id: 'exp_filter_history', name: 'Analista de Datos', description: 'Usa los filtros del historial de entrenamiento.', icon: PhosphorIcons.funnel(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
       Achievement(id: 'exp_phoenix', name: 'Ave Fénix', description: 'Recupera una racha perdida dentro de las 48 horas.', icon: PhosphorIcons.bird(PhosphorIconsStyle.duotone), category: AchievementCategory.exploration),
    ]);
  }
}
