# 🚀 Génération NFT - Mode Anti-Crash

## 🆕 Nouveau système de limites de performance

Pour éviter les crashs pendant la génération, j'ai implémenté :

### ✅ Fonctionnalités
- ⚡ **Génération par lots** : 50 NFTs puis pause de 2s
- 🗑️ **Nettoyage mémoire** : Garbage collection automatique
- 💾 **Sauvegarde progressive** : Tous les 100 NFTs
- 📊 **Monitoring RAM** : Affichage en temps réel
- ⚙️ **Configuration flexible** : Ajustable selon votre système

## 🎯 Utilisation rapide

### Générer tous les NFTs (30,000)
```bash
./generate-safe.sh
```

### Générer un tier spécifique
```bash
./generate-safe.sh POOR    # 0-9999
./generate-safe.sh MID     # 10000-19999
./generate-safe.sh RICH    # 20000-29999
```

### Mode test (10 NFTs par tier)
```bash
TEST_TIER_SIZE=10 ./generate-safe.sh
```

## ⚙️ Configuration

Éditez `performance.config.js` :

```javascript
module.exports = {
    BATCH_SIZE: 50,              // NFTs par lot avant pause
    BATCH_DELAY: 2000,           // Pause en millisecondes
    SAVE_METADATA_INTERVAL: 100, // Sauvegarde tous les X NFTs
    FORCE_GC: true,              // Nettoyage mémoire
    SHOW_MEMORY_STATS: true,     // Afficher stats RAM
};
```

## 🔧 Si ça crash encore

### Option 1 : Réduire la charge
```javascript
// Dans performance.config.js
BATCH_SIZE: 25,        // Moins de NFTs par lot
BATCH_DELAY: 3000,     // Pause plus longue
```

### Option 2 : Générer tier par tier
```bash
./generate-safe.sh POOR   # Générer 10,000
./generate-safe.sh MID    # Puis 10,000 autres
./generate-safe.sh RICH   # Enfin les derniers 10,000
```

### Option 3 : Vérifier votre système
```bash
free -h          # Vérifier RAM disponible
df -h            # Vérifier espace disque
```

## 📊 Pendant la génération

Vous verrez :
```
🚀 Starting generation for tier POOR: 10000 editions
⚡ Performance mode: 50 NFTs per batch with 2000ms delay

✅ Created edition: 0 (tier POOR) [1/10000]
✅ Created edition: 1 (tier POOR) [2/10000]
...
✅ Created edition: 49 (tier POOR) [50/10000]

⏸️  Batch complete (50 NFTs). Pausing 2000ms to prevent crash...
📊 Memory: 458MB used / 512MB total
🗑️  Memory cleaned
📊 Memory: 312MB used / 512MB total
▶️  Resuming generation...

✅ Created edition: 50 (tier POOR) [51/10000]
...
```

## 📁 Fichiers importants

- `generate-safe.sh` - Script optimisé de génération
- `performance.config.js` - Configuration des limites
- `PERFORMANCE_LIMITS.md` - Guide détaillé
- `src/main.js` - Logique de génération modifiée

## 💡 Conseils

### Pour un système avec peu de RAM (< 8GB)
```javascript
BATCH_SIZE: 25,
BATCH_DELAY: 3000,
```

### Pour un système puissant (> 16GB RAM)
```javascript
BATCH_SIZE: 100,
BATCH_DELAY: 1500,
```

### Pour maximiser la vitesse (si pas de crash)
```javascript
BATCH_SIZE: 200,
BATCH_DELAY: 500,
```

## 🎉 Avantages

| Avant | Après |
|-------|-------|
| ❌ Crash ~200 NFTs | ✅ Génération stable |
| ❌ Perte totale | ✅ Sauvegarde progressive |
| ❌ Impossible 30K | ✅ 30,000+ NFTs OK |
| ❌ Pas de feedback | ✅ Stats en temps réel |

## 📚 Documentation complète

Voir [PERFORMANCE_LIMITS.md](PERFORMANCE_LIMITS.md) pour plus de détails.

---

**Prêt à générer ?** Lancez simplement :
```bash
./generate-safe.sh
```
