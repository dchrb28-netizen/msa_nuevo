#!/usr/bin/env python3
"""
Script para descargar GIFs de ejercicios desde ExerciseDB API
"""
import requests
import os
import time
from pathlib import Path

# Configuración de la API
API_KEY = '0ac953731bmshed20d6a71805c71p1a5fa6jsnf19e05f0eeca'
BASE_URL = 'https://exercisedb.p.rapidapi.com'
HEADERS = {
    'X-RapidAPI-Key': API_KEY,
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
}

# Directorio de salida
OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# Mapeo de nombres de ejercicios a IDs locales
EXERCISE_MAPPING = {
    'push-up': ['chest_001', 'chest_012'],
    'decline push-up': ['chest_003', 'chest_013'],
    'diamond push-up': ['chest_004', 'arms_009'],
    'wide push-up': ['chest_012'],
    'pike push-up': ['shld_001', 'shoulders_012'],
    'dumbbell bench press': ['chest_006'],
    'dumbbell fly': ['chest_007'],
    'chest dip': ['chest_005'],
    
    # Espalda
    'superman': ['back_003', 'back_012'],
    'bird dog': ['back_004'],
    'inverted row': ['back_005', 'back_013'],
    'bent-over row': ['back_002'],
    'dumbbell row': ['back_008'],
    'pull-up': ['back_001'],
    'chin-up': ['back_010'],
    
    # Piernas
    'squat': ['legs_001', 'legs_012'],
    'sumo squat': ['legs_002'],
    'lunge': ['legs_003', 'legs_013'],
    'bulgarian split squat': ['legs_004'],
    'single-leg deadlift': ['legs_005'],
    'step-up': ['legs_006'],
    'glute bridge': ['legs_007', 'legs_014', 'yoga_007'],
    'calf raise': ['legs_008'],
    'pistol squat': ['legs_009'],
    'jump squat': ['legs_010'],
    'wall sit': ['legs_011'],
    
    # Hombros
    'shoulder press': ['shld_003'],
    'lateral raise': ['shld_004', 'shoulders_013'],
    'front raise': ['shld_005'],
    'upright row': ['shld_006'],
    'arnold press': ['shld_009'],
    'handstand push-up': ['shld_010'],
    
    # Brazos
    'bicep curl': ['arms_001', 'arms_012'],
    'hammer curl': ['arms_002'],
    'bench dip': ['arms_003', 'arms_013'],
    'tricep extension': ['arms_004'],
    'tricep kickback': ['arms_006'],
    'reverse curl': ['arms_008'],
    'wrist curl': ['arms_010'],
    
    # Abdomen
    'plank': ['abs_001', 'abs_012'],
    'side plank': ['abs_002'],
    'leg raise': ['abs_003'],
    'crunch': ['abs_004', 'abs_013'],
    'bicycle crunch': ['abs_005'],
    'v-up': ['abs_006'],
    'russian twist': ['abs_007'],
    'mountain climber': ['abs_008', 'crd_005', 'cardio_015', 'fullbody_002'],
    'flutter kick': ['abs_009'],
    'dead bug': ['abs_011'],
    
    # Cardio
    'jumping jack': ['crd_001', 'cardio_014'],
    'high knee': ['crd_002'],
    'butt kick': ['crd_003'],
    'burpee': ['crd_004', 'cardio_013', 'fullbody_001'],
    'jump rope': ['crd_007'],
    'box jump': ['crd_008'],
    'tuck jump': ['crd_010'],
}

def fetch_exercises(limit=1000):
    """Obtiene lista de ejercicios desde la API"""
    print(f"🔍 Consultando API de ExerciseDB...")
    try:
        response = requests.get(
            f'{BASE_URL}/exercises',
            headers=HEADERS,
            params={'limit': limit},
            timeout=10
        )
        
        if response.status_code == 200:
            exercises = response.json()
            print(f"✅ Obtenidos {len(exercises)} ejercicios de la API\n")
            return exercises
        else:
            print(f"❌ Error API: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def download_gif(url, filename):
    """Descarga un GIF desde URL"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, 0
    except Exception as e:
        return False, str(e)

def main():
    print("="*60)
    print("📥 DESCARGADOR DE GIFS DE EXERCISEDB API")
    print("="*60 + "\n")
    
    # Obtener ejercicios de la API
    api_exercises = fetch_exercises()
    
    if not api_exercises:
        print("⚠️  No se pudieron obtener ejercicios de la API")
        return
    
    # Crear índice de búsqueda
    exercise_index = {}
    for ex in api_exercises:
        name = ex.get('name', '').lower()
        exercise_index[name] = ex
    
    downloaded = 0
    skipped = 0
    failed = []
    
    print("🎯 Buscando y descargando GIFs...\n")
    
    for search_term, local_ids in EXERCISE_MAPPING.items():
        # Buscar ejercicio por nombre
        found = None
        for name, ex in exercise_index.items():
            if search_term.lower() in name:
                found = ex
                break
        
        if not found:
            print(f"⚠️  No encontrado: {search_term}")
            for local_id in local_ids:
                failed.append((local_id, f"No encontrado: {search_term}"))
            continue
        
        gif_url = found.get('gifUrl')
        if not gif_url:
            print(f"⚠️  Sin GIF: {search_term}")
            continue
        
        # Descargar para cada ID local
        for local_id in local_ids:
            filename = f"{local_id}.gif"
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            # Verificar si ya existe
            if os.path.exists(filepath):
                print(f"⏭️  Ya existe: {filename}")
                skipped += 1
                continue
            
            # Descargar
            print(f"⬇️  {filename} <- {found['name']}")
            success, size = download_gif(gif_url, filename)
            
            if success:
                print(f"   ✅ {size // 1024} KB\n")
                downloaded += 1
            else:
                print(f"   ❌ Error: {size}\n")
                failed.append((local_id, str(size)))
            
            time.sleep(0.3)  # Pausa para no saturar la API
    
    # Resumen
    print("\n" + "="*60)
    print("📊 RESUMEN")
    print("="*60)
    print(f"✅ Descargados: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ Fallidos: {len(failed)}")
    print(f"📁 Total en carpeta: {len(os.listdir(OUTPUT_DIR))}")
    
    if failed:
        print(f"\n⚠️  {len(failed)} archivos no se pudieron descargar")
    
    print("\n✨ ¡Proceso completado!")

if __name__ == '__main__':
    main()
