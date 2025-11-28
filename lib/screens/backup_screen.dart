import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';
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
    try {
      final success = await _backupService.exportBackup();
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('✅ Respaldo guardado exitosamente en Descargas.'), backgroundColor: Colors.green),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('❌ No se pudo guardar. Revisa los permisos de almacenamiento.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('❌ Error inesperado al exportar: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    setState(() => _isLoading = true);

    try {
      final status = await _backupService.importBackup();

      switch (status) {
        case ImportStatus.success:
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Restauración completada. Reiniciando la app...'), backgroundColor: Colors.green),
          );
          await Future.delayed(const Duration(seconds: 2));
          await userProvider.loadUsers();
          if (navigator.mounted) {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
          break;
        case ImportStatus.cancelled:
           scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Operación cancelada.'), backgroundColor: Colors.grey),
          );
          break;
        case ImportStatus.invalidFile:
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Error: El archivo no es un respaldo válido o está corrupto.'), backgroundColor: Colors.red),
          );
          break;
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error crítico durante la importación: $e'), backgroundColor: Colors.red),
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
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Procesando respaldo...')
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
                  const Text('Respaldo Local', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  const Text('Exporta todos tus datos a un archivo JSON para guardar un respaldo local, o importa un respaldo previo para restaurar tus datos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Exportar Respaldo'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _importBackup,
                    icon: const Icon(Icons.download_for_offline_sharp),
                    label: const Text('Importar Respaldo'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.blue, width: 2)),
                  ),
                  const Spacer(),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 30),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text('Al importar un respaldo, todos los datos actuales serán reemplazados. Se recomienda exportar uno primero.', textAlign: TextAlign.left),
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
