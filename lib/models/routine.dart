
import 'package:hive/hive.dart';
import 'package:myapp/models/routine_exercise.dart';

part 'routine.g.dart';

@HiveType(typeId: 15)
class Routine extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  HiveList<RoutineExercise>? exercises;

  Routine({
    required this.id,
    required this.name,
    required this.description,
    this.exercises,
  });
}
