import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/profile/create_profile_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Perfil'),
      ),
      body: ListView.builder(
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
            ),
            title: Text(user.name),
            onTap: () {
              userProvider.switchUser(user.id);
              Navigator.pushReplacementNamed(context, '/');
            },
            trailing: IconButton(
              icon: Icon(PhosphorIcons.trash(PhosphorIconsStyle.regular), color: colorScheme.error),
              tooltip: 'Eliminar Perfil',
              onPressed: () => _confirmDelete(context, userProvider, user),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
          );
        },
        tooltip: 'Añadir Perfil',
        child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
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
