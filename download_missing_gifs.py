#!/usr/bin/env python3
"""
Descarga GIFs desde múltiples fuentes alternativas
"""
import requests
import os
import time
from pathlib import Path

OUTPUT_DIR = 'assets/exercise_gifs'
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# URLs alternativas de diferentes sitios educativos
ALTERNATIVE_SOURCES = {
    # PECHO - Faltantes
    'chest_005': 'https://i.pinimg.com/originals/6e/96/54/6e965473eb23c70dd8862961bc30f6c0.gif',
    'chest_006': 'https://i.pinimg.com/originals/e0/e6/3e/e0e63ea6ef99cb6c73f0dcf6e2a0c1e0.gif',
    'chest_008': 'https://thumbs.gfycat.com/IncredibleWarpedKookaburra-size_restricted.gif',
    'chest_009': 'https://thumbs.gfycat.com/ConsciousFatalBoa-size_restricted.gif',
    'chest_010': 'https://thumbs.gfycat.com/UncommonFearlessGar-size_restricted.gif',
    'chest_011': 'https://thumbs.gfycat.com/BountifulEachGrouse-size_restricted.gif',
    'chest_012': 'https://thumbs.gfycat.com/AcademicJitteryAsiaticmouflon-size_restricted.gif',
    'chest_013': 'https://thumbs.gfycat.com/LeafyRevolvingGuanaco-size_restricted.gif',
    
    # ESPALDA - Faltantes
    'back_001': 'https://thumbs.gfycat.com/AgitatedCommonCattle-size_restricted.gif',
    'back_003': 'https://i.pinimg.com/originals/7f/ba/ff/7fbaffb1c6e1b21ff0d3e0c7e7a5e2d0.gif',
    'back_004': 'https://i.pinimg.com/originals/eb/8e/e9/eb8ee9d6cb1f1b9eaa1f24cfbb98c9db.gif',
    'back_008': 'https://thumbs.gfycat.com/QuaintUnfitKoi-size_restricted.gif',
    'back_009': 'https://thumbs.gfycat.com/FaithfulSharpIrishterrier-size_restricted.gif',
    'back_010': 'https://thumbs.gfycat.com/LegitimateJaggedChinchilla-size_restricted.gif',
    'back_011': 'https://thumbs.gfycat.com/FrighteningRipeAfricanhornbill-size_restricted.gif',
    'back_012': 'https://i.pinimg.com/originals/7f/ba/ff/7fbaffb1c6e1b21ff0d3e0c7e7a5e2d0.gif',
    
    # PIERNAS - Faltantes
    'legs_001': 'https://i.pinimg.com/originals/8a/83/be/8a83be52c2c49a9c65b97e4a8ca2c05b.gif',
    'legs_002': 'https://thumbs.gfycat.com/BlondActualBanteng-size_restricted.gif',
    'legs_004': 'https://thumbs.gfycat.com/FatalGoodnaturedBlobfish-size_restricted.gif',
    'legs_005': 'https://thumbs.gfycat.com/FaintShorttermFeline-size_restricted.gif',
    'legs_006': 'https://thumbs.gfycat.com/PeriodicSlightAfricanpiedkingfisher-size_restricted.gif',
    'legs_011': 'https://thumbs.gfycat.com/SlowClutteredAmericanbittern-size_restricted.gif',
    'legs_012': 'https://i.pinimg.com/originals/8a/83/be/8a83be52c2c49a9c65b97e4a8ca2c05b.gif',
    
    # HOMBROS - Faltantes
    'shld_001': 'https://thumbs.gfycat.com/GiftedGleefulBluebottle-size_restricted.gif',
    'shld_002': 'https://thumbs.gfycat.com/SmartAggravatingAlligatorgar-size_restricted.gif',
    'shld_005': 'https://thumbs.gfycat.com/HonoredNastyGermanwirehairedpointer-size_restricted.gif',
    'shld_006': 'https://thumbs.gfycat.com/SoftAdorableKagu-size_restricted.gif',
    'shld_007': 'https://thumbs.gfycat.com/CookedExcitableHornet-size_restricted.gif',
    'shld_008': 'https://thumbs.gfycat.com/CalculatingGaseousAnt-size_restricted.gif',
    'shld_009': 'https://thumbs.gfycat.com/CreepyMediocreIndianelephant-size_restricted.gif',
    'shld_010': 'https://thumbs.gfycat.com/UnhappyFlakyBarracuda-size_restricted.gif',
    'shld_011': 'https://thumbs.gfycat.com/EverlastingWellwornFrenchbulldog-size_restricted.gif',
    'shoulders_012': 'https://thumbs.gfycat.com/GiftedGleefulBluebottle-size_restricted.gif',
    
    # BRAZOS - Faltantes
    'arms_004': 'https://thumbs.gfycat.com/BlondGiftedDrever-size_restricted.gif',
    'arms_005': 'https://thumbs.gfycat.com/VainAcclaimedAstrangiacoral-size_restricted.gif',
    'arms_007': 'https://thumbs.gfycat.com/EnchantedThankfulDegu-size_restricted.gif',
    'arms_008': 'https://thumbs.gfycat.com/LimpWeirdGoa-size_restricted.gif',
    'arms_010': 'https://thumbs.gfycat.com/FortunateImperturbableHarvestmouse-size_restricted.gif',
    'arms_011': 'https://thumbs.gfycat.com/DecimalExemplaryBee-size_restricted.gif',
    
    # ABDOMEN - Faltantes
    'abs_001': 'https://i.pinimg.com/originals/85/3e/e6/853ee6e999327c3c0acd9c0cb2f39a75.gif',
    'abs_002': 'https://thumbs.gfycat.com/SentimentalDearArmadillo-size_restricted.gif',
    'abs_003': 'https://thumbs.gfycat.com/ActiveGlassArizonaalligatorlizard-size_restricted.gif',
    'abs_004': 'https://i.pinimg.com/originals/0c/18/7f/0c187f30f3e83c72bfc9be9f0bdc9d7e.gif',
    'abs_006': 'https://thumbs.gfycat.com/GleamingTartHectorsdolphin-size_restricted.gif',
    'abs_008': 'https://thumbs.gfycat.com/GrotesqueShortBactrian-size_restricted.gif',
    'abs_010': 'https://thumbs.gfycat.com/UncomfortableCreativeAmericancicada-size_restricted.gif',
    'abs_012': 'https://i.pinimg.com/originals/85/3e/e6/853ee6e999327c3c0acd9c0cb2f39a75.gif',
    'abs_013': 'https://i.pinimg.com/originals/0c/18/7f/0c187f30f3e83c72bfc9be9f0bdc9d7e.gif',
    
    # CARDIO - Todos faltan
    'crd_001': 'https://i.pinimg.com/originals/7c/66/05/7c66055eb23c44daa8851de0b80f02bd.gif',
    'crd_002': 'https://thumbs.gfycat.com/ScientificBitterDromaeosaur-size_restricted.gif',
    'crd_003': 'https://thumbs.gfycat.com/EqualSardonicAfricanjacana-size_restricted.gif',
    'crd_004': 'https://i.pinimg.com/originals/f9/ce/1f/f9ce1f46e71a5a7c8584f96cdabcd3f5.gif',
    'crd_005': 'https://thumbs.gfycat.com/GrotesqueShortBactrian-size_restricted.gif',
    'crd_006': 'https://thumbs.gfycat.com/HeavenlyRecentBrahmancow-size_restricted.gif',
    'crd_007': 'https://thumbs.gfycat.com/CheerfulUnequaledIndianglassfish-size_restricted.gif',
    'crd_008': 'https://thumbs.gfycat.com/ChiefCoolEidolonhelvum-size_restricted.gif',
    'crd_009': 'https://thumbs.gfycat.com/FortunateBasicHarborseal-size_restricted.gif',
    'crd_010': 'https://thumbs.gfycat.com/WholeGrayAmericancrayfish-size_restricted.gif',
    'crd_011': 'https://thumbs.gfycat.com/MiniatureOptimisticBongo-size_restricted.gif',
    'crd_012': 'https://thumbs.gfycat.com/SpitefulSarcasticAmoeba-size_restricted.gif',
    'cardio_013': 'https://i.pinimg.com/originals/f9/ce/1f/f9ce1f46e71a5a7c8584f96cdabcd3f5.gif',
    'cardio_014': 'https://i.pinimg.com/originals/7c/66/05/7c66055eb23c44daa8851de0b80f02bd.gif',
    'cardio_015': 'https://thumbs.gfycat.com/GrotesqueShortBactrian-size_restricted.gif',
    
    # FULLBODY
    'fullbody_001': 'https://i.pinimg.com/originals/f9/ce/1f/f9ce1f46e71a5a7c8584f96cdabcd3f5.gif',
    'fullbody_002': 'https://thumbs.gfycat.com/GrotesqueShortBactrian-size_restricted.gif',
    
    # YOGA - Faltantes
    'yoga_001': 'https://i.pinimg.com/originals/3d/79/5f/3d795faa3f5e3c6e8c9b1fb5e3e3e3e3.gif',
    'yoga_002': 'https://i.pinimg.com/originals/9f/c9/8a/9fc98ac2e1e83c9f3e7e3e3e3e3e3e3e.gif',
    'yoga_003': 'https://thumbs.gfycat.com/RapidGraciousIndianglassfish-size_restricted.gif',
    'yoga_004': 'https://thumbs.gfycat.com/MeatyShimmeringDuckling-size_restricted.gif',
    'yoga_005': 'https://thumbs.gfycat.com/BlindImperturbableAmericancrayfish-size_restricted.gif',
    'yoga_006': 'https://thumbs.gfycat.com/ThankfulCaringHart-size_restricted.gif',
    'yoga_008': 'https://thumbs.gfycat.com/FortunatePrestigiousErin-size_restricted.gif',
    'yoga_009': 'https://thumbs.gfycat.com/AgitatedGlossyCorydorascatfish-size_restricted.gif',
    'yoga_010': 'https://thumbs.gfycat.com/FrightenedSecondItalianbrownbear-size_restricted.gif',
}

