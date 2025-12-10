# 🔐 Guía de Firma de la App MiSaludActiva

## 📋 Prerequisitos

- Java Development Kit (JDK) instalado
- Flutter configurado correctamente
- Terminal con acceso a `keytool`

## 🔑 Paso 1: Generar el Keystore

El keystore es un archivo que contiene tu clave de firma. **Guárdalo en un lugar seguro y NUNCA lo compartas**.

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

Durante el proceso se te pedirá:
- **Contraseña del keystore**: Elige una contraseña segura
- **Contraseña de la clave**: Puede ser la misma o diferente
- **Nombre y apellidos**: Tu nombre o el de la organización
- **Unidad organizativa**: Ej: "Desarrollo"
- **Organización**: Ej: "MiSaludActiva"
- **Ciudad, Estado, Código de país**: Tu ubicación

⚠️ **IMPORTANTE**: Guarda las contraseñas en un lugar seguro. Si las pierdes, no podrás actualizar tu app en Google Play.

## 📝 Paso 2: Configurar key.properties

1. Copia el archivo plantilla:
```bash
cp android/key.properties.template android/key.properties
```

2. Edita `android/key.properties` con tus valores reales:
```properties
storeFile=/Users/tunombre/upload-keystore.jks
storePassword=tu_contraseña_del_keystore
keyAlias=upload
keyPassword=tu_contraseña_de_la_clave
```

3. Verifica que `android/.gitignore` incluya `key.properties` (ya está configurado)

## 🏗️ Paso 3: Construir la App Firmada

### Para APK (pruebas y distribución directa):
```bash
flutter build apk --release
```

El APK firmado estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Para App Bundle (Google Play Store - RECOMENDADO):
```bash
flutter build appbundle --release
```

El App Bundle firmado estará en: `build/app/outputs/bundle/release/app-release.aab`

## 📱 Paso 4: Probar el APK

Antes de publicar, prueba el APK en un dispositivo real:

```bash
flutter install --release
```

O instala manualmente:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🚀 Paso 5: Publicar en Google Play

1. Ve a [Google Play Console](https://play.google.com/console)
2. Crea una nueva aplicación o selecciona una existente
3. Ve a "Producción" → "Crear nueva versión"
4. Sube el archivo `app-release.aab`
5. Completa la información requerida (capturas, descripción, etc.)
6. Envía para revisión

## 🔒 Seguridad

**NUNCA COMPARTAS PÚBLICAMENTE**:
- ❌ Tu archivo `upload-keystore.jks`
- ❌ Tu archivo `key.properties`
- ❌ Las contraseñas del keystore
- ❌ El alias de la clave

**Respaldo seguro**:
- ✅ Guarda el keystore en un lugar seguro (nube privada, disco externo)
- ✅ Documenta las contraseñas en un gestor de contraseñas
- ✅ Considera hacer copias de seguridad en múltiples ubicaciones

## 📊 Versionado

Antes de cada nueva versión, actualiza en `pubspec.yaml`:

```yaml
version: 1.0.1+2  # formato: version_name+version_code
```

- **version_name** (1.0.1): Visible para usuarios
- **version_code** (+2): Número interno, debe incrementarse siempre

## 🐛 Solución de Problemas

### Error: "keystore not found"
- Verifica que la ruta en `key.properties` sea correcta
- Usa rutas absolutas en lugar de relativas

### Error: "Incorrect keystore password"
- Verifica que las contraseñas en `key.properties` sean correctas
- Prueba regenerar el keystore si las perdiste

### App no se instala
- Desinstala la versión de debug antes de instalar la release
- Verifica que el `applicationId` sea único

## 📚 Referencias

- [Documentación oficial de Flutter sobre firma](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Google Play Console](https://play.google.com/console)
- [Política de contenido de Google Play](https://play.google.com/about/developer-content-policy/)
