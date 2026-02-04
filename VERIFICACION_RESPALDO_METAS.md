# Verificación de Respaldo y Restauración de Metas Mensuales

## Cambios Implementados

Se ha mejorado el sistema de respaldo y restauración para garantizar que las **metas mensuales de tareas** se guarden y restauren correctamente.

### 1. Archivos Modificados

#### `lib/services/backup_service.dart`
- ✅ Agregado logging específico para metas mensuales durante la **exportación**
- ✅ Agregado logging específico para metas mensuales durante la **restauración**
- ✅ El sistema detecta y reporta automáticamente cuántas metas mensuales se encuentran

#### `lib/screens/backup_screen.dart`
- ✅ Actualizada la lista de "Datos Respaldados" para incluir explícitamente:
  - **"Metas mensuales de tareas"** (destacado en amarillo)

### 2. ¿Qué se Respalda?

Las metas mensuales se guardan en la caja `settings` de Hive con el formato:
```
monthly_tasks_goal_2026_2  (año_mes)
```

Por ejemplo:
- `monthly_tasks_goal_2026_2` → Meta de febrero 2026
- `monthly_tasks_goal_2026_3` → Meta de marzo 2026
- `monthly_tasks_goal_2025_12` → Meta de diciembre 2025

### 3. Cómo Verificar

#### Durante la Exportación (Consola de Debug):

Cuando exportes un respaldo, busca en la consola:

```
📦 Exportando settings: X configuraciones
  → Meta mensual: monthly_tasks_goal_2026_2 = 30
  → Meta mensual: monthly_tasks_goal_2026_1 = 25
  → Total metas mensuales: 2
```

#### Durante la Restauración (Consola de Debug):

Cuando importes un respaldo, busca en la consola:

```
✅ settings restaurada: X/Y registros
   ✓ Meta mensual restaurada: monthly_tasks_goal_2026_2 = 30
   ✓ Meta mensual restaurada: monthly_tasks_goal_2026_1 = 25
   🎯 Total metas mensuales restauradas: 2
```

#### En la Aplicación:

1. Ve a **Tareas Diarias** → Pestaña **"Completadas"**
2. Arriba verás la meta mensual actual con el slider
3. Ve a **Tareas Diarias** → Pestaña **"Mes"** 
4. En la vista circular verás el progreso hacia la meta

### 4. Prueba Completa

Para verificar que todo funciona:

1. **Establece una meta mensual**
   - Abre la app
   - Ve a Tareas → Completadas
   - Ajusta el slider a un valor (ej: 35 tareas)

2. **Exporta el respaldo**
   - Ve a Perfil → Respaldo
   - Toca "Exportar Respaldo"
   - Guarda el archivo JSON
   - Revisa la consola de debug para confirmar que se exportó

3. **Cambia la meta**
   - Ve a Tareas → Completadas
   - Ajusta el slider a otro valor (ej: 50 tareas)

4. **Importa el respaldo anterior**
   - Ve a Perfil → Respaldo
   - Toca "Importar Respaldo"
   - Selecciona el archivo JSON guardado
   - Espera a que la app se reinicie
   - Revisa la consola de debug para confirmar la restauración

5. **Verifica el resultado**
   - Ve a Tareas → Completadas
   - La meta debería volver al valor original (35 tareas)

### 5. Datos Incluidos en el Respaldo

El respaldo ahora incluye todo lo relacionado con el sistema de tareas del mes:

✅ **Tareas diarias** (todas las tareas y sus fechas de completado)
✅ **Metas mensuales** (objetivos de tareas por mes)
✅ **Configuraciones** (preferencias de usuario)
✅ **Rachas** (rachas de todas las actividades)

### 6. Notas Importantes

- Las metas mensuales se guardan en la caja `settings`, que **siempre** se incluye en el respaldo
- Cada mes tiene su propia meta independiente
- Al restaurar un respaldo, **todas** las metas mensuales se restauran automáticamente
- Si tienes metas de múltiples meses, todas se respaldan y restauran

### 7. Solución de Problemas

Si las metas no se restauran:

1. **Verifica el modo debug**
   - Ejecuta la app en modo debug para ver los logs
   - Los logs confirmarán si las metas se están exportando/importando

2. **Revisa el archivo JSON**
   - Abre el archivo de respaldo con un editor de texto
   - Busca la sección `"data": { "settings": {...}}`
   - Deberías ver entradas como `"monthly_tasks_goal_2026_2": 30`

3. **Verifica la versión**
   - Esta mejora está en la versión 1.5.6+
   - El respaldo debe tener `"version": "1.5.6"` o superior

## Conclusión

✅ Las metas mensuales de tareas ahora se respaldan **automáticamente**
✅ Se restauran **correctamente** al importar un respaldo
✅ El usuario puede ver esta información en la pantalla de Respaldo
✅ Los logs de debug permiten verificar que todo funciona

No se requiere ninguna acción especial del usuario. El sistema funciona automáticamente.
