import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile/create_profile_screen.dart';
import 'package:myapp/services/backup_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Use a background that is pure white or black for contrast
    final backgroundColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;

    final welcomeImage = themeProvider.themeMode == ThemeMode.dark
        ? 'assets/luna_png/luna_splash_b.png'
        : 'assets/luna_png/luna_splash_w.png';

    // Define explicit colors for better visibility
    final bodyTextColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[300]
        : Colors.black.withValues(alpha: 0.7);

    final outlinedButtonForegroundColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[300]
        : Colors.black.withValues(alpha: 0.7);

    final outlinedButtonBorderColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[700]
        : Colors.grey[400];

    void continueAsGuest() {
      userProvider.loginAsGuest();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }

    void navigateToCreateProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
      );
    }

    Future<void> restoreBackup() async {
      try {
        // Mostrar indicador de carga
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final backupService = BackupService();
        final success = await backupService.importBackup();
        
        if (context.mounted) {
          // Cerrar indicador de carga
          Navigator.of(context).pop();
          
          if (success) {
            // Recargar perfiles después de restaurar
            userProvider.loadUsers();
            
            // Esperar un momento para que se carguen los datos
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (context.mounted) {
              // Si hay perfiles después de restaurar, entrar automáticamente
              if (userProvider.users.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Respaldo restaurado - Entrando a la app...'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Seleccionar el primer perfil y navegar
                userProvider.switchUser(userProvider.users.first.id);
                
                // Navegar a MainScreen
                await Future.delayed(const Duration(milliseconds: 500));
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                }
              } else {
                // Si no hay perfiles, solo mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Respaldo restaurado correctamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error al restaurar el respaldo'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Cerrar indicador de carga si está abierto
        if (context.mounted) {
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al restaurar: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // The main content when no profiles exist
    Widget noProfilesWidget() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                welcomeImage,
                height: 150,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Bienvenido a MiSaludActiva!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Parece que no hay perfiles. ¡Crea uno para empezar a registrar tu progreso o explora la app como invitado!',
                style: textTheme.bodyLarge?.copyWith(
                  color: bodyTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: Icon(PhosphorIcons.userPlus(PhosphorIconsStyle.bold)),
                label: const Text('Crear Perfil'),
                onPressed: navigateToCreateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
                label: const Text('Continuar como invitado'),
                onPressed: continueAsGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: outlinedButtonForegroundColor,
                  side: BorderSide(color: outlinedButtonBorderColor!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.regular)),
                label: const Text('Recuperar Respaldo'),
                onPressed: restoreBackup,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The main content when profiles exist
    Widget profilesListWidget() {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for the FAB
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
            ),
            title: Text(user.name, style: textTheme.titleMedium),
            onTap: () {
              userProvider.switchUser(user.id);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            trailing: IconButton(
              icon: Icon(PhosphorIcons.trash(PhosphorIconsStyle.regular), color: colorScheme.error),
              tooltip: 'Eliminar Perfil',
              onPressed: () => _confirmDelete(context, userProvider, user),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor, // Apply the explicit background color
      body: SafeArea(
        child: userProvider.users.isEmpty
            ? noProfilesWidget()
            : profilesListWidget(),
      ),
      floatingActionButton: userProvider.users.isEmpty
          ? null // Hide FAB when there are no profiles
          : FloatingActionButton.extended(
              onPressed: navigateToCreateProfile,
              label: const Text('Añadir Perfil'),
              icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserProvider userProvider,
    User user,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar el perfil de "${user.name}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              onPressed: () {
                userProvider.deleteUser(user.id);
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}