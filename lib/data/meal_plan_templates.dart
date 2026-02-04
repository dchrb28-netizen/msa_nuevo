/// Plantillas de planes de comidas semanales predefinidas
class MealPlanTemplates {
  // Plan para pérdida de peso - 1500-1800 cal/día
  static const Map<String, Map<String, String>> weightLossPlan = {
    'Lunes': {
      'Desayuno': 'Avena integral (1/2 taza) con plátano (1) rebanado y almendras (15) | 350 cal',
      'Almuerzo': 'Pechuga de pollo a la plancha (150g) + Brócoli al vapor (200g) + Arroz integral (3/4 taza) | 420 cal',
      'Cena': 'Salmón a la papillota (120g) + Ensalada verde (200g con vinagre) + Camote al horno (1 mediano) | 380 cal',
      'Snacks': 'Manzana (1) + Mantequilla de cacahuete (1 cucharada) | 200 cal',
    },
    'Martes': {
      'Desayuno': 'Huevos revueltos (2) con tostada integral (1 rebanada) y tomate fresco (1 rodaja) | 280 cal',
      'Almuerzo': 'Pechuga de pavo molida (150g) con cebolla + Arroz integral (2/3 taza) + Verduras salteadas | 420 cal',
      'Cena': 'Filete de merluza al horno (140g) + Papa dulce (1 mediana) + Ensalada mixta | 360 cal',
      'Snacks': 'Yogur griego bajo en grasa (150g) | 120 cal',
    },
    'Miércoles': {
      'Desayuno': 'Batido: Proteína en polvo (25g) + Plátano (1) + Espinaca (1 puñado) + Leche descremada (200ml) | 320 cal',
      'Almuerzo': 'Atún enlatado en agua (110g) + Espagueti integral (1.5 tazas cocido) + Salsa de tomate casera | 420 cal',
      'Cena': 'Pollo al ajillo (140g) + Arroz integral (2/3 taza) + Zanahoria cocida (150g) | 380 cal',
      'Snacks': 'Zanahoria cruda (150g) + Hummus (2 cucharadas) | 150 cal',
    },
    'Jueves': {
      'Desayuno': 'Panqueques proteicos: Claras (2) + Avena (1/3 taza) + Endulzante natural | 280 cal',
      'Almuerzo': 'Filete de res magra a la parrilla (140g) + Papa cocida (1 mediana) + Lechuga | 420 cal',
      'Cena': 'Pechugas de pollo al horno con limón (150g) + Brócoli al vapor (250g) + Arroz integral (1/2 taza) | 360 cal',
      'Snacks': 'Nueces (15 unidades) | 180 cal',
    },
    'Viernes': {
      'Desayuno': 'Yogur natural sin azúcar (180g) + Granola casera (2 cucharadas) + Arándanos (80g) | 320 cal',
      'Almuerzo': 'Camarones al ajillo (150g) + Fideos de arroz (1.5 tazas cocidos) + Verduras salteadas | 400 cal',
      'Cena': 'Carne molida magra (140g) en salsa de tomate + Ensalada completa con aceite de oliva | 380 cal',
      'Snacks': 'Sandía fresca (1 rebanada mediana) | 140 cal',
    },
    'Sábado': {
      'Desayuno': 'Huevos revueltos (2) + Pan integral tostado (1 rebanada) + Aguacate (1/3) | 320 cal',
      'Almuerzo': 'Pechuga de pollo rellena de verduras (160g) + Ensalada mixta | 420 cal',
      'Cena': 'Salmón al horno con hierbas (130g) + Espárragos al vapor (200g) + Papa (1 pequeña) | 380 cal',
      'Snacks': 'Piña fresca (1 taza) | 120 cal',
    },
    'Domingo': {
      'Desayuno': 'Omelette de claras (3) con vegetales (champiñones, pimiento) + Queso bajo en grasa | 320 cal',
      'Almuerzo': 'Pollo a la naranja (140g) + Arroz integral (2/3 taza) + Brócoli | 420 cal',
      'Cena': 'Filete de tilapia (140g) al horno + Ensalada completa + Camote (3/4 taza) | 360 cal',
      'Snacks': 'Melocotón fresco (1) | 100 cal',
    },
  };

