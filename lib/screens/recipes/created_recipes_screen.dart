import 'package:flutter/material.dart';
import 'package:myapp/widgets/empty_state_widget.dart';

class CreatedRecipesScreen extends StatelessWidget {
  const CreatedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
      ),
      body: EmptyStateWidget(
        icon: Icons.restaurant_menu,
        title: 'Aún no has creado recetas',
        subtitle: '¡Crea tu primera receta para verla aquí!',
        iconColor: Colors.brown[400],
      ),
    );
  }
}
