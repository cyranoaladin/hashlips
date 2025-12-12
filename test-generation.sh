#!/bin/bash

# Script de test de génération rapide
# Génère 10 NFTs de chaque tier pour vérifier la configuration

echo "🧪 Test de génération des 3 tiers..."
echo ""

# Supprimer l'ancien build
if [ -d "build" ]; then
    echo "🗑️  Suppression de l'ancien build..."
    rm -rf build
fi

echo ""
echo "📦 Génération de 10 POOR NFTs (0-9)..."
TEST_TIER_SIZE=10 TIER=POOR npm run build

echo ""
echo "📦 Génération de 10 MID NFTs (10000-10009)..."
TEST_TIER_SIZE=10 TIER=MID APPEND_MODE=true npm run build

echo ""
echo "📦 Génération de 10 RICH NFTs (20000-20009)..."
TEST_TIER_SIZE=10 TIER=RICH APPEND_MODE=true npm run build

echo ""
echo "✅ Test terminé!"
echo ""
echo "📊 Résumé:"
ls -l build/images/*.png | wc -l | xargs echo "   - Images générées:"
ls -l build/json/*.json | grep -v "_metadata" | wc -l | xargs echo "   - Métadonnées créées:"

echo ""
echo "🔍 Vérification des ranges:"
echo "   - NFT #0 (POOR):"
cat build/json/0.json | grep -E '"name"|"edition"'
echo "   - NFT #10000 (MID):"
cat build/json/10000.json | grep -E '"name"|"edition"'
echo "   - NFT #20000 (RICH):"
cat build/json/20000.json | grep -E '"name"|"edition"'
