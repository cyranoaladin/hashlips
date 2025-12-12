#!/bin/bash

# Script de génération NFT optimisé pour éviter les crashs
# Usage: ./generate-safe.sh [TIER]
# Exemples:
#   ./generate-safe.sh POOR    (génère seulement le tier POOR)
#   ./generate-safe.sh         (génère tous les tiers)

echo "🚀 Démarrage de la génération NFT avec limites de performance..."
echo ""

# Vérifier la RAM disponible
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
AVAILABLE_RAM=$(free -m | awk 'NR==2{print $7}')

echo "💾 RAM système:"
echo "   Total: ${TOTAL_RAM}MB"
echo "   Disponible: ${AVAILABLE_RAM}MB"
echo ""

# Recommandations selon la RAM disponible
if [ "$AVAILABLE_RAM" -lt 4000 ]; then
    echo "⚠️  ATTENTION: RAM faible (<4GB disponible)"
    echo "   Recommandation: Réduisez BATCH_SIZE à 25 dans performance.config.js"
    echo ""
fi

# Options Node.js pour optimiser la mémoire
MAX_OLD_SPACE=4096  # 4GB max heap

if [ "$AVAILABLE_RAM" -gt 8000 ]; then
    MAX_OLD_SPACE=6144  # 6GB si beaucoup de RAM
    echo "✅ RAM suffisante, utilisation de 6GB max heap"
elif [ "$AVAILABLE_RAM" -gt 4000 ]; then
    MAX_OLD_SPACE=4096  # 4GB par défaut
    echo "✅ RAM correcte, utilisation de 4GB max heap"
else
    MAX_OLD_SPACE=2048  # 2GB si peu de RAM
    echo "⚠️  RAM limitée, utilisation de 2GB max heap"
fi

echo ""
echo "🎨 Configuration:"
echo "   Max Memory: ${MAX_OLD_SPACE}MB"
echo "   Garbage Collection: Activé"
echo "   Tier: ${1:-Tous}"
echo ""

# Définir le tier si spécifié
if [ ! -z "$1" ]; then
    export TIER="$1"
    echo "🎯 Génération du tier: $1"
else
    echo "🎯 Génération de tous les tiers"
fi

echo ""
echo "⏳ Lancement de la génération..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Lancer avec options optimisées
node --max-old-space-size=$MAX_OLD_SPACE \
     --expose-gc \
     --optimize-for-size \
     index.js

EXIT_CODE=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Génération terminée avec succès!"
    echo ""
    echo "📁 Fichiers générés dans:"
    echo "   Images: build/images/"
    echo "   Métadonnées: build/json/"
else
    echo "❌ Erreur lors de la génération (code: $EXIT_CODE)"
    echo ""
    echo "💡 Solutions si ça crash encore:"
    echo "   1. Réduisez BATCH_SIZE dans performance.config.js"
    echo "   2. Augmentez BATCH_DELAY (ex: 3000 ou 5000ms)"
    echo "   3. Fermez les autres applications"
    echo "   4. Générez par tier: ./generate-safe.sh POOR"
fi

echo ""
