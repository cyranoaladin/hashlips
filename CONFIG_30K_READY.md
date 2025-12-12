# ✅ Configuration 30K NFTs - Oinkonomics

**Date**: 6 décembre 2025  
**Status**: ✅ **CONFIGURÉ ET PRÊT**

---

## 📊 Configuration de la Collection

### Distribution des NFTs

| Tier | Range NFT | Quantité | Layers | Combinaisons Possibles |
|------|-----------|----------|--------|------------------------|
| **POOR** | 0 - 9,999 | 10,000 | 6 layers | 409,600 ✅ |
| **MID** | 10,000 - 19,999 | 10,000 | 8 layers | 29,491,200 ✅ |
| **RICH** | 20,000 - 29,999 | 10,000 | 8 layers | 86,400,000 ✅ |
| **TOTAL** | 0 - 29,999 | **30,000** | - | **Suffisant** |

---

## 🎨 Détails des Layers

### POOR (6 layers - 409,600 combinaisons)
- **Background**: 10 variations
- **Skin**: 4 variations
- **Outfit**: 10 variations
- **Eyes**: 8 variations
- **Mouth**: 8 variations
- **Headtop**: 16 variations

### MID (8 layers - 29,491,200 combinaisons)
- **Background**: 10 variations
- **Skin**: 4 variations
- **Outfit**: 8 variations
- **Eyes**: 8 variations
- **Nose**: 8 variations
- **Ears**: 8 variations
- **Mouth**: 12 variations
- **Headtop**: 15 variations

### RICH (8 layers - 86,400,000 combinaisons)
- **Background**: 10 variations
- **Skin**: 5 variations
- **Outfit**: 10 variations
- **Eyes**: 10 variations
- **Nose**: 8 variations
- **Ears**: 12 variations
- **Mouth**: 12 variations
- **Headtop**: 15 variations

---

## 📝 Métadonnées

Chaque NFT contient:

```json
{
  "name": "Oinkonomics #[0-29999]",
  "symbol": "OINK",
  "description": "Oinkonomics is a collection of 30,000 unique NFTs on Solana, divided into three tiers: Poor (0-9999), Mid (10000-19999), and Rich (20000-29999). Your wallet balance determines your tier!",
  "seller_fee_basis_points": 500,
  "image": "[index].png",
  "external_url": "https://oinkonomics.mfai.app",
  "edition": [0-29999],
  "attributes": [
    { "trait_type": "Background", "value": "..." },
    { "trait_type": "Skin", "value": "..." },
    { "trait_type": "Outfit", "value": "..." },
    { "trait_type": "Eyes", "value": "..." },
    { "trait_type": "Mouth", "value": "..." },
    { "trait_type": "Headtop", "value": "..." },
    { "trait_type": "Nose", "value": "..." },  // MID & RICH only
    { "trait_type": "Ears", "value": "..." },   // MID & RICH only
    { "trait_type": "Tier", "value": "Poor|Mid|Rich" }
  ],
  "properties": {
    "files": [{ "uri": "[index].png", "type": "image/png" }],
    "category": "image",
    "creators": [
      {
        "address": "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z",
        "share": 100
      }
    ]
  }
}
```

---

## 🚀 Commandes de Génération

### Test Rapide (10 NFTs par tier)
```bash
./test-generation.sh
```
Génère 30 NFTs pour tester:
- 10 POOR (0-9)
- 10 MID (10000-10009)  
- 10 RICH (20000-20009)

### Génération Complète (30,000 NFTs)
```bash
# Supprimer l'ancien build
rm -rf build

# Générer TOUS les NFTs
npm run build
```

### Génération par Tier Individuel
```bash
# Générer uniquement POOR (0-9999)
TIER=POOR npm run build

# Générer uniquement MID (10000-19999)
TIER=MID APPEND_MODE=true npm run build

# Générer uniquement RICH (20000-29999)
TIER=RICH APPEND_MODE=true npm run build
```

### Génération Limitée pour Tests
```bash
# Générer seulement 100 de chaque tier
TEST_TIER_SIZE=100 npm run build

# Générer 500 POOR seulement
TEST_TIER_SIZE=500 TIER=POOR npm run build
```

---

## ⚙️ Variables d'Environnement

| Variable | Description | Exemple |
|----------|-------------|---------|
| `TIER` | Tier(s) à générer (séparés par virgule) | `TIER=POOR,MID` |
| `TEST_TIER_SIZE` | Limite le nombre de NFTs par tier | `TEST_TIER_SIZE=100` |
| `APPEND_MODE` | Ajoute aux NFTs existants sans écraser | `APPEND_MODE=true` |

---

## 📦 Préparation pour Sugar CLI

Après génération, préparer les assets pour le déploiement:

```bash
# Convertir les métadonnées au format Sugar
npm run prepare-sugar

# Les assets seront dans le dossier ./assets/
# Prêts pour: sugar validate, sugar upload, sugar deploy
```

---

## ⏱️ Estimations de Temps

