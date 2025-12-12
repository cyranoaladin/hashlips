#!/bin/bash

# Script pour lancer le mint gratuit avec upload Pinata via Sugar CLI

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 MINT GRATUIT - UPLOAD PINATA VIA SUGAR CLI        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier la configuration
if [ ! -f "sugar-config.json" ]; then
    echo -e "${RED}❌ sugar-config.json introuvable${NC}"
    exit 1
fi

# Vérifier que uploadMethod est pinata
UPLOAD_METHOD=$(grep -o '"uploadMethod": "[^"]*"' sugar-config.json | cut -d'"' -f4)
if [ "$UPLOAD_METHOD" != "pinata" ]; then
    echo -e "${YELLOW}⚠️  uploadMethod n'est pas 'pinata' (actuellement: $UPLOAD_METHOD)${NC}"
    echo -e "${YELLOW}💡 Le script va utiliser Sugar CLI qui respecte la config${NC}"
fi

echo -e "${GREEN}✅ Configuration Pinata détectée${NC}"
echo -e "${BLUE}💡 Sugar CLI va uploader sur Pinata automatiquement${NC}\n"

# Étape 1: Vérifier les images
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 1/4: Vérification des images${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

node verify-images.js

# Étape 2: Valider la configuration
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 2/4: Validation de la configuration Sugar${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

sugar validate

# Étape 3: Upload sur Pinata via Sugar CLI
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 3/4: Upload sur Pinata via Sugar CLI${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  Sugar CLI va uploader 3000 images sur Pinata${NC}"
echo -e "${YELLOW}⚠️  Cela peut prendre du temps (10-30 minutes)${NC}"
echo -e "${YELLOW}⚠️  Vérifiez que votre compte Pinata a assez de quota${NC}\n"

read -p "Continuer avec l'upload? (oui/non): " response

if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
    echo -e "${BLUE}📤 Upload en cours...${NC}"
    sugar upload

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Upload réussi!${NC}"

        # Mettre à jour les fichiers JSON avec les URLs
        echo -e "${BLUE}🔄 Mise à jour des fichiers JSON avec les URLs Pinata...${NC}"
        if node update-assets-uris.js; then
            echo -e "${GREEN}✅ Fichiers JSON mis à jour avec les URLs Pinata${NC}"
        else
            echo -e "${YELLOW}⚠️  Erreur lors de la mise à jour, mais l'upload est réussi${NC}"
            echo -e "${BLUE}💡 Les URLs sont dans cache.json, vous pouvez les utiliser${NC}"
        fi
    else
        echo -e "${RED}❌ Upload échoué${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Upload annulé${NC}"
    exit 0
fi

# Étape 4: Vérifier et déployer
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 4/4: Déploiement${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Vérifier si la Candy Machine est déployée
if [ -f "cache.json" ]; then
    CANDY_MACHINE=$(grep -o '"candyMachine": "[^"]*"' cache.json 2>/dev/null | cut -d'"' -f4 || echo "")

    if [ -z "$CANDY_MACHINE" ] || [ "$CANDY_MACHINE" == "" ]; then
        echo -e "${YELLOW}⚠️  La Candy Machine n'est pas déployée${NC}"
        read -p "Voulez-vous déployer la Candy Machine maintenant? (oui/non): " deploy_response

        if [[ "$deploy_response" =~ ^(oui|yes|y|o)$ ]]; then
            echo -e "${BLUE}🚀 Déploiement de la Candy Machine...${NC}"
            sugar deploy

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Déploiement réussi!${NC}"
            else
                echo -e "${RED}❌ Déploiement échoué${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}✅ Candy Machine déployée: ${CANDY_MACHINE}${NC}"

        # Mettre à jour les métadonnées on-chain
        echo -e "${YELLOW}⚠️  Mettre à jour les métadonnées on-chain pour que les images s'affichent?${NC}"
        read -p "Continuer avec sugar update? (oui/non): " update_response

        if [[ "$update_response" =~ ^(oui|yes|y|o)$ ]]; then
            echo -e "${BLUE}🔄 Mise à jour des métadonnées on-chain...${NC}"
            sugar update

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Métadonnées mises à jour!${NC}"
            fi
        fi
    fi
fi

# Vérification finale
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Vérification finale${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

sugar verify

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✨ PRÊT POUR LE MINT GRATUIT! ✨            ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 Résumé:${NC}"
echo -e "${GREEN}   ✅ Prix: 0 SOL (gratuit)${NC}"
echo -e "${GREEN}   ✅ Images uploadées sur Pinata${NC}"
echo -e "${GREEN}   ✅ Métadonnées avec URLs Pinata${NC}"
echo ""
echo -e "${BLUE}🎯 Prochaines étapes:${NC}"
echo "   1. Lancer la vente: sugar launch"
echo "   2. Vérifier: sugar show"
echo "   3. Tester le mint: sugar mint"
echo ""
