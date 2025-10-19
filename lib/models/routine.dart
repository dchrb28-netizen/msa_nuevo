import 'package:hive/hive.dart';
import 'package:myapp/models/exercise.dart';

part 'routine.g.dart';

@HiveType(typeId: 7) // Asignamos un nuevo typeId único
class Routine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> exerciseIds; // Almacenamos solo los IDs de los ejercicios

  Routine({
    required this.id,
    required this.name,
    this.description,
    required this.exerciseIds,
  });

  // Nota: Para obtener los objetos Exercise completos, necesitaremos
  // buscarlos en el ExerciseService usando los exerciseIds.
}
