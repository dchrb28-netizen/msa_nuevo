import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 2)
class WaterLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount; // Changed to be non-final

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3) // Added userId
  final String userId;

  WaterLog({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.userId,
  });

  // Method to convert the object to a JSON-compatible Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
      };

  // Factory constructor to create an object from a Map
  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        id: json['id'],
        amount: json['amount'].toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        userId: json['userId'],
      );
}
