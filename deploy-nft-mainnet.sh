#!/bin/bash
set -e

# Script complet de déploiement des NFTs Oinkonomics sur Solana Mainnet
# Ce script automatise tout le processus depuis la génération jusqu'au déploiement

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SERVER_HOST="mf"
REMOTE_DIR="/root/hashlips"
WALLET_PATH="$HOME/.config/solana/id.json"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🐷 DÉPLOIEMENT OINKONOMICS NFT COLLECTION - MAINNET   ║"
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
if [ ! -f "src/config.js" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis le répertoire hashlips${NC}"
    exit 1
fi

# ═════════════════════════════════════════════════════════════
# ÉTAPE 1: Génération locale des NFTs
# ═════════════════════════════════════════════════════════════
step "1/8 - Génération des NFTs avec Hashlips Art Engine"

if [ -d "build" ]; then
    confirm "Le répertoire build existe déjà. Il sera supprimé et régénéré."
    rm -rf build
fi

echo -e "${BLUE}🎨 Génération des 300 NFTs (Poor: 0-99, Mid: 100-199, Rich: 200-299)...${NC}"
npm run build

if [ ! -d "build/images" ] || [ ! -d "build/json" ]; then
    echo -e "${RED}❌ Erreur: La génération a échoué${NC}"
    exit 1
fi

NFT_COUNT=$(ls -1 build/images/*.png 2>/dev/null | wc -l)
echo -e "${GREEN}✅ $NFT_COUNT NFTs générés avec succès${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 2: Préparation des assets pour Sugar
# ═════════════════════════════════════════════════════════════
step "2/8 - Préparation des assets au format Sugar"

echo -e "${BLUE}🔄 Conversion des métadonnées et organisation des fichiers...${NC}"
node prepare-sugar-assets.js

if [ ! -d "assets" ]; then
    echo -e "${RED}❌ Erreur: La préparation des assets a échoué${NC}"
    exit 1
fi

ASSET_COUNT=$(ls -1 assets/*.png 2>/dev/null | wc -l)
echo -e "${GREEN}✅ $ASSET_COUNT assets préparés pour Sugar${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 3: Déploiement sur le serveur
# ═════════════════════════════════════════════════════════════
step "3/8 - Déploiement du projet sur le serveur"

confirm "Déployer le projet hashlips sur le serveur $SERVER_HOST?"

echo -e "${BLUE}📤 Création du répertoire distant...${NC}"
ssh $SERVER_HOST "mkdir -p $REMOTE_DIR"

echo -e "${BLUE}📦 Copie des fichiers vers le serveur...${NC}"
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.git' \
  "$PWD/" $SERVER_HOST:"$REMOTE_DIR/"

echo -e "${BLUE}📥 Installation des dépendances sur le serveur...${NC}"
ssh $SERVER_HOST "cd $REMOTE_DIR && npm install"

echo -e "${GREEN}✅ Projet déployé sur le serveur${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 4: Vérification de l'environnement Solana sur le serveur
# ═════════════════════════════════════════════════════════════
step "4/8 - Vérification de l'environnement Solana sur le serveur"

echo -e "${BLUE}🔍 Vérification de Solana CLI...${NC}"
ssh $SERVER_HOST "command -v solana || (echo '❌ Solana CLI non installé sur le serveur' && exit 1)"

echo -e "${BLUE}🔍 Vérification de Sugar CLI...${NC}"
ssh $SERVER_HOST "command -v sugar || (echo '❌ Sugar CLI non installé sur le serveur' && exit 1)"

echo -e "${GREEN}✅ Environnement Solana vérifié${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 5: Configuration du réseau Mainnet
# ═════════════════════════════════════════════════════════════
step "5/8 - Configuration du réseau Solana Mainnet"

confirm "🚨 ATTENTION: Vous allez configurer le MAINNET (réseau de production). Les frais seront réels!"

echo -e "${BLUE}🌐 Configuration de Solana sur mainnet-beta...${NC}"
ssh $SERVER_HOST "solana config set --url mainnet-beta"

echo -e "${BLUE}💰 Vérification du solde du wallet...${NC}"
BALANCE=$(ssh $SERVER_HOST "solana balance")
echo -e "${YELLOW}💵 Solde actuel: $BALANCE${NC}"

# Estimation des coûts
echo ""
echo -e "${YELLOW}📊 Estimation des coûts (approximatif):${NC}"
echo -e "${YELLOW}   • Upload des assets (~300 NFTs): ~2-5 SOL${NC}"
echo -e "${YELLOW}   • Création de la collection: ~0.01 SOL${NC}"
echo -e "${YELLOW}   • Frais divers: ~0.5 SOL${NC}"
echo -e "${YELLOW}   • Total estimé: ~3-6 SOL${NC}"
echo ""

confirm "Votre solde est suffisant et vous voulez continuer?"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 6: Validation de la configuration Sugar
# ═════════════════════════════════════════════════════════════
step "6/8 - Validation de la configuration Sugar"

echo -e "${BLUE}✓ Validation de la configuration et des assets...${NC}"
ssh $SERVER_HOST "cd $REMOTE_DIR && sugar validate"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: La validation a échoué${NC}"
    echo -e "${YELLOW}💡 Vérifiez les logs ci-dessus pour plus de détails${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuration validée${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 7: Upload des assets sur Arweave (via Bundlr)
# ═════════════════════════════════════════════════════════════
step "7/8 - Upload des assets sur Arweave"

confirm "🚨 ATTENTION: L'upload va utiliser des SOL réels. Continuer?"

echo -e "${BLUE}☁️  Upload des assets sur Arweave via Bundlr...${NC}"
echo -e "${YELLOW}⏳ Cela peut prendre plusieurs minutes...${NC}"

ssh $SERVER_HOST "cd $REMOTE_DIR && sugar upload"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: L'upload a échoué${NC}"
    echo -e "${YELLOW}💡 Si l'erreur concerne le solde, ajoutez des SOL et réessayez${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Assets uploadés sur Arweave${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 8: Déploiement de la Candy Machine
# ═════════════════════════════════════════════════════════════
step "8/8 - Déploiement de la Candy Machine sur Solana Mainnet"

confirm "🚨 DERNIÈRE CONFIRMATION: Déployer la Candy Machine sur le MAINNET?"

echo -e "${BLUE}🚀 Déploiement de la Candy Machine...${NC}"
ssh $SERVER_HOST "cd $REMOTE_DIR && sugar deploy"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Le déploiement a échoué${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Candy Machine déployée avec succès!${NC}"

# Vérification finale
echo ""
echo -e "${BLUE}🔍 Vérification finale...${NC}"
ssh $SERVER_HOST "cd $REMOTE_DIR && sugar verify"

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
echo -e "${BLUE}📋 Informations importantes:${NC}"
echo -e "${YELLOW}   • Collection: 300 NFTs (Poor: 0-99, Mid: 100-199, Rich: 200-299)${NC}"
echo -e "${YELLOW}   • Symbol: OINK${NC}"
echo -e "${YELLOW}   • Royalties: 5%${NC}"
echo -e "${YELLOW}   • Treasury: 5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z${NC}"
echo ""
echo -e "${BLUE}🎯 Prochaines étapes:${NC}"
echo "   1. Récupérer l'adresse de la Candy Machine depuis les logs"
echo "   2. Tester le mint sur un wallet de test"
echo "   3. Lancer la vente: ssh $SERVER_HOST 'cd $REMOTE_DIR && sugar launch'"
echo "   4. Intégrer l'adresse dans votre application web"
echo ""
echo -e "${BLUE}📚 Commandes utiles:${NC}"
echo "   • Voir la config: ssh $SERVER_HOST 'cd $REMOTE_DIR && sugar show'"
echo "   • Mettre à jour: ssh $SERVER_HOST 'cd $REMOTE_DIR && sugar update'"
echo "   • Retirer: ssh $SERVER_HOST 'cd $REMOTE_DIR && sugar withdraw'"
echo ""
echo -e "${GREEN}🎊 Félicitations! Votre collection NFT est maintenant live!${NC}"
