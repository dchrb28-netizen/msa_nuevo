import 'package:flutter/material.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Sueño'),
      ),
      body: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Noche del ${DateTime.now().subtract(Duration(days: index)).toLocal()} '.split(' ')[0]),
            subtitle: const Text('Duración: 8h 15m, Calidad: 4/5'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to sleep detail screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new sleep log
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
