#!/bin/bash
set -e

# Script d'installation de l'environnement Solana sur le serveur
# Pour le déploiement des NFTs Oinkonomics sur mainnet

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     🔧 Configuration du Serveur pour Déploiement NFT     ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 1/6: Installation de Solana CLI${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Vérifier si Solana est déjà installé
if command -v solana &> /dev/null; then
    echo -e "${GREEN}✅ Solana CLI est déjà installé${NC}"
    solana --version
else
    echo -e "${YELLOW}⏳ Installation de Solana CLI...${NC}"
    
    # Télécharger et installer Solana
    cd /tmp
    wget -q https://github.com/solana-labs/solana/releases/download/v1.18.22/solana-release-x86_64-unknown-linux-gnu.tar.bz2
    tar jxf solana-release-x86_64-unknown-linux-gnu.tar.bz2
    
    # Installer dans /usr/local/bin pour que ce soit disponible globalement
    cd solana-release
    cp -r bin/* /usr/local/bin/
    
    # Nettoyer
    cd /tmp
    rm -rf solana-release*
    
    echo -e "${GREEN}✅ Solana CLI installé avec succès${NC}"
    solana --version
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 2/6: Installation de Sugar CLI${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Vérifier si Sugar est déjà installé
if command -v sugar &> /dev/null; then
    echo -e "${GREEN}✅ Sugar CLI est déjà installé${NC}"
    sugar --version
else
    echo -e "${YELLOW}⏳ Installation de Sugar CLI...${NC}"
    
    # Installer Sugar via cargo si disponible, sinon télécharger le binaire
    if command -v cargo &> /dev/null; then
        cargo install sugar-cli
    else
        # Télécharger le binaire pré-compilé
        cd /tmp
        wget -q https://github.com/metaplex-foundation/sugar/releases/download/v2.6.0/sugar-linux-x86_64
        chmod +x sugar-linux-x86_64
        mv sugar-linux-x86_64 /usr/local/bin/sugar
    fi
    
    echo -e "${GREEN}✅ Sugar CLI installé avec succès${NC}"
    sugar --version
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 3/6: Configuration de Solana pour Mainnet${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Créer le répertoire de configuration Solana
mkdir -p ~/.config/solana

echo -e "${YELLOW}⚠️  Configuration du réseau sur mainnet-beta${NC}"
solana config set --url https://api.mainnet-beta.solana.com

echo -e "${GREEN}✅ Configuration réseau terminée${NC}"
solana config get

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 4/6: Création du répertoire de travail${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mkdir -p /root/hashlips
echo -e "${GREEN}✅ Répertoire /root/hashlips créé${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 5/6: Installation des dépendances système${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Installer les dépendances nécessaires pour Canvas (génération d'images)
echo -e "${YELLOW}⏳ Installation des bibliothèques de traitement d'images...${NC}"
apt-get update -qq
apt-get install -y -qq build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

echo -e "${GREEN}✅ Dépendances système installées${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}▶ Étape 6/6: Vérification de l'installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo "📋 Résumé de l'installation:"
echo ""
echo -e "${GREEN}✅ Node.js:${NC} $(node --version)"
echo -e "${GREEN}✅ NPM:${NC} $(npm --version)"
echo -e "${GREEN}✅ Solana CLI:${NC} $(solana --version | head -n1)"
echo -e "${GREEN}✅ Sugar CLI:${NC} $(sugar --version)"
echo ""
echo -e "${GREEN}✅ Configuration réseau:${NC}"
solana config get | grep "RPC URL"
echo ""

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              ✨ Configuration Terminée! ✨               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}📋 Prochaines étapes:${NC}"
echo ""
echo "1. Transférer votre wallet sur le serveur:"
echo -e "${YELLOW}   scp ~/.config/solana/id.json mf:/root/.config/solana/${NC}"
echo ""
echo "2. Vérifier le solde du wallet:"
echo -e "${YELLOW}   ssh mf 'solana balance'${NC}"
echo ""
echo "3. Déployer votre projet HashLips:"
echo -e "${YELLOW}   ./deploy-to-server.sh${NC}"
echo ""
echo "4. Ou utiliser le script complet de déploiement:"
echo -e "${YELLOW}   ./deploy-nft-mainnet.sh${NC}"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Assurez-vous d'avoir suffisamment de SOL dans votre wallet${NC}"
echo -e "${RED}   (minimum 1 SOL recommandé pour 300 NFTs)${NC}"
echo ""
