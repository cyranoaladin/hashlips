#!/bin/bash
set -e

echo "🖼️  CORRECTION DE L'AFFICHAGE DES IMAGES - MAINNET"
echo "=================================================="
echo ""

# Vérifier qu'on est sur mainnet
echo "📡 Étape 1: Vérification du réseau..."
CURRENT_RPC=$(solana config get | grep "RPC URL" | awk '{print $3}')
if [[ "$CURRENT_RPC" != *"mainnet"* ]]; then
    echo "⚠️  Vous êtes sur $CURRENT_RPC"
    echo "🔄 Passage sur mainnet..."
    solana config set --url mainnet-beta
    echo "✅ Maintenant sur mainnet"
else
    echo "✅ Déjà sur mainnet"
fi
echo ""

# Demander les adresses si pas dans le cache
echo "📋 Étape 2: Vérification des adresses..."
python3 << 'PYTHON'
import json
import sys

with open('cache.json', 'r') as f:
    cache = json.load(f)

cm = cache['program'].get('candyMachine', '')
if not cm or cm == '':
    print("❌ Aucune Candy Machine dans le cache!")
    print("💡 Entrez l'adresse de votre Candy Machine mainnet:")
    sys.exit(1)
else:
    print(f"✅ Candy Machine trouvée: {cm}")
PYTHON

if [ $? -ne 0 ]; then
    read -p "Entrez l'adresse de votre Candy Machine mainnet: " CM_ADDRESS
    python3 << PYTHON
import json
with open('cache.json', 'r') as f:
    cache = json.load(f)
cache['program']['candyMachine'] = "$CM_ADDRESS"
with open('cache.json', 'w') as f:
    json.dump(cache, f, indent=2)
print("✅ Cache mis à jour")
PYTHON
fi

# Vérifier l'état des assets
echo ""
echo "📊 Étape 3: Vérification des assets..."
python3 << 'PYTHON'
import json

with open('cache.json', 'r') as f:
    cache = json.load(f)

items = cache.get('items', {})
total = len([k for k in items.keys() if k != '-1' and k.isdigit()])
with_images = sum(1 for item in items.values() if item.get('image_link', '').strip() != '')

print(f"   • Total items: {total}")
print(f"   • Avec image_link: {with_images}")
print(f"   • Sans image_link: {total - with_images}")

if with_images == 0:
    print("\n⚠️  Aucun asset uploadé!")
    print("💡 Il faut uploader les assets d'abord")
    sys.exit(1)
elif with_images < total:
    print(f"\n⚠️  Seulement {with_images}/{total} assets uploadés")
else:
    print("\n✅ Tous les assets sont uploadés!")
PYTHON

if [ $? -ne 0 ]; then
    echo ""
    echo "☁️  Upload des assets nécessaires..."
    read -p "Continuer avec sugar upload? (oui/non): " upload_confirm
    if [[ "$upload_confirm" =~ ^(oui|yes|y|o)$ ]]; then
        sugar upload
    else
        echo "⏭️  Upload ignoré - vous devez uploader les assets pour que les images s'affichent"
        exit 1
    fi
fi

# Mettre à jour les fichiers JSON
echo ""
echo "📝 Étape 4: Mise à jour des fichiers JSON avec les URLs..."
if command -v node &> /dev/null; then
    node update-assets-uris.js
    echo "✅ Fichiers JSON mis à jour!"
else
    echo "⚠️  Node.js non trouvé, étape ignorée"
fi

# Mettre à jour on-chain
echo ""
echo "⛓️  Étape 5: Mise à jour des métadonnées on-chain (MAINNET - COÛTE DES SOL RÉELS)..."
echo "⚠️  ATTENTION: Cela va mettre à jour TOUS les NFTs on-chain et coûter des frais!"
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

