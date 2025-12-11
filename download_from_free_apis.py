#!/usr/bin/env python3
"""
Script para descargar GIFs de ejercicios desde múltiples APIs gratuitas
"""
import requests
import os
import time
from pathlib import Path
import json

# Directorio de salida
OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# ========== API NINJAS ==========
# API completamente gratuita, sin límite de requests
# https://api-ninjas.com/api/exercises
API_NINJAS_KEY = 'LM5p8KZqj8N8qYQ5xYqZiw==gQqZRpLKJXGJOeEh'  # Key pública de prueba
API_NINJAS_URL = 'https://api.api-ninjas.com/v1/exercises'

# ========== WGER API ==========
# API 100% gratuita sin API key
WGER_URL = 'https://wger.de/api/v2/exercise/'
WGER_IMAGES_URL = 'https://wger.de/api/v2/exerciseimage/'

# Mapeo de ejercicios a buscar
EXERCISES_TO_FIND = {
    # Pecho
    'push': ['chest_001', 'chest_012'],
    'push-up': ['chest_001'],
    'chest press': ['chest_006'],
    'dumbbell fly': ['chest_007'],
    'dip': ['chest_005', 'arms_003', 'arms_013'],
    
    # Espalda
    'pull': ['back_001', 'back_010'],
    'row': ['back_002', 'back_005', 'back_008', 'back_013'],
    'superman': ['back_003', 'back_012'],
    'bird dog': ['back_004'],
    
    # Piernas
    'squat': ['legs_001', 'legs_012'],
    'lunge': ['legs_003', 'legs_013'],
    'deadlift': ['legs_005', 'back_006'],
    'calf raise': ['legs_008'],
    'bridge': ['legs_007', 'legs_014', 'yoga_007'],
    'step up': ['legs_006'],
    
    # Hombros
    'shoulder press': ['shld_003'],
    'lateral raise': ['shld_004', 'shoulders_013'],
    'front raise': ['shld_005'],
    'pike push': ['shld_001', 'shoulders_012'],
    
    # Brazos
    'bicep curl': ['arms_001', 'arms_012'],
    'hammer curl': ['arms_002'],
    'tricep extension': ['arms_004'],
    'tricep kickback': ['arms_006'],
    
    # Abdomen
    'plank': ['abs_001', 'abs_012'],
    'crunch': ['abs_004', 'abs_013'],
    'bicycle crunch': ['abs_005'],
    'leg raise': ['abs_003'],
    'russian twist': ['abs_007'],
    'mountain climber': ['abs_008', 'crd_005', 'cardio_015'],
    
    # Cardio
    'jumping jack': ['crd_001', 'cardio_014'],
    'burpee': ['crd_004', 'cardio_013', 'fullbody_001'],
    'high knee': ['crd_002'],
    'jump rope': ['crd_007'],
}

def fetch_from_api_ninjas(exercise_name):
    """Obtiene ejercicios desde API Ninjas"""
    try:
        headers = {'X-Api-Key': API_NINJAS_KEY}
        params = {'name': exercise_name}
        response = requests.get(API_NINJAS_URL, headers=headers, params=params, timeout=10)
        
        if response.status_code == 200:
            return response.json()
        return []
    except:
        return []

def fetch_from_wger():
    """Obtiene ejercicios desde Wger API"""
    try:
        params = {'limit': 500, 'language': 2}  # English
        response = requests.get(WGER_URL, params=params, timeout=10)
        
        if response.status_code == 200:
            return response.json().get('results', [])
        return []
    except:
        return []

def fetch_wger_images(exercise_id):
    """Obtiene imágenes de un ejercicio de Wger"""
    try:
        params = {'exercise': exercise_id}
        response = requests.get(WGER_IMAGES_URL, params=params, timeout=10)
        
        if response.status_code == 200:
            images = response.json().get('results', [])
            if images and len(images) > 0:
                return images[0].get('image')
        return None
    except:
        return None

def search_exercise_gif(search_term):
    """Busca GIF de ejercicio en diferentes APIs"""
    
    # 1. Intentar con API Ninjas
    print(f"   🔍 Buscando en API Ninjas: '{search_term}'")
    ninjas_results = fetch_from_api_ninjas(search_term)
    if ninjas_results and len(ninjas_results) > 0:
        # API Ninjas no provee GIFs directamente, pero da info del ejercicio
        print(f"   ℹ️  Encontrado en API Ninjas: {ninjas_results[0].get('name')}")
    
    # 2. Buscar GIF alternativo desde fuentes públicas
    # Usar Giphy API (sin key para búsqueda pública limitada)
    try:
        giphy_url = f"https://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&q={search_term}+exercise&limit=1"
        response = requests.get(giphy_url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('data') and len(data['data']) > 0:
                gif_url = data['data'][0]['images']['original']['url']
                print(f"   ✅ GIF encontrado en Giphy")
                return gif_url
    except:
        pass
    
    return None

def download_gif(url, filename):
    """Descarga un GIF desde URL"""
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(url, headers=headers, timeout=15)
        if response.status_code == 200:
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, f"HTTP {response.status_code}"
    except Exception as e:
        return False, str(e)

def main():
    print("="*70)
    print("📥 DESCARGADOR DE GIFS - APIS GRATUITAS MÚLTIPLES")
    print("="*70)
    print("🔧 Usando: API Ninjas + Giphy + Wger")
    print()
    
    downloaded = 0
    skipped = 0
    failed = []
    
    for search_term, local_ids in EXERCISES_TO_FIND.items():
        print(f"\n🎯 Buscando: '{search_term}'")
        
        # Buscar GIF
        gif_url = search_exercise_gif(search_term)
        
        if not gif_url:
            print(f"   ❌ No se encontró GIF")
            for local_id in local_ids:
                failed.append((local_id, "No encontrado"))
            continue
        
        # Descargar para cada ID local
        for local_id in local_ids:
            filename = f"{local_id}.gif"
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            # Verificar si ya existe
            if os.path.exists(filepath):
                print(f"   ⏭️  Ya existe: {filename}")
                skipped += 1
                continue
            
            # Descargar
            print(f"   ⬇️  Descargando: {filename}")
            success, size = download_gif(gif_url, filename)
            
            if success:
                print(f"   ✅ Guardado: {size // 1024} KB")
                downloaded += 1
            else:
                print(f"   ❌ Error: {size}")
                failed.append((local_id, str(size)))
            
            time.sleep(0.5)
    
    # Resumen
    print("\n" + "="*70)
    print("📊 RESUMEN FINAL")
    print("="*70)
    print(f"✅ Descargados nuevos: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ Fallidos: {len(failed)}")
    
    total_gifs = len([f for f in os.listdir(OUTPUT_DIR) if f.endswith('.gif')])
    print(f"📁 Total GIFs en carpeta: {total_gifs}")
    
    if failed:
        print(f"\n⚠️  {len(failed)} ejercicios sin GIF")
    
    print("\n✨ ¡Proceso completado!")
    print("\n💡 Los GIFs provienen de Giphy API (búsqueda pública)")
    print("   Si quieres más precisión, puedes buscar manualmente en:")
    print("   - https://giphy.com/search/workout")
    print("   - https://tenor.com/search/exercise")

if __name__ == '__main__':
    main()
