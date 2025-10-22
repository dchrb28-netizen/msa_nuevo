import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WeightGoalsScreen extends StatefulWidget {
  const WeightGoalsScreen({super.key});

  @override
  State<WeightGoalsScreen> createState() => _WeightGoalsScreenState();
}

class _WeightGoalsScreenState extends State<WeightGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _weightGoalController;

  bool _isEditing = false;
  double? _imc;
  String _imcCategory = 'N/A';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _weightGoalController = TextEditingController();

    if (user != null && user.weight > 0 && user.height > 0) {
      _updateControllers(user);
      _calculateIMC();
    } else {
      _isEditing = true;
    }

    _weightController.addListener(_calculateIMC);
    _heightController.addListener(_calculateIMC);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: true).user;
    if (user != null && user.weight > 0 && user.height > 0) {
      if (!_isEditing) {
        _updateControllers(user);
        _calculateIMC();
      }
    } else {
      if (!_isEditing) {
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  void _updateControllers(dynamic user) {
    _weightController.text = user.weight.toStringAsFixed(1);
    _heightController.text = user.height.toStringAsFixed(0);
    _weightGoalController.text = user.weightGoal?.toStringAsFixed(1) ?? '';
  }

  @override
  void dispose() {
    _weightController.removeListener(_calculateIMC);
    _heightController.removeListener(_calculateIMC);
    _weightController.dispose();
    _heightController.dispose();
    _weightGoalController.dispose();
    super.dispose();
  }

  void _calculateIMC() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height != null && height > 0 && weight != null && weight > 0) {
      final heightInMeters = height / 100;
      if (mounted) {
        setState(() {
          _imc = weight / (heightInMeters * heightInMeters);
          _imcCategory = _getImcCategory(_imc!);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _imc = null;
          _imcCategory = 'N/A';
        });
      }
    }
  }

  String _getImcCategory(double imc) {
    if (imc < 18.5) return 'Bajo Peso';
    if (imc < 25) return 'Peso Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getCategoryColor(double? imc) {
    if (imc == null) return Colors.grey;
    if (imc < 18.5) return Colors.blue.shade300;
    if (imc < 25) return Colors.green.shade400;
    if (imc < 30) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  void _saveGoals() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user!;

      final updatedUser = currentUser.copyWith(
        weight: double.parse(_weightController.text.replaceAll(',', '.')),
        height: double.parse(_heightController.text.replaceAll(',', '.')),
        weightGoal: double.tryParse(_weightGoalController.text.replaceAll(',', '.')),
      );

      userProvider.updateUser(updatedUser);
      _calculateIMC(); 
      
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Tus datos han sido actualizados!')),
      );
    }
  }
  
  void _showIMCInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline), 
            SizedBox(width: 10),
            Text('¿Qué es el IMC?'),
            ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'El Índice de Masa Corporal (IMC) es una medida que relaciona el peso y la altura de una persona para estimar su grasa corporal.\n\n'
            'Se calcula dividiendo el peso en kilogramos por el cuadrado de la altura en metros (kg/m²).\n\n'
            'Categorías:\n'
            '• Menos de 18.5: Bajo Peso\n'
            '• 18.5 - 24.9: Peso Normal\n'
            '• 25.0 - 29.9: Sobrepeso\n'
            '• 30.0 o más: Obesidad\n\n'
            'Importante: El IMC es una herramienta de referencia y no distingue entre grasa y masa muscular. Siempre es recomendable consultar a un profesional de la salud.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final user = Provider.of<UserProvider>(context).user;
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;
  
  // Comprueba si falta información esencial del perfil
  final isProfileIncomplete = user == null || user.weight <= 0 || user.height <= 0;

  return Scaffold(
    backgroundColor: _isEditing ? Theme.of(context).colorScheme.surface : null,
    body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isEditing
            ? _buildEditView()
            : (isProfileIncomplete ? _buildProfileCompletionMessage(context) : _buildSummaryView()),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: !_isEditing && !isProfileIncomplete
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Actualizar Mis Datos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          )
        : null,
  );
}


  Widget _buildSummaryView() {
    final user = Provider.of<UserProvider>(context).user!;

    return SingleChildScrollView(
      key: const ValueKey('summaryView'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
      child: Column(
        children: [
          _buildIMCGauge(),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Column(
              children: [
                _buildSummaryTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Peso Actual',
                  value: '${user.weight.toStringAsFixed(1)} kg',
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSummaryTile(
                  icon: Icons.height_outlined,
                  title: 'Altura',
                  value: '${user.height.toStringAsFixed(0)} cm',
                ),
                if (user.weightGoal != null && user.weightGoal! > 0)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                if (user.weightGoal != null && user.weightGoal! > 0)
                  _buildSummaryTile(
                    icon: Icons.flag_outlined,
                    title: 'Meta de Peso',
                    value: '${user.weightGoal!.toStringAsFixed(1)} kg',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIMCGauge() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 15,
              maximum: 40,
              showLabels: false,
              showTicks: false,
              axisLineStyle: const AxisLineStyle(thickness: 0.2, thicknessUnit: GaugeSizeUnit.factor),
              pointers: <GaugePointer>[
                if (_imc != null)
                  NeedlePointer(
                    value: _imc!,
                    enableAnimation: true,
                    animationType: AnimationType.easeOutBack,
                    animationDuration: 1200,
                    needleStartWidth: 1,
                    needleEndWidth: 5,
                    needleColor: colorScheme.onSurface,
                    knobStyle: KnobStyle(knobRadius: 0.08, sizeUnit: GaugeSizeUnit.factor, color: colorScheme.onSurface),
                  ),
              ],
              ranges: <GaugeRange>[
                GaugeRange(startValue: 15, endValue: 18.5, color: Colors.blue.shade200, label: 'Bajo', labelStyle: const GaugeTextStyle(fontWeight: FontWeight.bold)),
                GaugeRange(startValue: 18.5, endValue: 25, color: Colors.green.shade300, label: 'Normal', labelStyle: const GaugeTextStyle(fontWeight: FontWeight.bold)),
                GaugeRange(startValue: 25, endValue: 30, color: Colors.orange.shade300, label: 'Alto', labelStyle: const GaugeTextStyle(fontWeight: FontWeight.bold)),
                GaugeRange(startValue: 30, endValue: 40, color: Colors.red.shade300, label: 'Obeso', labelStyle: const GaugeTextStyle(fontWeight: FontWeight.bold)),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                       Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('IMC', style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.info_outline, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                            onPressed: _showIMCInfoDialog,
                            padding: const EdgeInsets.only(left: 8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _imc?.toStringAsFixed(1) ?? '--',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: _getCategoryColor(_imc)),
                      ),
                      Text(
                        _imcCategory,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _getCategoryColor(_imc), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.1,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile({required IconData icon, required String title, required String value, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditView() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final isInitialSetup = user == null || user.weight <= 0 || user.height <= 0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        key: const ValueKey('editView'),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isInitialSetup ? 'Completa tu Perfil' : 'Actualiza tus Datos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            if (isInitialSetup)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Text(
                  'Necesitamos tu peso y altura para calcular tu IMC y establecer metas realistas.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _weightController,
              label: 'Mi Peso Actual (kg)',
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _heightController,
              label: 'Mi Altura (cm)',
              icon: Icons.height_outlined,
            ),
            const SizedBox(height: 30),
            Text('Mi Meta de Peso', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _weightGoalController,
              label: 'Mi Peso Ideal (kg) (Opcional)',
              icon: Icons.flag_outlined,
              isRequired: false,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _saveGoals,
              icon: const Icon(Icons.save_outlined),
              label: Text(isInitialSetup ? 'Guardar y Continuar' : 'Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (!isInitialSetup)
            const SizedBox(height: 10),
             if (!isInitialSetup)
             TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text('Cancelar'))
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: (value) {
        if (!isRequired && (value == null || value.isEmpty)) return null;
        if (value == null || value.isEmpty) return 'Este campo es obligatorio';
        if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Introduce un número válido';
        return null;
      },
    );
  }

  Widget _buildProfileCompletionMessage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin_circle_outlined, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              'Completa tu Perfil',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Por favor, añade tu peso y altura para poder calcular tu IMC y establecer tus objetivos de peso.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              label: const Text('Añadir Mis Datos'),
            )
          ],
        ),
      ),
    );
  }
}
