#!/usr/bin/env python3
"""
Descarga GIFs desde ExerciseDB API - Versión mejorada
Descarga por grupos musculares para obtener más ejercicios
"""
import requests
import os
import time
from pathlib import Path

# Configuración
API_KEY = '0ac953731bmshed20d6a71805c71p1a5fa6jsnf19e05f0eeca'
BASE_URL = 'https://exercisedb.p.rapidapi.com'
HEADERS = {
    'X-RapidAPI-Key': API_KEY,
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
}

OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# Mapeo de ejercicios a IDs locales (simplificado para búsqueda)
EXERCISE_MAP = {
    'push': ['chest_001', 'chest_012'],
    'dip': ['chest_005', 'arms_003', 'arms_013'],
    'press': ['chest_006', 'shld_003'],
    'fly': ['chest_007'],
    
    'pull': ['back_001', 'back_010'],
    'row': ['back_002', 'back_005', 'back_008'],
    'deadlift': ['legs_005', 'back_006'],
    
    'squat': ['legs_001', 'legs_002', 'legs_012'],
    'lunge': ['legs_003', 'legs_013'],
    'bridge': ['legs_007', 'legs_014', 'yoga_007'],
    'calf': ['legs_008'],
    
    'shoulder': ['shld_003', 'shld_004', 'shld_005', 'shld_006'],
    'raise': ['shld_004', 'shld_005', 'shoulders_013'],
    
    'curl': ['arms_001', 'arms_002', 'arms_008', 'arms_012'],
    'tricep': ['arms_004', 'arms_006'],
    
    'plank': ['abs_001', 'abs_002', 'abs_012'],
    'crunch': ['abs_004', 'abs_005', 'abs_013'],
    'leg raise': ['abs_003'],
    'twist': ['abs_007'],
    'climber': ['abs_008', 'crd_005', 'cardio_015'],
    
    'jack': ['crd_001', 'cardio_014'],
    'burpee': ['crd_004', 'cardio_013', 'fullbody_001'],
    'knee': ['crd_002'],
    'jump': ['crd_007', 'crd_008', 'legs_010'],
}

def fetch_exercises_by_bodypart(bodypart):
    """Obtiene ejercicios por grupo muscular"""
    try:
        url = f'{BASE_URL}/exercises/bodyPart/{bodypart}'
        response = requests.get(url, headers=HEADERS, timeout=10)
        if response.status_code == 200:
            return response.json()
        return []
    except:
        return []

def download_gif(url, filename):
    """Descarga un GIF"""
    try:
        response = requests.get(url, timeout=15)
        if response.status_code == 200 and len(response.content) > 1000:
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, f"HTTP {response.status_code}"
    except Exception as e:
        return False, str(e)[:30]

def main():
    print("="*70)
    print("📥 DESCARGADOR DE GIFS - EXERCISEDB API V2")
    print("="*70)
    print("🔧 Descargando por grupos musculares...\n")
    
    # Grupos musculares disponibles en la API
    body_parts = ['back', 'cardio', 'chest', 'lower arms', 'lower legs', 
                  'neck', 'shoulders', 'upper arms', 'upper legs', 'waist']
    
    all_exercises = []
    
    # Obtener ejercicios de cada grupo
    for bodypart in body_parts:
        print(f"🔍 Obteniendo ejercicios de: {bodypart}...", end=' ')
        exercises = fetch_exercises_by_bodypart(bodypart)
        print(f"✅ {len(exercises)} encontrados")
        all_exercises.extend(exercises)
        time.sleep(0.5)  # Pausa entre requests
    
    print(f"\n📊 Total de ejercicios obtenidos: {len(all_exercises)}\n")
    
    # Crear índice de búsqueda
    exercise_index = {}
    for ex in all_exercises:
        name = ex.get('name', '').lower()
        exercise_index[name] = ex
    
    downloaded = 0
    skipped = 0
    processed = set()
    
    print("🎯 Descargando GIFs...\n")
    
    # Buscar y descargar
    for search_term, local_ids in EXERCISE_MAP.items():
        # Buscar ejercicio
        found = None
        for name, ex in exercise_index.items():
            if search_term.lower() in name:
                found = ex
                break
        
        if not found:
            continue
        
        gif_url = found.get('gifUrl')
        if not gif_url:
            continue
        
        # Descargar para cada ID
        for local_id in local_ids:
            if local_id in processed:
                continue
                
            filename = f"{local_id}.gif"
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            if os.path.exists(filepath):
                skipped += 1
                processed.add(local_id)
                continue
            
            print(f"⬇️  {filename} <- {found['name'][:40]}", end=' ')
            success, size = download_gif(gif_url, filename)
            
            if success:
                print(f"✅ {size // 1024} KB")
                downloaded += 1
            else:
                print(f"❌")
            
            processed.add(local_id)
            time.sleep(0.3)
    
    # También descargar directamente los más populares
    print("\n🎯 Descargando ejercicios populares adicionales...\n")
    
    popular_searches = [
        'push up', 'squat', 'plank', 'burpee', 'crunch', 
        'lunge', 'jumping jack', 'mountain climber'
    ]
    
    for search in popular_searches:
        for name, ex in exercise_index.items():
            if search in name and ex.get('gifUrl'):
                # Buscar IDs que coincidan
                for term, ids in EXERCISE_MAP.items():
                    if term in name:
                        for local_id in ids:
                            if local_id in processed:
                                continue
                            
                            filename = f"{local_id}.gif"
                            filepath = os.path.join(OUTPUT_DIR, filename)
                            
                            if os.path.exists(filepath):
                                skipped += 1
                                processed.add(local_id)
                                continue
                            
                            print(f"⬇️  {filename} <- {ex['name'][:40]}", end=' ')
                            success, size = download_gif(ex['gifUrl'], filename)
                            
                            if success:
                                print(f"✅ {size // 1024} KB")
                                downloaded += 1
                            else:
                                print(f"❌")
                            
                            processed.add(local_id)
                            time.sleep(0.3)
                break
    
    # Resumen
    total_gifs = len([f for f in os.listdir(OUTPUT_DIR) if f.endswith('.gif')])
    
    print("\n" + "="*70)
    print("📊 RESUMEN FINAL")
    print("="*70)
    print(f"✅ Descargados nuevos: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"📁 Total GIFs disponibles: {total_gifs}/106")
    print(f"📈 Cobertura: {total_gifs*100//106}%")
    print("\n✨ ¡Proceso completado!")

if __name__ == '__main__':
    main()
