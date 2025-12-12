#!/bin/bash
set -e

echo "🖼️  CORRECTION DE L'AFFICHAGE DES IMAGES"
echo "========================================"
echo ""

# 1. Vérifier qu'on est sur devnet
echo "📡 Étape 1: Vérification du réseau..."
CURRENT_RPC=$(solana config get | grep "RPC URL" | awk '{print $3}')
if [[ "$CURRENT_RPC" != *"devnet"* ]]; then
    echo "⚠️  Vous êtes sur $CURRENT_RPC"
    echo "🔄 Passage sur devnet..."
    solana config set --url devnet
    echo "✅ Maintenant sur devnet"
else
    echo "✅ Déjà sur devnet"
fi
echo ""

# 2. Valider la configuration
echo "📋 Étape 2: Validation de la configuration..."
sugar validate
echo ""

# 3. Uploader les assets
echo "☁️  Étape 3: Upload des assets sur Pinata..."
echo "⚠️  Cela peut prendre du temps et coûter des frais..."
read -p "Continuer avec l'upload? (oui/non): " upload_confirm
if [[ "$upload_confirm" =~ ^(oui|yes|y|o)$ ]]; then
    sugar upload
    echo "✅ Upload terminé!"
else
    echo "⏭️  Upload ignoré"
fi
echo ""

# 4. Mettre à jour les fichiers JSON
echo "📝 Étape 4: Mise à jour des fichiers JSON avec les URLs..."
if command -v node &> /dev/null; then
    node update-assets-uris.js
    echo "✅ Fichiers JSON mis à jour!"
else
    echo "⚠️  Node.js non trouvé, étape ignorée"
fi
echo ""

# 5. Mettre à jour on-chain
echo "⛓️  Étape 5: Mise à jour des métadonnées on-chain..."
echo "⚠️  Cela va mettre à jour TOUS les NFTs on-chain..."
read -p "Continuer avec sugar update? (oui/non): " update_confirm
if [[ "$update_confirm" =~ ^(oui|yes|y|o)$ ]]; then
    sugar update
    echo "✅ Métadonnées mises à jour!"
else
    echo "⏭️  Mise à jour on-chain ignorée"
fi
echo ""

echo "✨ TERMINÉ!"
echo ""
echo "🔍 Vérification finale:"
sugar verify

