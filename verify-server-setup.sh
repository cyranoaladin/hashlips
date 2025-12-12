#!/bin/bash

# Script de vérification rapide de la configuration serveur
# Vérifie que tous les prérequis sont installés et configurés

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        🔍 Vérification de la Configuration Serveur       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

# Fonction de vérification
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

# Vérifier la connexion SSH
echo -e "${BLUE}📡 Vérification de la connexion SSH...${NC}"
ssh mf "echo 'Connection OK'" > /dev/null 2>&1
check "Connexion SSH au serveur 'mf'"
echo ""

# Vérifier Node.js
echo -e "${BLUE}🟢 Vérification de Node.js...${NC}"
NODE_VERSION=$(ssh mf "node --version" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Node.js installé: ${NODE_VERSION}${NC}"
else
    echo -e "${RED}❌ Node.js non installé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Vérifier NPM
echo -e "${BLUE}📦 Vérification de NPM...${NC}"
NPM_VERSION=$(ssh mf "npm --version" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ NPM installé: ${NPM_VERSION}${NC}"
else
    echo -e "${RED}❌ NPM non installé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Vérifier Solana CLI
echo -e "${BLUE}⚡ Vérification de Solana CLI...${NC}"
SOLANA_VERSION=$(ssh mf "solana --version 2>/dev/null | head -n1")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Solana CLI installé: ${SOLANA_VERSION}${NC}"
else
    echo -e "${RED}❌ Solana CLI non installé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Vérifier Sugar CLI
echo -e "${BLUE}🍬 Vérification de Sugar CLI...${NC}"
SUGAR_VERSION=$(ssh mf "sugar --version 2>/dev/null")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Sugar CLI installé: ${SUGAR_VERSION}${NC}"
else
    echo -e "${RED}❌ Sugar CLI non installé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Vérifier la configuration Solana
echo -e "${BLUE}⚙️  Vérification de la configuration Solana...${NC}"
RPC_URL=$(ssh mf "solana config get 2>/dev/null | grep 'RPC URL' | awk '{print \$3}'")
if [ ! -z "$RPC_URL" ]; then
    echo -e "${GREEN}✅ RPC configuré: ${RPC_URL}${NC}"
    if [[ "$RPC_URL" == *"mainnet"* ]]; then
        echo -e "${YELLOW}⚠️  Réseau: MAINNET (Production)${NC}"
    elif [[ "$RPC_URL" == *"devnet"* ]]; then
        echo -e "${BLUE}ℹ️  Réseau: DEVNET (Test)${NC}"
    fi
else
    echo -e "${RED}❌ Configuration Solana non trouvée${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Vérifier le wallet
echo -e "${BLUE}💰 Vérification du wallet...${NC}"
WALLET_EXISTS=$(ssh mf "test -f /root/.config/solana/id.json && echo 'yes' || echo 'no'" 2>/dev/null)
if [ "$WALLET_EXISTS" == "yes" ]; then
    WALLET_ADDRESS=$(ssh mf "solana address 2>/dev/null")
    BALANCE=$(ssh mf "solana balance 2>/dev/null")
    echo -e "${GREEN}✅ Wallet configuré${NC}"
    echo -e "   Adresse: ${WALLET_ADDRESS}"
    echo -e "   Solde: ${BALANCE}"
    
    # Vérifier le solde minimum
    BALANCE_NUM=$(echo $BALANCE | awk '{print $1}')
    if (( $(echo "$BALANCE_NUM < 0.5" | bc -l) )); then
        echo -e "${YELLOW}⚠️  Solde faible! Recommandé: minimum 1 SOL pour le déploiement${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Wallet non configuré sur le serveur${NC}"
    echo -e "   ${BLUE}Pour configurer:${NC} scp ~/.config/solana/id.json mf:/root/.config/solana/"
fi
echo ""

# Vérifier le répertoire hashlips
echo -e "${BLUE}📁 Vérification du répertoire de travail...${NC}"
HASHLIPS_DIR=$(ssh mf "test -d /root/hashlips && echo 'yes' || echo 'no'" 2>/dev/null)
if [ "$HASHLIPS_DIR" == "yes" ]; then
    echo -e "${GREEN}✅ Répertoire /root/hashlips existe${NC}"
else
    echo -e "${YELLOW}⚠️  Répertoire /root/hashlips n'existe pas encore${NC}"
    echo -e "   ${BLUE}Il sera créé lors du déploiement${NC}"
fi
echo ""

# Vérifier les dépendances système
echo -e "${BLUE}🔧 Vérification des dépendances système...${NC}"
CAIRO_INSTALLED=$(ssh mf "pkg-config --exists cairo && echo 'yes' || echo 'no'" 2>/dev/null)
if [ "$CAIRO_INSTALLED" == "yes" ]; then
    echo -e "${GREEN}✅ Bibliothèques de traitement d'images installées${NC}"
else
    echo -e "${YELLOW}⚠️  Bibliothèques Cairo non détectées (nécessaires pour la génération d'images)${NC}"
fi
echo ""

# Résumé
echo "╔═══════════════════════════════════════════════════════════╗"
if [ $ERRORS -eq 0 ]; then
    echo -e "║ ${GREEN}             ✅ Configuration Serveur OK                 ${NC}║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}🎉 Le serveur est prêt pour le déploiement!${NC}"
    echo ""
    echo -e "${BLUE}📋 Prochaines étapes:${NC}"
    echo ""
    if [ "$WALLET_EXISTS" == "no" ]; then
        echo "1. Transférer votre wallet:"
        echo -e "   ${YELLOW}scp ~/.config/solana/id.json mf:/root/.config/solana/${NC}"
        echo ""
    fi
    echo "2. Déployer le projet avec:"
    echo -e "   ${YELLOW}./deploy-nft-mainnet.sh${NC}"
    echo ""
    echo "   Ou manuellement:"
    echo -e "   ${YELLOW}./deploy-to-server.sh${NC}"
    echo -e "   ${YELLOW}ssh mf 'cd /root/hashlips && npm run build'${NC}"
    echo -e "   ${YELLOW}ssh mf 'cd /root/hashlips && node prepare-sugar-assets.js'${NC}"
    echo -e "   ${YELLOW}ssh mf 'cd /root/hashlips && sugar validate'${NC}"
    echo -e "   ${YELLOW}ssh mf 'cd /root/hashlips && sugar upload'${NC}"
    echo -e "   ${YELLOW}ssh mf 'cd /root/hashlips && sugar deploy'${NC}"
else
    echo -e "║ ${RED}          ⚠️  Configuration Serveur Incomplète            ${NC}║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${RED}❌ ${ERRORS} erreur(s) détectée(s)${NC}"
    echo ""
    echo -e "${BLUE}💡 Solution:${NC}"
    echo "   Exécutez le script de configuration:"
    echo -e "   ${YELLOW}scp setup-server.sh mf:/root/${NC}"
    echo -e "   ${YELLOW}ssh mf 'bash /root/setup-server.sh'${NC}"
fi
echo ""

exit $ERRORS
