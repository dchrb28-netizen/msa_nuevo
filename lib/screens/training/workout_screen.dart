import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:myapp/providers/workout_history_provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late Map<int, List<SetLog?>> _setsData;
  late DateTime _startTime; // Para registrar el inicio del entreno

  Timer? _timer;
  int _countdownTime = 0;
  bool _isResting = false;
  int? _restingExerciseIndex;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Se guarda la hora de inicio
    _setsData = {
      for (var i = 0; i < (widget.routine.exercises?.length ?? 0); i++)
        i: List.generate(widget.routine.exercises![i].sets, (_) => null),
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int exerciseIndex, int restTimeInSeconds) {
    if (restTimeInSeconds <= 0) return;

    _cancelRestTimer();

    setState(() {
      _countdownTime = restTimeInSeconds;
      _isResting = true;
      _restingExerciseIndex = exerciseIndex;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownTime > 0) {
        setState(() {
          _countdownTime--;
        });
      } else {
        _cancelRestTimer();
      }
    });
  }

  void _cancelRestTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isResting = false;
        _restingExerciseIndex = null;
        _countdownTime = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );
    final routineExercises = widget.routine.exercises;

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenamiento: ${widget.routine.name}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmationDialog(),
        ),
      ),
      body: (routineExercises == null || routineExercises.isEmpty)
          ? const Center(
              child: Text('Esta rutina no tiene ejercicios todavía.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: routineExercises.length,
              itemBuilder: (context, index) {
                final routineExercise = routineExercises[index];
                final Exercise? exercise = exerciseProvider.getExerciseById(
                  routineExercise.exerciseId,
                );

                if (exercise == null) {
                  return ListTile(
                    title: Text(
                      'Ejercicio no encontrado (ID: ${routineExercise.exerciseId})',
                    ),
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                  );
                }

                return _buildExerciseCard(exercise, routineExercise, index);
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Finalizar Entrenamiento'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isResting ? null : _finishWorkout,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    Exercise exercise,
    RoutineExercise routineExercise,
    int exerciseIndex,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<SetLog?> loggedSets = _setsData[exerciseIndex]!;
    final bool isCurrentlyResting =
        _isResting && _restingExerciseIndex == exerciseIndex;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GIF demostrativo del ejercicio
            if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    exercise.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fitness_center, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${routineExercise.sets} series x ${routineExercise.reps} reps',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (routineExercise.restTime != null &&
                routineExercise.restTime! > 0 &&
                !isCurrentlyResting)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routineExercise.restTime} seg de descanso',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (isCurrentlyResting)
              _buildTimerWidget(routineExercise.restTime!)
            else
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: List.generate(routineExercise.sets, (setIndex) {
                  final bool isCompleted = loggedSets[setIndex] != null;

                  return OutlinedButton(
                    onPressed: () => _showLogSetDialog(
                      exerciseIndex,
                      setIndex,
                      routineExercise,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCompleted
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      backgroundColor: isCompleted
                          ? colorScheme.primary
                          : Colors.transparent,
                      side: BorderSide(
                        color: colorScheme.primary.withAlpha(128),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted) ...[
                          const Icon(Icons.check, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Text('Set ${setIndex + 1}'),
                      ],
                    ),
                  );
                }),
              ),
            if (loggedSets.any((log) => log != null)) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text("Registros:", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...List.generate(loggedSets.length, (setIndex) {
                final log = loggedSets[setIndex];
                if (log == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('  • Set ${setIndex + 1}: ${log.toString()}'),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget(int totalRestTime) {
    final double progress = 1.0 - (_countdownTime / totalRestTime);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$_countdownTime',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(width: 4),
            Text('seg', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _cancelRestTimer,
          child: const Text('Saltar Descanso'),
        ),
      ],
    );
  }

  void _showLogSetDialog(
    int exerciseIndex,
    int setIndex,
    RoutineExercise routineExercise,
  ) {
    final repsController = TextEditingController(
      text: routineExercise.reps.split('-').first,
    );

    double? initialWeight;
    if (setIndex > 0 && _setsData[exerciseIndex]![setIndex - 1] != null) {
      initialWeight = _setsData[exerciseIndex]![setIndex - 1]!.weight;
    } else if (routineExercise.weight != null && routineExercise.weight! > 0) {
      initialWeight = routineExercise.weight;
    }

    final weightController = TextEditingController(
      text: initialWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Registrar Set ${setIndex + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repsController,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones',
                  icon: Icon(Icons.repeat),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) (Opcional)',
                  icon: Icon(Icons.fitness_center),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                final int? reps = int.tryParse(repsController.text);
                final String weightText = weightController.text;
                final double? weight =
                    weightText.isEmpty ? null : double.tryParse(weightText);

                if (reps != null) {
                  if (weightText.isNotEmpty && weight == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El peso introducido no es un número válido.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _setsData[exerciseIndex]![setIndex] = SetLog(
                      reps: reps,
                      weight: weight ?? 0.0,
                    );
                  });
                  Navigator.of(ctx).pop();

                  final bool isLastSet = setIndex == routineExercise.sets - 1;
                  if (!isLastSet &&
                      routineExercise.restTime != null &&
                      routineExercise.restTime! > 0) {
                    _startRestTimer(exerciseIndex, routineExercise.restTime!);
                  }
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, introduce un número válido de repeticiones.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('¿Finalizar Entrenamiento?'),
          content: const Text(
            '¿Estás seguro de que quieres terminar la sesión? El progreso no guardado se perderá.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text(
                'Finalizar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _timer?.cancel();
                Navigator.of(ctx).pop();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final durationInMinutes = DateTime.now().difference(_startTime).inMinutes;

    final historyProvider = Provider.of<WorkoutHistoryProvider>(
      context,
      listen: false,
    );
    final routineProvider = Provider.of<RoutineProvider>(
      context,
      listen: false,
    );
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );
    final List<PerformedExerciseLog> performedExercisesForHistory = [];
    final List<ExerciseLog> exerciseLogsForRoutineLog = [];

    int totalWeightLifted = 0;

    _setsData.forEach((exerciseIndex, logs) {
      final routineExercise = widget.routine.exercises![exerciseIndex];
      final exercise = exerciseProvider.getExerciseById(
        routineExercise.exerciseId,
      );
      final List<SetLog> completedSets =
          logs.where((log) => log != null).cast<SetLog>().toList();

      if (exercise != null && completedSets.isNotEmpty) {
        performedExercisesForHistory.add(
          PerformedExerciseLog(
            exerciseName: exercise.name,
            sets: completedSets,
          ),
        );
        exerciseLogsForRoutineLog.add(
          ExerciseLog(exercise: exercise, sets: completedSets),
        );

        for (var set in completedSets) {
          totalWeightLifted += (set.reps * set.weight).toInt();
        }
      }
    });

    if (performedExercisesForHistory.isEmpty) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha registrado ninguna serie. El entrenamiento no se guardará.',
          ),
        ),
      );
      return;
    }

    final newSession = WorkoutSession(
      routineName: widget.routine.name,
      date: DateTime.now(),
      performedExercises: performedExercisesForHistory,
      durationInMinutes: durationInMinutes,
    );
    historyProvider.addWorkoutSession(newSession);

    final newLog = RoutineLog(
      routineName: widget.routine.name,
      date: DateTime.now(),
      exerciseLogs: exerciseLogsForRoutineLog,
      durationInMinutes: durationInMinutes,
    );
    await routineProvider.addRoutineLog(newLog);

    final achievementService = AchievementService();
    achievementService.grantExperience(30);
    achievementService.updateProgress('first_workout', 1);
    achievementService.updateProgress('cum_train_25', 1, cumulative: true);
    achievementService.updateProgress('cum_train_100', 1, cumulative: true);
    achievementService.updateProgress('cum_lift_50k', totalWeightLifted, cumulative: true);

    if (!mounted) return;
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('¡Entrenamiento guardado! Buen trabajo.')),
    );

    if (!mounted) return;
    navigator.pop();
  }
}
