import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/backup_service.dart';
import 'main_screen.dart';

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
    bool isPermissionGranted = false;

    if (kIsWeb) {
      isPermissionGranted = true;
    } else {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        isPermissionGranted = true;
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text(
                  '❌ Permiso de almacenamiento denegado. No se puede exportar.'),
              backgroundColor: Colors.red),
        );
      }
    }

    if (isPermissionGranted) {
      try {
        final exportStatus = await _backupService.exportBackup();
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
          case ExportStatus.failure:
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                  content: Text('❌ No se pudo guardar el respaldo.'),
                  backgroundColor: Colors.red),
            );
            break;
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('❌ Error inesperado al exportar: $e'),
            backgroundColor: Colors.red));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
            'El permiso de almacenamiento es necesario para guardar el respaldo. Por favor, actívalo en los ajustes de la aplicación.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Abrir Ajustes'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

Future<void> _importBackup() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    setState(() => _isLoading = true);

    try {
      final List<User>? importedUsers = await _backupService.importBackup();

      if (importedUsers == null) {
        // Caso: El usuario canceló la selección de archivo o el archivo era inválido.
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Operación cancelada o archivo no válido.'),
              backgroundColor: Colors.orange),
        );
      } else {
        // Caso: La importación se procesó correctamente.
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('✅ Restauración completada. Reiniciando la app...'),
              backgroundColor: Colors.green),
        );

        // Actualiza el UserProvider con los perfiles importados.
        await userProvider.setUsers(importedUsers);

        // Si se importaron perfiles, selecciona el primero. 
        // Si no, la app mostrará la pantalla de creación de perfiles.
        if (importedUsers.isNotEmpty) {
          await userProvider.switchUser(importedUsers.first.id);
        }

        // Reinicia la navegación de la app para reflejar el nuevo estado.
        if (navigator.mounted) {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldo y Restauración'),
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.backup_sharp, size: 100, color: Colors.blue),
                  const SizedBox(height: 32),
                  const Text('Respaldo Local',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  const Text(
                      'Exporta todos tus datos a un archivo JSON para guardar un respaldo local, o importa un respaldo previo para restaurar tus datos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Exportar Respaldo'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _importBackup,
                    icon: const Icon(Icons.download_for_offline_sharp),
                    label: const Text('Importar Respaldo'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue, width: 2)),
                  ),
                  const Spacer(),
                  Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withAlpha(128),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 30),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                                'Al importar un respaldo, todos los datos actuales serán reemplazados. Se recomienda exportar uno primero.',
                                textAlign: TextAlign.left),
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
