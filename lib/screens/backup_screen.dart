import 'package:flutter/material.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:provider/provider.dart';
import '../services/backup_service.dart';

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
    try {
      final path = await _backupService.exportBackup();
      if (mounted) {
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Respaldo guardado exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Operación cancelada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar respaldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    setState(() => _isLoading = true);
    try {
      final success = await _backupService.importBackup();
      
      if (success && mounted) {
        // Reinicializar el servicio de logros después de la restauración
        final achievementService = Provider.of<AchievementService>(context, listen: false);
        await achievementService.init();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Respaldo importado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Ir directamente a la pantalla principal, limpiando todo el stack de navegación
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo importar el respaldo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al importar respaldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldo y Restauración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.backup,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Respaldo Local',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exporta todos tus datos a un archivo JSON para guardar un respaldo local, o importa un respaldo previo para restaurar tus datos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Exportar Respaldo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _importBackup,
                    icon: const Icon(Icons.download),
                    label: const Text('Importar Respaldo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Card(
                    color: Colors.amber,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(height: 8),
                          Text(
                            'Importante',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Al importar un respaldo, todos los datos actuales serán reemplazados. Se recomienda exportar un respaldo antes de importar.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
