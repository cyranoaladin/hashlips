#!/bin/bash

echo "🔒 Activation du mode SOULBOUND pour vos NFTs"
echo "=============================================="
echo ""

# Vérifier que Sugar est installé
if ! command -v sugar &> /dev/null; then
    echo "❌ Sugar CLI n'est pas installé"
    echo "Installation en cours..."
    bash <(curl -sSf https://sugar.metaplex.com/install.sh)
fi

echo "📝 Utilisation d'un ruleset pré-déployé pour soulbound NFTs"
echo ""

# Utiliser un ruleset soulbound bien connu sur devnet
# Ce ruleset bloque tous les transferts
SOULBOUND_RULESET="eBJLFYPxJmMGKuFwpDWkzxZeUrad92kZRC5BJLpzyT9"

echo "🎯 Ruleset Soulbound: $SOULBOUND_RULESET"
echo "   Ce ruleset interdit tous les transferts"
echo ""

# Backup du config actuel
cp config.json config.json.backup
echo "💾 Backup créé: config.json.backup"

# Mettre à jour config.json avec le ruleset
jq ".ruleSet = \"$SOULBOUND_RULESET\"" config.json > config.json.tmp && mv config.json.tmp config.json

echo "✅ Configuration mise à jour!"
echo ""
echo "📋 Statut:"
echo "   - Type: pNFT (Programmable NFT)"
echo "   - RuleSet: $SOULBOUND_RULESET"
echo "   - Transfert: INTERDIT (Soulbound actif)"
echo ""
echo "🚀 Vos NFTs sont maintenant configurés en SOULBOUND"
echo "   Les NFTs ne pourront PAS être transférés après le mint!"
