# Instrucciones para Compilar en Windows

## ⚠️ Prerequisitos OBLIGATORIOS

Antes de poder compilar este proyecto, **DEBES tener instalado**:

1. **Flutter SDK** ✅ (Ya lo tienes instalado)
2. **Git para Windows** ❌ (FALTA - Es obligatorio)

### Instalar Git para Windows

1. Descarga Git desde: https://git-scm.com/download/win
2. Ejecuta el instalador
3. **IMPORTANTE:** Durante la instalación, marca la opción **"Git from the command line and also from 3rd-party software"**
4. Finaliza la instalación
5. **Reinicia PowerShell**
6. Verifica: `git --version`

## Problema
Los archivos `.g.dart` (generados por build_runner) no están en el repositorio porque son archivos generados automáticamente y no se suben a GitHub.

**Flutter necesita Git para funcionar correctamente**, por eso obtienes el error: `El término 'git' no se reconoce`

## Solución: Generar los archivos .g.dart

Una vez que Git esté instalado, ejecuta este comando en PowerShell:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Esto generará todos los archivos necesarios:
- body_measurement.g.dart
- daily_meal_plan.g.dart
- fasting_log.g.dart
- food_log.g.dart
- meal_entry.g.dart
- meal_type.g.dart
- recipe.g.dart
- reminder.g.dart
- routine.g.dart
- routine_exercise.g.dart
- user.g.dart
- user_recipe.g.dart
- water_log.g.dart
- Y otros archivos de código generado

## Pasos Completos para Ejecutar la App

1. **Clonar o actualizar el repositorio:**
   ```powershell
   git pull origin main
   ```

2. **Obtener dependencias:**
   ```powershell
   flutter pub get
   ```

3. **Generar archivos .g.dart:**
   ```powershell
   dart run build_runner build --delete-conflicting-outputs
   ```
   
   Este proceso puede tomar 30-60 segundos.

4. **Ejecutar la app:**
   ```powershell
   flutter run
   ```

## Notas Importantes

- Solo necesitas ejecutar `build_runner` UNA VEZ después de clonar el proyecto
- Si actualizas modelos que tienen `@HiveType` o `@JsonSerializable`, debes ejecutar `build_runner` de nuevo
- Los archivos `.g.dart` se regeneran automáticamente cuando cambias los modelos

## Solución de Problemas

Si obtienes errores después de ejecutar build_runner:

```powershell
# Limpiar y regenerar todo
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Si aún hay errores, ejecuta:

```powershell
# Ver análisis de errores
flutter analyze
```