  // Plan para ganancia muscular - 2400-2800 cal/día
  static const Map<String, Map<String, String>> muscleBuildingPlan = {
    'Lunes': {
      'Desayuno': 'Avena (3/4 taza) + Plátano (2) + Huevos revueltos (3) + Almendras (20) | 750 cal',
      'Almuerzo': 'Pechuga de pollo (200g) a la parrilla + Arroz integral (1.5 tazas) + Espinaca salteada (150g) | 850 cal',
      'Cena': 'Salmón (180g) al horno + Papa cocida (1 grande) + Ensalada (200g) | 820 cal',
      'Snacks': 'Batido: Proteína (30g) + Avena (1/3 taza) + Leche (240ml) + Plátano (1) | 480 cal',
    },
    'Martes': {
      'Desayuno': 'Panqueques proteicos (3 claras) + Plátano (2) + Mantequilla de cacahuete (2 cucharadas) | 700 cal',
      'Almuerzo': 'Filete de res (180g) a la parrilla + Papas al horno (2 medianas) + Verduras salteadas (200g) | 850 cal',
      'Cena': 'Pechugas de pollo (200g) + Arroz integral (1.5 tazas) + Brócoli al vapor (250g) | 800 cal',
      'Snacks': 'Yogur griego (200g) + Granola (3 cucharadas) + Almendras (15) | 450 cal',
    },
    'Miércoles': {
      'Desayuno': 'Tortilla española (4 huevos) + Pan integral (2 rebanadas) + Aguacate (1/2) | 720 cal',
      'Almuerzo': 'Pechuga de pavo (200g) + Fideos integrales (2 tazas cocidos) + Salsa casera (100g) | 840 cal',
      'Cena': 'Atún fresco (200g) al horno + Arroz integral (1.5 tazas) + Zanahoria cocida (150g) | 800 cal',
      'Snacks': 'Batido: Proteína (30g) + Plátano (1) + Leche (240ml) + Miel (1 cucharada) | 440 cal',
    },
    'Jueves': {
      'Desayuno': 'Granola casera (4 cucharadas) + Yogur griego (250g) + Nueces (20) + Miel (1 cucharada) | 750 cal',
      'Almuerzo': 'Carne molida (200g) + Papas cocidas (1.5 medianas) + Lechuga | 850 cal',
      'Cena': 'Pollo al horno (200g) + Arroz integral (1.5 tazas) + Espárragos al vapor (200g) | 820 cal',
      'Snacks': 'Barrita de proteína + Manzana (1) + Mantequilla de almendra (1 cucharada) | 480 cal',
    },
    'Viernes': {
      'Desayuno': 'Avena instantánea (1 taza) + Plátano (2) + Huevos (3) + Mantequilla de cacahuete (2 cucharadas) | 800 cal',
      'Almuerzo': 'Salmón (180g) al horno + Arroz integral (1.5 tazas) + Verduras mixtas (200g) | 840 cal',
      'Cena': 'Pechugas de pollo (200g) + Papas dulces (1.5 medianas) + Ensalada | 800 cal',
      'Snacks': 'Batido: Proteína (30g) + Avena (1/3 taza) + Leche (240ml) + Plátano (1) | 480 cal',
    },
    'Sábado': {
      'Desayuno': 'Crepes de proteína (6 claras) + Mermelada natural (2 cucharadas) + Nueces (25) | 700 cal',
      'Almuerzo': 'Filete de res (200g) + Camote al horno (1.5 medianos) + Verduras (200g) | 850 cal',
      'Cena': 'Pollo (200g) + Fideos integrales (2 tazas) + Salsa casera | 800 cal',
      'Snacks': 'Yogur (200g) + Granola (3 cucharadas) + Almendras (20) | 500 cal',
    },
    'Domingo': {
      'Desayuno': 'Huevos revueltos (4) + Tostadas integrales (2) + Aguacate (1/2) | 750 cal',
      'Almuerzo': 'Atún (200g) + Arroz integral (1.5 tazas) + Papas cocidas (1 grande) + Lechuga | 850 cal',
      'Cena': 'Salmón (200g) al horno + Papa (1 grande) + Brócoli al vapor (250g) | 820 cal',
      'Snacks': 'Batido: Proteína (30g) + Leche (240ml) + Plátano (1) + Avena (1/4 taza) | 480 cal',
    },
  };

