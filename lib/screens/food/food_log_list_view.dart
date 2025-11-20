import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/food_log.dart';

class FoodLogListView extends StatelessWidget {
  final DateTime date;

  const FoodLogListView({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('food_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        bool isSameDay(DateTime d1, DateTime d2) {
          return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
        }

        final dailyLogs = box.values
            .where((log) => isSameDay(log.date, date))
            .toList();

        if (dailyLogs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No hay comidas registradas para esta fecha.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            80,
          ), // Padding to avoid overlap with FAB
          itemCount: dailyLogs.length,
          itemBuilder: (context, index) {
            final log = dailyLogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  log.foodName,
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${log.calories.toStringAsFixed(0)} kcal | P: ${log.protein.toStringAsFixed(0)}g, C: ${log.carbohydrates.toStringAsFixed(0)}g, G: ${log.fat.toStringAsFixed(0)}g',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(context, box, log),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Box<FoodLog> box, FoodLog log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el registro de "${log.foodName}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                box.delete(log.key);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
