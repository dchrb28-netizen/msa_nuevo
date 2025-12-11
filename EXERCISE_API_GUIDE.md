# API de Ejercicios - ExerciseDB

## 🔑 Configuración

1. **Registrarse en RapidAPI:**
   - Ir a: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
   - Crear cuenta gratuita
   - Suscribirse al plan **Basic (Gratuito)**

2. **Obtener API Key:**
   - En la página de ExerciseDB, copiar tu API Key
   - Reemplazar `TU_API_KEY_AQUI` en `lib/services/exercise_api_service.dart`

## 📊 Plan Gratuito

- **Requests:** 500 por día
- **Ejercicios:** 1300+
- **GIFs:** Alta calidad
- **Sin tarjeta de crédito**

## 🎯 Características

### Endpoints Disponibles:

1. **Todos los ejercicios** (con límite)
   ```dart
   await ExerciseApiService.fetchExercises(limit: 50);
   ```

2. **Por grupo muscular**
   ```dart
   await ExerciseApiService.fetchByBodyPart('chest');
   // Opciones: chest, back, shoulders, arms, legs, cardio, etc.
   ```

3. **Por equipo**
   ```dart
   await ExerciseApiService.fetchByEquipment('body weight');
   // Opciones: body weight, dumbbell, barbell, cable, etc.
   ```

4. **Por músculo objetivo**
   ```dart
   await ExerciseApiService.fetchByTarget('biceps');
   // Opciones: abs, biceps, triceps, pectorals, quads, etc.
   ```

## 🖼️ GIFs

Cada ejercicio incluye:
- **gifUrl**: URL del GIF animado mostrando la técnica correcta
- Alta calidad, fondo transparente
- Ángulo óptimo para entender el movimiento

## 🌐 Alternativas Gratuitas

Si ExerciseDB no funciona, considera:

### 1. **Wger API** (Completamente gratis, sin límites)
```
Base URL: https://wger.de/api/v2/
Ejercicios: 300+
GIFs: Algunos tienen imágenes
Sin API Key necesaria
```

### 2. **API-SPORTS Exercises** (100 requests/día gratis)
```
RapidAPI: api-sports.io
Ejercicios: 1000+
Requiere API Key de RapidAPI
```

### 3. **FitBod API** (Beta, gratis)
```
Ejercicios: 500+
Enfoque en entrenamientos personalizados
```

## 📝 Ejemplo de Uso

```dart
// En tu pantalla de ejercicios
class ExerciseLibraryScreen extends StatefulWidget {
  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<Exercise> _exercises = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _loading = true);
    try {
      // Cargar ejercicios de peso corporal
      final exercises = await ExerciseApiService.fetchByEquipment('body weight');
      setState(() {
        _exercises = exercises;
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return ListTile(
          leading: Image.network(
            exercise.imageUrl!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text(exercise.name),
          subtitle: Text(exercise.muscleGroup),
        );
      },
    );
  }
}
```

## 💡 Recomendaciones

1. **Cachear datos:** Guarda ejercicios en Hive para uso offline
2. **Límite de requests:** No exceder 500/día en plan gratuito
3. **Combinar con ejercicios locales:** Usar API solo para descubrir nuevos ejercicios
4. **Imágenes:** Los GIFs se cargan rápido pero considera cachearlos

## 🚀 Implementación Sugerida

1. Mantener lista de ejercicios local (`exercise_list.dart`)
2. Agregar botón "Descubrir más ejercicios" 
3. Buscar en API y permitir guardar favoritos
4. Guardar favoritos en Hive para uso offline
