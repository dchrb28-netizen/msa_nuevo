import 'package:flutter/material.dart';
import 'package:myapp/services/routine_adjustment_service.dart';

/// Pantalla de confirmación para ajustar rutinas basado en cambio de peso
class RoutineAdjustmentConfirmationScreen extends StatelessWidget {
  final double oldWeight;
  final double newWeight;
  final Map<String, RoutineAdjustment> adjustments;

  const RoutineAdjustmentConfirmationScreen({
    super.key,
    required this.oldWeight,
    required this.newWeight,
    required this.adjustments,
  });

  @override
  Widget build(BuildContext context) {
    final weightChange = newWeight - oldWeight;
    final weightChangePercentage = RoutineAdjustmentService.calculateWeightChangePercentage(
      oldWeight,
      newWeight,
    );
    final isWeightLoss = weightChange < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar Rutinas'),
      ),
      body: Column(
        children: [
          // Header con información del cambio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Icon(
                  isWeightLoss ? Icons.trending_down : Icons.trending_up,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  isWeightLoss ? '¡Has bajado de peso!' : '¡Has ganado peso!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${oldWeight.toStringAsFixed(1)} kg → ${newWeight.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg (${weightChangePercentage > 0 ? '+' : ''}${weightChangePercentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  isWeightLoss
                      ? 'Sugerimos reducir los pesos en tus rutinas proporcionalmente'
                      : 'Sugerimos aumentar los pesos en tus rutinas proporcionalmente',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          
          // Lista de ajustes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adjustments.length,
              itemBuilder: (context, index) {
                final adjustment = adjustments.values.elementAt(index);
                return _buildRoutineCard(context, adjustment);
              },
            ),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No ajustar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => _applyAdjustments(context),
                      child: const Text('Aplicar ajustes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, RoutineAdjustment adjustment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          Icons.fitness_center,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          adjustment.routineName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${adjustment.exercises.length} ejercicios ajustados'),
        children: adjustment.exercises.map((exercise) {
          return ListTile(
            dense: true,
            title: Text(exercise.exerciseName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${exercise.oldWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${exercise.newWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: exercise.difference > 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.differenceText} kg',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: exercise.difference > 0 ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _applyAdjustments(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ajustando rutinas...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final updatedCount = await RoutineAdjustmentService.applyAdjustments(adjustments);
      
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading
        Navigator.pop(context, true); // Cerrar pantalla con éxito
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $updatedCount rutinas ajustadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al ajustar rutinas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
