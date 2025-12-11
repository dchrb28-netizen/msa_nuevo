# 🔑 Guía para Obtener Nueva API Key de ExerciseDB

## Paso 1: Registrarse en RapidAPI

1. Ve a: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
2. Haz clic en **"Sign Up"** o **"Log In"**
3. Crea una cuenta (puedes usar Google/GitHub)

## Paso 2: Suscribirse al Plan Gratuito

1. En la página de ExerciseDB, selecciona la pestaña **"Pricing"**
2. Elige el plan **"Basic (Free)"**:
   - ✅ 0$/mes
   - ✅ 10,000 requests/mes
   - ✅ Acceso completo a 1300+ ejercicios con GIFs
3. Haz clic en **"Subscribe"**

## Paso 3: Copiar tu API Key

1. En la página de ExerciseDB, ve a la pestaña **"Code Snippets"**
2. Copia el valor de **`X-RapidAPI-Key`**
3. Se ve algo así: `1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p`

## Paso 4: Actualizar en tu Proyecto

Reemplaza la API key en:

**`lib/services/exercise_api_service.dart`** línea 10:

```dart
static const String _apiKey = 'TU_NUEVA_API_KEY_AQUI';
```

## Paso 5: Descargar GIFs

Una vez actualizada la key, ejecuta:

```bash
python3 download_gifs_from_api.py
```

## 🎯 Alternativas SI NO FUNCIONA:

### Opción A: Usar los 11 GIFs que YA tienes
Los ejercicios principales ya tienen GIF. Los demás mostrarán un ícono representativo.

### Opción B: API Alternativa Gratuita - Wger
Wger API es 100% gratuita sin API key necesaria:
```
https://wger.de/api/v2/exercise/?limit=999
```
No requiere registro, pero los GIFs son de menor calidad.

### Opción C: Descargar manualmente
Busca GIFs en:
- https://giphy.com/search/workout
- https://www.inspireusafoundation.org/exercises/ (muchos ejercicios con GIFs)
- https://fitnessvolt.com/exercise-library/

Guárdalos en `assets/exercise_gifs/` con el nombre correcto (ej: `chest_001.gif`)

## 📊 Estado Actual

Actualmente tienes **11 GIFs funcionando**:
- chest_001, chest_002, chest_003, chest_004
- back_005, back_013
- legs_007, legs_008, legs_014  
- arms_009
- yoga_007

**El código YA está preparado** para mostrar estos GIFs y manejar los faltantes con iconos.

## ✅ Recomendación

Por ahora, **usa la app con los 11 GIFs** que ya tienes. Funcionará perfectamente y los ejercicios sin GIF mostrarán un ícono bonito de fitness.

Cuando tengas tiempo, renueva la API key para descargar el resto.
