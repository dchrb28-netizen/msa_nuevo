#!/usr/bin/env python3
"""
Script para descargar GIFs de ejercicios desde GymVisual.com
"""

import requests
from bs4 import BeautifulSoup
import os
import time
from pathlib import Path

# Mapeo de ejercicios con términos de búsqueda en inglés
EXERCISE_MAPPING = {
    # PECHO
    'chest_001': ['push-up', 'pushup', 'push up'],
    'chest_002': ['incline push-up', 'incline pushup'],
    'chest_003': ['decline push-up', 'decline pushup'],
    'chest_004': ['diamond push-up', 'diamond pushup'],
    'chest_005': ['dip', 'chest dip'],
    'chest_007': ['dumbbell fly', 'chest fly'],
    
    # ESPALDA
    'back_001': ['pull-up', 'pullup', 'pull up'],
    'back_002': ['bent-over row', 'dumbbell row'],
    'back_003': ['superman'],
    'back_005': ['inverted row'],
    'back_010': ['chin-up', 'chinup'],
    
    # PIERNAS
    'legs_001': ['squat', 'bodyweight squat'],
    'legs_002': ['sumo squat'],
    'legs_003': ['lunge'],
    'legs_004': ['bulgarian split squat'],
    'legs_007': ['glute bridge', 'hip bridge'],
    'legs_008': ['calf raise'],
    'legs_010': ['jump squat'],
    
    # HOMBROS
    'shld_001': ['pike push-up', 'pike pushup'],
    'shld_003': ['shoulder press', 'overhead press'],
    'shld_004': ['lateral raise'],
    'shld_005': ['front raise'],
    
    # BRAZOS
    'arms_001': ['bicep curl', 'dumbbell curl'],
    'arms_002': ['hammer curl'],
    'arms_003': ['bench dip', 'tricep dip'],
    'arms_004': ['tricep extension', 'overhead tricep'],
    'arms_006': ['tricep kickback'],
    
    # ABDOMEN
    'abs_001': ['plank', 'forearm plank'],
    'abs_002': ['side plank'],
    'abs_003': ['leg raise', 'lying leg raise'],
    'abs_004': ['crunch'],
    'abs_005': ['bicycle crunch'],
    'abs_007': ['russian twist'],
    'abs_009': ['flutter kick'],
    'abs_011': ['dead bug'],
    
    # CARDIO
    'crd_001': ['jumping jack'],
    'crd_002': ['high knee'],
    'crd_003': ['butt kick'],
    'crd_004': ['burpee'],
    'crd_005': ['mountain climber'],
    'crd_008': ['box jump'],
    'crd_009': ['inchworm'],
    'crd_010': ['tuck jump'],
}

def get_all_exercise_gifs():
    """Obtener todos los GIFs disponibles en GymVisual"""
    url = "https://gymvisual.com/16-animated-gifs"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    try:
        print("🔍 Obteniendo lista de GIFs de GymVisual.com...")
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code != 200:
            print(f"❌ Error: Status {response.status_code}")
            return []
        
        soup = BeautifulSoup(response.content, 'html.parser')
        gifs = []
        
        img_tags = soup.find_all('img')
        for img in img_tags:
            src = img.get('src', '')
            if '.gif' in src.lower():
                if src.startswith('//'):
                    src = 'https:' + src
                elif src.startswith('/'):
                    src = 'https://gymvisual.com' + src
                elif not src.startswith('http'):
                    src = 'https://gymvisual.com/' + src
                
                gifs.append({
                    'url': src,
                    'name': img.get('alt', '').lower(),
                    'title': img.get('title', '').lower()
                })
        
        print(f"✅ Encontrados {len(gifs)} GIFs\n")
        return gifs
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def find_matching_gif(exercise_id, search_terms, available_gifs):
    """Buscar GIF que coincida con los términos de búsqueda"""
    for search_term in search_terms:
        search_lower = search_term.lower()
        for gif in available_gifs:
            gif_text = (gif['name'] + ' ' + gif['title']).lower()
            if search_lower in gif_text:
                return gif
    return None

def download_gif(url, filename, output_dir):
    """Descargar un GIF"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            filepath = output_dir / filename
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True
        return False
    except Exception as e:
        print(f"   ⚠️  Error descargando: {e}")
        return False

def main():
    # Crear directorio de salida
    output_dir = Path('assets/exercise_gifs')
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("  DESCARGADOR DE GIFS DE GYMVISUAL.COM")
    print("=" * 60)
    print()
    
    # Obtener todos los GIFs disponibles
    available_gifs = get_all_exercise_gifs()
    
    if not available_gifs:
        print("❌ No se pudieron obtener los GIFs")
        return
    
    # Estadísticas
    downloaded = 0
    skipped = 0
    not_found = 0
    
    print("🎯 Buscando coincidencias...\n")
    
    for exercise_id, search_terms in EXERCISE_MAPPING.items():
        gif_path = output_dir / f"{exercise_id}.gif"
        
        # Saltar si ya existe
        if gif_path.exists():
            print(f"⏭️  {exercise_id}: Ya existe")
            skipped += 1
            continue
        
        # Buscar GIF coincidente
        matching_gif = find_matching_gif(exercise_id, search_terms, available_gifs)
        
        if matching_gif:
            print(f"📥 {exercise_id}: {matching_gif['name']}")
            print(f"   URL: {matching_gif['url']}")
            
            if download_gif(matching_gif['url'], f"{exercise_id}.gif", output_dir):
                print(f"   ✅ Descargado")
                downloaded += 1
            else:
                print(f"   ❌ Error al descargar")
                not_found += 1
        else:
            print(f"❌ {exercise_id}: No se encontró coincidencia")
            print(f"   Términos buscados: {', '.join(search_terms)}")
            not_found += 1
        
        print()
        time.sleep(0.5)  # Pausa para no saturar el servidor
    
    # Resumen
    print("\n" + "=" * 60)
    print("📊 RESUMEN")
    print("=" * 60)
    print(f"✅ Descargados: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ No encontrados: {not_found}")
    print(f"📁 Total en carpeta: {len(list(output_dir.glob('*.gif')))}")
    print()

if __name__ == "__main__":
    main()
