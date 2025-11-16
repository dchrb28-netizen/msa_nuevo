import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/models/workout_session.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:myapp/providers/workout_history_provider.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late Map<int, List<SetLog?>> _setsData;
  
  // --- Temporizador State ---
  Timer? _timer;
  int _countdownTime = 0;
  bool _isResting = false;
  int? _restingExerciseIndex;
  // --------------------------

  @override
  void initState() {
    super.initState();
    _setsData = {
      for (var i = 0; i < (widget.routine.exercises?.length ?? 0); i++)
        i: List.generate(widget.routine.exercises![i].sets, (_) => null)
    };
  }

  @override
  void dispose() {
    // Cancelar el temporizador al salir de la pantalla para evitar errores
    _timer?.cancel();
    super.dispose();
  }

  // --- Lógica del Temporizador ---
  void _startRestTimer(int exerciseIndex, int restTimeInSeconds) {
    if (restTimeInSeconds <= 0) return;

    _cancelRestTimer(); // Cancela cualquier temporizador anterior

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
        // Notificación con vibración al finalizar
        Vibrate.feedback(FeedbackType.success);
      }
    });
  }

  void _cancelRestTimer() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _restingExerciseIndex = null;
      _countdownTime = 0;
    });
  }
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
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
                final Exercise? exercise = exerciseProvider.getExerciseById(routineExercise.exerciseId);

                if (exercise == null) {
                  return ListTile(
                    title: Text('Ejercicio no encontrado (ID: ${routineExercise.exerciseId})'),
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
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: _isResting ? null : _finishWorkout, // Desactivar si se está en descanso
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, RoutineExercise routineExercise, int exerciseIndex) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<SetLog?> loggedSets = _setsData[exerciseIndex]!;
    final bool isCurrentlyResting = _isResting && _restingExerciseIndex == exerciseIndex;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${routineExercise.sets} series x ${routineExercise.reps} reps', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            if (routineExercise.restTime != null && routineExercise.restTime! > 0 && !isCurrentlyResting)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${routineExercise.restTime} seg de descanso', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // --- Widget del Temporizador ---
            if (isCurrentlyResting)
              _buildTimerWidget(routineExercise.restTime!)
            else
            // ---------------------------
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: List.generate(routineExercise.sets, (setIndex) {
                  final bool isCompleted = loggedSets[setIndex] != null;

                  return OutlinedButton(
                    onPressed: () => _showLogSetDialog(exerciseIndex, setIndex, routineExercise),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCompleted ? colorScheme.onPrimary : colorScheme.primary,
                      backgroundColor: isCompleted ? colorScheme.primary : Colors.transparent,
                      side: BorderSide(color: colorScheme.primary.withAlpha(128)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            ]
          ],
        ),
      ),
    );
  }

  // --- Widget para mostrar el temporizador ---
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
            Text('$_countdownTime', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
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
        TextButton(onPressed: _cancelRestTimer, child: const Text('Saltar Descanso')),
      ],
    );
  }
  // ----------------------------------------

  void _showLogSetDialog(int exerciseIndex, int setIndex, RoutineExercise routineExercise) {
    final repsController = TextEditingController(text: routineExercise.reps.split('-').first);

    double? initialWeight;
    if (setIndex > 0 && _setsData[exerciseIndex]![setIndex - 1] != null) {
      initialWeight = _setsData[exerciseIndex]![setIndex - 1]!.weight;
    } else if (routineExercise.weight != null && routineExercise.weight! > 0) {
      initialWeight = routineExercise.weight;
    }

    final weightController = TextEditingController(text: initialWeight?.toString() ?? '');

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
                decoration: const InputDecoration(labelText: 'Repeticiones', icon: Icon(Icons.repeat)),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)', icon: Icon(Icons.fitness_center)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                final double? weight = double.tryParse(weightController.text);
                if (reps != null && weight != null) {
                  setState(() {
                    _setsData[exerciseIndex]![setIndex] = SetLog(reps: reps, weight: weight);
                  });
                  Navigator.of(ctx).pop();

                  // Iniciar el temporizador después de guardar una serie
                  // Solo si no es la última serie del ejercicio
                  final bool isLastSet = setIndex == routineExercise.sets - 1;
                  if (!isLastSet) {
                    _startRestTimer(exerciseIndex, routineExercise.restTime ?? 60);
                  }

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, introduce valores numéricos válidos.')),
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
          content: const Text('¿Estás seguro de que quieres terminar la sesión? El progreso no guardado se perderá.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Finalizar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _timer?.cancel(); // Detener el temporizador si se sale
                Navigator.of(ctx).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Cierra la pantalla de entrenamiento
              },
            ),
          ],
        );
      },
    );
  }

  void _finishWorkout({bool confirmed = false}) {
    _timer?.cancel(); // Detener el temporizador al finalizar

    final historyProvider = Provider.of<WorkoutHistoryProvider>(context, listen: false);
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final List<PerformedExerciseLog> performedExercises = [];

    _setsData.forEach((exerciseIndex, logs) {
      final routineExercise = widget.routine.exercises![exerciseIndex];
      final exercise = exerciseProvider.getExerciseById(routineExercise.exerciseId);
      final List<SetLog> completedSets = logs.where((log) => log != null).cast<SetLog>().toList();

      if (exercise != null && completedSets.isNotEmpty) {
        performedExercises.add(PerformedExerciseLog(
          exerciseName: exercise.name,
          sets: completedSets,
        ));
      }
    });

    if (performedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha registrado ninguna serie. El entrenamiento no se guardará.')),
      );
      if (confirmed) Navigator.of(context).pop();
      return;
    }

    final newSession = WorkoutSession(
      routineName: widget.routine.name,
      date: DateTime.now(),
      performedExercises: performedExercises,
    );

    historyProvider.addWorkoutSession(newSession);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Entrenamiento guardado en el historial! Buen trabajo.')),
    );
    
    if (confirmed) {
        Navigator.of(context).pop(); 
    } else {
        Navigator.of(context).pop();
    }
  }
}
