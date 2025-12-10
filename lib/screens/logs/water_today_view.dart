import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/providers/water_intake_provider.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:myapp/widgets/dashboard/aquarium_widget.dart';
import 'package:provider/provider.dart';

class WaterTodayView extends StatelessWidget {
  const WaterTodayView({super.key});

  void _showAddWaterDialog(BuildContext context, WaterIntakeProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Agua'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                provider.addWaterLog(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _editWaterLogDialog(
    BuildContext context,
    WaterLog log,
    WaterIntakeProvider provider,
  ) {
    final TextEditingController controller = TextEditingController(
      text: log.amount.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Registro'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                provider.editWaterLog(log, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final waterProvider = Provider.of<WaterIntakeProvider>(context);
    final currentUser = userProvider.user;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String catImagePath = isDarkMode
        ? 'assets/images/gato_agua_dark.png'
        : 'assets/images/gato_agua_light.png';

    return ValueListenableBuilder(
      valueListenable: waterProvider.waterLogBox.listenable(),
      builder: (context, Box<WaterLog> box, _) {
        if (currentUser == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Por favor, crea un perfil de usuario para poder registrar tu ingesta de agua.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final intakeForSelectedDate =
            waterProvider.getWaterIntakeForDate(waterProvider.selectedDate);
        final logsForSelectedDate = waterProvider.getLogsForSelectedDate();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AquariumWidget(
                      totalWater: intakeForSelectedDate,
                      dailyGoal: waterProvider.dailyGoal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (waterProvider.dailyGoal > 0)
                  Column(
                    children: [
                      Center(
                        child: Text(
                          'Meta Diaria: ${waterProvider.dailyGoal.toInt()} ml',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => waterProvider.showEditGoalDialog(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar meta diaria'),
                      ),
                    ],
                  )
                else
                  Card(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Establece tu meta de agua',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Define una meta diaria para mantenerte hidratado.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => waterProvider.showEditGoalDialog(context),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Establecer Meta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWaterButton(250, waterProvider),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildWaterButton(500, waterProvider),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAddCustomButton(context, waterProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: waterProvider.goToPreviousDay,
                    ),
                    Expanded(
                      child: Text(
                        DateFormat.yMMMMd(
                          'es',
                        ).format(waterProvider.selectedDate),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: waterProvider.goToNextDay,
                    ),
                  ],
                ),
                const Divider(),
                Stack(
                  children: [
                    if (logsForSelectedDate.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: Center(
                          child: Text('Aún no has añadido agua hoy.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logsForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final log = logsForSelectedDate[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.local_drink,
                              color: Colors.blue,
                            ),
                            title: Text(
                              '${log.amount.toInt()} ml',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              Provider.of<TimeFormatService>(context).formatTime(log.timestamp),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _editWaterLogDialog(
                                    context,
                                    log,
                                    waterProvider,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      waterProvider.deleteWaterLog(log),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        catImagePath,
                        width: 100,
                        height: 100,
                        errorBuilder: (c, o, s) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterButton(double amount, WaterIntakeProvider provider) {
    return OutlinedButton.icon(
      onPressed: () => provider.addWaterLog(amount),
      icon: const Icon(Icons.local_drink_outlined, size: 16),
      label: Text('${amount.toInt()} ml', style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAddCustomButton(
    BuildContext context,
    WaterIntakeProvider provider,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _showAddWaterDialog(context, provider),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Otro', style: TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
