#!/usr/bin/env python3
"""
Script mejorado para descargar GIFs de ejercicios desde GymVisual.com
Explora múltiples páginas y hace búsqueda inteligente
"""

import requests
from bs4 import BeautifulSoup
import os
import time
from pathlib import Path
import re

# Mapeo mejorado con más variaciones
EXERCISE_MAPPING = {
    # PECHO
    'chest_001': ['push-up', 'pushup', 'push up', 'standard push'],
    'chest_002': ['incline push-up', 'incline pushup'],
    'chest_003': ['decline push-up', 'decline pushup'],
    'chest_004': ['diamond push-up', 'diamond pushup', 'tricep push'],
    'chest_005': ['dip', 'chest dip', 'parallel bar dip'],
    'chest_006': ['press', 'chest press'],
    'chest_007': ['fly', 'chest fly', 'dumbbell fly'],
    
    # ESPALDA
    'back_001': ['pull-up', 'pullup', 'pull up', 'chin up'],
    'back_002': ['bent-over row', 'dumbbell row', 'barbell row'],
    'back_003': ['superman'],
    'back_004': ['bird dog'],
    'back_005': ['inverted row', 'australian pull'],
    'back_007': ['pullover'],
    'back_010': ['chin-up', 'chinup'],
    
    # PIERNAS
    'legs_001': ['squat', 'air squat', 'bodyweight squat'],
    'legs_002': ['sumo squat', 'wide squat'],
    'legs_003': ['lunge', 'forward lunge'],
    'legs_004': ['bulgarian split squat', 'split squat'],
    'legs_005': ['single leg deadlift', 'one leg deadlift'],
    'legs_006': ['step-up', 'step up'],
    'legs_007': ['glute bridge', 'hip bridge', 'bridge'],
    'legs_008': ['calf raise'],
    'legs_009': ['pistol squat', 'single leg squat'],
    'legs_010': ['jump squat', 'squat jump'],
    'legs_011': ['wall sit'],
    
    # HOMBROS
    'shld_001': ['pike push-up', 'pike pushup'],
    'shld_002': ['handstand'],
    'shld_003': ['shoulder press', 'overhead press', 'military press'],
    'shld_004': ['lateral raise', 'side raise'],
    'shld_005': ['front raise'],
    'shld_006': ['upright row'],
    'shld_008': ['shoulder tap'],
    
    # BRAZOS
    'arms_001': ['bicep curl', 'dumbbell curl', 'arm curl'],
    'arms_002': ['hammer curl'],
    'arms_003': ['bench dip', 'tricep dip'],
    'arms_004': ['tricep extension', 'overhead tricep'],
    'arms_006': ['tricep kickback', 'kickback'],
    'arms_007': ['close grip', 'close-grip'],
    'arms_008': ['reverse curl'],
    'arms_010': ['wrist curl'],
    
    # ABDOMEN
    'abs_001': ['plank', 'forearm plank'],
    'abs_002': ['side plank', 'lateral plank'],
    'abs_003': ['leg raise', 'lying leg raise'],
    'abs_004': ['crunch', 'abdominal crunch'],
    'abs_005': ['bicycle', 'bicycle crunch'],
    'abs_006': ['v-up', 'v up'],
    'abs_007': ['russian twist', 'seated twist'],
    'abs_008': ['mountain climber'],
    'abs_009': ['flutter kick'],
    'abs_010': ['hollow'],
    'abs_011': ['dead bug'],
    
    # CARDIO
    'crd_001': ['jumping jack', 'star jump'],
    'crd_002': ['high knee', 'high knees'],
    'crd_003': ['butt kick'],
    'crd_004': ['burpee'],
    'crd_005': ['mountain climber'],
    'crd_006': ['skater', 'lateral skater'],
    'crd_007': ['jump rope', 'rope skip'],
    'crd_008': ['box jump'],
    'crd_009': ['inchworm'],
    'crd_010': ['tuck jump'],
    
    # YOGA
    'yoga_001': ['downward dog', 'down dog'],
    'yoga_002': ['upward dog', 'up dog'],
    'yoga_003': ['warrior 1', 'warrior i'],
    'yoga_004': ['warrior 2', 'warrior ii'],
    'yoga_005': ['triangle'],
    'yoga_006': ['tree pose'],
    'yoga_007': ['bridge pose'],
}

