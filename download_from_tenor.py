#!/usr/bin/env python3
"""
Script para descargar GIFs de ejercicios desde fuentes públicas alternativas
Usa APIs gratuitas sin necesidad de API key
"""
import requests
import os
import time
from pathlib import Path
import json

# Directorio de salida
OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# URLs de GIFs conocidas que funcionan (desde sitios públicos)
WORKING_GIFS = {
    # Pecho
    'chest_001': 'https://media.tenor.com/6OxJMJR-TfUAAAAM/push-up-exercise.gif',
    'chest_002': 'https://media.tenor.com/pEaZkvLUXfgAAAAM/incline-push-up.gif',
    'chest_003': 'https://media.tenor.com/uuRHGhHZ9p0AAAAM/decline-push-up.gif',
    'chest_004': 'https://media.tenor.com/Rk8JhvZKs-QAAAAM/diamond-push-up.gif',
    
    # Espalda
    'back_003': 'https://media.tenor.com/VKE6mBNRF5wAAAAM/superman-exercise.gif',
    'back_004': 'https://media.tenor.com/DXJvM7CtmOoAAAAM/bird-dog-exercise.gif',
    'back_005': 'https://media.tenor.com/vVo7Q5GZyJcAAAAM/inverted-row.gif',
    
    # Piernas
    'legs_001': 'https://media.tenor.com/xmKN8nJ5GSUAAAAM/squat-exercise.gif',
    'legs_003': 'https://media.tenor.com/K6WpxDYqGIUAAAAM/lunge-exercise.gif',
    'legs_007': 'https://media.tenor.com/BYZzC5xTTWEAAAAM/glute-bridge.gif',
    'legs_008': 'https://media.tenor.com/DsJ7lYhK6kQAAAAM/calf-raise.gif',
    
    # Hombros
    'shld_001': 'https://media.tenor.com/9Vy9YlQKMfUAAAAM/pike-push-up.gif',
    'shld_004': 'https://media.tenor.com/ZRK8mIJxgNgAAAAM/lateral-raise.gif',
    
    # Brazos
    'arms_001': 'https://media.tenor.com/qF-L7B_KETYAAAAM/bicep-curl.gif',
    'arms_003': 'https://media.tenor.com/P2YhKzKVJWoAAAAM/bench-dip.gif',
    
    # Abdomen
    'abs_001': 'https://media.tenor.com/KQeELw9oGssAAAAM/plank-exercise.gif',
    'abs_004': 'https://media.tenor.com/nHQF4tYxN-sAAAAM/crunch-exercise.gif',
    'abs_005': 'https://media.tenor.com/DfDvJYPJqMEAAAAM/bicycle-crunch.gif',
    'abs_007': 'https://media.tenor.com/bK0pZZwZXYMAAAAM/russian-twist.gif',
    'abs_008': 'https://media.tenor.com/ZvP9hXYqp5gAAAAM/mountain-climber.gif',
    
    # Cardio
    'crd_001': 'https://media.tenor.com/eDK-TdcdhTMAAAAM/jumping-jacks.gif',
    'crd_002': 'https://media.tenor.com/Xk5JqQrRkiYAAAAM/high-knees.gif',
    'crd_004': 'https://media.tenor.com/r7EqHQVJKjsAAAAM/burpee-exercise.gif',
}

def download_gif(url, filename):
    """Descarga un GIF desde URL"""
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, f"HTTP {response.status_code}"
    except Exception as e:
        return False, str(e)

def main():
    print("="*60)
    print("📥 DESCARGADOR DE GIFS (Fuentes Públicas)")
    print("="*60 + "\n")
    
    downloaded = 0
    skipped = 0
    failed = []
    
    for exercise_id, url in WORKING_GIFS.items():
        filename = f"{exercise_id}.gif"
        filepath = os.path.join(OUTPUT_DIR, filename)
        
        # Verificar si ya existe
        if os.path.exists(filepath):
            print(f"⏭️  Ya existe: {filename}")
            skipped += 1
            continue
        
        print(f"⬇️  Descargando: {filename}")
        success, size = download_gif(url, filename)
        
        if success:
            print(f"   ✅ {size // 1024} KB\n")
            downloaded += 1
        else:
            print(f"   ❌ Error: {size}\n")
            failed.append((exercise_id, size))
        
        time.sleep(0.5)
    
    # Resumen
    print("\n" + "="*60)
    print("📊 RESUMEN")
    print("="*60)
    print(f"✅ Descargados: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ Fallidos: {len(failed)}")
    print(f"📁 Total en carpeta: {len(os.listdir(OUTPUT_DIR))}")
    
    if failed:
        print("\n⚠️  Archivos fallidos:")
        for ex_id, error in failed:
            print(f"  - {ex_id}: {error}")
    
    print("\n✨ ¡Proceso completado!")
    print("\n💡 Nota: Para más ejercicios, puedes:")
    print("   1. Buscar GIFs en https://tenor.com/search/exercise")
    print("   2. Agregarlos manualmente a la carpeta assets/exercise_gifs/")
    print("   3. O usar iconos representativos en lugar de GIFs")

if __name__ == '__main__':
    main()
