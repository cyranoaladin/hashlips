#!/bin/bash
# Script pour vérifier la progression de l'upload

echo "🔍 Vérification de la progression de l'upload..."
echo ""

# Vérifier si sugar upload est en cours
if pgrep -f "sugar upload" > /dev/null; then
    echo "✅ sugar upload est en cours d'exécution"
    echo ""
else
    echo "⚠️  sugar upload n'est pas en cours"
    echo ""
fi

# Vérifier le cache.json
if [ -f "cache.json" ]; then
    SIZE=$(wc -l < cache.json)
    ITEMS_WITH_LINKS=$(grep -c '"image_link": "[^"]*[^"]"' cache.json 2>/dev/null || echo "0")
    ITEMS_WITH_LINKS=$(echo "$ITEMS_WITH_LINKS" | tr -d '[:space:]')
    TOTAL_ITEMS=$(grep -c '"[0-9]": {' cache.json 2>/dev/null || echo "0")
    TOTAL_ITEMS=$(echo "$TOTAL_ITEMS" | tr -d '[:space:]')

    echo "📊 État du cache.json:"
    echo "   • Lignes: $SIZE"
    echo "   • Items avec URLs: $ITEMS_WITH_LINKS"
    echo "   • Total items: $TOTAL_ITEMS"

    if [ ! -z "$ITEMS_WITH_LINKS" ] && [ "$ITEMS_WITH_LINKS" != "0" ] && [ "$ITEMS_WITH_LINKS" -gt 0 ]; then
        PERCENTAGE=$((ITEMS_WITH_LINKS * 100 / 3000))
        echo "   • Progression: $PERCENTAGE%"
    fi
    echo ""

    # Afficher quelques URLs pour vérifier
    if [ "$ITEMS_WITH_LINKS" -gt 0 ]; then
        echo "📋 Exemples d'URLs:"
        grep '"image_link": "[^"]*[^"]"' cache.json | head -3 | sed 's/.*"image_link": "\([^"]*\)".*/   • \1/'
    fi
else
    echo "⚠️  cache.json n'existe pas encore (upload pas commencé)"
fi

echo ""
echo "📝 Dernières lignes du log:"
tail -5 sugar.log 2>/dev/null | grep -v '"v":0' | tail -3 || echo "   (pas de log récent)"
