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
      name: 'Anabólica',
      description: 'Justo después de comer, tu cuerpo está en modo \"construcción\". Está digiriendo y absorbiendo los nutrientes que le acabas de dar, usando la glucosa como su principal fuente de energía. ¡Es el momento de reponer fuerzas!',
      startHour: 0,
      endHour: 4,
      icon: Icons.wb_sunny_outlined,
    ),
    FastingPhase(
      name: 'Catabólica',
      description: 'Tu cuerpo ha terminado de procesar tu última comida y empieza a usar las reservas de glucógeno (azúcar almacenado). Estás en la transición para convertirte en una máquina de quemar grasa.',
      startHour: 4,
      endHour: 12,
      icon: Icons.directions_run,
    ),
    FastingPhase(
      name: 'Quema de Grasa',
      description: '¡Felicidades, has llegado al primer gran hito! Tus reservas de glucógeno están casi agotadas. Para obtener energía, tu cuerpo empieza a quemar la grasa almacenada, produciendo cetonas. ¡Estás oficialmente en cetosis!',
      startHour: 12,
      endHour: 18,
      icon: Icons.local_fire_department_outlined,
    ),
    FastingPhase(
      name: 'Autofagia',
      description: 'Aquí empieza la magia celular. Tu cuerpo activa un proceso de \"limpieza interna\" llamado autofagia. Las células dañadas y viejas se reciclan para crear otras nuevas y más fuertes. Es como una renovación para tu organismo.',
      startHour: 18,
      endHour: 24,
      icon: Icons.recycling_outlined,
    ),
    FastingPhase(
      name: 'Pico de H. Crecimiento',
      description: 'Tu cuerpo aumenta significativamente la producción de la hormona del crecimiento. Esto ayuda a preservar la masa muscular, reparar tejidos y tiene efectos antienvejecimiento. ¡Estás construyendo un cuerpo más fuerte y resiliente!',
      startHour: 24,
      endHour: 48,
      icon: Icons.trending_up,
    ),
     FastingPhase(
      name: 'Regeneración Celular',
      description: 'En ayunos más largos, el cuerpo potencia la regeneración de células madre, especialmente en el sistema inmune. Esto puede ayudar a reducir la inflamación crónica y fortalecer tus defensas. Es un reseteo completo.',
      startHour: 48,
      endHour: 1000, // Represents a long duration
      icon: Icons.healing_outlined,
    ),
  ];
}
