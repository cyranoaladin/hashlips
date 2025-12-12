#!/bin/bash
# Script pour upload et deploy de manière sûre avec gestion du cache

echo "🔍 Checking cache status..."
python3 fix_cache.py

echo ""
echo "🚀 Starting upload process..."
sugar upload

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Upload successful!"
    echo ""
    echo "🔍 Checking cache before deploy..."
    python3 fix_cache.py
    
    echo ""
    echo "🚀 Starting deploy process..."
    sugar deploy
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Deploy successful!"
        echo ""
        echo "📋 Collection info:"
        sugar show
    else
        echo ""
        echo "❌ Deploy failed - checking cache..."
        python3 fix_cache.py
        exit 1
    fi
else
    echo ""
    echo "❌ Upload failed"
    exit 1
fi
