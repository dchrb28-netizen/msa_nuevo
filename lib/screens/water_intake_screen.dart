import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final Box<WaterLog> waterLogBox = Hive.box<WaterLog>('water_logs');
  DateTime _selectedDate = DateTime.now();

  void _addWater(double amount) {
    final log = WaterLog(id: DateTime.now().millisecondsSinceEpoch.toString(), amount: amount, timestamp: DateTime.now());
    waterLogBox.add(log);
  }

  void _showAddOtherDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Otra Cantidad'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                _addWater(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: waterLogBox.listenable(),
      builder: (context, Box<WaterLog> box, _) {
        final todayLogs = box.values.where((log) => DateUtils.isSameDay(log.timestamp, _selectedDate)).toList();
        final totalWater = todayLogs.fold<double>(0, (sum, log) => sum + log.amount);
        const double dailyGoal = 2500;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resumen del día
              Text('Consumo de Hoy', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(
                child: Text('${totalWater.toInt()} ml', style: GoogleFonts.lato(fontSize: 48, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
              Center(child: Text('Meta: ${dailyGoal.toInt()} ml', style: const TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 24),

              // Botones de acción rápida
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton(250, colorScheme),
                  _buildWaterButton(500, colorScheme),
                  ElevatedButton.icon(
                    onPressed: _showAddOtherDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Otro'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Historial del día seleccionado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeDate(-1)),
                  Text(DateFormat.yMMMd('es').format(_selectedDate), style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: DateUtils.isSameDay(_selectedDate, DateTime.now()) ? null : () => _changeDate(1)),
                ],
              ),
              const SizedBox(height: 16),
              if (todayLogs.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aún no hay registros para esta fecha.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayLogs.length,
                  itemBuilder: (context, index) {
                    final log = todayLogs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.water_drop_outlined, color: Colors.blueAccent),
                        title: Text('${log.amount.toInt()} ml'),
                        subtitle: Text(DateFormat.jm().format(log.timestamp)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => log.delete()),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterButton(int amount, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: () => _addWater(amount.toDouble()),
      icon: const Icon(Icons.local_drink_outlined),
      label: Text('${amount}ml'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