  // Plan equilibrado - 2000-2200 cal/día
  static const Map<String, Map<String, String>> balancedPlan = {
    'Lunes': {
      'Desayuno': 'Avena (1/2 taza) + Manzana (1) picada + Yogur natural (180g) + Almendras (15) | 420 cal',
      'Almuerzo': 'Pechuga de pollo (160g) a la parrilla + Arroz integral (1 taza) + Verduras mixtas salteadas (200g) | 580 cal',
      'Cena': 'Salmón (130g) al horno + Papa (1 mediana) + Ensalada verde (200g) con aceite de oliva | 520 cal',
      'Snacks': 'Plátano (1) + Mantequilla de almendra (1 cucharada) | 280 cal',
    },
    'Martes': {
      'Desayuno': 'Huevos revueltos (2) + Tostada integral (1) + Tomate fresco (2 rodajas) | 380 cal',
      'Almuerzo': 'Carne magra (160g) a la parrilla + Papas cocidas (2 medianas) + Brócoli (200g) | 580 cal',
      'Cena': 'Filete de tilapia (140g) + Camote (1 mediano) + Zanahoria cocida (150g) | 480 cal',
      'Snacks': 'Yogur con granola (200g yogur + 2 cucharadas granola) | 300 cal',
    },
    'Miércoles': {
      'Desayuno': 'Batido: Plátano (1) + Espinaca (1 puñado) + Leche (200ml) + Proteína (20g) | 380 cal',
      'Almuerzo': 'Pechuga de pavo (160g) + Fideos integrales (1.5 tazas) + Tomate en salsa | 580 cal',
      'Cena': 'Pollo al horno (150g) + Arroz integral (1 taza) + Ensalada mixta | 500 cal',
      'Snacks': 'Manzana (1) + Queso fresco (50g) | 280 cal',
    },
    'Jueves': {
      'Desayuno': 'Panqueques integrales (2) + Fresas (100g) + Miel (1 cucharada) | 400 cal',
      'Almuerzo': 'Atún (140g) + Arroz integral (1 taza) + Verduras salteadas (200g) | 580 cal',
      'Cena': 'Pechugas de pollo (160g) + Papa dulce (1 mediana) + Ensalada verde | 500 cal',
      'Snacks': 'Nueces (15 unidades) + Fruta (plátano o naranja) | 300 cal',
    },
    'Viernes': {
      'Desayuno': 'Yogur natural (200g) + Granola casera (3 cucharadas) + Arándanos (80g) | 400 cal',
      'Almuerzo': 'Res magra a la parrilla (160g) + Papas (2 medianas) + Lechuga | 580 cal',
      'Cena': 'Salmón (130g) al horno + Arroz integral (1 taza) + Brócoli al vapor (200g) | 520 cal',
      'Snacks': 'Batido: Proteína (20g) + Plátano (1) + Leche (200ml) | 280 cal',
    },
    'Sábado': {
      'Desayuno': 'Huevos al horno (2) con vegetales (pimiento, champiñones) + Pan integral (1) | 400 cal',
      'Almuerzo': 'Pollo relleno de vegetales (170g) + Papas al horno (1.5 medianas) + Ensalada | 580 cal',
      'Cena': 'Filete de merluza (140g) + Fideos integrales (1.5 tazas) + Zanahoria | 480 cal',
      'Snacks': 'Fruta fresca (1 taza) + Yogur (150g) | 280 cal',
    },
    'Domingo': {
      'Desayuno': 'Omelette (3 claras) con champiñones y queso fresco + Pan tostado | 400 cal',
      'Almuerzo': 'Pechuga de pollo (160g) + Arroz integral (1 taza) + Verduras (200g) | 580 cal',
      'Cena': 'Camarones al ajillo (150g) + Papa (1 grande) + Ensalada verde (200g) | 500 cal',
      'Snacks': 'Sandía o melón (1.5 tazas) | 200 cal',
    },
  };