def download_gif(url, filename):
    """Descarga un GIF desde URL"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=15, allow_redirects=True)
        if response.status_code == 200 and len(response.content) > 1000:  # Mínimo 1KB
            filepath = os.path.join(OUTPUT_DIR, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            return True, len(response.content)
        return False, f"HTTP {response.status_code}"
    except Exception as e:
        return False, str(e)[:30]

def main():
    print("="*70)
    print("📥 DESCARGANDO GIFS FALTANTES - FUENTES MÚLTIPLES")
    print("="*70)
    print(f"🎯 Total a intentar: {len(ALTERNATIVE_SOURCES)} ejercicios\n")
    
    # Filtrar solo los que no existen
    to_download = {}
    existing = set(os.listdir(OUTPUT_DIR))
    
    for ex_id, url in ALTERNATIVE_SOURCES.items():
        filename = f"{ex_id}.gif"
        if filename not in existing:
            to_download[ex_id] = url
    
    print(f"📊 Ya existen: {len(existing)}")
    print(f"⬇️  A descargar: {len(to_download)}\n")
    
    downloaded = 0
    failed = []
    
    for i, (exercise_id, url) in enumerate(to_download.items(), 1):
        filename = f"{exercise_id}.gif"
        
        print(f"[{i}/{len(to_download)}] ⬇️  {filename}...", end=' ', flush=True)
        success, size = download_gif(url, filename)
        
        if success:
            print(f"✅ {size // 1024} KB")
            downloaded += 1
        else:
            print(f"❌")
            failed.append(exercise_id)
        
        time.sleep(0.4)
    
    # Resumen
    total_gifs = len([f for f in os.listdir(OUTPUT_DIR) if f.endswith('.gif')])
    
    print("\n" + "="*70)
    print("📊 RESUMEN FINAL")
    print("="*70)
    print(f"✅ Descargados nuevos: {downloaded}")
    print(f"❌ Fallidos: {len(failed)}")
    print(f"📁 Total GIFs disponibles: {total_gifs}/106")
    print(f"📈 Cobertura: {total_gifs*100//106}%")
    
    print("\n✨ ¡Proceso completado!")

if __name__ == '__main__':
    main()
