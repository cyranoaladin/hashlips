#!/bin/bash

# Script pour nettoyer et recommencer la génération
# Usage: ./clean-and-restart.sh [TIER]

echo "🧹 Nettoyage et redémarrage de la génération"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Compter les fichiers actuels
if [ -d "build/images" ]; then
    CURRENT_COUNT=$(find build/images -name "*.png" 2>/dev/null | wc -l)
    echo "📊 Fichiers actuels: $CURRENT_COUNT NFTs"
else
    CURRENT_COUNT=0
    echo "📊 Aucun fichier existant"
fi

echo ""

# Demander confirmation si fichiers existent
if [ $CURRENT_COUNT -gt 0 ]; then
    echo "⚠️  ATTENTION: Vous allez supprimer $CURRENT_COUNT NFTs !"
    echo ""
    read -p "Êtes-vous sûr ? (oui/NON): " confirm
    
    if [ "$confirm" != "oui" ]; then
        echo "❌ Annulé. Aucun fichier supprimé."
        exit 0
    fi
fi

echo ""
echo "🗑️  Suppression des fichiers..."

# Supprimer le dossier build
if [ -d "build" ]; then
    rm -rf build
    echo "   ✅ Dossier build supprimé"
fi

echo ""
echo "✨ Nettoyage terminé !"
echo ""

# Demander si on lance la génération
read -p "Lancer la génération maintenant ? (oui/NON): " launch

if [ "$launch" == "oui" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ ! -z "$1" ]; then
        echo "🚀 Lancement de la génération pour le tier: $1"
        ./generate-safe.sh "$1"
    else
        echo "🚀 Lancement de la génération complète"
        ./generate-safe.sh
    fi
else
    echo ""
    echo "💡 Pour lancer manuellement:"
    echo "   ./generate-safe.sh"
    echo ""
    echo "Ou par tier:"
    echo "   ./generate-safe.sh POOR"
    echo "   ./generate-safe.sh MID"
    echo "   ./generate-safe.sh RICH"
fi

echo ""