  // Plan vegano - 1800-2200 cal/día
  static const Map<String, Map<String, String>> veganPlan = {
    'Lunes': {
      'Desayuno': 'Avena (3/4 taza) + Leche de almendra (200ml) + Plátano (1) + Nueces (15) | 420 cal',
      'Almuerzo': 'Lentejas cocidas (1.5 tazas) + Arroz integral (1 taza) + Verduras salteadas (200g) | 580 cal',
      'Cena': 'Tofu firme a la parrilla (200g) + Batata asada (1 mediana) + Brócoli al vapor (200g) | 520 cal',
      'Snacks': 'Hummus (2 cucharadas) + Zanahorias crudas (150g) | 180 cal',
    },
    'Martes': {
      'Desayuno': 'Batido vegano: Aguacate (1/2) + Plátano (1) + Leche de coco (200ml) + Semillas de lino (1 cucharada) | 400 cal',
      'Almuerzo': 'Garbanzos asados (1.5 tazas) + Cuscús integral (1.5 tazas) + Espinaca cocida (150g) | 620 cal',
      'Cena': 'Sopa de verduras (2 tazas) + Frijoles negros (1 taza) + Quinoa (3/4 taza) | 500 cal',
      'Snacks': 'Fruta seca (puñado) + Semillas de girasol (2 cucharadas) | 280 cal',
    },
    'Miércoles': {
      'Desayuno': 'Tostadas de pan integral (2) + Aguacate (1/2) + Tomate (2 rodajas) | 380 cal',
      'Almuerzo': 'Falafel casero (6 unidades) + Tahini (2 cucharadas) + Ensalada | 600 cal',
      'Cena': 'Pasta integral (2 tazas) + Salsa de tomate y verduras (200g) | 520 cal',
      'Snacks': 'Manzana (1) + Mantequilla de cacahuete (1 cucharada) | 280 cal',
    },
    'Jueves': {
      'Desayuno': 'Granola vegana (4 cucharadas) + Leche de almendra (200ml) + Arándanos (80g) | 400 cal',
      'Almuerzo': 'Tempeh marinado (200g) al horno + Arroz integral (1 taza) + Vegetales al vapor (200g) | 600 cal',
      'Cena': 'Curry de garbanzos (2 tazas) + Arroz integral (1 taza) + Brócoli | 540 cal',
      'Snacks': 'Yogur de soja (150g) + Frutos rojos (80g) | 200 cal',
    },
    'Viernes': {
      'Desayuno': 'Pudín de semillas de chía (2 cucharadas) + Leche de almendra (200ml) + Canela | 380 cal',
      'Almuerzo': 'Lentejas rojas cocidas (1.5 tazas) + Quinoa (1 taza) + Zanahoria asada (150g) | 600 cal',
      'Cena': 'Tofu deshebrado (200g) + Fideos de arroz (2 tazas) + Verduras salteadas (200g) | 520 cal',
      'Snacks': 'Batido: Proteína vegana (25g) + Plátano (1) + Leche de almendra (200ml) | 300 cal',
    },
    'Sábado': {
      'Desayuno': 'Panqueques veganos (2) con arándanos (100g) + Jarabe de agave (1 cucharada) | 400 cal',
      'Almuerzo': 'Hamburguesa vegana (1) con pan integral + Ensalada completa (200g) | 600 cal',
      'Cena': 'Chili de frijoles (2 tazas) + Papas cocidas (1.5 medianas) | 520 cal',
      'Snacks': 'Nueces (20 unidades) + Fruta fresca | 300 cal',
    },
    'Domingo': {
      'Desayuno': 'Omelette de tofu (200g) con setas y espinaca + Pan tostado (1) | 420 cal',
      'Almuerzo': 'Garbanzos al curry (1.5 tazas) + Arroz integral (1 taza) + Vegetales (150g) | 600 cal',
      'Cena': 'Pasta vegana (2 tazas) + Salsa de champiñones y espinaca (200g) | 520 cal',
      'Snacks': 'Batido vegano con proteína (25g) + Leche de almendra (200ml) | 280 cal',
    },
  };

