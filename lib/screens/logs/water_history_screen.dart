import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    return ValueListenableBuilder(
      valueListenable: Hive.box<WaterLog>('water_logs').listenable(),
      builder: (context, Box<WaterLog> box, _) {
        // Filtrar logs del usuario actual y ordenar por fecha descendente
        final logs = box.values
            .where((log) => currentUser != null && log.userId == currentUser.id)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (logs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.water_drop,
            title: 'No hay registros de agua',
            subtitle: '¡Empieza a registrar tu hidratación!',
            iconColor: Colors.blue[400],
          );
        }

        // Agrupar por fecha
        final groupedLogs = <String, List<WaterLog>>{};
        for (var log in logs) {
          final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
          groupedLogs.putIfAbsent(dateKey, () => []).add(log);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedLogs.length,
          itemBuilder: (context, index) {
            final dateKey = groupedLogs.keys.elementAt(index);
            final dayLogs = groupedLogs[dateKey]!;
            final totalMl = dayLogs.fold<double>(0, (sum, log) => sum + log.amount);
            final date = DateTime.parse(dateKey);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.water_drop,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Total: ${totalMl.toStringAsFixed(0)} ml (${dayLogs.length} registros)',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                children: dayLogs.map((log) {
                  return ListTile(
                    leading: const Icon(Icons.local_drink, size: 20),
                    title: Text('${log.amount.toStringAsFixed(0)} ml'),
                    trailing: Text(
                      DateFormat('HH:mm').format(log.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
