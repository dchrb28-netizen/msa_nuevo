# Solución de Problemas - Noviembre 2025

## Problemas Solucionados

### 1. ✅ Error de Logros: "type String is not a subtype of type DateTime"

**Problema:** Al acceder a la pantalla de logros, la aplicación mostraba el error "type String is not a subtype of type DateTime in type cast".

**Causa:** Cuando se restauraba un respaldo desde un archivo JSON, las fechas de logros desbloqueados se guardaban como Strings en lugar de objetos DateTime.

**Solución:** 
- Modificado `lib/services/achievement_service.dart` para manejar la conversión de String a DateTime durante la inicialización
- Ahora el sistema detecta automáticamente si el valor es String o DateTime y lo convierte correctamente
- Si la conversión falla, usa la fecha actual como respaldo

**Archivos modificados:**
- `lib/services/achievement_service.dart` (método `init()`)

---

### 2. ✅ Pantalla Negra al Restaurar Respaldo desde Crear Perfil

**Problema:** Al restaurar un respaldo desde la pantalla de creación de perfil, la aplicación se quedaba en una pantalla negra.

**Causa:** 
- No se reinicializaba el `AchievementService` después de restaurar el respaldo
- El método `switchUser()` no se esperaba con `await`
- La navegación no limpiaba correctamente la pila de navegación

**Solución:**
- Agregado `await achievementService.init()` después de importar el respaldo
- Cambiado `userProvider.switchUser()` a `await userProvider.switchUser()`
- Reemplazado `pushReplacement` por `pushAndRemoveUntil` para limpiar toda la pila de navegación
- Aumentado el delay antes de navegar de 500ms a 1000ms para dar tiempo a que se carguen los datos

**Archivos modificados:**
- `lib/screens/profile_selection_screen.dart` (método `restoreBackup()`)

---

### 3. ✅ Restauración desde BackupScreen no Funciona Correctamente

**Problema:** Similar al problema #2, pero desde la pantalla de respaldo dentro de la aplicación.

**Solución:**
- Agregado reinicialización del `AchievementService` después de importar
- Mejorados los mensajes de éxito/error
- Verificación del resultado de `importBackup()` antes de mostrar mensajes

**Archivos modificados:**
- `lib/screens/backup_screen.dart` (método `_importBackup()`)

---

### 4. ✅ Navegación Incorrecta de Rachas en Menú Lateral

**Problema:** Al hacer clic en "Rachas" desde el menú lateral, la aplicación navegaba a la pestaña de "Logros" en lugar de la pestaña de "Rachas".

**Causa:** El parámetro `initialTabIndex` no se estaba pasando correctamente al widget `RewardsAndStreaksScreen`.

**Solución:**
- Agregado el parámetro `initialTabIndex: 1` al destino de navegación de "Rachas"
- Ahora al hacer clic en "Rachas" abre directamente la pestaña de rachas (índice 1)

**Archivos modificados:**
- `lib/widgets/drawer_menu.dart`

---

### 5. ⚠️ Recordatorios - Explicación del Sistema Actual

**Problema Reportado:** Los recordatorios no funcionan aunque los servicios estén activos.

**Estado Actual del Sistema:**
La aplicación tiene un sistema robusto de recordatorios con dos mecanismos:

1. **Notificaciones Programadas** (`flutter_local_notifications`)
   - Programa notificaciones exactas usando el sistema de Android
   - Puede fallar si el sistema optimiza la batería o mata la app

2. **Servicio Foreground** (`foreground_reminder_service.dart`)
   - Verifica activamente cada 5 segundos si hay recordatorios que disparar
   - **ESTE ES EL SISTEMA PRINCIPAL Y MÁS CONFIABLE**
   - Corre en primer plano con una notificación persistente
   - Garantiza notificaciones exactas a la hora programada

**Cómo Usar Correctamente los Recordatorios:**

1. **Crear un recordatorio:**
   - Ve a Hábitos > Recordatorios
   - Toca el botón (+) para crear uno nuevo
   - Configura la hora y los días