  // Plan cetogénico - 1800-2200 cal/día
  static const Map<String, Map<String, String>> ketoPlan = {
    'Lunes': {
      'Desayuno': 'Huevos fritos (3) en mantequilla + Bacon (3 tiras) + Queso cheddar (50g) | 580 cal',
      'Almuerzo': 'Pechuga de pollo (180g) con mayo (2 cucharadas) + Ensalada con aceite de oliva (200g) | 620 cal',
      'Cena': 'Salmón a la mantequilla (160g) + Espárragos cocidos en mantequilla (200g) | 600 cal',
      'Snacks': 'Queso fresco (60g) + Almendras (20) | 400 cal',
    },
    'Martes': {
      'Desayuno': 'Omelette (3 huevos) con champiñones y queso cheddar (50g) | 520 cal',
      'Almuerzo': 'Filete de res (180g) a la parrilla con mantequilla + Verduras bajas en carbos (150g) | 620 cal',
      'Cena': 'Camarones al ajillo (160g) con aceite de oliva + Ensalada (200g) | 580 cal',
      'Snacks': 'Aguacate (1) con sal y pimienta | 350 cal',
    },
    'Miércoles': {
      'Desayuno': 'Huevos revueltos (3) con embutido (60g) + Queso cheddar (50g) | 580 cal',
      'Almuerzo': 'Hamburguesa sin pan (180g) con queso + Aguacate (1/2) + Lechuga | 600 cal',
      'Cena': 'Pechuga de pollo (180g) a la crema (150ml nata) + Brócoli (150g) | 620 cal',
      'Snacks': 'Nueces de macadamia (30g) | 380 cal',
    },
    'Jueves': {
      'Desayuno': 'Tocino (5 tiras) + Huevos fritos (3) + Aguacate (1/2) | 600 cal',
      'Almuerzo': 'Atún (140g) con mayonesa (2 cucharadas) + Queso fresco (50g) + Aceitunas (20) | 580 cal',
      'Cena': 'Salmón (160g) con salsa de queso (100ml) + Espárragos (200g) | 620 cal',
      'Snacks': 'Queso fresco (70g) | 350 cal',
    },
    'Viernes': {
      'Desayuno': 'Huevos rellenos de espinaca (3 huevos) + Queso cheddar (50g) | 520 cal',
      'Almuerzo': 'Carne molida (180g) con queso cheddar (50g) + Ensalada (200g) | 600 cal',
      'Cena': 'Costillas al horno (200g) + Col cocida en mantequilla (250g) | 620 cal',
      'Snacks': 'Almendras (25g) + Queso (50g) | 420 cal',
    },
    'Sábado': {
      'Desayuno': 'Huevos benedictinos (3 huevos) con jamón (60g) + Salsa holandesa (2 cucharadas) | 580 cal',
      'Almuerzo': 'Filete (180g) a la parrilla con queso azul (50g) + Ensalada (200g) | 620 cal',
      'Cena': 'Camarones (160g) en mantequilla + Calabacín salteado (200g) | 600 cal',
      'Snacks': 'Pecanas tostadas (30g) | 400 cal',
    },
    'Domingo': {
      'Desayuno': 'Huevos revueltos (4) + Salmón ahumado (60g) + Queso cheddar (50g) | 600 cal',
      'Almuerzo': 'Pechuga de pollo (180g) con mayo (2 cucharadas) + Tocino (3 tiras) + Lechuga | 620 cal',
      'Cena': 'Costillar a la parrilla (200g) + Espinaca con ajo (200g) en aceite | 620 cal',
      'Snacks': 'Queso cheddar (70g) | 400 cal',
    },
  };

