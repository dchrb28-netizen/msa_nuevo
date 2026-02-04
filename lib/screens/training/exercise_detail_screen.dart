import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determina si hay alguna recomendación general que mostrar.
    final bool hasGeneralRecommendations =
        exercise.recommendations != null &&
        exercise.recommendations!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Descripción o explicación del ejercicio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cómo hacer este ejercicio',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _generateDetailedDescription(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoCard(theme),
            const SizedBox(height: 24),

            _buildRecommendationsCard(theme),
            const SizedBox(height: 24),

            // Solo muestra la tarjeta si hay recomendaciones generales.
            if (hasGeneralRecommendations)
              _buildGeneralRecommendationsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              theme,
              Icons.fitness_center,
              'Grupo Muscular',
              exercise.muscleGroup ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.construction,
              'Equipamiento',
              exercise.equipment ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.leaderboard,
              'Dificultad',
              exercise.difficulty ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              theme,
              Icons.repeat,
              'Medición',
              (exercise.measurement ?? 'reps') == 'reps'
                  ? 'Repeticiones'
                  : 'Tiempo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendaciones por Nivel',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationRow(
              theme,
              'Principiante',
              exercise.beginnerSets ?? 'N/A',
              exercise.beginnerReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
            const Divider(height: 16),
            _buildRecommendationRow(
              theme,
              'Intermedio',
              exercise.intermediateSets ?? 'N/A',
              exercise.intermediateReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
            const Divider(height: 16),
            _buildRecommendationRow(
              theme,
              'Avanzado',
              exercise.advancedSets ?? 'N/A',
              exercise.advancedReps ?? 'N/A',
              exercise.measurement ?? 'reps',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralRecommendationsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendaciones Generales',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(exercise.recommendations!, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(
    ThemeData theme,
    String level,
    String sets,
    String reps,
    String measurement,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          level,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (sets != 'N/A')
              Text('Series: $sets', style: theme.textTheme.bodyLarge),
            Text(
              '${measurement == 'reps' ? 'Reps' : 'Duración'}: $reps',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _generateDetailedDescription() {
    final name = exercise.name.toLowerCase();
    final muscleGroup = exercise.muscleGroup ?? 'músculos';
    final equipment = exercise.equipment ?? 'tu propio peso';
    
    // Instrucciones específicas por tipo de ejercicio
    String specificInstructions = _getSpecificInstructions();
    
    return '''CÓMO HACER ESTE EJERCICIO:

$specificInstructions

MÚSCULOS TRABAJADOS: $muscleGroup
EQUIPO: $equipment

CONSEJOS:
• Realiza el movimiento de forma controlada
• Evita usar impulso - enfócate en la tensión muscular
• Respira constantemente durante el ejercicio
• Si sientes dolor, detente inmediatamente'''.trim();
  }

  String _getSpecificInstructions() {
    final name = exercise.name.toLowerCase();
    final description = (exercise.description ?? '').trim();
    final recommendations = (exercise.recommendations ?? '').trim();
    final equipment = (exercise.equipment ?? '').toLowerCase();
    final measurement = (exercise.measurement ?? '').toLowerCase();
    final type = (exercise.type ?? '').toLowerCase();
    
    // Instrucciones personalizadas por ejercicio
    if (name.contains('flexion')) {
      return '''1. Colócate boca abajo con las manos bajo los hombros
2. Mantén el cuerpo recto de cabeza a pies
3. Baja lentamente doblando los codos
4. Baja hasta que el pecho casi toque el suelo
5. Empuja hacia arriba hasta la posición inicial
6. Exhala al subir, inhala al bajar''';
    } else if (name.contains('sentadilla') || name.contains('squat')) {
      return '''1. Colócate de pie con los pies al ancho de hombros
2. Baja lentamente bajando caderas y doblando rodillas
3. Mantén el pecho hacia adelante y la espalda recta
4. Baja hasta que los muslos estén paralelos al suelo
5. Empuja con los talones para volver a subir
6. Exhala al subir, inhala al bajar''';
    } else if (name.contains('plancha lateral') || name.contains('side plank')) {
      return '''1. Acuéstate de lado con el codo debajo del hombro
2. Apoya los pies uno sobre otro o escalonados
3. Eleva las caderas formando una línea recta de cabeza a pies
4. Mantén el abdomen y oblicuos contraídos
5. Evita rotar el torso hacia adelante o atrás
6. Cambia de lado al finalizar el tiempo''';
    } else if (name.contains('plancha') || name.contains('plank')) {
      return '''1. Colócate boca abajo apoyado en codos y punteras
2. Mantén el cuerpo recto de cabeza a talones
3. Aprieta el core (abdomen) durante todo el tiempo
4. Evita dejar caer las caderas
5. Mantén la posición el tiempo indicado
6. Respira lentamente y mantén tensión constante''';
    } else if (name.contains('abdomen') || name.contains('crunch')) {
      return '''1. Recuéstate boca arriba con rodillas dobladas
2. Coloca las manos detrás de la cabeza sin jalarte
3. Levanta los hombros del suelo contrayendo abdominales
4. Evita usar el cuello para tirar hacia arriba
5. Baja lentamente a la posición inicial
6. Exhala al subir, inhala al bajar''';
    } else if (name.contains('sentadilla bulgara') || name.contains('bulgarian')) {
      return '''1. Coloca un pie atrás apoyado en una silla o banco
2. Estira la pierna trasera
3. Baja doblando la rodilla delantera
4. Baja hasta formar un ángulo de 90 grados
5. Empuja con la pierna delantera para subir
6. Completa todas las repeticiones, luego cambia de pierna''';
    } else if (name.contains('remo') || name.contains('row')) {
      return '''1. Inclínate hacia adelante con las rodillas ligeramente flexionadas
2. Mantén la espalda recta
3. Tira los codos hacia atrás llevando peso hacia tu cuerpo
4. Aprieta la espalda en la posición superior
5. Baja lentamente con control
6. Exhala al tirar, inhala al soltar''';
    } else if (name.contains('press')) {
      return '''1. Colócate acostado o sentado según el ejercicio
2. Sostén el peso a la altura del pecho
3. Empuja hacia arriba completamente
4. Evita bloquear los codos en la parte superior
5. Baja lentamente con control
6. Exhala al empujar, inhala al bajar''';
    } else if (name.contains('tríceps')) {
      return '''1. Colócate en posición según el movimiento
2. Flexiona solo los codos, mantén los brazos quietos
3. Baja lentamente el peso
4. Siente la tensión en los tríceps
5. Sube llevando los codos a la extensión completa
6. Exhala al extender, inhala al bajar''';
    } else if (name.contains('bíceps')) {
      return '''1. Colócate de pie con pies al ancho de hombros
2. Sostén el peso con brazos extendidos
3. Flexiona los codos llevando peso hacia los hombros
4. Mantén los codos pegados al cuerpo
5. Baja lentamente con control
6. Exhala al levantar, inhala al bajar''';
    } else if (name.contains('dominio') || name.contains('pull')) {
      return '''1. Agárrate de la barra con las manos al ancho de hombros
2. Mantén el cuerpo recto
3. Tira hacia arriba doblando los codos
4. Sube hasta que tu barbilla pase la barra
5. Baja lentamente con control
6. Exhala al subir, inhala al bajar''';
    }

    if (type.contains('yoga') || (exercise.muscleGroup ?? '').toLowerCase() == 'yoga') {
      final postura = exercise.name;
      return '''1. Colócate en la postura de $postura guiándote por la imagen
  2. Alinea el cuerpo con una base firme y estable
  3. Mantén la respiración lenta y profunda durante la posición
  4. Mantén la postura el tiempo indicado y sal con control
  ${recommendations.isNotEmpty ? '5. $recommendations' : '5. Evita tensiones en cuello y hombros'}''';
    }
    
    // Instrucción genérica si no coincide con ninguna
    final isFloor = description.toLowerCase().contains('suelo') ||
      description.toLowerCase().contains('tumb') ||
      equipment.contains('mat') ||
      equipment.contains('colchoneta');
    final isSeated = description.toLowerCase().contains('sentad');

    final basePosition = isSeated
      ? 'Siéntate con la espalda recta y el core activo.'
      : isFloor
        ? 'Colócate en el suelo con la espalda neutra y el core activo.'
        : 'Ponte de pie con pies al ancho de hombros y postura erguida.';

    final equipmentNote = (equipment.contains('silla') || equipment.contains('banco'))
      ? 'Usa una silla/banco estable como apoyo.'
      : (equipment.isNotEmpty && equipment != 'ninguno')
        ? 'Ten a mano el equipo: ${exercise.equipment}.'
        : '';

    final movement = description.isNotEmpty
      ? 'Movimiento principal: $description'
      : 'Movimiento principal: sigue la trayectoria mostrada en la imagen.';

    final holdNote = measurement == 'time'
      ? 'Mantén la posición el tiempo indicado sin perder la alineación.'
      : 'Completa las repeticiones sin perder la forma.';

    final tips = recommendations.isNotEmpty
      ? recommendations
      : 'Controla el movimiento y evita impulsos.';

    return '''1. $basePosition ${equipmentNote.isNotEmpty ? equipmentNote : ''}
  2. $movement
  3. $holdNote
  4. $tips
  5. Regresa con control a la posición neutral y respira de forma constante''';
  }
}