def get_all_gifs_from_gymvisual(max_pages=10):
    """Obtener todos los GIFs disponibles de GymVisual con paginación"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    all_gifs = []
    
    print(f"🔍 Explorando hasta {max_pages} páginas de GymVisual.com...")
    
    for page in range(1, max_pages + 1):
        url = f"https://gymvisual.com/16-animated-gifs?p={page}"
        
        try:
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code != 200:
                break
            
            soup = BeautifulSoup(response.content, 'html.parser')
            img_tags = soup.find_all('img')
            
            page_gifs = []
            for img in img_tags:
                src = img.get('src', '')
                if '.gif' in src.lower() and '/img/p/' in src:
                    if src.startswith('//'):
                        src = 'https:' + src
                    elif src.startswith('/'):
                        src = 'https://gymvisual.com' + src
                    
                    page_gifs.append({
                        'url': src,
                        'name': img.get('alt', '').lower(),
                        'title': img.get('title', '').lower()
                    })
            
            if not page_gifs:
                break
            
            all_gifs.extend(page_gifs)
            print(f"  Página {page}: {len(page_gifs)} GIFs")
            time.sleep(0.3)  # Pausa entre páginas
            
        except Exception as e:
            print(f"  ⚠️  Error en página {page}: {e}")
            break
    
    # Eliminar duplicados por URL
    unique_gifs = {gif['url']: gif for gif in all_gifs}
    result = list(unique_gifs.values())
    
    print(f"✅ Total de GIFs únicos: {len(result)}\n")
    return result

def find_best_match(exercise_id, search_terms, available_gifs):
    """Buscar la mejor coincidencia usando fuzzy matching"""
    best_match = None
    best_score = 0
    
    for gif in available_gifs:
        gif_text = (gif['name'] + ' ' + gif['title']).lower()
        
        for search_term in search_terms:
            search_lower = search_term.lower()
            
            # Coincidencia exacta
            if search_lower in gif_text:
                words = search_lower.split()
                score = sum(1 for word in words if word in gif_text)
                
                if score > best_score:
                    best_score = score
                    best_match = gif
    
    return best_match if best_score > 0 else None

def download_gif(url, filename, output_dir):
    """Descargar un GIF"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            filepath = output_dir / filename
            with open(filepath, 'wb') as f:
                f.write(response.content)
            size_kb = len(response.content) / 1024
            return True, size_kb
        return False, 0
    except Exception as e:
        return False, 0

def main():
    output_dir = Path('assets/exercise_gifs')
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 70)
    print("  DESCARGADOR MEJORADO DE GIFS DE GYMVISUAL.COM")
    print("=" * 70)
    print()
    
    # Obtener todos los GIFs
    available_gifs = get_all_gifs_from_gymvisual(max_pages=15)
    
    if not available_gifs:
        print("❌ No se pudieron obtener los GIFs")
        return
    
    downloaded = 0
    skipped = 0
    not_found = 0
    total_size_kb = 0
    
    print("🎯 Buscando y descargando ejercicios...\n")
    
    for exercise_id, search_terms in sorted(EXERCISE_MAPPING.items()):
        gif_path = output_dir / f"{exercise_id}.gif"
        
        if gif_path.exists():
            print(f"⏭️  {exercise_id}: Ya existe")
            skipped += 1
            continue
        
        matching_gif = find_best_match(exercise_id, search_terms, available_gifs)
        
        if matching_gif:
            display_name = matching_gif['name'] or matching_gif['title']
            print(f"📥 {exercise_id}: {display_name}")
            
            success, size_kb = download_gif(matching_gif['url'], f"{exercise_id}.gif", output_dir)
            
            if success:
                print(f"   ✅ Descargado ({size_kb:.1f} KB)")
                downloaded += 1
                total_size_kb += size_kb
            else:
                print(f"   ❌ Error al descargar")
                not_found += 1
        else:
            print(f"❌ {exercise_id}: No encontrado")
            print(f"   Buscado: {search_terms[0]}")
            not_found += 1
        
        print()
        time.sleep(0.3)
    
    # Resumen final
    print("\n" + "=" * 70)
    print("📊 RESUMEN FINAL")
    print("=" * 70)
    print(f"✅ Nuevos descargados: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ No encontrados: {not_found}")
    print(f"📁 Total en carpeta: {len(list(output_dir.glob('*.gif')))}")
    print(f"💾 Tamaño descargado: {total_size_kb:.1f} KB ({total_size_kb/1024:.2f} MB)")
    
    # Calcular porcentaje de cobertura
    total_needed = 106  # Total de ejercicios en la app
    current_total = len(list(output_dir.glob('*.gif')))
    coverage = (current_total / total_needed) * 100
    print(f"📈 Cobertura: {current_total}/106 ejercicios ({coverage:.1f}%)")
    print()

if __name__ == "__main__":
    main()
