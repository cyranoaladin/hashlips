#!/bin/bash
set -e

# Script de déploiement de Hashlips sur le serveur Money Factory
# Ce script copie le projet hashlips sur le serveur et installe les dépendances

echo "🚀 Déploiement de Hashlips sur le serveur..."

# Configuration
SERVER_HOST="mf"
REMOTE_DIR="/root/hashlips"
LOCAL_DIR="/home/alaeddine/Bureau/hashlips"

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Création du répertoire distant...${NC}"
ssh $SERVER_HOST "mkdir -p $REMOTE_DIR"

echo -e "${BLUE}📤 Copie des fichiers vers le serveur...${NC}"
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude 'build' \
  --exclude '.git' \
  --exclude '.gitignore' \
  "$LOCAL_DIR/" $SERVER_HOST:"$REMOTE_DIR/"

echo -e "${BLUE}📥 Installation des dépendances sur le serveur...${NC}"
ssh $SERVER_HOST "cd $REMOTE_DIR && npm install"

echo -e "${GREEN}✅ Déploiement terminé avec succès!${NC}"
echo -e "${YELLOW}📁 Chemin sur le serveur: $REMOTE_DIR${NC}"
echo ""
echo -e "${BLUE}Pour vous connecter au serveur et générer les NFTs:${NC}"
echo "  ssh $SERVER_HOST"
echo "  cd $REMOTE_DIR"
echo "  npm run build"
