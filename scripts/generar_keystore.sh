#!/bin/bash

# Script para generar keystore de firma para MiSaludActiva
# Este script te guiará paso a paso para crear tu keystore

echo "🔐 Generador de Keystore para MiSaludActiva"
echo "============================================="
echo ""

# Directorio por defecto para guardar el keystore
DEFAULT_KEYSTORE_PATH="$HOME/upload-keystore.jks"

echo "📍 Ubicación del keystore:"
echo "Por defecto se guardará en: $DEFAULT_KEYSTORE_PATH"
read -p "¿Quieres usar esta ubicación? (S/n): " use_default

if [[ $use_default == "n" || $use_default == "N" ]]; then
    read -p "Ingresa la ruta completa donde guardar el keystore: " KEYSTORE_PATH
else
    KEYSTORE_PATH=$DEFAULT_KEYSTORE_PATH
fi

echo ""
echo "📋 A continuación se te pedirá:"
echo "  1. Contraseña del keystore (mínimo 6 caracteres)"
echo "  2. Contraseña de la clave (puede ser la misma)"
echo "  3. Tu nombre y apellidos"
echo "  4. Unidad organizativa (ej: Desarrollo)"
echo "  5. Organización (ej: MiSaludActiva)"
echo "  6. Ciudad"
echo "  7. Estado/Provincia"
echo "  8. Código de país (ej: CO para Colombia, ES para España, MX para México)"
echo ""
echo "⚠️  IMPORTANTE: Guarda las contraseñas en un lugar seguro."
echo "   Si las pierdes, NO podrás actualizar tu app en Google Play."
echo ""
read -p "Presiona ENTER para continuar..."

echo ""
echo "🔨 Generando keystore..."
echo ""

keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ¡Keystore creado exitosamente!"
    echo ""
    echo "📄 Ahora crea el archivo key.properties:"
    echo "   1. Copia la plantilla:"
    echo "      cp android/key.properties.template android/key.properties"
    echo ""
    echo "   2. Edita android/key.properties con estos valores:"
    echo "      storeFile=$KEYSTORE_PATH"
    echo "      storePassword=TU_CONTRASEÑA_DEL_KEYSTORE"
    echo "      keyAlias=upload"
    echo "      keyPassword=TU_CONTRASEÑA_DE_LA_CLAVE"
    echo ""
    echo "🚀 Después podrás construir tu app firmada con:"
    echo "   flutter build appbundle --release"
    echo ""
else
    echo ""
    echo "❌ Error al generar el keystore"
    echo "   Revisa los mensajes de error anteriores"
    echo ""
fi
