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

  @HiveField(4)
  String? dayOfWeek; // Mantener para compatibilidad, deprecated

  @HiveField(5)
  List<String>? daysOfWeek; // Nuevo: múltiples días ['Lunes', 'Miércoles', 'Viernes']

  Routine({
    required this.id,
    required this.name,
    required this.description,
    this.exercises,
    this.dayOfWeek,
    this.daysOfWeek,
  });

  // Getter para obtener los días (prioriza daysOfWeek sobre dayOfWeek)
  List<String> get activeDays {
    if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      return daysOfWeek!;
    } else if (dayOfWeek != null && dayOfWeek!.isNotEmpty) {
      return [dayOfWeek!];
    }
    return [];
  }

  // toJson method
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'dayOfWeek': dayOfWeek,
        'daysOfWeek': daysOfWeek,
        'exercises': exercises?.map((e) => e.toJson()).toList(),
      };

  // fromJson factory
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dayOfWeek: json['dayOfWeek'],
      daysOfWeek: json['daysOfWeek'] != null 
          ? List<String>.from(json['daysOfWeek'])
          : null,
      // exercises will be handled separately due to HiveList
    );
  }
}