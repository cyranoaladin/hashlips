#!/bin/bash

# Script rapide pour mettre à jour une collection déjà déployée

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔄 Mise à jour d'une collection NFT déjà déployée${NC}\n"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "cache.json" ]; then
    echo -e "${RED}❌ Erreur: cache.json introuvable${NC}"
    exit 1
fi

# Vérifier si les assets sont uploadés
ITEMS_WITH_LINKS=$(grep -c '"image_link": "[^"]*[^"]"' cache.json 2>/dev/null || echo "0")

if [ "$ITEMS_WITH_LINKS" -eq "0" ]; then
    echo -e "${YELLOW}⚠️  Les assets ne semblent pas être uploadés${NC}"
    echo -e "${YELLOW}💡 Voulez-vous uploader les assets maintenant? (coûte ~3-6 SOL)${NC}"
    read -p "Continuer avec sugar upload? (oui/non): " response

    if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
        echo -e "${BLUE}📤 Upload des assets...${NC}"
        sugar upload

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Upload réussi!${NC}\n"
        else
            echo -e "${RED}❌ Upload échoué${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Upload annulé. Les métadonnées ne seront pas mises à jour.${NC}"
        exit 0
    fi
fi

# Mettre à jour les fichiers JSON avec les URLs
echo -e "${BLUE}📝 Mise à jour des fichiers JSON avec les URLs...${NC}"
node update-assets-uris.js

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la mise à jour des fichiers JSON${NC}"
    exit 1
fi

# Valider la configuration
echo -e "\n${BLUE}✓ Validation de la configuration...${NC}"
sugar validate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Validation échouée${NC}"
    exit 1
fi

# Mettre à jour les métadonnées on-chain
echo -e "\n${YELLOW}⚠️  Mise à jour des métadonnées on-chain...${NC}"
echo -e "${YELLOW}⚠️  Cela va mettre à jour TOUS les NFTs de la collection${NC}"
read -p "Continuer avec sugar update? (oui/non): " response

if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
    echo -e "${BLUE}🚀 Mise à jour des métadonnées on-chain...${NC}"
    sugar update

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✨ Mise à jour terminée avec succès!${NC}"
        echo -e "\n${BLUE}📋 Vérification finale...${NC}"
        sugar verify
    else
        echo -e "${RED}❌ Mise à jour échouée${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Mise à jour annulée${NC}"
    echo -e "${BLUE}💡 Les fichiers JSON locaux ont été mis à jour${NC}"
    echo -e "${BLUE}💡 Exécutez manuellement: sugar update${NC}"
fi
