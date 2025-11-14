import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Perfil'),
      ),
      body: ListView.builder(
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return ListTile(
            title: Text(user.name),
            onTap: () {
              userProvider.switchUser(user.id);
              Navigator.pushReplacementNamed(context, '/');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
