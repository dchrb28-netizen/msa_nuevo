import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile/create_profile_screen.dart';
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
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Parece que no hay perfiles. ¡Crea uno para empezar a registrar tu progreso o explora la app como invitado!',
                style: textTheme.bodyLarge,
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
                  foregroundColor: colorScheme.secondary,
                  side: BorderSide(color: colorScheme.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
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
      appBar: AppBar(
        title: const Text('Seleccionar Perfil'),
        backgroundColor: Colors.transparent, // Make AppBar transparent to see the background
        elevation: 0,
        foregroundColor: themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black,
      ),
      body: userProvider.users.isEmpty
          ? noProfilesWidget()
          : profilesListWidget(),
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
