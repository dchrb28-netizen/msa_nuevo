# Guía de Uso: Marca de Agua Luna Mascota

## 🎨 Descripción

El widget `LunaWatermark` permite agregar la mascota Luna como marca de agua en cualquier pantalla de la aplicación. Se adapta automáticamente al tema claro/oscuro.

## 📦 Ubicación

- **Widget:** `lib/widgets/luna_watermark.dart`
- **Imágenes:** `assets/luna_png/`

## 🖼️ Tipos de Imágenes Disponibles

Cada tipo tiene dos versiones:
- `_b.png` → Tema oscuro (black background/fondo negro)
- `_w.png` → Tema claro (white background/fondo blanco)

### Tipos Disponibles:

| Tipo | Descripción | Uso Recomendado |
|------|-------------|-----------------|
| `LunaType.agua` | Luna con tema de agua | Pantalla de registro de agua |
| `LunaType.ayuno` | Luna en postura de ayuno | Pantalla de ayuno intermitente |
| `LunaType.comida` | Luna con comida | Pantallas de nutrición/comidas |
| `LunaType.configuracion` | Luna con engranajes | Pantalla de configuración |
| `LunaType.entrenamiento` | Luna haciendo ejercicio | Pantallas de entrenamiento |
| `LunaType.inicio` | Luna saludando | Dashboard/pantalla principal |
| `LunaType.lista` | Luna con checklist | Pantallas de listas/tareas |
| `LunaType.medida` | Luna con cinta métrica | Pantalla de medidas corporales |
| `LunaType.menus` | Luna con menú | Pantalla de menús |
| `LunaType.objetivos` | Luna con meta | Pantalla de objetivos/metas |
| `LunaType.perfil` | Luna neutral | Pantalla de perfil |
| `LunaType.progreso` | Luna celebrando | Pantalla de progreso |
| `LunaType.recompensa` | Luna con trofeo | Pantalla de logros/recompensas |
| `LunaType.recordatorios` | Luna con campana | Pantalla de recordatorios |
| `LunaType.splash` | Luna especial | Pantalla de inicio/splash |

## 🚀 Uso Básico

### 1. Importar el Widget

```dart
import 'package:myapp/widgets/luna_watermark.dart';
```

### 2. Agregar la Marca de Agua

```dart
Stack(
  children: [
    // Marca de agua de Luna
    const LunaWatermark(
      type: LunaType.agua,
      opacity: 0.15,
      size: 250,
      alignment: Alignment.center,
    ),
    // Tu contenido aquí
    YourContent(),
  ],
)
```

## ⚙️ Parámetros

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `type` | `LunaType` | **Requerido** | Tipo de imagen de Luna |
| `opacity` | `double` | `0.15` | Opacidad (0.0 a 1.0) |
| `size` | `double` | `200` | Tamaño en píxeles |
| `alignment` | `Alignment` | `Alignment.center` | Posición en pantalla |

### Valores de Alignment Comunes:

```dart
Alignment.center          // Centro
Alignment.topCenter       // Arriba centro
Alignment.bottomCenter    // Abajo centro
Alignment.centerLeft      // Izquierda centro
Alignment.centerRight     // Derecha centro
Alignment(0.7, 0.3)       // Personalizado (x, y de -1.0 a 1.0)
```

## 📝 Ejemplos de Implementación

### Ejemplo 1: Pantalla Vacía (Más Visible)

```dart
Stack(
  children: [
    if (items.isEmpty)
      const LunaWatermark(
        type: LunaType.lista,
        opacity: 0.18,  // Más visible
        size: 280,
        alignment: Alignment.center,
      ),
    if (items.isEmpty)
      const Center(child: Text('No hay elementos')),
    else
      ListView.builder(/* ... */),
  ],
)
```

### Ejemplo 2: Pantalla con Contenido (Más Sutil)

```dart
Stack(
  children: [
    // Marca de agua sutil en esquina
    const LunaWatermark(
      type: LunaType.entrenamiento,
      opacity: 0.08,  // Muy sutil
      size: 180,
      alignment: Alignment(0.8, 0.6),  // Esquina inferior derecha
    ),
    // Contenido principal
    YourContent(),
  ],
)
```

### Ejemplo 3: Condición Dual

