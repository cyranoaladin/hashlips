# 🐷 Analyse des 3 Catégories Oinkonomics

## 📊 Structure des Layers par Catégorie

### 🥉 POOR (0-9999) - 6 Layers
```
layers/POOR/
├── 1.Background/    # Arrière-plan
├── 2.Skins/         # Peau du cochon
├── 3.Outfit/        # Tenue/vêtements
├── 4.Mouth/         # Bouche
├── 5.Eyes/          # Yeux
└── 6.Headtop/       # Accessoire de tête
```

**Caractéristiques POOR:**
- 6 layers seulement (moins de détails)
- Pas de nez, pas d'oreilles (traits simplifiés)
- Design plus simple et minimaliste
- Représente les portefeuilles avec peu de SOL

---

### 🥈 MID (10000-19999) - 8 Layers
```
layers/MID/
├── 1.Background/    # Arrière-plan
├── 2.Skin/          # Peau du cochon
├── 3.Outfit/        # Tenue/vêtements
├── 4.Eyes/          # Yeux
├── 5.Nose/          # Nez ⭐
├── 6.Ears/          # Oreilles ⭐
├── 7.Mouth/         # Bouche
└── 8.Headtop/       # Accessoire de tête
```

**Caractéristiques MID:**
- 8 layers (plus détaillé)
- **+ Nez** (trait additionnel)
- **+ Oreilles** (trait additionnel)
- Design plus élaboré
- Représente les portefeuilles moyens

---

### 🥇 RICH (20000-29999) - 8 Layers
```
layers/RICH/
├── 1.Background/    # Arrière-plan
├── 2.Skins/         # Peau du cochon
├── 3.Outfit/        # Tenue/vêtements  
├── 4.Mouth/         # Bouche
├── 5.Eyes/          # Yeux
├── 6.Nose/          # Nez ⭐
├── 7.Ears/          # Oreilles ⭐
└── 8.Headtop/       # Accessoire de tête
```

**Caractéristiques RICH:**
- 8 layers (maximum de détails)
- **+ Nez** (trait premium)
- **+ Oreilles** (trait premium)
- Design le plus sophistiqué
- Outfits probablement plus luxueux
- Représente les gros portefeuilles

---

## 🎯 Différences Clés

| Feature | POOR | MID | RICH |
|---------|------|-----|------|
| **Layers** | 6 | 8 | 8 |
| **Nez** | ❌ | ✅ | ✅ |
| **Oreilles** | ❌ | ✅ | ✅ |
| **Complexité** | Simple | Moyenne | Élevée |
| **Range** | 0-9999 | 10000-19999 | 20000-29999 |
| **Quantité** | 10,000 | 10,000 | 10,000 |

## 🎨 Implications Visuelles

### POOR (Simple)
- Look plus cartoon/minimaliste
- Moins de layers = moins de variations
- Accessibles visuellement

### MID (Équilibré)
- Look plus détaillé
- Ajout du nez et des oreilles pour plus de personnalité
- Bon équilibre entre simplicité et détail

### RICH (Premium)
- Look le plus détaillé
- Tous les traits faciaux présents
- Probablement les outfits les plus luxueux
- Maximum de variations possibles

## 🔢 Calcul de Variations

### POOR (6 layers)
Si chaque layer a ~10 variantes :
- 10^6 = 1,000,000 combinaisons possibles
- Génération de 10,000 = 1% des possibilités

### MID & RICH (8 layers)
Si chaque layer a ~10 variantes :
- 10^8 = 100,000,000 combinaisons possibles
- Génération de 10,000 = 0.01% des possibilités

✅ **Pas de risque de manquer de variations uniques !**

## 🌐 Métadonnées

Tous les NFTs incluent :
```json
{
  "name": "Oinkonomics #0",
  "symbol": "OINK",
  "description": "Oinkonomics collection...",
  "external_url": "https://oinkonomics.fun",
  "image": "0.png",
  "attributes": [
    { "trait_type": "Background", "value": "..." },
    { "trait_type": "Skin", "value": "..." },
    { "trait_type": "Outfit", "value": "..." },
    ...
  ]
}
```

## 📁 Structure de Génération

```
build/
├── images/
│   ├── 0.png → 9999.png      (POOR)
│   ├── 10000.png → 19999.png (MID)
│   └── 20000.png → 29999.png (RICH)
└── json/
    ├── 0.json → 9999.json      (POOR)
    ├── 10000.json → 19999.json (MID)
    └── 20000.json → 29999.json (RICH)
```

## ✅ Configuration Actuelle

- ✅ URL mise à jour: **oinkonomics.fun**
- ✅ 3 tiers correctement configurés
- ✅ Layers séparés par catégorie
- ✅ Total: 30,000 NFTs
- ✅ Symbol: OINK
- ✅ Royalties: 5%

---

**Prêt à générer avec la nouvelle URL !** 🚀