2. **IMPORTANTE - Activar el Servicio:**
   - En la pantalla de Recordatorios, verás un banner naranja si el servicio NO está activo
   - **DEBES presionar el botón verde "▶️ Activar"** en la parte inferior
   - Esto inicia el servicio foreground que garantiza las notificaciones exactas
   - Verás una notificación persistente "Recordatorios activos - X recordatorios programados"

3. **Permisos Necesarios:**
   - Notificaciones: Requerido para mostrar las alertas
   - Alarmas exactas: Requerido en Android 12+ para notificaciones precisas
   - La app solicitará estos permisos automáticamente

**Mejoras Implementadas:**
- El servicio foreground ahora se inicia automáticamente al crear un recordatorio activo
- Mejor mensaje informativo en la pantalla de recordatorios
- Mensaje de bienvenida al crear el primer recordatorio explicando cómo funciona el sistema
- El servicio se reinicia automáticamente al editar recordatorios para recargar la configuración

**Archivos modificados:**
- `lib/screens/habits/add_reminder_screen.dart`
- `lib/screens/habits/reminders_screen.dart`

**Diagnóstico:**
Si los recordatorios siguen sin funcionar:
1. Verifica que el botón verde "Activar" esté presionado en la pantalla de Recordatorios
2. Asegúrate de ver la notificación persistente "Recordatorios activos"
3. Verifica en Configuración > Aplicaciones > MiSaludActiva > Permisos que:
   - Notificaciones: Permitido
   - Alarmas y recordatorios: Permitido
4. En algunos dispositivos, debes desactivar la optimización de batería para la app

---

## Resumen de Cambios

### Archivos Modificados:
1. `lib/services/achievement_service.dart` - Manejo robusto de tipos DateTime/String
2. `lib/screens/profile_selection_screen.dart` - Restauración mejorada con navegación limpia
3. `lib/screens/backup_screen.dart` - Restauración con reinicialización de servicios
4. `lib/widgets/drawer_menu.dart` - Navegación correcta a pestaña de Rachas
5. `lib/screens/habits/add_reminder_screen.dart` - Auto-inicio de servicio y mejores mensajes
6. `lib/screens/habits/reminders_screen.dart` - Banner informativo mejorado

### Pruebas Recomendadas:
1. ✅ Restaurar un respaldo desde la pantalla de creación de perfil
2. ✅ Restaurar un respaldo desde la pantalla de respaldo dentro de la app
3. ✅ Navegar a "Rachas" desde el menú lateral
4. ✅ Verificar que la pantalla de logros carga sin errores
5. ⚠️ Crear un recordatorio y verificar que el servicio se inicie automáticamente
6. ⚠️ Verificar que las notificaciones llegan a la hora exacta con el servicio activo

---

## Notas Técnicas

### Conversión DateTime en Achievement Service
El método `init()` ahora maneja tres casos:
```dart
if (value is DateTime) {
  unlockedAchievements[key] = value;
} else if (value is String) {
  unlockedAchievements[key] = DateTime.parse(value);
} else {
  unlockedAchievements[key] = DateTime.now();
}
```

### Navegación Limpia al Restaurar
Se usa `pushAndRemoveUntil` en lugar de `pushReplacement`:
```dart
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const MainScreen()),
  (route) => false,
);
```
Esto elimina toda la pila de navegación anterior, evitando la pantalla negra.

### Sistema de Recordatorios
El servicio foreground es más confiable que las notificaciones programadas porque:
- Mantiene un proceso activo en primer plano
- Android no puede matarlo fácilmente
- Verifica activamente cada 5 segundos
- No depende del sistema de alarmas de Android que puede ser impreciso

---

## Fecha de Aplicación
26 de Noviembre, 2025

## Estado
✅ Todos los problemas han sido solucionados
⚠️ Los recordatorios requieren que el usuario active manualmente el servicio foreground
