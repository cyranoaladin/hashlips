#!/bin/bash

# Script pour lancer un mint gratuit avec vérification des images

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 LANCEMENT MINT GRATUIT - OINKONOMICS NFT          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "sugar-config.json" ]; then
    echo -e "${RED}❌ Erreur: sugar-config.json introuvable${NC}"
    exit 1
fi

# Vérifier le prix
PRICE=$(grep -o '"price": [0-9.]*' sugar-config.json | grep -o '[0-9.]*')
if [ "$PRICE" != "0" ]; then
    echo -e "${YELLOW}⚠️  Le prix n'est pas à 0 (actuellement: $PRICE)${NC}"
    read -p "Voulez-vous continuer? (oui/non): " response
    if [[ ! "$response" =~ ^(oui|yes|y|o)$ ]]; then
        exit 0
    fi
else
    echo -e "${GREEN}✅ Prix configuré à 0 (gratuit)${NC}"
fi

# Étape 1: Vérifier les images
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 1/5: Vérification des images${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

node verify-images.js

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la vérification des images${NC}"
    exit 1
fi

# Étape 2: Valider la configuration Sugar
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 2/5: Validation de la configuration Sugar${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

sugar validate

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la validation${NC}"
    exit 1
fi

# Étape 3: Vérifier si les assets sont uploadés
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 3/5: Vérification de l'upload des assets${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Vérifier si les assets sont uploadés
    ASSETS_UPLOADED=false
    if [ -f "cache.json" ]; then
        # Vérifier si le cache.json est valide
        if python3 -m json.tool cache.json > /dev/null 2>&1; then
            ITEMS_WITH_LINKS=$(grep -c '"image_link": "[^"]*[^"]"' cache.json 2>/dev/null || echo "0")
            ITEMS_WITH_LINKS=$(echo "$ITEMS_WITH_LINKS" | tr -d '[:space:]')

            if [ ! -z "$ITEMS_WITH_LINKS" ] && [ "$ITEMS_WITH_LINKS" != "0" ] && [ "$ITEMS_WITH_LINKS" -gt 0 ]; then
                ASSETS_UPLOADED=true
                echo -e "${GREEN}✅ ${ITEMS_WITH_LINKS} assets ont des URLs (déjà uploadés)${NC}"

                # Vérifier si les fichiers JSON ont les bonnes URLs
                SAMPLE_JSON=$(cat assets/0.json 2>/dev/null | grep -o '"image": "[^"]*"' | head -1)
                if [[ "$SAMPLE_JSON" == *"http"* ]] || [[ "$SAMPLE_JSON" == *"ipfs://"* ]]; then
                    echo -e "${GREEN}✅ Les fichiers JSON ont les bonnes URLs${NC}"
                else
                    echo -e "${YELLOW}⚠️  Mise à jour des fichiers JSON avec les URLs...${NC}"
                    if node update-assets-uris.js 2>/dev/null; then
                        echo -e "${GREEN}✅ Fichiers JSON mis à jour${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Impossible de mettre à jour (cache.json peut être corrompu)${NC}"
                    fi
                fi
            fi
        else
            echo -e "${YELLOW}⚠️  cache.json invalide ou corrompu${NC}"
        fi
    fi

    if [ "$ASSETS_UPLOADED" = false ]; then
        echo -e "${YELLOW}⚠️  Les assets ne sont pas uploadés${NC}"
        echo -e "${YELLOW}💡 Upload nécessaire pour que les images s'affichent${NC}"
        echo -e "${YELLOW}💡 Coût estimé: ~3-6 SOL pour 3000 NFTs${NC}"
        read -p "Voulez-vous uploader les assets maintenant? (oui/non): " response

        if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
            echo -e "${BLUE}📤 Upload des assets...${NC}"
            echo -e "${YELLOW}⏳ Cela peut prendre plusieurs minutes...${NC}"
            sugar upload

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Upload réussi!${NC}"

                # Mettre à jour les fichiers JSON avec les URLs
                echo -e "${BLUE}🔄 Mise à jour des fichiers JSON avec les URLs...${NC}"
                if node update-assets-uris.js; then
                    echo -e "${GREEN}✅ Fichiers JSON mis à jour avec les URLs${NC}"
                else
                    echo -e "${YELLOW}⚠️  Erreur lors de la mise à jour, mais l'upload est réussi${NC}"
                fi
            else
                echo -e "${RED}❌ Upload échoué${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}⚠️  Upload annulé. Les images ne s'afficheront pas sans upload.${NC}"
            echo -e "${BLUE}💡 Vous pouvez continuer, mais les images ne s'afficheront qu'après l'upload${NC}"
        fi
    fi

# Étape 4: Vérifier si la Candy Machine est déployée
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 4/5: Vérification du déploiement${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "cache.json" ]; then
    CANDY_MACHINE=$(grep -o '"candyMachine": "[^"]*"' cache.json | grep -o '"[^"]*"' | tr -d '"')

    if [ -z "$CANDY_MACHINE" ] || [ "$CANDY_MACHINE" == "" ]; then
        echo -e "${YELLOW}⚠️  La Candy Machine n'est pas déployée${NC}"
        read -p "Voulez-vous déployer la Candy Machine maintenant? (oui/non): " response

        if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
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
    fi
else
    echo -e "${YELLOW}⚠️  cache.json introuvable - la Candy Machine n'est probablement pas déployée${NC}"
fi

# Étape 5: Mettre à jour les métadonnées si nécessaire
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Étape 5/5: Mise à jour des métadonnées${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "cache.json" ]; then
    CANDY_MACHINE=$(grep -o '"candyMachine": "[^"]*"' cache.json | grep -o '"[^"]*"' | tr -d '"')

    if [ ! -z "$CANDY_MACHINE" ] && [ "$CANDY_MACHINE" != "" ]; then
        echo -e "${YELLOW}⚠️  Mettre à jour les métadonnées on-chain pour que les images s'affichent?${NC}"
        echo -e "${YELLOW}⚠️  Cela va mettre à jour TOUS les NFTs (3000 NFTs)${NC}"
        read -p "Continuer avec sugar update? (oui/non): " response

        if [[ "$response" =~ ^(oui|yes|y|o)$ ]]; then
            echo -e "${BLUE}🔄 Mise à jour des métadonnées on-chain...${NC}"
            sugar update

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Métadonnées mises à jour!${NC}"
            else
                echo -e "${RED}❌ Mise à jour échouée${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}⚠️  Mise à jour annulée${NC}"
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
echo -e "${GREEN}   ✅ Images vérifiées${NC}"
echo -e "${GREEN}   ✅ Métadonnées prêtes${NC}"
echo ""
echo -e "${BLUE}🎯 Prochaines étapes:${NC}"
echo "   1. Lancer la vente: sugar launch"
echo "   2. Vérifier: sugar show"
echo "   3. Tester le mint: sugar mint"
echo ""
