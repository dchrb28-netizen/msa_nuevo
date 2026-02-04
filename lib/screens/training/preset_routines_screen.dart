import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:myapp/data/routine_templates.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/services/routine_recommendation_service.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:myapp/widgets/sub_tab_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PresetRoutinesScreen extends StatefulWidget {
  const PresetRoutinesScreen({super.key});

  @override
  State<PresetRoutinesScreen> createState() => _PresetRoutinesScreenState();
}

class _PresetRoutinesScreenState extends State<PresetRoutinesScreen> with SingleTickerProviderStateMixin {
  String _selectedLevel = 'Todos';
  late TabController _tabController;
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userBox = await Hive.openBox<User>('user_box');
    if (userBox.isNotEmpty) {
      setState(() {
        _currentUser = userBox.values.firstWhere(
          (user) => !user.isGuest,
          orElse: () => userBox.values.first,
        );
      });
    }
  }

  List<RoutineTemplate> _getFilteredTemplates() {
    if (_selectedLevel == 'Todos') {
      return RoutineTemplates.all;
    }
    return RoutineTemplates.getByLevel(_selectedLevel);
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'avanzado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return PhosphorIcons.userCircle(PhosphorIconsStyle.fill);
      case 'intermedio':
        return PhosphorIcons.userCirclePlus(PhosphorIconsStyle.fill);
      case 'avanzado':
        return PhosphorIcons.fire(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.lightning(PhosphorIconsStyle.fill);
    }
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pecho':
        return Colors.red;
      case 'espalda':
        return Colors.blue;
      case 'piernas':
        return Colors.green;
      case 'hombros':
        return Colors.orange;
      case 'brazos':
        return Colors.purple;
      case 'abdomen':
      case 'core':
        return Colors.amber;
      case 'cardio':
        return Colors.pink;
      case 'glúteos':
        return Colors.teal;
      case 'pantorrillas':
        return Colors.brown;
      case 'movilidad':
      case 'flexibilidad':
        return Colors.cyan;
      case 'cuerpo completo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pecho':
        return PhosphorIcons.heartbeat(PhosphorIconsStyle.fill);
      case 'espalda':
        return PhosphorIcons.path(PhosphorIconsStyle.fill);
      case 'piernas':
        return PhosphorIcons.footprints(PhosphorIconsStyle.fill);
      case 'hombros':
        return PhosphorIcons.arrowsOutCardinal(PhosphorIconsStyle.fill);
      case 'brazos':
        return PhosphorIcons.barbell(PhosphorIconsStyle.fill);
      case 'abdomen':
      case 'core':
        return PhosphorIcons.dot(PhosphorIconsStyle.fill);
      case 'cardio':
        return PhosphorIcons.lightning(PhosphorIconsStyle.fill);
      case 'glúteos':
        return PhosphorIcons.circle(PhosphorIconsStyle.fill);
      case 'pantorrillas':
        return PhosphorIcons.arrowDown(PhosphorIconsStyle.fill);
      case 'movilidad':
      case 'flexibilidad':
        return PhosphorIcons.treeEvergreen(PhosphorIconsStyle.fill);
      case 'cuerpo completo':
        return PhosphorIcons.user(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.question(PhosphorIconsStyle.fill);
    }
  }

  Future<void> _addRoutineFromTemplate(BuildContext context, RoutineTemplate template) async {
    if (_isLoading) return;
    // Capturar referencias a ScaffoldMessenger y Navigator antes de cualquier await
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(this.context);
    final navigator = Navigator.of(this.context);

    // Verificar que los ejercicios estén cargados
    final exerciseBox = Hive.box<Exercise>('exercises');
    if (exerciseBox.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('⏳ Los ejercicios aún se están cargando. Intenta de nuevo en un momento.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Mostrar diálogo de selección de días ANTES de crear la rutina
    final selectedDays = await _showDaySelectionDialog(context, template.name);
    
    // Si el usuario canceló, no hacer nada
    if (selectedDays == null || !mounted) return;
    
    debugPrint('[PresetRoutines] _addRoutineFromTemplate: starting for ${template.name}');

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<RoutineProvider>(context, listen: false);
      final exerciseBox = Hive.box<Exercise>('exercises');
      // Construir la lista de RoutineExercise a partir del template
      final List<RoutineExercise> routineExercises = [];
      for (final exerciseTemplate in template.exercises) {
        final exerciseData = exerciseBox.get(exerciseTemplate.exerciseId);
        if (exerciseData == null) {
          debugPrint('⚠️ Ejercicio no encontrado: ${exerciseTemplate.exerciseId}');
          continue;
        }
        final routineExercise = RoutineExercise(
          exerciseId: exerciseTemplate.exerciseId,
          sets: exerciseTemplate.sets,
          reps: exerciseTemplate.reps,
          restTime: exerciseTemplate.restTime,
        );
        routineExercise.setExercise(exerciseData);
        routineExercises.add(routineExercise);
      }
      // Guardar todo en una sola operación atómica
      await provider.createFullRoutine(
        name: template.name,
        description: template.description,
        daysOfWeek: selectedDays,
        exercises: routineExercises,
      );
      debugPrint('[PresetRoutines] _addRoutineFromTemplate: createFullRoutine returned for ${template.name}');
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('✅ "${template.name}" agregada a tus rutinas'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) navigator.pop();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear rutina: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        // Mostrar indicador de carga si los ejercicios aún no están cargados
        if (exerciseProvider.isLoading || !exerciseProvider.isInitialized) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Cargando ejercicios...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            bottom: SubTabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Para Ti', icon: Icon(Icons.person)),
                Tab(text: 'Generales', icon: Icon(Icons.fitness_center)),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalizedTab(theme, colorScheme),
                    _buildGeneralTab(theme, colorScheme),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPersonalizedTab(ThemeData theme, ColorScheme colorScheme) {
    if (_currentUser == null) {
      return EmptyStateWidget(
        icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
        title: 'No se encontró usuario',
        subtitle: 'Completa tu perfil primero',
        iconColor: Colors.grey,
      );
    }

    final recommendedRoutines = RoutineRecommendationService.getRecommendedRoutines(_currentUser!);
    final personalizedRoutine = RoutineRecommendationService.generatePersonalizedRoutine(_currentUser!);
    final recommendation = RoutineRecommendationService.getWeeklyRecommendation(_currentUser!);

    return Column(
      children: [
        // Tarjeta de información del perfil
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu Perfil Fitness',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentUser!.gender} • ${_currentUser!.age} años',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          'IMC: ${recommendation['bmi'].toStringAsFixed(1)} • Nivel: ${recommendation['level']}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(
                    icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
                    label: '${recommendation['daysPerWeek']} días/semana',
                    color: Colors.blue,
                  ),
                  _buildInfoChip(
                    icon: PhosphorIcons.barbell(PhosphorIconsStyle.fill),
                    label: recommendation['split'],
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de rutinas
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Rutina personalizada primero
              _buildRoutineCard(
                context,
                personalizedRoutine,
                theme,
                colorScheme,
                isPersonalized: true,
              ),
              const SizedBox(height: 8),
              
              // Rutinas recomendadas
              ...recommendedRoutines.map((template) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRoutineCard(context, template, theme, colorScheme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ThemeData theme, ColorScheme colorScheme) {
    final templates = _getFilteredTemplates();

    return Column(
      children: [
        // Filtros de nivel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Nivel: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                ...['Todos', 'Principiante', 'Intermedio', 'Avanzado'].map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(level),
                      selected: _selectedLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de rutinas
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay rutinas para este nivel',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRoutineCard(context, templates[index], theme, colorScheme),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    RoutineTemplate template,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isPersonalized = false,
  }) {
    final levelColor = isPersonalized ? Colors.purple : _getLevelColor(template.level);
    final levelIcon = isPersonalized
        ? PhosphorIcons.sparkle(PhosphorIconsStyle.fill)
        : _getLevelIcon(template.level);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: levelColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTemplateDetails(context, template, theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(levelIcon, color: levelColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPersonalized)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PERSONALIZADA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        Text(
                          template.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.barbell(PhosphorIconsStyle.fill),
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${template.exercises.length} ejercicios',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              PhosphorIcons.clock(PhosphorIconsStyle.fill),
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              template.duration ?? template.estimatedDurationRange,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                template.description,
                style: theme.textTheme.bodyMedium,
              ),
              if (template.muscleGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: template.muscleGroups.map((muscle) {
                    final muscleColor = _getMuscleGroupColor(muscle);
                    return Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMuscleGroupIcon(muscle),
                            size: 14,
                            color: muscleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            muscle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: muscleColor,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: muscleColor.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showTemplateDetails(context, template, theme),
                    icon: Icon(PhosphorIcons.eye(PhosphorIconsStyle.regular)),
                    label: const Text('Ver detalles'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _addRoutineFromTemplate(context, template),
                    icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: levelColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplateDetails(BuildContext context, RoutineTemplate template, ThemeData theme) {
    // Obtener la caja de ejercicios
    final exerciseBox = Hive.box<Exercise>('exercises');
    
    // Verificar si hay ejercicios cargados
    if (exerciseBox.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Cargando ejercicios, por favor espera un momento...'),
          duration: Duration(seconds: 2),
        ),
      );
      // Esperar un momento y volver a intentar
      Future.delayed(const Duration(milliseconds: 500), () {
        if (exerciseBox.isNotEmpty) {
          _showTemplateDetails(context, template, theme);
        }
      });
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    template.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.description,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: template.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = template.exercises[index];
                  // Obtener el nombre del ejercicio desde la base de datos
                  final exerciseData = exerciseBox.get(exercise.exerciseId);
                  final exerciseName = exerciseData?.name ?? exercise.exerciseId;
                  final muscleGroup = exerciseData?.muscleGroup ?? '';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (muscleGroup.isNotEmpty)
                            Text(
                              muscleGroup,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text('${exercise.sets} series × ${exercise.reps} reps'),
                          Text('Descanso: ${exercise.restTime}s'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        // Cerrar el bottom sheet primero y luego invocar
                        // la creación de la rutina usando el contexto del
                        // State (`this.context`) para evitar usar el
                        // contexto del bottom sheet que queda desactivado.
                        Navigator.of(context).pop();
                        final parentContext = this.context;
                        Future.microtask(() => _addRoutineFromTemplate(parentContext, template));
                      },
                icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
                label: const Text('Agregar a mis rutinas'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>?> _showDaySelectionDialog(BuildContext context, String routineName) async {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final daysShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final selectedDays = List<bool>.generate(7, (_) => false);

    return showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('¿Qué días harás "$routineName"?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecciona los días de la semana:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDays[index] = !selectedDays[index];
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedDays[index]
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            child: Center(
                              child: Text(
                                daysShort[index],
                                style: TextStyle(
                                  color: selectedDays[index]
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: selectedDays[index] ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Puedes cambiar esto después',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selected = <String>[];
                    for (int i = 0; i < selectedDays.length; i++) {
                      if (selectedDays[i]) {
                        selected.add(days[i]);
                      }
                    }
                    Navigator.of(context).pop(selected);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
