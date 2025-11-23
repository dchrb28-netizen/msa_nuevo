
import 'dart:convert';

class MeditationLog {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;

  MeditationLog({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
  });

  // Convierte el objeto MeditationLog a un mapa para JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(), // Corregido el error de tipeo
      'durationInSeconds': durationInSeconds,
    };
  }

  // Crea un objeto MeditationLog desde un mapa
  factory MeditationLog.fromMap(Map<String, dynamic> map) {
    return MeditationLog(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationInSeconds: map['durationInSeconds'],
    );
  }

  // Codifica a JSON String
  String toJson() => json.encode(toMap());

  // Decodifica desde JSON String
  factory MeditationLog.fromJson(String source) => MeditationLog.fromMap(json.decode(source));
}
