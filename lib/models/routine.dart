import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 13)
class Routine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> exerciseIds;

  Routine({
    required this.id,
    required this.name,
    this.description,
    required this.exerciseIds,
  });
}
