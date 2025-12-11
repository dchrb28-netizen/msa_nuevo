# 🏗️ Comandos de Build

## Construcción de App Bundle (Release)

Para construir el App Bundle firmado para Google Play Store:

```bash
flutter build appbundle --release --no-tree-shake-icons
```

### ¿Por qué `--no-tree-shake-icons`?

La app usa iconos dinámicos en el sistema de logros (`Achievement` model) que se cargan desde la base de datos Hive. Estos iconos no pueden ser constantes, por lo que necesitamos deshabilitar el tree shaking de iconos.

**Archivos afectados:**
- `lib/models/achievement.dart` (línea 86)
- `lib/models/achievement_adapter.dart` (línea 19)

## Construcción de APK (Pruebas)

Para construir un APK de prueba:

```bash
flutter build apk --release --no-tree-shake-icons
```

## Verificar antes de construir

1. Asegúrate de tener configurado `android/key.properties`
2. Verifica que el keystore exista en la ruta especificada
3. Actualiza la versión en `pubspec.yaml` si es necesario

## Ubicación de archivos generados

- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`

## Instalación en dispositivo

Para instalar el APK directamente en un dispositivo conectado:

```bash
flutter install --release
```

O manualmente con adb:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