  // Todos los planes disponibles
  static const Map<String, Map<String, Map<String, String>>> allPlans = {
    'Pérdida de Peso': weightLossPlan,
    'Ganancia Muscular': muscleBuildingPlan,
    'Equilibrado': balancedPlan,
    'Vegano': veganPlan,
    'Cetogénico': ketoPlan,
  };

  // Obtener descripción del plan
  static String getPlanDescription(String planName) {
    // Verificar si es una variante (contiene " - ")
    if (planName.contains(' - ')) {
      final parts = planName.split(' - ');
      if (parts.length == 2) {
        final basePlan = parts[0];
        return getPlanDescription(basePlan); // Retorna descripción del plan base
      }
    }

    switch (planName) {
      case 'Pérdida de Peso':
        return 'Plan 1500-1800 cal/día con déficit calórico controlado. Proteína moderada para mantener músculo y saciedad prolongada.';
      case 'Ganancia Muscular':
        return 'Plan 2400-2800 cal/día con alto contenido proteico (30-35%). Ideal para hipertrofia con múltiples comidas.';
      case 'Equilibrado':
        return 'Plan 2000-2200 cal/día con macros balanceados (40% carbs, 30% proteína, 30% grasas). Perfecto para mantenimiento.';
      case 'Vegano':
        return 'Plan completamente vegano 1800-2200 cal/día con proteínas de legumbres, tofu y tempeh. Nutricionalmente completo.';
      case 'Cetogénico':
        return 'Plan bajo en carbos 1800-2200 cal/día (<50g carbos). Alto en grasas saludables para cetosis natural.';
      default:
        return '';
    }
  }

