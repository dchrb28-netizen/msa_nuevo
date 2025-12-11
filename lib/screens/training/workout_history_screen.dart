import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/providers/workout_history_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:provider/provider.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  DateTime? _selectedDate;

  Future<void> _presentDatePicker() async {
    // Capture the service before the async gap.
    final achievementService = Provider.of<AchievementService>(context, listen: false);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // After the async gap, check if the widget is still mounted.
    if (!mounted || pickedDate == null) {
      return;
    }

    // Now it's safe to use the service and call setState.
    achievementService.updateProgress('exp_filter_history', 1);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _presentDatePicker,
            tooltip: 'Filtrar por fecha',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Chip(
                label: Text(
                  'Filtrando por: ${DateFormat.yMMMd('es').format(_selectedDate!)}',
                ),
                onDeleted: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            ),
          Expanded(
            child: Consumer<WorkoutHistoryProvider>(
              builder: (context, historyProvider, child) {
                var history = historyProvider.workoutHistory;

                if (_selectedDate != null) {
                  history = history.where((session) {
                    return DateUtils.isSameDay(session.date, _selectedDate);
                  }).toList();
                }

                if (history.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final session = history[index];
                    return _buildDismissibleSessionCard(
                      context,
                      session,
                      historyProvider,
                      index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            _selectedDate == null
                ? 'Tu historial está vacío'
                : 'No hay entrenamientos en esta fecha',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Completa un entrenamiento para verlo aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleSessionCard(
    BuildContext context,
    WorkoutSession session,
    WorkoutHistoryProvider provider,
    int originalIndex,
  ) {
    final theme = Theme.of(context);
    final totalExercises = session.performedExercises.length;
    final totalSets = session.performedExercises.fold(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final originalSession = session;
        final fullHistory = provider.workoutHistory;
        final actualIndex = fullHistory.indexWhere((s) => s.id == originalSession.id);

        provider.deleteWorkoutSession(session.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entrenamiento eliminado'),
            action: SnackBarAction(
              label: 'DESHACER',
              onPressed: () {
                provider.addWorkoutSessionAtIndex(actualIndex, originalSession);
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
      ),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () => _navigateToSessionDetail(context, session),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.routineName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat.yMMMMEEEEd('es').format(session.date)} ${Provider.of<TimeFormatService>(context).formatTime(session.date)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                      theme,
                      Icons.fitness_center,
                      '$totalExercises',
                      'Ejercicios',
                    ),
                    _buildStat(
                      theme,
                      Icons.replay,
                      '$totalSets',
                      'Series totales',
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToSessionDetail(BuildContext context, WorkoutSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionDetailScreen(session: session),
      ),
    );
  }
}

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // title removed
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(25.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${DateFormat.yMMMMEEEEd('es').format(session.date)} ${Provider.of<TimeFormatService>(context).formatTime(session.date)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.appBarTheme.foregroundColor?.withAlpha(204),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: session.performedExercises.length,
        itemBuilder: (context, index) {
          final performedExercise = session.performedExercises[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performedExercise.exerciseName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  ...List.generate(performedExercise.sets.length, (setIndex) {
                    final set = performedExercise.sets[setIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Set ${setIndex + 1}: ',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${set.reps} reps con ${set.weight} kg',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
