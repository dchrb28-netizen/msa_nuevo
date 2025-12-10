#!/usr/bin/env python3
"""
Descargar GIFs del repositorio free-exercise-db en GitHub
https://github.com/yuhonas/free-exercise-db
"""

import requests
import json
from pathlib import Path
import time

# Mapeo de ejercicios faltantes con términos de búsqueda
NEEDED_EXERCISES = {
    # CARDIO (prioritario)
    'crd_001': ['jumping jack'],
    'crd_002': ['high knee'],
    'crd_003': ['butt kick'],
    'crd_004': ['burpee'],
    'crd_005': ['mountain climber'],
    'crd_006': ['skater'],
    'crd_007': ['jump rope', 'rope skip'],
    'crd_008': ['box jump'],
    'crd_009': ['inchworm'],
    'crd_010': ['tuck jump'],
    
    # YOGA (prioritario)
    'yoga_001': ['downward dog', 'down dog'],
    'yoga_002': ['upward dog', 'up dog', 'upward facing'],
    'yoga_003': ['warrior 1', 'warrior i', 'warrior one'],
    'yoga_004': ['warrior 2', 'warrior ii', 'warrior two'],
    'yoga_005': ['triangle'],
    'yoga_006': ['tree pose'],
    
    # ABDOMEN faltantes
    'abs_002': ['side plank'],
    'abs_008': ['mountain climber'],
    'abs_010': ['hollow'],
    
    # BRAZOS faltantes
    'arms_004': ['tricep extension', 'overhead tricep'],
    'arms_008': ['reverse curl'],
    'arms_010': ['wrist curl'],
    
    # ESPALDA faltantes
    'back_004': ['bird dog'],
    
    # PIERNAS faltantes
    'legs_005': ['single leg deadlift'],
    'legs_006': ['step up'],
    'legs_009': ['pistol squat'],
    'legs_011': ['wall sit'],
    
    # HOMBROS faltantes
    'shld_001': ['pike push'],
    'shld_002': ['handstand'],
    'shld_005': ['front raise'],
    'shld_006': ['upright row'],
    'shld_008': ['shoulder tap'],
    
    # FULLBODY
    'fullbody_001': ['burpee'],
    'fullbody_002': ['mountain climber'],
}

def get_exercise_database():
    """Descargar la base de datos de ejercicios"""
    url = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json'
    
    print("📥 Descargando base de datos de ejercicios...")
    try:
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            exercises = json.loads(response.text)
            print(f"✅ Base de datos cargada: {len(exercises)} ejercicios\n")
            return exercises
        else:
            print(f"❌ Error: Status {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def find_exercise(search_terms, database):
    """Buscar ejercicio en la base de datos"""
    for search_term in search_terms:
        search_lower = search_term.lower()
        for exercise in database:
            name = exercise.get('name', '').lower()
            if search_lower in name:
                return exercise
    return None

def download_image(url, filepath):
    """Descargar una imagen"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, 0
    except Exception as e:
        return False, 0

def main():
    output_dir = Path('assets/exercise_gifs')
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("="*70)
    print("  DESCARGADOR DE FREE-EXERCISE-DB (GitHub)")
    print("="*70)
    print()
    
    # Obtener base de datos
    database = get_exercise_database()
    if not database:
        print("❌ No se pudo cargar la base de datos")
        return
    
    downloaded = 0
    skipped = 0
    not_found = 0
    total_size = 0
    
    print("🎯 Buscando y descargando ejercicios faltantes...\n")
    
    for exercise_id, search_terms in sorted(NEEDED_EXERCISES.items()):
        gif_path = output_dir / f"{exercise_id}.gif"
        
        # Saltar si ya existe
        if gif_path.exists():
            print(f"⏭️  {exercise_id}: Ya existe")
            skipped += 1
            continue
        
        # Buscar en base de datos
        exercise = find_exercise(search_terms, database)
        
        if exercise:
            name = exercise.get('name')
            images = exercise.get('images', [])
            
            print(f"📥 {exercise_id}: {name}")
            print(f"   Términos: {', '.join(search_terms)}")
            
            # Intentar descargar la primera imagen disponible
            downloaded_any = False
            for i, image_url in enumerate(images[:3]):  # Probar hasta 3 imágenes
                print(f"   Probando imagen {i+1}/{len(images)}... ", end='')
                
                # Convertir a GIF si es necesario
                if '.gif' in image_url.lower() or '.jpg' in image_url.lower() or '.png' in image_url.lower():
                    success, size = download_image(image_url, gif_path)
                    
                    if success:
                        size_kb = size / 1024
                        print(f"✅ Descargado ({size_kb:.1f} KB)")
                        downloaded += 1
                        total_size += size
                        downloaded_any = True
                        break
                    else:
                        print(f"❌")
                else:
                    print(f"⏭️  No es GIF/imagen")
            
            if not downloaded_any:
                print(f"   ❌ No se pudo descargar ninguna imagen")
                not_found += 1
        else:
            print(f"❌ {exercise_id}: No encontrado en DB")
            print(f"   Buscado: {search_terms[0]}")
            not_found += 1
        
        print()
        time.sleep(0.2)
    
    # Resumen
    print("\n" + "="*70)
    print("📊 RESUMEN FINAL")
    print("="*70)
    print(f"✅ Nuevos descargados: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ No encontrados: {not_found}")
    
    total_gifs = len(list(output_dir.glob('*.gif')))
    print(f"📁 Total en carpeta: {total_gifs}")
    print(f"💾 Tamaño descargado: {total_size/1024:.1f} KB ({total_size/1024/1024:.2f} MB)")
    
    coverage = (total_gifs / 106) * 100
    print(f"📈 Cobertura: {total_gifs}/106 ejercicios ({coverage:.1f}%)")
    print()

if __name__ == "__main__":
    main()