  // Obtener descripción detallada del plan (para mostrar en modal)
  static String getPlanDetailedDescription(String planName) {
    // Verificar si es una variante (contiene " - ")
    if (planName.contains(' - ')) {
      return _getVariantDescription(planName);
    }

    switch (planName) {
      case 'Pérdida de Peso':
        return '''🎯 PLAN PÉRDIDA DE PESO

📊 Calorías: 1500-1800 kcal/día
⚖️ Macros: 40% Carbos, 30% Proteína, 30% Grasas

📝 Descripción:
Este plan crea un déficit calórico controlado (500 kcal/día) para perder peso de forma sostenible. Enfatiza alimentos ricos en proteína y fibra para mantener la saciedad y evitar perder músculo.

✨ Beneficios:
• Pérdida de peso consistente (0.5-1 kg/semana)
• Mantiene la masa muscular gracias a proteína suficiente
• Alimentos naturales y sin restricciones extremas
• Fácil de mantener a largo plazo

🥗 Alimentos recomendados:
• Proteínas magras (pollo, pavo, pescado)
• Verduras bajas en calorías (brócoli, espinaca)
• Carbos complejos (arroz integral, avena)
• Grasas saludables (aceite de oliva, aguacate)

⚠️ Consideraciones:
• Requiere consistencia en el entrenamiento
• Mantén ingesta de agua alta (2-3L/día)
• Evita azúcares refinados''';

      case 'Ganancia Muscular':
        return '''💪 PLAN GANANCIA MUSCULAR

📊 Calorías: 2400-2800 kcal/día
⚖️ Macros: 40% Carbos, 35% Proteína, 25% Grasas

📝 Descripción:
Este plan proporciona un superávit calórico moderado combinado con alta ingesta proteica (2-2.2g por kg de peso). Diseñado para construir masa muscular con entrenamiento de fuerza regular.

✨ Beneficios:
• Proporciona energía para entrenamientos intensos
• Alto contenido proteico para recuperación muscular
• Ganancia de peso controlada (0.5 kg/semana)
• Macros optimizados para hipertrofia

🥗 Alimentos recomendados:
• Proteínas de calidad (res magra, huevos, salmón)
• Carbos energéticos (papa, plátano, pasta integral)
• Grasas para hormona anabólica (nueces, aceite)
• Lácteos (queso, yogur griego)

⚠️ Consideraciones:
• Combina con entrenamiento de fuerza 4-5 veces/semana
• Duerme 7-9 horas diarias
• Come cada 3-4 horas para máxima síntesis proteica''';

      case 'Equilibrado':
        return '''⚖️ PLAN EQUILIBRADO

📊 Calorías: 2000-2200 kcal/día
⚖️ Macros: 40% Carbos, 30% Proteína, 30% Grasas

📝 Descripción:
Este es el plan más versátil y fácil de mantener. Mantiene el peso actual con una distribución balanceada de macronutrientes, ideal para personas activas o que buscan estabilidad.

✨ Beneficios:
• Balance perfecto para salud general
• Fácil de adaptar a cualquier estilo de vida
• Proporciona energía sostenida todo el día
• Adecuado para ejercicio moderado regular

🥗 Alimentos recomendados:
• Variedad de proteínas (pollo, pescado, legumbres)
• Granos integrales (avena, arroz, quinoa)
• Frutas y verduras coloridas
• Grasas variadas (olive, frutos secos, coco)

⚠️ Consideraciones:
• Perfecto para mantenimiento a largo plazo
• Mantén la consistencia en porciones
• Ideal combinado con 150 min ejercicio/semana''';

      case 'Vegano':
        return '''🌱 PLAN VEGANO

📊 Calorías: 1800-2200 kcal/día
⚖️ Macros: 45% Carbos, 25% Proteína, 30% Grasas

📝 Descripción:
Plan 100% basado en plantas sin carne, pescado ni productos animales. Utiliza legumbres, tofu, tempeh y semillas como fuentes principales de proteína. Nutricionalmente completo cuando se planifica correctamente.

✨ Beneficios:
• Alineado con valores éticos y ambientales
• Alto en fibra y antioxidantes
• Reduce inflamación
• Generalmente más económico

🥗 Alimentos recomendados:
• Proteínas (legumbres, tofu, tempeh, seitán)
• Semillas (chía, lino, calabaza, girasol)
• Granos integrales (quinoa, mijo)
• Leches vegetales enriquecidas
• Frutos secos y mantequillas de frutos secos

⚠️ Consideraciones:
• Monitorea vitamina B12 (suplemento recomendado)
• Asegura combinación de aminoácidos
• Come variedad de legumbres y granos
• Considera suplemento de vitamina D en invierno''';

      case 'Cetogénico':
        return '''🥑 PLAN CETOGÉNICO

📊 Calorías: 1800-2200 kcal/día
⚖️ Macros: <5% Carbos, 25% Proteína, 70% Grasas

📝 Descripción:
Plan muy bajo en carbohidratos (<50g/día) que induce cetosis, donde el cuerpo quema grasa como combustible principal. Altas en grasas saludables, proteína moderada, mínimo carbos.

✨ Beneficios:
• Pérdida de peso rápida inicial
• Reducción de apetito natural
• Energía estable sin picos de azúcar
• Mejora de enfoque mental ("keto flu" desaparece)

🥗 Alimentos recomendados:
• Grasas saludables (aceite de oliva, aguacate, coco)
• Proteínas (huevos, carne, pescado, queso)
• Verduras bajas en carbos (espinaca, brócoli, calabacín)
• Frutos secos y semillas sin abusar
• Lácteos enteros

❌ Alimentos prohibidos:
• Azúcar y dulces
• Granos y harinas
• Frutas con alto índice glucémico
• Refrescos y bebidas azucaradas

⚠️ Consideraciones:
• Adaptación de 1-2 semanas
• Riesgo de "keto flu" (cansancio temporal)
• Monitorea electrolitos (sodio, potasio, magnesio)
• No ideal para atletas de alto rendimiento
• Requiere seguimiento médico para algunos casos''';

      default:
        return '';
    }
  }

