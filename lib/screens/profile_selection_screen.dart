import 'package:flutter/material.dart';
import 'package:myapp/main.dart' show restartApp;
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile/create_profile_screen.dart';
import 'package:myapp/services/backup_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {

  // Muestra un SnackBar con un mensaje y color específicos.
  void _showSnackbar(String message, {Color backgroundColor = Colors.red}) {
    if (!mounted) return; // Asegurarse de que el widget esté montado.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // Orquesta el proceso de restauración.
  Future<void> _restoreBackup(UserProvider userProvider) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    
    // Muestra un diálogo de carga.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final backupService = BackupService();
    // Llama al servicio de importación, que ahora devuelve una lista de usuarios o null.
    final List<User>? importedUsers = await backupService.importBackup();

    // Cierra el diálogo de carga.
    navigator.pop(); 

    if (importedUsers == null) {
       _showSnackbar('Operación cancelada o archivo no válido.', backgroundColor: Colors.orange);
       return;
    }

    if (importedUsers.isEmpty) {
      _showSnackbar('Restaurado, pero el respaldo no contenía perfiles.', backgroundColor: Colors.orange);
      return;
    }

    // Si la importación fue exitosa y se encontraron usuarios.
    
    // Mostrar mensaje de éxito
    _showSnackbar('✅ Restauración completada. Reiniciando...', backgroundColor: Colors.green);
    
    // Esperar un momento para que el usuario vea el mensaje
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Reiniciar la app completamente
    if (!mounted) return;
    restartApp();
  }

  Future<void> _confirmDelete(UserProvider userProvider, User user) async {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('¿Estás seguro de que quieres eliminar el perfil de "${user.name}"?')]),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              onPressed: () {
                userProvider.deleteUser(user.id);
                Navigator.of(dialogContext).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = themeProvider.themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final welcomeImage = themeProvider.themeMode == ThemeMode.dark ? 'assets/luna_png/luna_splash_b.png' : 'assets/luna_png/luna_splash_w.png';
    final bodyTextColor = themeProvider.themeMode == ThemeMode.dark ? Colors.grey[300] : Colors.black.withAlpha(179);
    final outlinedButtonForegroundColor = themeProvider.themeMode == ThemeMode.dark ? Colors.grey[300] : Colors.black.withAlpha(179);
    final outlinedButtonBorderColor = themeProvider.themeMode == ThemeMode.dark ? Colors.grey[700] : Colors.grey[400];

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
      ).then((_) => setState(() {}));
    }

    Widget noProfilesWidget() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(welcomeImage, height: 150),
              const SizedBox(height: 24),
              Text(
                '¡Bienvenido a MiSaludActiva!',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Parece que no hay perfiles. ¡Crea uno para empezar a registrar tu progreso o explora la app como invitado!',
                style: textTheme.bodyLarge?.copyWith(color: bodyTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: Icon(PhosphorIcons.userPlus(PhosphorIconsStyle.bold)),
                label: const Text('Crear Perfil'),
                onPressed: navigateToCreateProfile,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: textTheme.titleMedium),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
                label: const Text('Continuar como invitado'),
                onPressed: continueAsGuest,
                style: OutlinedButton.styleFrom(foregroundColor: outlinedButtonForegroundColor, side: BorderSide(color: outlinedButtonBorderColor!), padding: const EdgeInsets.symmetric(vertical: 16), textStyle: textTheme.titleMedium),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.regular)),
                label: const Text('Recuperar Respaldo'),
                onPressed: () => _restoreBackup(userProvider),
                style: TextButton.styleFrom(foregroundColor: colorScheme.secondary, padding: const EdgeInsets.symmetric(vertical: 12), textStyle: textTheme.titleSmall),
              ),
            ],
          ),
        ),
      );
    }

    Widget profilesListWidget() {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 20, bottom: 80),
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular))),
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
              onPressed: () => _confirmDelete(userProvider, user),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: userProvider.users.isEmpty ? null : AppBar(
        title: const Text('Seleccionar Perfil'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(child: userProvider.users.isEmpty ? noProfilesWidget() : profilesListWidget()),
      floatingActionButton: userProvider.users.isEmpty ? null : FloatingActionButton.extended(
        onPressed: navigateToCreateProfile,
        label: const Text('Añadir Perfil'),
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
      ),
    );
  }
}