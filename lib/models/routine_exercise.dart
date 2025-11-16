import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';

part 'routine_exercise.g.dart';

@HiveType(typeId: 18) // Changed from 17 to 18 to resolve conflict
class RoutineExercise extends HiveObject {

  // This field remains as it is, linking to the Exercise model by its ID.
  @HiveField(0)
  late String exerciseId;

  @HiveField(1)
  late int sets;

  @HiveField(2)
  late String reps;

  @HiveField(3)
  double? weight;

  @HiveField(4)
  int? restTime; // in seconds

  // Non-Hive field to hold the loaded Exercise object
  Exercise? _exercise;

  // Public getter to access the exercise
  Exercise get exercise {
    if (_exercise == null) {
      // This is a safeguard, the exercise should be pre-loaded by the provider
      throw StateError('Exercise has not been loaded for RoutineExercise');
    } 
    return _exercise!;
  }

  // Method to set the exercise instance
  void setExercise(Exercise exercise) {
    // We could add a check here to ensure the ID matches
    // if (exercise.id != this.exerciseId) {
    //   throw ArgumentError('The provided Exercise ID does not match the stored exerciseId.');
    // }
    _exercise = exercise;
  }

  RoutineExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weight,
    this.restTime,
  });

  // No-argument constructor for Hive
  RoutineExercise.empty();
}
