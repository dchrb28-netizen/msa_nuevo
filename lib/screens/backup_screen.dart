import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/main.dart' show restartApp;
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/meal_plan_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/backup_service.dart';
import 'package:provider/provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final exportStatus = await _backupService.exportBackup();
      if (!mounted) return;

      switch (exportStatus) {
        case ExportStatus.success:
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('✅ Respaldo guardado exitosamente.'),
                backgroundColor: Colors.green),
          );
          break;
        case ExportStatus.webDownloadInitiated:
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('Iniciando la descarga del respaldo...'),
                backgroundColor: Colors.blue),
          );
          break;
        case ExportStatus.cancelled:
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('Operación cancelada por el usuario.'),
                backgroundColor: Colors.grey),
          );
          break;
        case ExportStatus.permissionDenied:
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('Permiso de almacenamiento denegado.'),
                backgroundColor: Colors.orange),
          );
          break;
        case ExportStatus.failure:
          scaffoldMessenger.showSnackBar(
            const SnackBar(
                content: Text('❌ No se pudo guardar el respaldo.'),
                backgroundColor: Colors.red),
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('❌ Error inesperado al exportar: $e'),
            backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);

    try {
      final List<User>? importedUsers = await _backupService.importBackup();

      if (importedUsers == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Operación cancelada o archivo no válido.'),
              backgroundColor: Colors.orange),
        );
      } else {
        // Recargar las preferencias del ThemeProvider después de restaurar
        if (mounted) {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          await themeProvider.loadPreferences();
          if (kDebugMode) print('🎨 ThemeProvider recargado después de restauración');

          final mealPlanProvider = Provider.of<MealPlanProvider>(context, listen: false);
          await mealPlanProvider.reloadFromStorage();
          if (kDebugMode) print('🍽️ MealPlanProvider recargado después de restauración');
        }

        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('✅ Restauración completada. Reiniciando...'),
              backgroundColor: Colors.green),
        );

        // Esperar un momento para que el usuario vea el mensaje
        await Future.delayed(const Duration(milliseconds: 500));

        // Reiniciar la app completamente
        restartApp();
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('❌ Error crítico durante la importación: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBackupItem(String text, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: highlight ? Colors.amber.shade700 : Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 13,
                height: 1.4,
                color: highlight ? Colors.amber.shade900 : Colors.green.shade700,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 80, color: Colors.blue),
                  SizedBox(height: 32),
                  CircularProgressIndicator(strokeWidth: 5),
                  SizedBox(height: 24),
                  Text(
                    'Procesando...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono con gradiente
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.cyan.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_done_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título
                    Text(
                      'Respaldo Local',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Descripción
                    Text(
                      'Protege tus datos exportando un respaldo o restaura tus registros importando uno anterior.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        height: 1.6,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Botón Exportar
                    ElevatedButton.icon(
                      onPressed: _exportBackup,
                      icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                      label: const Text(
                        'Exportar Respaldo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón Importar
                    OutlinedButton.icon(
                      onPressed: _importBackup,
                      icon: Icon(
                        Icons.cloud_download_outlined,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                      label: Text(
                        'Importar Respaldo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue.shade600, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Tarjeta informativa sobre qué se respalda
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.teal.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Datos Respaldados',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildBackupItem('Perfiles y usuarios'),
                            _buildBackupItem('Registros de comida y agua'),
                            _buildBackupItem('Entrenamientos y rutinas'),
                            _buildBackupItem('Mediciones corporales'),
                            _buildBackupItem('Ayunos y meditaciones'),
                            _buildBackupItem('Tareas diarias y recordatorios'),
                            _buildBackupItem('Rachas de todas las actividades', highlight: true),
                            _buildBackupItem('Logros, XP y nivel', highlight: true),
                            _buildBackupItem('Recetas personalizadas'),
                            _buildBackupItem('Preferencias y tema'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tarjeta informativa mejorada
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.cyan.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Importante',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Al importar un respaldo, todos tus datos serán reemplazados. Exporta primero para no perder tu información.',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
