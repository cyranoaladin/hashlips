# 🛡️ Guide Anti-Crash - Génération NFT

## Problème résolu
Le système crashait pendant la génération à cause de :
- Trop de NFTs générés d'un coup (surcharge mémoire)
- Pas de libération de mémoire entre les générations
- Pas de sauvegarde intermédiaire (perte de progression)

## ✅ Solutions implémentées

### 1. **Génération par lots (Batch Processing)**
- Génère 50 NFTs puis fait une pause de 2 secondes
- Permet au système de respirer et libérer la mémoire
- Configurable dans `performance.config.js`

### 2. **Garbage Collection automatique**
- Libère la mémoire après chaque lot
- Nécessite le flag `--expose-gc` (inclus dans generate-safe.sh)

### 3. **Sauvegarde progressive**
- Sauvegarde les métadonnées tous les 100 NFTs
- En cas de crash, vous ne perdez pas tout !

### 4. **Statistiques mémoire**
- Affiche l'utilisation RAM pendant la génération
- Permet de détecter les problèmes rapidement

## 🚀 Utilisation

### Méthode recommandée (avec limites)
```bash
./generate-safe.sh
```

### Générer un seul tier
```bash
./generate-safe.sh POOR    # Génère 0-9999
./generate-safe.sh MID     # Génère 10000-19999
./generate-safe.sh RICH    # Génère 20000-29999
```

### Méthode manuelle
```bash
node --max-old-space-size=4096 --expose-gc index.js
```

## ⚙️ Configuration (performance.config.js)

```javascript
module.exports = {
    BATCH_SIZE: 50,              // NFTs par lot
    BATCH_DELAY: 2000,           // Pause en ms
    SAVE_METADATA_INTERVAL: 100, // Sauvegarde tous les X
    FORCE_GC: true,              // Garbage collection
    SHOW_MEMORY_STATS: true,     // Afficher la RAM
};
```

### 🔧 Ajustements selon votre système

| RAM disponible | BATCH_SIZE | BATCH_DELAY | MAX_OLD_SPACE |
|----------------|------------|-------------|---------------|
| < 4GB          | 25         | 3000ms      | 2048MB        |
| 4-8GB          | 50         | 2000ms      | 4096MB        |
| 8-16GB         | 100        | 1500ms      | 6144MB        |
| > 16GB         | 150        | 1000ms      | 8192MB        |

## 💡 Si ça crash encore

### 1. Réduire la taille des lots
```javascript
// Dans performance.config.js
BATCH_SIZE: 25,  // Au lieu de 50
```

### 2. Augmenter la pause
```javascript
BATCH_DELAY: 5000,  // 5 secondes au lieu de 2
```

### 3. Fermer les applications
- Fermez Chrome/Firefox (gros consommateurs de RAM)
- Fermez VS Code si pas nécessaire
- Fermez Discord, Slack, etc.

### 4. Vérifier la RAM
```bash
free -h
```

### 5. Générer tier par tier
Au lieu de générer les 30,000 d'un coup :
```bash
./generate-safe.sh POOR   # D'abord 10,000
./generate-safe.sh MID    # Puis 10,000
./generate-safe.sh RICH   # Enfin 10,000
```

### 6. Mode test (petit nombre)
```bash
TEST_TIER_SIZE=100 ./generate-safe.sh
# Génère seulement 100 NFTs par tier pour tester
```

## 📊 Pendant la génération

Vous verrez :
```
✅ Created edition: 0 (tier POOR) [1/10000]
✅ Created edition: 1 (tier POOR) [2/10000]
...
⏸️  Batch complete (50 NFTs). Pausing 2000ms to prevent crash...
📊 Memory: 458MB used / 512MB total
🗑️  Memory cleaned
📊 Memory: 312MB used / 512MB total
▶️  Resuming generation...
```

## 🎯 Avantages

### Avant (sans limites)
- ❌ Crash après ~200 NFTs
- ❌ Perte de tout le travail
- ❌ Impossible de générer 30,000

### Après (avec limites)
- ✅ Génération stable
- ✅ Sauvegarde progressive
- ✅ Génération complète possible
- ✅ Monitoring RAM en temps réel

## 📁 Fichiers modifiés

- `src/main.js` - Logique de génération par lots
- `performance.config.js` - Configuration des limites
- `generate-safe.sh` - Script optimisé de lancement
- `PERFORMANCE_LIMITS.md` - Ce guide

## 🆘 Support

Si problèmes persistent :
1. Vérifiez `free -h` (RAM disponible)
2. Vérifiez `df -h` (espace disque)
3. Réduisez BATCH_SIZE à 10-25
4. Générez tier par tier
5. Utilisez un serveur avec plus de RAM

## 📝 Notes techniques

- **Garbage Collection** : Libère la mémoire non utilisée
- **Batch Processing** : Évite la surcharge mémoire
- **Progressive Save** : Évite la perte de données
- **Memory Stats** : Monitoring en temps réel

---

**Important** : Ces limites sont là pour ÉVITER les crashs, pas pour ralentir. 
La génération prendra un peu plus de temps mais sera STABLE ! 🚀
