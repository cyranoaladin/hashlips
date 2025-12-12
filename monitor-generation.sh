#!/bin/bash

# Script pour surveiller la génération en cours
# Usage: ./monitor-generation.sh

echo "📊 Monitoring de la génération NFT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Compter les fichiers générés
count_files() {
    IMAGE_COUNT=$(find build/images -name "*.png" 2>/dev/null | wc -l)
    JSON_COUNT=$(find build/json -name "[0-9]*.json" 2>/dev/null | wc -l)
    
    echo "📁 Fichiers générés:"
    echo "   Images: $IMAGE_COUNT"
    echo "   Métadonnées: $JSON_COUNT"
    echo ""
}

# Vérifier la taille du dossier
check_size() {
    if [ -d "build" ]; then
        SIZE=$(du -sh build 2>/dev/null | cut -f1)
        echo "💾 Taille du dossier build: $SIZE"
        echo ""
    fi
}

# Progression par tier
check_tiers() {
    echo "🎯 Progression par tier:"
    
    # POOR (0-9999)
    POOR_COUNT=$(find build/images -name "[0-9]*.png" 2>/dev/null | xargs -I {} basename {} .png | awk '$1 >= 0 && $1 < 10000' | wc -l)
    POOR_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($POOR_COUNT/10000)*100}")
    echo "   POOR (0-9999):    $POOR_COUNT / 10000 ($POOR_PERCENT%)"
    
    # MID (10000-19999)
    MID_COUNT=$(find build/images -name "*.png" 2>/dev/null | xargs -I {} basename {} .png | awk '$1 >= 10000 && $1 < 20000' | wc -l)
    MID_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MID_COUNT/10000)*100}")
    echo "   MID (10000-19999): $MID_COUNT / 10000 ($MID_PERCENT%)"
    
    # RICH (20000-29999)
    RICH_COUNT=$(find build/images -name "*.png" 2>/dev/null | xargs -I {} basename {} .png | awk '$1 >= 20000 && $1 < 30000' | wc -l)
    RICH_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($RICH_COUNT/10000)*100}")
    echo "   RICH (20000-29999): $RICH_COUNT / 10000 ($RICH_PERCENT%)"
    
    echo ""
    
    # Total
    TOTAL=$((POOR_COUNT + MID_COUNT + RICH_COUNT))
    TOTAL_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($TOTAL/30000)*100}")
    echo "   TOTAL: $TOTAL / 30000 ($TOTAL_PERCENT%)"
    echo ""
}

# Vérifier l'utilisation RAM
check_memory() {
    echo "💾 Utilisation mémoire:"
    free -h | awk 'NR==2{printf "   Utilisée: %s / %s (%.1f%%)\n", $3, $2, $3*100/$2}'
    echo ""
}

# Dernier fichier généré
check_last() {
    if [ -d "build/images" ]; then
        LAST=$(ls -t build/images/*.png 2>/dev/null | head -1)
        if [ ! -z "$LAST" ]; then
            LAST_NUM=$(basename "$LAST" .png)
            LAST_TIME=$(stat -c %y "$LAST" | cut -d. -f1)
            echo "🕐 Dernier NFT généré:"
            echo "   Numéro: #$LAST_NUM"
            echo "   Heure: $LAST_TIME"
            echo ""
        fi
    fi
}

# Vérifier si en cours
check_running() {
    if pgrep -f "index.js" > /dev/null; then
        echo "▶️  Statut: Génération EN COURS"
        
        # Trouver le PID et afficher les infos
        PID=$(pgrep -f "index.js")
        echo "   PID: $PID"
        
        # CPU et RAM du processus
        if [ ! -z "$PID" ]; then
            ps aux | awk -v pid=$PID '$2==pid {printf "   CPU: %.1f%% | RAM: %.1f%%\n", $3, $4}'
        fi
    else
        echo "⏸️  Statut: Génération ARRÊTÉE"
    fi
    echo ""
}

# Mode monitoring continu
if [ "$1" == "--watch" ] || [ "$1" == "-w" ]; then
    echo "Mode surveillance continue (Ctrl+C pour arrêter)"
    echo ""
    
    while true; do
        clear
        echo "📊 Monitoring de la génération NFT - $(date '+%H:%M:%S')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        check_running
        count_files
        check_tiers
        check_last
        check_memory
        check_size
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Mise à jour dans 5 secondes... (Ctrl+C pour arrêter)"
        
        sleep 5
    done
else
    # Mode snapshot unique
    check_running
    count_files
    check_tiers
    check_last
    check_memory
    check_size
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 Pour un monitoring continu:"
    echo "   ./monitor-generation.sh --watch"
fi