```dart
Stack(
  children: [
    // Más visible cuando vacío
    if (logs.isEmpty)
      const LunaWatermark(
        type: LunaType.agua,
        opacity: 0.15,
        size: 280,
        alignment: Alignment.center,
      ),
    // Sutil cuando hay contenido
    if (logs.isNotEmpty)
      const LunaWatermark(
        type: LunaType.agua,
        opacity: 0.08,
        size: 200,
        alignment: Alignment(0.7, 0.3),
      ),
    // Contenido
    YourListView(),
  ],
)
```

### Ejemplo 4: Scaffold Completo

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Stack(
      children: [
        const LunaWatermark(
          type: LunaType.progreso,
          opacity: 0.06,
          size: 300,
          alignment: Alignment(0.0, 0.4),
        ),
        SingleChildScrollView(
          child: YourContent(),
        ),
      ],
    ),
  );
}
```

## 🎯 Recomendaciones de Opacidad

| Situación | Opacidad Recomendada |
|-----------|---------------------|
| Pantalla vacía (sin contenido) | `0.15 - 0.20` |
| Pantalla con poco contenido | `0.10 - 0.15` |
| Pantalla con mucho contenido | `0.06 - 0.10` |
| Fondo oscuro | `0.08 - 0.12` |
| Fondo claro | `0.10 - 0.18` |

## 🎨 Recomendaciones de Tamaño

| Posición | Tamaño Recomendado |
|----------|-------------------|
| Centro (sin contenido) | `250 - 300px` |
| Esquina con contenido | `150 - 200px` |
| Fondo completo | `300 - 400px` |

## ✅ Pantallas Ya Implementadas

- ✅ **Water Today View** (`water_today_view.dart`)
  - Tipo: `LunaType.agua`
  - Opacidad dual: 0.15 (vacío) / 0.08 (con datos)
  
- ✅ **Intermittent Fasting** (`intermittent_fasting_screen.dart`)
  - Tipo: `LunaType.ayuno`
  - Opacidad: 0.08
  
- ✅ **Dashboard** (`dashboard_screen.dart`)
  - Tipo: `LunaType.inicio`
  - Opacidad: 0.06

## 🔄 Próximas Pantallas Sugeridas

### Alta Prioridad:
- **Training Screen** → `LunaType.entrenamiento`
- **Profile Screen** → `LunaType.perfil`
- **Rewards Screen** → `LunaType.recompensa`
- **Nutrition Screen** → `LunaType.comida`
- **Goals Screen** → `LunaType.objetivos`

### Media Prioridad:
- **Settings Screen** → `LunaType.configuracion`
- **Reminders Screen** → `LunaType.recordatorios`
- **Measurements Screen** → `LunaType.medida`
- **Menu Planning** → `LunaType.menus`

### Baja Prioridad:
- **Logs Screen** → `LunaType.lista`
- **Progress Screen** → `LunaType.progreso`

## 🐛 Solución de Problemas

### La imagen no aparece:
1. Verificar que el archivo exista en `assets/luna_png/`
2. Comprobar que el `pubspec.yaml` incluya: `- assets/luna_png/`
3. Ejecutar `flutter pub get`
4. Hacer hot restart (no hot reload)

### La opacidad es muy alta/baja:
- Ajustar el parámetro `opacity` entre 0.05 y 0.20
- Probar en ambos temas (claro/oscuro)

### La imagen obstruye el contenido:
- Reducir `opacity` a 0.08 o menos
- Cambiar `alignment` a una esquina: `Alignment(0.8, 0.6)`
- Reducir `size` a 150-180

## 🎓 Buenas Prácticas

1. **Usar condiciones para visibilidad**:
   ```dart
   if (shouldShowWatermark) const LunaWatermark(...)
   ```

2. **Opacidad más alta cuando vacío**:
   ```dart
   opacity: items.isEmpty ? 0.15 : 0.08
   ```

3. **Posicionar estratégicamente**:
   - Centro para pantallas vacías
   - Esquinas para pantallas con contenido

4. **Tamaño proporcional**:
   - Más grande para pantallas amplias
   - Más pequeño en esquinas o con mucho contenido

5. **Consistencia temática**:
   - Usar el tipo de Luna apropiado para cada sección
   - Mantener opacidades similares en pantallas relacionadas

## 📚 Documentación Adicional

Para más información sobre las imágenes disponibles, revisar:
- Carpeta: `assets/luna_png/`
- Nomenclatura: `luna_{tipo}_{tema}.png`
- Temas: `_b` (oscuro/black) y `_w` (claro/white)