Sur votre serveur Hetzner (i7-8700, 62GB RAM):

| Opération | Temps Estimé |
|-----------|--------------|
| Génération 10K POOR | ~25-35 min |
| Génération 10K MID | ~30-40 min |
| Génération 10K RICH | ~30-40 min |
| **Total 30K NFTs** | **~1h30-2h** |
| Préparation Sugar | ~5-10 min |
| Upload Arweave | ~30-60 min |
| **TOTAL DÉPLOIEMENT** | **~2h30-3h30** |

---

## 💾 Espace Disque Requis

| Composant | Taille Estimée |
|-----------|----------------|
| 30,000 images PNG (1000x1000) | ~4-6 GB |
| 30,000 fichiers JSON | ~100-150 MB |
| Assets preparés (copie) | ~4-6 GB |
| **Total requis** | **~10-15 GB** |

**Espace disponible serveur**: 1+ TB ✅

---

## 💰 Coûts Mainnet Estimés

| Opération | Coût (SOL) |
|-----------|------------|
| Upload 30K images sur Arweave | 3-5 SOL |
| Création Candy Machine | 0.01 SOL |
| Frais de transaction | 0.01-0.02 SOL |
| Buffer de sécurité | 0.5-1 SOL |
| **TOTAL RECOMMANDÉ** | **~5-7 SOL** |

---

## 🔒 Fichiers Modifiés

### [src/config.js](src/config.js)
- ✅ Configuration 3 tiers (10K chacun)
- ✅ Description mise à jour avec les ranges
- ✅ Support TEST_TIER_SIZE
- ✅ growEditionSizeTo configuré correctement

### [src/main.js](src/main.js)
- ✅ Gestion growEditionSizeTo
- ✅ Calcul editionSize dynamique
- ✅ Support des startEdition personnalisés

### [sugar-config.json](sugar-config.json)
- ✅ Number: 30000
- ✅ Configuration Candy Machine prête

### [prepare-sugar-assets.js](prepare-sugar-assets.js)
- ✅ Détection tier basée sur ranges 10K
- ✅ Attribution automatique du tier dans metadata

### [test-generation.sh](test-generation.sh) (nouveau)
- ✅ Script de test rapide
- ✅ Génère 10 NFTs par tier pour validation

---

## ✅ Checklist de Validation

Avant génération complète:

- [x] Configuration vérifiée (3 tiers × 10K)
- [x] Layers comptabilisés (211 assets sources)
- [x] Combinaisons suffisantes pour 30K NFTs
- [x] Métadonnées au bon format Solana
- [x] Scripts de test créés
- [ ] Test de génération effectué (./test-generation.sh)
- [ ] Validation visuelle des images
- [ ] Vérification des métadonnées JSON

Avant déploiement mainnet:

- [ ] Génération 30K complète réussie
- [ ] prepare-sugar-assets.js exécuté
- [ ] sugar validate réussi
- [ ] Wallet financé (5-7 SOL minimum)
- [ ] Backup du wallet effectué
- [ ] Configuration sugar-config.json revue

---

## 🎯 Prochaines Étapes

### 1. Test de Configuration (MAINTENANT)
```bash
cd /home/b13/Desktop/hashlips
./test-generation.sh
```

Vérifiez que:
- ✅ 30 NFTs générés (10 par tier)
- ✅ Les ranges sont corrects (0-9, 10000-10009, 20000-20009)
- ✅ Les métadonnées contiennent le bon tier

### 2. Génération Complète
```bash
# Nettoyer
rm -rf build

# Générer les 30,000 NFTs
npm run build

# Durée: ~1h30-2h
```

### 3. Préparation Déploiement
```bash
# Préparer pour Sugar
npm run prepare-sugar

# Transférer sur serveur
rsync -avz --exclude 'node_modules' ./ mf:/root/hashlips/
```

### 4. Déploiement Mainnet
```bash
# Sur le serveur
ssh mf "cd /root/hashlips && sugar validate"
ssh mf "cd /root/hashlips && sugar upload"
ssh mf "cd /root/hashlips && sugar deploy"
ssh mf "cd /root/hashlips && sugar verify"
```

---

## 📚 Documentation

- [README.md](README.md) - Documentation HashLips
- [MAINNET_DEPLOYMENT_GUIDE.md](MAINNET_DEPLOYMENT_GUIDE.md) - Guide déploiement
- [DEPLOYMENT_READY.md](DEPLOYMENT_READY.md) - État serveur

---

## 🎉 Résumé

Votre projet est **prêt à générer 30,000 NFTs**:

✅ **POOR**: 10,000 NFTs (range 0-9999)  
✅ **MID**: 10,000 NFTs (range 10000-19999)  
✅ **RICH**: 10,000 NFTs (range 20000-29999)  

**Combinaisons uniques garanties** pour chaque tier!

**Commande de test**: `./test-generation.sh`  
**Commande complète**: `npm run build`

---

**Prêt à lancer? 🚀🐷**
