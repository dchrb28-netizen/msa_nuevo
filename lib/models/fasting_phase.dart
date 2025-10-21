import 'package:flutter/material.dart';

class FastingPhase {
  final String name;
  final String description;
  final int startHour;
  final int endHour;
  final IconData icon;

  const FastingPhase({
    required this.name,
    required this.description,
    required this.startHour,
    required this.endHour,
    required this.icon,
  });

  static const List<FastingPhase> phases = [
    FastingPhase(
      name: 'Fase 1: Anabólica',
      description: 'Tu cuerpo está digiriendo y absorbiendo nutrientes.',
      startHour: 0,
      endHour: 4,
      icon: Icons.wb_sunny_outlined,
    ),
    FastingPhase(
      name: 'Fase 2: Catabólica',
      description: 'El cuerpo agota el glucógeno y busca otras fuentes de energía.',
      startHour: 4,
      endHour: 12,
      icon: Icons.directions_run,
    ),
    FastingPhase(
      name: 'Fase 3: Quema de Grasa (Cetosis)',
      description: 'Agotado el glucógeno, el cuerpo empieza a quemar grasa como combustible.',
      startHour: 12,
      endHour: 18,
      icon: Icons.local_fire_department_outlined,
    ),
    FastingPhase(
      name: 'Fase 4: Autofagia',
      description: 'El cuerpo inicia un proceso de limpieza y reciclaje celular.',
      startHour: 18,
      endHour: 24,
      icon: Icons.recycling_outlined,
    ),
    FastingPhase(
      name: 'Fase 5: Pico de Hormona del Crecimiento',
      description: 'Aumenta la producción de la hormona del crecimiento, beneficiando la masa muscular.',
      startHour: 24,
      endHour: 48,
      icon: Icons.trending_up,
    ),
     FastingPhase(
      name: 'Fase 6: Regeneración Celular',
      description: 'Se promueve la regeneración de células madre y la reducción de la inflamación.',
      startHour: 48,
      endHour: 1000, // Represents a long duration
      icon: Icons.healing_outlined,
    ),
  ];
}
