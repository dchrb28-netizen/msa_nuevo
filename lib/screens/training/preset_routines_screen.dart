import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:myapp/data/default_routines.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/services/routine_recommendation_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PresetRoutinesScreen extends StatefulWidget {
  const PresetRoutinesScreen({super.key});

  @override
  State<PresetRoutinesScreen> createState() => _PresetRoutinesScreenState();
}

class _PresetRoutinesScreenState extends State<PresetRoutinesScreen> with SingleTickerProviderStateMixin {
  String _selectedDifficulty = 'Todos';
  late TabController _tabController;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profileBox = await Hive.openBox('profile_data');
    final profileData = profileBox.get('user_profile');
    if (profileData != null) {
      setState(() {
        _userProfile = profileData is UserProfile 
            ? profileData 
            : UserProfile.fromJson(Map<String, dynamic>.from(profileData));
      });
    }
  }
  
  List<Routine> _getFilteredRoutines() {
    if (_selectedDifficulty == 'Todos') {
      return DefaultRoutines.all;
    }
    return DefaultRoutines.getByDifficulty(_selectedDifficulty);
  }

  Color _getDifficultyColor(String routineName) {
    if (routineName.toLowerCase().contains('principiante')) {
      return Colors.green;
    } else if (routineName.toLowerCase().contains('intermedio')) {
      return Colors.orange;
    } else if (routineName.toLowerCase().contains('avanzado')) {
      return Colors.red;
    }
    return Colors.blue;
  }

  IconData _getDifficultyIcon(String routineName) {
    if (routineName.toLowerCase().contains('principiante')) {
      return PhosphorIcons.userCircle(PhosphorIconsStyle.fill);
    } else if (routineName.toLowerCase().contains('intermedio')) {
      return PhosphorIcons.userCirclePlus(PhosphorIconsStyle.fill);
    } else if (routineName.toLowerCase().contains('avanzado')) {
      return PhosphorIcons.fire(PhosphorIconsStyle.fill);
    }
    return PhosphorIcons.lightning(PhosphorIconsStyle.fill);
  }

  void _addRoutineToUser(BuildContext context, Routine routine) {
    final provider = Provider.of<RoutineProvider>(context, listen: false);
    
    // Crear una copia de la rutina con nuevo ID para el usuario
    final userRoutine = Routine(
      id: routine.id,
      name: routine.name,
      description: routine.description,
      createdAt: DateTime.now(),
      exercises: routine.exercises,
    );
    
    provider.addRoutine(userRoutine);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "${routine.name}" agregada a tus rutinas'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Predefinidas'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Para Ti', icon: Icon(Icons.person)),
            Tab(text: 'Generales', icon: Icon(Icons.fitness_center)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Rutinas Personalizadas
          _buildPersonalizedTab(theme, colorScheme),
          // Tab 2: Rutinas Generales
          _buildGeneralTab(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTab(ThemeData theme, ColorScheme colorScheme) {
    if (_userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.user(PhosphorIconsStyle.regular),
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Completa tu perfil primero',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ve a Perfil y agrega tu información',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final personalizedRoutines = RoutineRecommendationService.generatePersonalizedRoutines(_userProfile!);
    final recommendation = RoutineRecommendationService.getWeeklyRecommendation(_userProfile!);
    final bmi = RoutineRecommendationService.calculateBMI(
      _userProfile!.weight ?? 70, 
      _userProfile!.height ?? 170
    );

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
                color: Colors.black.withOpacity(0.1),
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
                          '${_userProfile!.sex ?? "N/A"} • ${_userProfile!.age ?? "N/A"} años',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          'IMC: ${bmi.toStringAsFixed(1)} • Nivel: ${recommendation['level']}',
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
                    icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.fill),
                    label: recommendation['split'],
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Lista de rutinas personalizadas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: personalizedRoutines.length,
            itemBuilder: (context, index) {
              final routine = personalizedRoutines[index];
              return _buildRoutineCard(
                context, 
                routine, 
                theme, 
                colorScheme,
                isPerson: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
    final routines = _getFilteredRoutines();
    
    return Column(
      children: [
        // Filtros de dificultad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  (difficulty) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(difficulty),
                      selected: _selectedDifficulty == difficulty,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDifficulty = difficulty;
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
        
        // Lista de rutinas generales
        Expanded(
          child: routines.isEmpty
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
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return _buildRoutineCard(context, routine, theme, colorScheme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, 
    Routine routine, 
    ThemeData theme, 
    ColorScheme colorScheme,
    {bool isPerson = false}
  ) {
    final difficultyColor = isPerson ? Colors.purple : _getDifficultyColor(routine.name);
    final difficultyIcon = isPerson 
        ? PhosphorIcons.sparkle(PhosphorIconsStyle.fill)
        : _getDifficultyIcon(routine.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: difficultyColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRoutineDetails(context, routine),
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
                      color: difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      difficultyIcon,
                      color: difficultyColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPerson)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
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
                        const SizedBox(height: 4),
                        Text(
                          routine.name,
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
                              '${routine.exercises.length} ejercicios',
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
                routine.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showRoutineDetails(context, routine),
                    icon: Icon(PhosphorIcons.eye(PhosphorIconsStyle.regular)),
                    label: const Text('Ver detalles'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addRoutineToUser(context, routine),
                    icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: difficultyColor,
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

  void _showRoutineDetails(BuildContext context, Routine routine) {
    final theme = Theme.of(context);
    
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
                color: theme.colorScheme.surfaceVariant,
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
                    routine.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    routine.description,
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
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = routine.exercises[index];
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
                        'Ejercicio',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${exercise.sets} series × ${exercise.reps} reps'),
                          Text('Descanso: ${exercise.restSeconds}s'),
                          if (exercise.notes?.isNotEmpty ?? false)
                            Text(
                              exercise.notes!,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _addRoutineToUser(context, routine);
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
}
