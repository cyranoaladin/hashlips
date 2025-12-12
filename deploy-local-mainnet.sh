#!/bin/bash
set -e

# Script de déploiement LOCAL des NFTs Oinkonomics sur Solana Mainnet
# Déploiement direct depuis la machine locale sans serveur distant

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🐷 DÉPLOIEMENT LOCAL OINKONOMICS - MAINNET            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Fonction pour afficher une étape
step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Fonction pour confirmer une action critique
confirm() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    read -p "Voulez-vous continuer? (oui/non): " response
    if [[ ! "$response" =~ ^(oui|yes|y|o)$ ]]; then
        echo -e "${RED}❌ Opération annulée${NC}"
        exit 1
    fi
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "assets" ]; then
    echo -e "${RED}❌ Erreur: Le répertoire assets n'existe pas${NC}"
    echo -e "${YELLOW}💡 Les assets doivent être préparés d'abord${NC}"
    exit 1
fi

# ═════════════════════════════════════════════════════════════
# ÉTAPE 1: Vérification des assets
# ═════════════════════════════════════════════════════════════
step "1/6 - Vérification des assets"

ASSET_COUNT=$(ls -1 assets/*.png 2>/dev/null | wc -l)
echo -e "${GREEN}✅ $ASSET_COUNT assets trouvés${NC}"

if [ $ASSET_COUNT -lt 30000 ]; then
    echo -e "${YELLOW}⚠️  Seulement $ASSET_COUNT/30000 NFTs trouvés${NC}"
    confirm "Continuer avec $ASSET_COUNT NFTs?"
fi

# ═════════════════════════════════════════════════════════════
# ÉTAPE 2: Vérification de l'environnement Solana
# ═════════════════════════════════════════════════════════════
step "2/6 - Vérification de l'environnement Solana"

echo -e "${BLUE}🔍 Vérification de Solana CLI...${NC}"
if ! command -v solana &> /dev/null; then
    echo -e "${RED}❌ Solana CLI non installé${NC}"
    echo -e "${YELLOW}💡 Installation: sh -c \"\$(curl -sSfL https://release.solana.com/stable/install)\"${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Solana CLI: $(solana --version)${NC}"

echo -e "${BLUE}🔍 Vérification de Sugar CLI...${NC}"
if ! command -v sugar &> /dev/null; then
    echo -e "${RED}❌ Sugar CLI non installé${NC}"
    echo -e "${YELLOW}💡 Installation: bash <(curl -sSf https://sugar.metaplex.com/install.sh)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Sugar CLI: $(sugar --version)${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 3: Configuration du réseau Mainnet
# ═════════════════════════════════════════════════════════════
step "3/6 - Configuration du réseau Solana Mainnet"

confirm "🚨 ATTENTION: Vous allez configurer le MAINNET (réseau de production). Les frais seront réels!"

echo -e "${BLUE}🌐 Configuration sur mainnet-beta...${NC}"
solana config set --url mainnet-beta

echo -e "${BLUE}💰 Vérification du solde du wallet...${NC}"
BALANCE=$(solana balance)
echo -e "${YELLOW}💵 Solde actuel: $BALANCE${NC}"

# Estimation des coûts
echo ""
echo -e "${YELLOW}📊 Estimation des coûts pour 30,000 NFTs (approximatif):${NC}"
echo -e "${YELLOW}   • Upload des assets: ~150-300 SOL${NC}"
echo -e "${YELLOW}   • Création de la collection: ~0.01 SOL${NC}"
echo -e "${YELLOW}   • Frais divers: ~5-10 SOL${NC}"
echo -e "${YELLOW}   • Total estimé: ~160-320 SOL${NC}"
echo ""

confirm "Votre solde est suffisant et vous voulez continuer?"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 4: Validation de la configuration Sugar
# ═════════════════════════════════════════════════════════════
step "4/6 - Validation de la configuration Sugar"

echo -e "${BLUE}✓ Validation de la configuration et des assets...${NC}"
sugar validate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: La validation a échoué${NC}"
    echo -e "${YELLOW}💡 Vérifiez les logs ci-dessus pour plus de détails${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuration validée${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 5: Upload des assets sur Arweave (via Bundlr)
# ═════════════════════════════════════════════════════════════
step "5/6 - Upload des assets sur Arweave"

confirm "🚨 ATTENTION: L'upload va utiliser des SOL réels. Continuer?"

echo -e "${BLUE}☁️  Upload des assets sur Arweave via Bundlr...${NC}"
echo -e "${YELLOW}⏳ Cela peut prendre plusieurs heures pour 30,000 NFTs...${NC}"
echo -e "${YELLOW}💡 Le processus peut être interrompu et repris avec la même commande${NC}"
echo ""

sugar upload

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: L'upload a échoué${NC}"
    echo -e "${YELLOW}💡 Si l'erreur concerne le solde, ajoutez des SOL et relancez ce script${NC}"
    echo -e "${YELLOW}💡 Sugar reprendra là où il s'est arrêté${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Assets uploadés sur Arweave${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 6: Déploiement de la Candy Machine
# ═════════════════════════════════════════════════════════════
step "6/6 - Déploiement de la Candy Machine sur Solana Mainnet"

confirm "🚨 DERNIÈRE CONFIRMATION: Déployer la Candy Machine sur le MAINNET?"

echo -e "${BLUE}🚀 Déploiement de la Candy Machine...${NC}"
sugar deploy

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Le déploiement a échoué${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Candy Machine déployée avec succès!${NC}"

# Vérification finale
echo ""
echo -e "${BLUE}🔍 Vérification finale...${NC}"
sugar verify

# ═════════════════════════════════════════════════════════════
# RÉSUMÉ FINAL
# ═════════════════════════════════════════════════════════════
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    🎉 DÉPLOIEMENT RÉUSSI!                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✅ La collection Oinkonomics a été déployée sur Solana Mainnet${NC}"
echo ""
echo -e "${BLUE}📋 Informations de la collection:${NC}"
echo -e "${YELLOW}   • Réseau: Mainnet-Beta (production)${NC}"
echo -e "${YELLOW}   • Collection: 30,000 NFTs${NC}"
echo -e "${YELLOW}   • Tiers: Poor (0-9999), Mid (10000-19999), Rich (20000-29999)${NC}"
echo -e "${YELLOW}   • Symbol: OINK${NC}"
echo -e "${YELLOW}   • Royalties: 5%${NC}"
echo -e "${YELLOW}   • Website: https://oinkonomics.fun${NC}"
echo ""
echo -e "${BLUE}🎯 Prochaines étapes:${NC}"
echo "   1. Récupérer l'adresse de la Candy Machine (voir les logs ci-dessus)"
echo "   2. Configurer les paramètres de vente: sugar config set"
echo "   3. Tester le mint: sugar mint"
echo "   4. Lancer la vente publique: sugar launch"
echo "   5. Intégrer l'adresse dans votre application web"
echo ""
echo -e "${BLUE}📚 Commandes utiles:${NC}"
echo "   • Voir la config: sugar show"
echo "   • Mint test: sugar mint"
echo "   • Mettre à jour: sugar update"
echo "   • Retirer les fonds: sugar withdraw"
echo "   • Vérifier: sugar verify"
echo ""
echo -e "${BLUE}💰 Solde final:${NC}"
FINAL_BALANCE=$(solana balance)
echo -e "${YELLOW}   $FINAL_BALANCE${NC}"
echo ""
echo -e "${GREEN}🎊 Félicitations! Votre collection NFT est maintenant live sur Solana!${NC}"
