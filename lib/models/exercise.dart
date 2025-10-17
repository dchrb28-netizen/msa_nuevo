import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 6) // Asignar un typeId único
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final String reps;

  @HiveField(4)
  final String? imageUrl;

  Exercise({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    this.imageUrl,
  });
}
