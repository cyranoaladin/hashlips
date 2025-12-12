#!/bin/bash
set -e

# Script de déploiement des NFTs Oinkonomics sur Solana DEVNET
# Version test avant le déploiement mainnet

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🐷 DÉPLOIEMENT OINKONOMICS NFT - DEVNET (TEST)        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Fonction pour afficher une étape
step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Vérifier le répertoire
if [ ! -f "src/config.js" ]; then
    echo -e "${RED}❌ Erreur: Exécuter depuis le répertoire hashlips${NC}"
    exit 1
fi

# ═════════════════════════════════════════════════════════════
# ÉTAPE 1: Vérifier que les NFTs sont générés
# ═════════════════════════════════════════════════════════════
step "1/7 - Vérification des NFTs générés"

if [ ! -d "build/images" ] || [ ! -d "build/json" ]; then
    echo -e "${RED}❌ Les NFTs ne sont pas générés${NC}"
    echo -e "${YELLOW}💡 Lancez d'abord: ./generate-safe.sh${NC}"
    exit 1
fi

NFT_COUNT=$(ls -1 build/images/*.png 2>/dev/null | wc -l)
echo -e "${GREEN}✅ $NFT_COUNT NFTs trouvés${NC}"

if [ $NFT_COUNT -lt 30000 ]; then
    echo -e "${YELLOW}⚠️  Génération en cours ($NFT_COUNT/30000)${NC}"
    read -p "Voulez-vous attendre la fin de la génération? (oui/non): " wait_response
    if [[ "$wait_response" =~ ^(oui|yes|y|o)$ ]]; then
        echo -e "${YELLOW}⏳ Attente de la fin de la génération...${NC}"
        while [ $(ls -1 build/images/*.png 2>/dev/null | wc -l) -lt 30000 ]; do
            current=$(ls -1 build/images/*.png 2>/dev/null | wc -l)
            echo -ne "\r${YELLOW}Progression: $current/30000 NFTs${NC}"
            sleep 10
        done
        echo -e "\n${GREEN}✅ Génération terminée!${NC}"
    else
        echo -e "${YELLOW}⚠️  Déploiement avec $NFT_COUNT NFTs${NC}"
    fi
fi

# ═════════════════════════════════════════════════════════════
# ÉTAPE 2: Préparation des assets pour Sugar
# ═════════════════════════════════════════════════════════════
step "2/7 - Préparation des assets Sugar"

if [ ! -f "prepare-sugar-assets.js" ]; then
    echo -e "${YELLOW}⚠️  Script de préparation manquant${NC}"
    echo -e "${YELLOW}💡 Création du dossier assets manuellement...${NC}"
    
    mkdir -p assets
    
    # Copier les images et JSON
    echo -e "${BLUE}📦 Copie des assets...${NC}"
    cp build/images/*.png assets/
    cp build/json/*.json assets/
    
    # Supprimer _metadata.json s'il existe
    rm -f assets/_metadata.json
else
    echo -e "${BLUE}🔄 Conversion des métadonnées...${NC}"
    node prepare-sugar-assets.js
fi

ASSET_COUNT=$(ls -1 assets/*.png 2>/dev/null | wc -l)
echo -e "${GREEN}✅ $ASSET_COUNT assets préparés${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 3: Vérification de Sugar CLI
# ═════════════════════════════════════════════════════════════
step "3/7 - Vérification de l'environnement"

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
# ÉTAPE 4: Configuration sur DEVNET
# ═════════════════════════════════════════════════════════════
step "4/7 - Configuration Solana DEVNET"

echo -e "${BLUE}🌐 Configuration sur devnet...${NC}"
solana config set --url devnet

echo -e "${BLUE}💰 Vérification du solde...${NC}"
BALANCE=$(solana balance 2>/dev/null || echo "0 SOL")
echo -e "${YELLOW}💵 Solde actuel: $BALANCE${NC}"

# Airdrop si nécessaire
BALANCE_NUM=$(echo $BALANCE | awk '{print $1}')
if (( $(echo "$BALANCE_NUM < 5" | bc -l) )); then
    echo -e "${YELLOW}💧 Solde insuffisant, demande d'airdrop...${NC}"
    solana airdrop 2 || echo -e "${YELLOW}⚠️  Airdrop limité, continuez avec le solde actuel${NC}"
    sleep 2
fi

BALANCE=$(solana balance)
echo -e "${GREEN}✅ Solde final: $BALANCE${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 5: Validation de la configuration
# ═════════════════════════════════════════════════════════════
step "5/7 - Validation de la configuration"

echo -e "${BLUE}✓ Validation des assets et configuration...${NC}"
sugar validate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Validation échouée${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Configuration validée${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 6: Upload sur devnet (gratuit)
# ═════════════════════════════════════════════════════════════
step "6/7 - Upload des assets"

echo -e "${BLUE}☁️  Upload sur devnet...${NC}"
echo -e "${YELLOW}⏳ Cela peut prendre du temps selon le nombre de NFTs...${NC}"

sugar upload

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Upload échoué${NC}"
    echo -e "${YELLOW}💡 Vérifiez le solde et réessayez${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Assets uploadés${NC}"

# ═════════════════════════════════════════════════════════════
# ÉTAPE 7: Déploiement de la Candy Machine
# ═════════════════════════════════════════════════════════════
step "7/7 - Déploiement de la Candy Machine"

echo -e "${BLUE}🚀 Déploiement sur devnet...${NC}"
sugar deploy

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Déploiement échoué${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Candy Machine déployée!${NC}"

# Vérification
echo ""
echo -e "${BLUE}🔍 Vérification finale...${NC}"
sugar verify

# ═════════════════════════════════════════════════════════════
# RÉSUMÉ
# ═════════════════════════════════════════════════════════════
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              🎉 DÉPLOIEMENT DEVNET RÉUSSI!               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✅ Collection Oinkonomics déployée sur DEVNET${NC}"
echo ""
echo -e "${BLUE}📋 Informations:${NC}"
echo -e "${YELLOW}   • Réseau: DEVNET (test)${NC}"
echo -e "${YELLOW}   • Collection: $ASSET_COUNT NFTs${NC}"
echo -e "${YELLOW}   • Symbol: OINK${NC}"
echo -e "${YELLOW}   • Prix: 0.1 SOL (devnet)${NC}"
echo ""
echo -e "${BLUE}🎯 Prochaines étapes:${NC}"
echo "   1. Tester le mint: sugar mint"
echo "   2. Voir les infos: sugar show"
echo "   3. Si tout fonctionne, déployer sur mainnet"
echo ""
echo -e "${BLUE}📚 Commandes utiles:${NC}"
echo "   • Info Candy Machine: sugar show"
echo "   • Mint test: sugar mint"
echo "   • Mettre à jour: sugar update"
echo "   • Retirer funds: sugar withdraw"
echo ""
echo -e "${GREEN}✅ Testez votre collection avant le déploiement mainnet!${NC}"
