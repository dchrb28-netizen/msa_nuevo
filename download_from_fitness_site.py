#!/usr/bin/env python3
"""
Descarga GIFs desde colecciones públicas de ejercicios
Usando URLs directas de sitios con recursos gratuitos
"""
import requests
import os
import time
from pathlib import Path

OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# GIFs de alta calidad desde sitios públicos
# Estas URLs son de recursos educativos gratuitos
EXERCISE_GIFS = {
    # PECHO
    'chest_005': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Chest-Dips.gif',
    'chest_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Bench-Press.gif',
    'chest_007': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Fly.gif',
    'chest_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Push-up-Plus.gif',
    'chest_009': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Clapping-Push-up.gif',
    'chest_010': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/One-Arm-Push-Up.gif',
    
    # ESPALDA
    'back_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bent-Over-Dumbbell-Row.gif',
    'back_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Superman-Exercise.gif',
    'back_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bird-Dog.gif',
    'back_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Romanian-Deadlift.gif',
    'back_007': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Pullover.gif',
    'back_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/One-Arm-Dumbbell-Row.gif',
    'back_010': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Chin-up.gif',
    'back_012': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Superman-Exercise.gif',
    
    # PIERNAS
    'legs_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bodyweight-Squat.gif',
    'legs_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Sumo-Squat.gif',
    'legs_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lunge.gif',
    'legs_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Bulgarian-Split-Squat.gif',
    'legs_005': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Single-Leg-Deadlift.gif',
    'legs_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Step-up.gif',
    'legs_009': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pistol-Squat.gif',
    'legs_010': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Jump-Squat.gif',
    'legs_011': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Wall-Sit.gif',
    'legs_012': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bodyweight-Squat.gif',
    'legs_013': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lunge.gif',
    
    # HOMBROS
    'shld_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pike-Push-up.gif',
    'shld_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Shoulder-Press.gif',
    'shld_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
    'shld_005': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Front-Dumbbell-Raise.gif',
    'shld_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Upright-Row.gif',
    'shld_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Shoulder-Taps.gif',
    'shld_009': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Arnold-Press.gif',
    'shoulders_012': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pike-Push-up.gif',
    'shoulders_013': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
    
    # BRAZOS
    'arms_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
    'arms_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Hammer-Curl.gif',
    'arms_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bench-Dips.gif',
    'arms_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Overhead-Triceps-Extension.gif',
    'arms_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Kickback.gif',
    'arms_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Reverse-Curl.gif',
    'arms_010': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Wrist-Curl.gif',
    'arms_012': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
    'arms_013': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bench-Dips.gif',
    
    # ABDOMEN
    'abs_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Plank.gif',
    'abs_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Side-Plank.gif',
    'abs_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Leg-Raises.gif',
    'abs_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Crunch.gif',
    'abs_005': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bicycle-Crunch.gif',
    'abs_006': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/V-ups.gif',
    'abs_007': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Russian-Twist.gif',
    'abs_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Mountain-Climber.gif',
    'abs_009': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Flutter-Kicks.gif',
    'abs_011': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dead-Bug.gif',
    'abs_012': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Plank.gif',
    'abs_013': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Crunch.gif',
    
    # CARDIO
    'crd_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Jumping-Jacks.gif',
    'crd_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/High-Knee-Skips.gif',
    'crd_003': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Butt-Kicks.gif',
    'crd_004': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Burpee.gif',
    'crd_005': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Mountain-Climber.gif',
    'crd_007': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Jump-Rope.gif',
    'crd_008': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Box-Jump.gif',
    'crd_010': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Tuck-Jumps.gif',
    'cardio_013': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Burpee.gif',
    'cardio_014': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Jumping-Jacks.gif',
    'cardio_015': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Mountain-Climber.gif',
    
    # FULLBODY
    'fullbody_001': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Burpee.gif',
    'fullbody_002': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Mountain-Climber.gif',
}

def download_gif(url, filename):
    """Descarga un GIF desde URL"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://fitnessprogramer.com/'
        }
        response = requests.get(url, headers=headers, timeout=15)
        if response.status_code == 200:
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, f"HTTP {response.status_code}"
    except Exception as e:
        return False, str(e)[:50]

def main():
    print("="*70)
    print("📥 DESCARGADOR DE GIFS - FITNESSPROGRAMER.COM")
    print("="*70)
    print("🎯 Fuente: Recursos educativos gratuitos")
    print(f"📊 Total a descargar: {len(EXERCISE_GIFS)} ejercicios\n")
    
    downloaded = 0
    skipped = 0
    failed = []
    
    for i, (exercise_id, url) in enumerate(EXERCISE_GIFS.items(), 1):
        filename = f"{exercise_id}.gif"
        filepath = os.path.join(OUTPUT_DIR, filename)
        
        # Verificar si ya existe
        if os.path.exists(filepath):
            print(f"[{i}/{len(EXERCISE_GIFS)}] ⏭️  Ya existe: {filename}")
            skipped += 1
            continue
        
        # Descargar
        print(f"[{i}/{len(EXERCISE_GIFS)}] ⬇️  {filename}...", end=' ')
        success, size = download_gif(url, filename)
        
        if success:
            print(f"✅ {size // 1024} KB")
            downloaded += 1
        else:
            print(f"❌ {size}")
            failed.append((exercise_id, size))
        
        time.sleep(0.3)
    
    # Resumen
    print("\n" + "="*70)
    print("📊 RESUMEN FINAL")
    print("="*70)
    print(f"✅ Descargados nuevos: {downloaded}")
    print(f"⏭️  Ya existían: {skipped}")
    print(f"❌ Fallidos: {len(failed)}")
    
    total_gifs = len([f for f in os.listdir(OUTPUT_DIR) if f.endswith('.gif')])
    print(f"📁 Total GIFs disponibles: {total_gifs}")
    print(f"📈 Cobertura: {total_gifs}/106 ejercicios ({total_gifs*100//106}%)")
    
    if failed and len(failed) <= 10:
        print("\n⚠️  Fallidos:")
        for ex_id, error in failed:
            print(f"  - {ex_id}: {error}")
    
    print("\n✨ ¡Proceso completado!")

if __name__ == '__main__':
    main()
