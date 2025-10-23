
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/models/routine.dart';
import 'package:myapp/models/routine_log.dart';
import 'package:myapp/models/exercise_log.dart';
import 'package:myapp/models/set_log.dart';
import 'package:myapp/providers/routine_provider.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({super.key, required this.routine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<ExerciseLog> _exerciseLogs;
  late DateTime _startTime;
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  Timer? _restTimer;
  int _restTimeRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _exerciseLogs = widget.routine.exercises.map((routineExercise) {
      return ExerciseLog(
        exercise: routineExercise.exercise,
        sets: List.generate(
          routineExercise.sets,
          (index) => SetLog(reps: 0, weight: 0), // Initialize with 0 or planned values
        ),
      );
    }).toList();
  }

  void _finishWorkout() {
    final duration = DateTime.now().difference(_startTime);
    final routineLog = RoutineLog(
      date: _startTime,
      routineName: widget.routine.name,
      exerciseLogs: _exerciseLogs,
      duration: duration,
    );
    Provider.of<RoutineProvider>(context, listen: false).addRoutineLog(routineLog);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _completeSet(int setIndex) {
    setState(() {
      _exerciseLogs[_currentExerciseIndex].sets[setIndex].isCompleted = true;
      _startRestTimer();
    });
  }

  void _startRestTimer() {
    final restTime = widget.routine.exercises[_currentExerciseIndex].restTime ?? 60;
    _restTimeRemaining = restTime;
    setState(() {
      _isResting = true;
    });
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimeRemaining > 0) {
        setState(() {
          _restTimeRemaining--;
        });
      } else {
        _restTimer?.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isResting = false;
        _restTimer?.cancel();
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _isResting = false;
        _restTimer?.cancel();
      });
    }
  }
  
  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoutineExercise = widget.routine.exercises[_currentExerciseIndex];
    final currentExerciseLog = _exerciseLogs[_currentExerciseIndex];

    if (_isResting) {
      return _buildRestScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentExerciseIndex + 1}/${widget.routine.exercises.length}'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: const Text('Finalizar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(currentRoutineExercise.exercise.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('${currentRoutineExercise.sets} series x ${currentRoutineExercise.reps} reps', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildSetList(currentExerciseLog),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentExerciseIndex > 0)
                  ElevatedButton(onPressed: _previousExercise, child: const Text('Anterior')),
                if (_currentExerciseIndex < widget.routine.exercises.length - 1)
                  ElevatedButton(onPressed: _nextExercise, child: const Text('Siguiente')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSetList(ExerciseLog exerciseLog) {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: exerciseLog.sets.length,
    itemBuilder: (context, index) {
      final set = exerciseLog.sets[index];
      return Card(
        color: set.isCompleted ? Colors.green[100] : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Serie ${index + 1}', style: const TextStyle(fontSize: 16)),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: set.weight.toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Peso'),
                  onChanged: (value) => set.weight = double.tryParse(value) ?? 0,
                ),
              ),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: set.reps.toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  onChanged: (value) => set.reps = int.tryParse(value) ?? 0,
                ),
              ),
              IconButton(
                icon: Icon(set.isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                color: set.isCompleted ? Colors.green : Colors.grey,
                onPressed: () => _completeSet(index),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildRestScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('DESCANSO', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 20),
            Text('${_restTimeRemaining}s', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _restTimer?.cancel();
                setState(() {
                  _isResting = false;
                });
              },
              child: const Text('Saltar Descanso'),
            ),
          ],
        ),
      ),
    );
  }
}
