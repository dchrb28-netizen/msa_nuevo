import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_exercise.dart';
import 'package:myapp/providers/exercise_provider.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // A map to track the completion status of each set for each exercise.
  // The key is the routineExercise's index, value is a list of booleans for sets.
  late Map<int, List<bool>> _setsCompletion;

  @override
  void initState() {
    super.initState();
    // Initialize the completion status for all sets of all exercises to false.
    _setsCompletion = {
      for (var i = 0; i < (widget.routine.exercises?.length ?? 0); i++) 
        i: List.generate(widget.routine.exercises![i].sets, (_) => false)
    };
  }

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
          onPressed: _finishWorkout,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, RoutineExercise routineExercise, int exerciseIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${routineExercise.sets} series x ${routineExercise.reps} reps', style: Theme.of(context).textTheme.titleMedium),
            if (routineExercise.restTime != null && routineExercise.restTime! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${routineExercise.restTime} seg de descanso entre series', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(routineExercise.sets, (setIndex) {
                return ChoiceChip(
                  label: Text('Set ${setIndex + 1}'),
                  selected: _setsCompletion[exerciseIndex]![setIndex],
                  onSelected: (bool selected) {
                    setState(() {
                      _setsCompletion[exerciseIndex]![setIndex] = selected;
                    });
                  },
                  avatar: _setsCompletion[exerciseIndex]![setIndex]
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: _setsCompletion[exerciseIndex]![setIndex] ? Colors.white : Colors.black,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
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
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _finishWorkout() {
    // TODO: Implement logic to save the workout session to history
    // For now, just show a confirmation and pop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Entrenamiento completado! Buen trabajo.')),
    );
    Navigator.of(context).pop();
  }
}
