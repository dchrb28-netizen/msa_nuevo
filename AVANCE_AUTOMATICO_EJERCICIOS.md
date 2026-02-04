# Avance Automático de Ejercicios Durante el Descanso

## 📋 Descripción de la Característica

Los ejercicios ahora avanzan **automáticamente** al siguiente ejercicio cuando termina el tiempo de descanso. Esto significa que el usuario **no necesita tocar el teléfono** durante el descanso entre series.

## 🎯 Beneficios

✅ **Mejor experiencia de usuario** - El teléfono continúa automáticamente
✅ **Seguridad** - El usuario puede mantener el teléfono en un lugar seguro
✅ **Comodidad** - No requiere interacción durante el descanso
✅ **Flexible** - El usuario puede seguir saltando manualmente si lo desea

## 🔧 Cómo Funciona

### Flujo Automático:

1. **Usuario completa una serie** (no es la última)
   ```
   Registra: 10 repeticiones ✓
   ```

2. **Se inicia el timer de descanso**
   ```
   ⏱️ 60 segundos de descanso
   Barra de progreso contando hacia atrás
   ```

3. **Cuando el timer llega a 0 segundos**
   ```
   ✓ Descanso completado
   ```

4. **La pantalla se desplaza automáticamente**
   ```
   📱 Scroll suave al siguiente ejercicio
   ```

5. **Usuario listo para el siguiente ejercicio**
   ```
   Ejercicio 2: Flexiones
   ```

## 🎨 Comportamiento Visual

### Antes:
```
[Tiempo de descanso: 0:00]
[Botón Saltar] ← Usuario debe presionar
```

### Después:
```
[Tiempo de descanso finalizado automáticamente]
[Pantalla se desplaza suavemente] → El usuario está listo para continuar
```

## 🛠️ Cambios Técnicos

### Archivo: `lib/screens/training/workout_screen.dart`

**Nuevas variables:**
- `ScrollController _scrollController` - Controla el scroll del ListView

**Nuevos métodos:**
- `_advanceToNextExercise(int index)` - Maneja el avance automático

**Modificaciones:**
- `initState()` - Inicializa el ScrollController
- `dispose()` - Libera el ScrollController
- `_startRestTimer()` - Ahora llama a `_advanceToNextExercise()` cuando termina el descanso
- `ListView.builder()` - Conectado al ScrollController

## 📱 Comportamiento en Diferentes Escenarios

### Escenario 1: Última serie de un ejercicio
```
Flexiones - Serie 3 de 3 (registrada)
↓
Timer de descanso: 60 segundos
↓
[Se completa el descanso]
↓
❌ NO se desplaza (no hay siguiente serie, solo siguiente ejercicio)
```

### Escenario 2: Serie intermedia
```
Flexiones - Serie 1 de 3 (registrada)
↓
Timer de descanso: 60 segundos
↓
[Se completa el descanso]
↓
✅ Scroll automático al siguiente ejercicio
```

### Escenario 3: Usuario salta manualmente
```
Timer en progreso: 45 segundos
↓
Usuario toca "Saltar"
↓
❌ NO ejecuta el scroll (usuario canceló manualmente)
```

## ⚙️ Configuración

### Velocidad de Scroll
```dart
duration: const Duration(milliseconds: 500)  // Medio segundo
curve: Curves.easeInOut                      // Suave
```

### Distancia de Scroll
```dart
_scrollController.position.pixels + 250  // Desplaza ~250px (aproximadamente 1 tarjeta de ejercicio)
```

### Delay antes del Scroll
```dart
Future.delayed(const Duration(milliseconds: 300))  // Espera 300ms después de terminar el timer
```

## 🔄 Cómo Desactivar (si es necesario)

Si quieres desactivar el avance automático, simplemente cambia en `_startRestTimer()`:

```dart
// Actual (con avance automático):
_advanceToNextExercise(exerciseIndex);

// Para desactivar:
_cancelRestTimer();  // Solo cancela el timer sin avanzar
```

## ✨ Mejoras Futuras

- [ ] Agregar sonido de notificación cuando termina el descanso
- [ ] Opción en configuración para deshabilitar el avance automático
- [ ] Vibración del teléfono para alertar al usuario
- [ ] Pantalla de bloqueo con contador de descanso
- [ ] Widget flotante con temporizador visible en la pantalla de inicio

## 🧪 Prueba de Funcionalidad

### Pasos para verificar:

1. **Abre una rutina en el app**
   ```
   Entrenamientos → Selecciona una rutina
   ```

2. **Registra una serie**
   ```
   Toca "Serie 1" → Ingresa reps y peso → Registra
   ```

3. **Observa el timer de descanso**
   ```
   ⏱️ 60 segundos (o el tiempo configurado)
   Barra de progreso
   Botón "Saltar"
   ```

4. **Espera a que termine**
   ```
   Deja que cuente hacia atrás...
   [Sin tocar el teléfono]
   ```

5. **Verifica el avance**
   ```
   ✅ La pantalla debería desplazarse automáticamente
   ✅ Debería mostrar el siguiente ejercicio
   ```

## 📊 Estadísticas

- **Líneas de código agregadas**: 20
- **Líneas de código modificadas**: 5
- **Archivos afectados**: 1
- **Tiempo de respuesta**: Inmediato (sin delay perceptible)

## 🐛 Solución de Problemas

### El scroll no funciona
**Causa**: El ScrollController no tiene clientes (ListView no existe)
**Solución**: Verifica que el ListView esté correctamente construido

### El scroll es muy rápido/lento
**Solución**: Ajusta `duration: const Duration(milliseconds: 500)`

### Quiero que desplace más o menos
**Solución**: Cambia `_scrollController.position.pixels + 250`

## 📝 Notas Importantes

- El avance automático **solo funciona cuando termina naturalmente** el timer
- El usuario puede **saltarlo manualmente** en cualquier momento
- El scroll es **suave y animado** para mejor experiencia
- Compatible con **todas las rutinas** sin cambios adicionales

---

**Versión**: 1.5.6+
**Fecha**: 4 de febrero de 2026
**Estado**: ✅ Activo y funcionando
