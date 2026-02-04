import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpManualScreen extends StatefulWidget {
  const HelpManualScreen({super.key});

  @override
  State<HelpManualScreen> createState() => _HelpManualScreenState();
}

class _HelpManualScreenState extends State<HelpManualScreen> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _sections = [
    {
      'title': '🏠 Inicio (Dashboard)',
      'content':
          'Pantalla principal que muestra un resumen de tu día:\n\n'
          '• Bienvenida personalizada con tu nombre\n'
          '• Anillos de progreso diario: Agua, Comida y Entrenamientos\n'
          '• Card de entrenamientos: Muestra tu próxima rutina\n'
          '• Card de meditación: Acceso rápido a la meditación del día\n'
          '• Recordatorios pendientes: Tareas y eventos del día\n\n'
          'Desliza los anillos para ver detalles, o toca los cards para acceder a funciones específicas.'
    },
    {
      'title': '💧 Agua',
      'content':
          'Registra y monitorea tu consumo de agua diario:\n\n'
          '• Pecera animada: Visualización progresiva del agua consumida\n'
          '• Botones rápidos: 250ml, 500ml u otro cantidad personalizada\n'
          '• Historial: Revisa tus registros diarios de agua\n'
          '• Meta diaria: Ajustable según tus necesidades\n'
          '• Rachas: Completa la meta diaria para mantener tu racha activa\n\n'
          'Solo puedes registrar agua del día actual o pasado, no de fechas futuras.'
    },
    {
      'title': '🍽️ Menús',
      'content':
          'Planifica tus comidas para la semana:\n\n'
          '• Planificador Semanal: Diseña el menú de los próximos días\n'
          '• Tipos de comida: Desayuno, Almuerzo, Cena y Snacks\n'
          '• Selecciona recetas: Elige de tus recetas guardadas\n'
          '• Vista por día: Organiza qué comerás cada día\n'
          '• Lista de compras: Genera automáticamente según tu menú\n\n'
          'Funciones:\n'
          '• Copia menú: Duplica un menú anterior\n'
          '• Recetas favoritas: Acceso rápido a tus favoritas\n'
          '• Notas: Agrega observaciones a cada comida\n\n'
          'Esto te ayuda a planificar, organizarte y prepararte mejor para la semana.'
    },
    {
      'title': '📝 Registro de Comidas',
      'content':
          'Registra las comidas que realmente consumiste:\n\n'
          '• Toca "Nueva Comida" para registrar una comida realizada\n'
          '• Selecciona el tipo: Desayuno, Almuerzo, Cena o Snack\n'
          '• Agrega descripción de lo que comiste\n'
          '• Hora: Marca cuándo comiste\n'
          '• Calorías (opcional): Registra si lo deseas\n\n'
          'Funciones:\n'
          '• Historial: Ve todas tus comidas registradas\n'
          '• Rachas: Completa comidas para mantener tu racha\n'
          '• Análisis: Revisa tus patrones de alimentación real\n'
          '• Comparación: Compara con lo que planeaste vs consumiste\n\n'
          'Consejos:\n'
          '• Registra inmediatamente después de comer\n'
          '• Sé específico en los detalles\n'
          '• Revisa análisis para mejorar tus hábitos'
    },
    {
      'title': '💪 Entrenamientos',
      'content':
          'Gestiona tus rutinas de ejercicio:\n\n'
          '• Crear rutinas: Diseña tus propias rutinas de entrenamiento\n'
          '• Rutinas preestablecidas: Elige de plantillas profesionales\n'
          '• Registra entrenamientos: Marca ejercicios completados\n'
          '• Historial: Revisa tu historial de entrenamientos\n'
          '• Rachas: Completa entrenamientos consecutivos\n'
          '• Series y repeticiones: Personaliza cada ejercicio\n\n'
          'Los entrenamientos completados cuentan hacia tu racha y te dan experiencia (XP).'
    },
    {
      'title': '📊 Progreso',
      'content':
          'Monitorea tu evolución a lo largo del tiempo:\n\n'
          '• Gráficos de progreso: Visualiza tendencias en agua, comida y entrenamientos\n'
          '• Mediciones corporales: Registra peso, medidas, porcentaje de grasa\n'
          '• Estadísticas: Promedio diario, totales semanales, etc.\n'
          '• Comparativas: Antes y después\n'
          '• Exportar datos: Descarga tus estadísticas\n\n'
          'Revisa regularmente tu progreso para mantenerte motivado.'
    },
    {
      'title': '🎯 Tareas Diarias',
      'content':
          'Gestiona tus tareas y hábitos diarios:\n\n'
          '• Tareas únicas: Para un día específico\n'
          '• Tareas recurrentes: Se repiten cada semana en días específicos\n'
          '• Pendientes: Lista de tareas sin completar\n'
          '• Completadas: Historial de tareas finalizadas\n'
          '• Calendario compacto: Vista semanal expandible a mes completo\n'
          '• Rachas: Mantén tu racha de tareas completadas\n\n'
          'Solo puedes completar tareas de hoy o fechas pasadas.'
    },
    {
      'title': '🏆 Logros y Rachas',
      'content':
          'Sistema de gamificación y recompensas:\n\n'
          '• Logros: Desbloquea logros por completar objetivos\n'
          '• XP (Experiencia): Gana puntos por cada acción\n'
          '• Niveles: Sube de nivel acumulando XP\n'
          '• Rachas: Contador de días consecutivos completando actividades\n'
          '• Récords: Tu mejor racha registrada\n'
          '• Recompensas: Desbloquea marcos especiales para tu perfil\n\n'
          'Cada actividad completada (agua, comida, entrenamiento, tareas) cuenta hacia tus logros.'
    },
    {
      'title': '🧘 Meditación',
      'content':
          'Seguimiento de sesiones de meditación:\n\n'
          '• Sesiones: Crea y registra tus meditaciones\n'
          '• Duración: Especifica cuánto tiempo meditaste\n'
          '• Tipo: Selecciona el tipo de meditación (guiada, libre, etc.)\n'
          '• Historial: Revisa todas tus sesiones\n'
          '• Racha: Mantén una racha meditando consecutivamente\n'
          '• Tiempo total: Ve tu tiempo total acumulado\n\n'
          'La meditación mejora tu bienestar y contribuye a tus rachas.'
    },
    {
      'title': '⏱️ Ayuno',
      'content':
          'Monitorea tus períodos de ayuno:\n\n'
          '• Registra ayunos: Duración y horarios\n'
          '• Tipos de ayuno: 16:8, 14:10, 24h, etc.\n'
          '• Historial: Revisa tus ayunos pasados\n'
          '• Estadísticas: Promedio de duración\n'
          '• Beneficios: Información sobre beneficios del ayuno\n'
          '• Racha: Mantén una racha de ayunos consecutivos\n\n'
          'El ayuno intermitente es una práctica popular para salud y peso.'
    },
    {
      'title': '⚙️ Configuración',
      'content':
          'Personaliza tu experiencia:\n\n'
          '• Tema: Elige entre claro, oscuro o automático\n'
          '• Color de tema: Personaliza el color principal\n'
          '• Metas: Ajusta tus metas diarias de agua, calorías, etc.\n'
          '• Notificaciones: Activa/desactiva recordatorios\n'
          '• Unidades: Cambia entre métrico e imperial\n'
          '• Privacidad: Controla qué datos se comparten\n\n'
          'Personaliza la app según tus preferencias.'
    },
    {
      'title': '💾 Respaldo y Restauración',
      'content':
          'Guarda y restaura tus datos:\n\n'
          '• Exportar: Crea un respaldo de todos tus datos en JSON\n'
          '• Importar: Restaura un respaldo guardado\n'
          '• Ubicación: Selecciona dónde guardar el archivo\n'
          '• Seguridad: Tus datos se guardan de forma segura\n'
          '• Sincronización: Puedes usar respaldos entre dispositivos\n'
          '• Versión: El respaldo incluye la versión de la app\n\n'
          'Realiza respaldos regularmente para no perder tus datos.'
    },
    {
      'title': '👤 Perfil',
      'content':
          'Gestiona tu información personal:\n\n'
          '• Datos básicos: Nombre, edad, género\n'
          '• Medidas: Altura, peso inicial y objetivo\n'
          '• Objetivo: Pérdida de peso, ganancia muscular, etc.\n'
          '• Preferencias: Dieta y alimentos favoritos\n'
          '• Foto: Agrega foto de perfil\n'
          '• Foto de progreso: Documenta tu transformación\n'
          '• Marco: Elige un marco especial para tu perfil\n\n'
          'Mantén tu perfil actualizado para un mejor seguimiento.'
    },
    {
      'title': '📖 Recetas',
      'content':
          'Biblioteca de recetas:\n\n'
          '• Crear recetas: Diseña tus propias recetas\n'
          '• Ingredientes: Lista completa y cantidades\n'
          '• Preparación: Pasos detallados\n'
          '• Favoritas: Marca recetas como favoritas\n'
          '• Información nutricional: Calorías, proteínas, carbohidratos, grasas\n'
          '• Compartir: Comparte recetas con otros\n\n'
          'Personaliza tu recetario con tus mejores creaciones.'
    },
    {
      'title': '🔔 Recordatorios',
      'content':
          'Configurar notificaciones:\n\n'
          '• Recordatorios de agua: Notificaciones para beber agua\n'
          '• Recordatorios de comidas: Alertas para comidas programadas\n'
          '• Recordatorios de tareas: Notificaciones de tareas pendientes\n'
          '• Hora personalizada: Elige cuándo recibir notificaciones\n'
          '• Frecuencia: Cada X horas o a hora específica\n'
          '• Silenciar: Desactiva notificaciones cuando necesites\n\n'
          'Los recordatorios te ayudan a mantener tus hábitos.'
    },
    {
      'title': '📏 Mediciones Corporales',
      'content':
          'Registra tus medidas corporales para seguir tu progreso físico.\n\n'
          'Funciones disponibles:\n'
          '• Agregar nueva medición: Peso, cintura, pecho, brazos, muslos\n'
          '• Historial: Ve cómo han cambiado tus medidas con el tiempo\n'
          '• Rachas: Sigue rachas por completar mediciones\n'
          '• Gráficos: Visualiza tu progreso con gráficos de tendencias\n\n'
          'Consejos:\n'
          '• Mide siempre a la misma hora del día\n'
          '• Usa la misma unidad de medida (kg, cm, etc)\n'
          '• Toma medidas una vez por semana para ver cambios significativos'
    },
    {
      'title': '❓ Preguntas Frecuentes',
      'content':
          '¿Cómo cambio mi meta diaria de agua?\n'
          'Ve a Agua → Toca "Meta Diaria" → Edita la cantidad\n\n'
          '¿Cómo creo una rutina de entrenamiento?\n'
          'Ve a Entrenamientos → Nueva Rutina → Agrega ejercicios\n\n'
          '¿Cómo veo mis logros desbloqueados?\n'
          'Toca el card de Logros en el Dashboard o ve a Rachas → Logros\n\n'
          '¿Puedo recuperar datos si desinstalo la app?\n'
          'Sí, usa Respaldo → Exportar antes, luego Importar después\n\n'
          '¿Cada cuánto se resetean mis rachas?\n'
          'Las rachas se rompen si no completas la actividad en un día'
    },
    {
      'title': '❗ Acerca de la App',
      'content':
          'MSA - Mi Sistema de Salud es tu asistente personal de bienestar.\n\n'
          'Características principales:\n'
          '• Seguimiento integral de salud y hábitos\n'
          '• Sistema de logros y rachas motivador\n'
          '• Almacenamiento seguro local de tus datos\n'
          '• Respaldo y restauración automática\n'
          '• Temas claro y oscuro\n'
          '• Interfaz intuitiva y fácil de usar\n\n'
          'Privacidad:\n'
          'Todos tus datos se guardan localmente en tu dispositivo. No se envía información a servidores externos.\n\n'
          'Versión: 1.0.0\n'
          'Última actualización: 2024\n\n'
          'Para reportar problemas o sugerir mejoras, contacta al soporte técnico.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manual de Usuario',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado informativo
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Bienvenido al Manual',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí encontrarás una guía completa de cada función de la aplicación. Toca cualquier sección para expandirla y conocer más detalles.',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            // Lista de secciones expandibles
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final isExpanded = _expandedIndex == index;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isExpanded ? 4 : 1,
                    child: ExpansionTile(
                      title: Text(
                        _sections[index]['title']!,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : -1;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _sections[index]['content']!,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Consejo: Lee todas las secciones para aprovechar al máximo la app',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Pie de página
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 12),
                  Text(
                    '¿Necesitas más ayuda?',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si tienes dudas o sugerencias, contacta con el equipo de soporte. ¡Nos encanta recibir tu feedback!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
