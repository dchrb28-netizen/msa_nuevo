import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/water_log.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/providers/water_intake_provider.dart';
import 'package:myapp/services/time_format_service.dart';
import 'package:myapp/widgets/dashboard/aquarium_widget.dart';
import 'package:myapp/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class WaterTodayView extends StatelessWidget {
  const WaterTodayView({super.key});

  static const String _waterViewModeKey = 'water_view_mode';
  static const String _waterViewAquarium = 'aquarium';
  static const String _waterViewSimple = 'simple';

  String _viewLabel(String mode) {
    switch (mode) {
      case _waterViewAquarium:
        return 'Pecera';
      case _waterViewSimple:
        return 'Vista simple';
      default:
        return 'Pecera';
    }
  }

  void _showViewModeDialog(BuildContext context, Box settingsBox) {
    final current = settingsBox.get(_waterViewModeKey, defaultValue: _waterViewAquarium) as String;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visualización de agua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: _waterViewAquarium,
              groupValue: current,
              title: const Text('Pecera'),
              onChanged: (value) {
                if (value == null) return;
                settingsBox.put(_waterViewModeKey, value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: _waterViewSimple,
              groupValue: current,
              title: const Text('Simple'),
              onChanged: (value) {
                if (value == null) return;
                settingsBox.put(_waterViewModeKey, value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

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

    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, Box settingsBox, _) {
        return ValueListenableBuilder(
          valueListenable: waterProvider.waterLogBox.listenable(),
          builder: (context, Box<WaterLog> box, _) {
            final viewMode = settingsBox.get(
              _waterViewModeKey,
              defaultValue: _waterViewAquarium,
            ) as String;
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
                Row(
                  children: [
                    Text(
                      _viewLabel(viewMode),
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cambiar vista',
                      icon: const Icon(Icons.settings),
                      onPressed: () => _showViewModeDialog(context, settingsBox),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (viewMode == _waterViewAquarium)
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
                  )
                else
                  _buildSimpleWaterCard(
                    context,
                    intakeForSelectedDate,
                    waterProvider.dailyGoal,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60.0),
                        child: EmptyStateWidget(
                          icon: Icons.water_drop,
                          title: 'Aún no has añadido agua hoy',
                          subtitle: 'Comienza a registrar tu hidratación',
                          iconColor: Colors.blue[400],
                          padding: const EdgeInsets.all(24),
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
      },
    );
  }

  Widget _buildSimpleWaterCard(
    BuildContext context,
    double intake,
    double goal,
  ) {
    final theme = Theme.of(context);
    final progress = goal <= 0 ? 0.0 : (intake / goal).clamp(0.0, 1.0);
    final remaining = (goal - intake).clamp(0.0, double.infinity);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Progreso de hoy',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildWaterStatChip(
                  context,
                  label: 'Actual',
                  value: '${intake.toInt()} ml',
                  fillProgress: progress,
                ),
                const SizedBox(width: 8),
                _buildWaterStatChip(
                  context,
                  label: 'Meta',
                  value: '${goal.toInt()} ml',
                  fillProgress: 1.0,
                ),
                const SizedBox(width: 8),
                _buildWaterStatChip(
                  context,
                  label: remaining == 0 ? 'Logrado' : 'Faltan',
                  value: remaining == 0 ? '✓' : '${remaining.toInt()} ml',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining == 0
                  ? 'Meta alcanzada'
                  : 'Faltan ${remaining.toInt()} ml para la meta',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWaterStatChip(
    BuildContext context, {
    required String label,
    required String value,
    double? fillProgress,
  }) {
    final theme = Theme.of(context);
    final fill = (fillProgress ?? 0).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: fillProgress == null
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primary.withValues(alpha: 0.15 + (0.45 * fill)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
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
