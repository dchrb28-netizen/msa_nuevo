#!/usr/bin/env python3
"""
Script para descargar todos los GIFs de ejercicios desde las URLs en exercise_list.dart
"""
import re
import os
import urllib.request
import time
from pathlib import Path

# Leer el archivo exercise_list.dart
dart_file = 'lib/data/exercise_list.dart'
output_dir = 'assets/exercise_gifs'

# Crear directorio si no existe
Path(output_dir).mkdir(parents=True, exist_ok=True)

print(f"📂 Leyendo {dart_file}...")

with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Buscar todos los ejercicios con ID y URL
pattern = r"id:\s*'([^']+)'[\s\S]*?imageUrl:\s*'(https?://[^']+\.gif)'"
matches = re.findall(pattern, content)

print(f"✅ Encontrados {len(matches)} ejercicios con URLs de GIF\n")

# Descargar cada GIF
downloaded = 0
failed = []
skipped = 0

for exercise_id, url in matches:
    output_file = os.path.join(output_dir, f"{exercise_id}.gif")
    
    # Verificar si ya existe
    if os.path.exists(output_file):
        print(f"⏭️  Ya existe: {exercise_id}.gif")
        skipped += 1
        continue
    
    try:
        print(f"⬇️  Descargando: {exercise_id}.gif")
        print(f"   URL: {url}")
        
        # Descargar el archivo
        headers = {'User-Agent': 'Mozilla/5.0'}
        request = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(request, timeout=10) as response:
            data = response.read()
            
            # Guardar el archivo
            with open(output_file, 'wb') as f:
                f.write(data)
            
            downloaded += 1
            print(f"   ✅ Guardado ({len(data) // 1024} KB)\n")
        
        # Pequeña pausa para no saturar los servidores
        time.sleep(0.5)
        
    except Exception as e:
        print(f"   ❌ Error: {e}\n")
        failed.append((exercise_id, url, str(e)))

# Resumen
print("\n" + "="*60)
print("📊 RESUMEN")
print("="*60)
print(f"✅ Descargados exitosamente: {downloaded}")
print(f"⏭️  Ya existían: {skipped}")
print(f"❌ Fallidos: {len(failed)}")
print(f"📁 Total en carpeta: {len(os.listdir(output_dir))}")

if failed:
    print("\n⚠️  Archivos que fallaron:")
    for exercise_id, url, error in failed:
        print(f"  - {exercise_id}: {error[:50]}...")

print("\n✨ ¡Proceso completado!")
