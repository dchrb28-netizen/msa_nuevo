#!/bin/bash
# Script para subir el código a GitHub de forma automática.

echo "✅ Paso 1: Preparando todos los ficheros..."
git add .

echo "✅ Paso 2: Guardando una instantánea de los cambios..."
# Usamos un mensaje descriptivo y la fecha para que el commit sea claro.
git commit -m "Solucionado error de meditación y mejoras generales: $(date)"

echo "✅ Paso 3: Asegurando que la rama principal se llama 'main'..."
git branch -M main

echo "✅ Paso 4: Conectando con tu repositorio en GitHub..."
# Si el repositorio remoto 'origin' ya existe, actualiza la URL. Si no, la añade.
if git remote | grep -q 'origin'; then
    git remote set-url origin https://github.com/dchrb28-netizen/msa_nuevo.git
else
    git remote add origin https://github.com/dchrb28-netizen/msa_nuevo.git
fi

echo "✅ Paso 5: Subiendo los cambios a GitHub..."
# Usamos --force para sobrescribir el historial remoto y asegurar que el local es la única fuente de verdad.
git push -u origin main --force

echo "🎉 ¡Éxito! El código está en GitHub."