  // Obtener descripción para variantes (ej: "Pérdida de Peso - Vegano")
  static String _getVariantDescription(String variantName) {
    final parts = variantName.split(' - ');
    if (parts.length != 2) return '';

    final basePlan = parts[0];
    final variant = parts[1].trim();

    String baseDescription = getPlanDetailedDescription(basePlan);
    
    // Agregar información específica de la variante
    String variantNote = '';

    switch (variant) {
      case 'Vegano':
        variantNote = '''

───────────────────────────────────────

🌱 VARIANTE: VEGANO

Esta es una adaptación vegana del plan base, reemplazando todas las proteínas animales por alternativas basadas en plantas:

✅ Cambios principales:
• Proteína animal → Legumbres (lentejas, garbanzos, frijoles)
• Carne → Tofu, tempeh, seitán
• Pescado → Algas ricas en omega-3, semillas de chía y lino
• Lácteos → Bebidas y productos vegetales enriquecidos

⚡ Consideraciones veganas:
• Asegura ingesta de vitamina B12 (suplemento recomendado)
• Combina legumbres con granos para proteína completa
• Aumenta variedad de semillas por minerales
• Planifica combinaciones cuidadosamente

🥗 Sustituciones sugeridas:
• Pollo → Tofu marinado o tempeh a la parrilla
• Huevos → Tofu revuelto o legumbres
• Leche → Leche de almendra, soya o avena enriquecida
• Queso → Queso vegano o nutritional yeast''';
        break;

      case 'Sin Azúcar':
        variantNote = '''

───────────────────────────────────────

🍯 VARIANTE: SIN AZÚCAR

Esta variante elimina azúcares refinados y reduce al mínimo los azúcares naturales, ideal para control glucémico:

✅ Cambios principales:
• Sin azúcar refinada en bebidas o postres
• Frutas limitadas a bajas en índice glucémico (berries, manzanas)
• Alimentos altamente procesados → opciones naturales
• Endulzantes naturales (stevia, eritritol) en lugar de azúcar

⚡ Consideraciones:
• Aumenta saciedad con más proteína y grasas
• Energía más estable sin picos de glucosa
• Mejor para control de diabetes o prediabetes
• Requiere lectura de etiquetas cuidadosa

🚫 Alimentos a evitar:
• Azúcar blanca/morena, miel, agave
• Bebidas azucaradas (refrescos, jugos)
• Postres y dulces convencionales
• Carbos refinados (pan blanco, pasta blanca)

✅ Opciones recomendadas:
• Endulzantes sin calorías (stevia, eritritol)
• Frutas con bajo índice glucémico
• Granos integrales
• Proteína y grasas saludables para saciedad''';
        break;

      case 'Cetogénico':
        variantNote = '''

───────────────────────────────────────

🥑 VARIANTE: CETOGÉNICA

Esta versión extremadamente baja en carbos (<30g/día) potencia la cetosis para máxima pérdida de peso:

✅ Cambios principales:
• Reducción drástica de carbos (objetivo <30-50g/día)
• Aumento significativo de grasas saludables (70% de calorías)
• Eliminación casi total de carbos refinados
• Énfasis en proteína moderada

⚡ Estado cetónico:
• El cuerpo quema grasa como combustible primario
• Pérdida de peso más rápida inicialmente
• Apetito reducido naturalmente
• Energía mental mejorada (después de adaptación)

📊 Macros cetogénicos:
• Carbos: <5% (máximo 30g/día)
• Proteína: 20-25%
• Grasas: 70-75%

⚠️ Adaptación (semanas 1-2):
• Posible "keto flu" (fatiga, dolores de cabeza)
• Aumenta ingesta de agua y electrolitos
• Paciencia - el cuerpo se adapta

🥒 Alimentos estrella:
• Grasas: aceite de oliva, aguacate, coco, mantequilla
• Proteína: carne, pescado, huevos, queso completo
• Verduras bajas en carbos: espinaca, brócoli, calabacín
• Frutos secos: almendras, nueces (en moderación)''';
        break;

      default:
        return baseDescription;
    }

    return baseDescription + variantNote;
  }

}
