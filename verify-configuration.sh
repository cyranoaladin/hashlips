#!/bin/bash

# 🔍 Script de Vérification de Configuration - Oinkonomics NFT
# Ce script vérifie que tous les prérequis et configurations sont corrects

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Variables
HASHLIPS_DIR="/home/alaeddine/Bureau/hashlips"
OINKONOMICS_DIR="/home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness"
ERRORS=0
WARNINGS=0
SUCCESS=0

# Fonctions d'affichage
print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((SUCCESS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 est installé: $(command -v $1)"
        return 0
    else
        print_error "$1 n'est pas installé"
        return 1
    fi
}

# Bannière
clear
echo -e "${BOLD}${BLUE}"
cat << "EOF"
   ____  _       _                           _          
  / __ \(_)     | |                         (_)         
 | |  | |_ _ __ | | _____  _ __   ___  _ __ ___  ___ ___
 | |  | | | '_ \| |/ / _ \| '_ \ / _ \| '_ ` _ \| / __/ __|
 | |__| | | | | |   < (_) | | | | (_) | | | | | | | (__\__ \
  \____/|_|_| |_|_|\_\___/|_| |_|\___/|_| |_| |_|_|\___|___/
                                                            
  Vérification de Configuration NFT
EOF
echo -e "${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 1. VÉRIFICATION DES OUTILS SYSTÈME
# ═══════════════════════════════════════════════════════════
print_header "1. Vérification des Outils Système"

check_command "node"
if [ $? -eq 0 ]; then
    NODE_VERSION=$(node --version)
    print_info "Version Node.js: $NODE_VERSION"
fi

check_command "npm"
if [ $? -eq 0 ]; then
    NPM_VERSION=$(npm --version)
    print_info "Version npm: $NPM_VERSION"
fi

check_command "solana"
if [ $? -eq 0 ]; then
    SOLANA_VERSION=$(solana --version | head -n1)
    print_info "Version: $SOLANA_VERSION"
fi

check_command "sugar"
if [ $? -eq 0 ]; then
    SUGAR_VERSION=$(sugar --version 2>/dev/null || echo "sugar (version non disponible)")
    print_info "Version: $SUGAR_VERSION"
fi

check_command "git"
check_command "rsync"
check_command "ssh"

# ═══════════════════════════════════════════════════════════
# 2. VÉRIFICATION DU PROJET HASHLIPS
# ═══════════════════════════════════════════════════════════
print_header "2. Vérification du Projet Hashlips"

if [ -d "$HASHLIPS_DIR" ]; then
    print_success "Répertoire hashlips trouvé"
    cd "$HASHLIPS_DIR"
    
    # Vérifier package.json
    if [ -f "package.json" ]; then
        print_success "package.json trouvé"
    else
        print_error "package.json non trouvé"
    fi
    
    # Vérifier node_modules
    if [ -d "node_modules" ]; then
        print_success "node_modules trouvé (dépendances installées)"
    else
        print_warning "node_modules non trouvé. Exécutez: npm install"
    fi
    
    # Vérifier .env
    if [ -f ".env" ]; then
        print_success "Fichier .env trouvé"
        
        # Vérifier les variables importantes
        if grep -q "SOLANA_RPC_URL=" .env && ! grep -q "SOLANA_RPC_URL=$" .env; then
            RPC_URL=$(grep "SOLANA_RPC_URL=" .env | grep -v "^#" | cut -d'=' -f2)
            print_success "SOLANA_RPC_URL configuré: $RPC_URL"
        else
            print_error "SOLANA_RPC_URL non configuré dans .env"
        fi
        
        if grep -q "TREASURY_ADDRESS=" .env && ! grep -q "TREASURY_ADDRESS=$" .env; then
            TREASURY=$(grep "TREASURY_ADDRESS=" .env | grep -v "^#" | cut -d'=' -f2)
            print_success "TREASURY_ADDRESS configuré: $TREASURY"
        else
            print_error "TREASURY_ADDRESS non configuré dans .env"
        fi
        
    else
        print_error "Fichier .env non trouvé. Exécutez: cp .env.example .env"
    fi
    
    # Vérifier layers/
    if [ -d "layers" ]; then
        LAYER_COUNT=$(find layers -type d -mindepth 1 -maxdepth 1 | wc -l)
        print_success "Dossier layers/ trouvé ($LAYER_COUNT layers)"
    else
        print_error "Dossier layers/ non trouvé"
    fi
    
    # Vérifier src/config.js
    if [ -f "src/config.js" ]; then
        print_success "src/config.js trouvé"
        
        # Vérifier le treasury wallet dans config.js
        if grep -q "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z" src/config.js; then
            print_success "Treasury wallet cohérent dans src/config.js"
        else
            print_warning "Treasury wallet peut ne pas correspondre dans src/config.js"
        fi
    else
        print_error "src/config.js non trouvé"
    fi
    
    # Vérifier sugar-config.json
    if [ -f "sugar-config.json" ]; then
        print_success "sugar-config.json trouvé"
        
        if grep -q "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z" sugar-config.json; then
            print_success "Treasury wallet cohérent dans sugar-config.json"
        else
            print_warning "Treasury wallet peut ne pas correspondre dans sugar-config.json"
        fi
    else
        print_error "sugar-config.json non trouvé"
    fi
    
else
    print_error "Répertoire hashlips non trouvé: $HASHLIPS_DIR"
fi

# ═══════════════════════════════════════════════════════════
# 3. VÉRIFICATION DU PROJET OINKONOMICS
# ═══════════════════════════════════════════════════════════
print_header "3. Vérification du Projet Oinkonomics"

if [ -d "$OINKONOMICS_DIR" ]; then
    print_success "Répertoire oinkonomics trouvé"
    cd "$OINKONOMICS_DIR"
    
    # Vérifier package.json
    if [ -f "package.json" ]; then
        print_success "package.json trouvé"
    else
        print_error "package.json non trouvé"
    fi
    
    # Vérifier node_modules
    if [ -d "node_modules" ]; then
        print_success "node_modules trouvé (dépendances installées)"
    else
        print_warning "node_modules non trouvé. Exécutez: npm install"
    fi
    
    # Vérifier .env.local
    if [ -f ".env.local" ]; then
        print_success "Fichier .env.local trouvé"
        
        # Vérifier les variables importantes
        if grep -q "NEXT_PUBLIC_RPC_URL=" .env.local && ! grep -q "NEXT_PUBLIC_RPC_URL=$" .env.local; then
            FRONTEND_RPC=$(grep "NEXT_PUBLIC_RPC_URL=" .env.local | grep -v "^#" | cut -d'=' -f2)
            print_success "NEXT_PUBLIC_RPC_URL configuré: $FRONTEND_RPC"
        else
            print_warning "NEXT_PUBLIC_RPC_URL non configuré dans .env.local"
        fi
        
        if grep -q "RPC_URL=" .env.local && ! grep -q "RPC_URL=$" .env.local; then
            BACKEND_RPC=$(grep "RPC_URL=" .env.local | grep -v "^#" | head -1 | cut -d'=' -f2)
            print_success "RPC_URL (backend) configuré: $BACKEND_RPC"
        else
            print_warning "RPC_URL (backend) non configuré dans .env.local"
        fi
        
    else
        print_warning "Fichier .env.local non trouvé. Exécutez: cp env.example .env.local"
    fi
    
    # Vérifier lib/constants.ts
    if [ -f "lib/constants.ts" ]; then
        print_success "lib/constants.ts trouvé"
        
        if grep -q "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z" lib/constants.ts; then
            print_success "Treasury wallet cohérent dans lib/constants.ts"
        else
            print_warning "Treasury wallet peut ne pas correspondre dans lib/constants.ts"
        fi
    else
        print_error "lib/constants.ts non trouvé"
    fi
    
else
    print_error "Répertoire oinkonomics non trouvé: $OINKONOMICS_DIR"
fi

# ═══════════════════════════════════════════════════════════
# 4. VÉRIFICATION DU WALLET SOLANA
# ═══════════════════════════════════════════════════════════
print_header "4. Vérification du Wallet Solana"

# Vérifier la configuration Solana
if command -v solana &> /dev/null; then
    SOLANA_CONFIG=$(solana config get)
    echo "$SOLANA_CONFIG"
    echo ""
    
    # Vérifier l'adresse du wallet
    if WALLET_ADDRESS=$(solana address 2>/dev/null); then
        print_success "Wallet détecté: $WALLET_ADDRESS"
        
        # Vérifier le solde
        if BALANCE=$(solana balance 2>/dev/null); then
            print_success "Solde du wallet: $BALANCE"
            
            # Extraire le montant numérique
            BALANCE_NUM=$(echo $BALANCE | awk '{print $1}')
            
            # Vérifier si le solde est suffisant (au moins 0.5 SOL pour devnet, 1 SOL pour mainnet)
            if (( $(echo "$BALANCE_NUM >= 1.0" | bc -l) )); then
                print_success "Solde suffisant pour le déploiement mainnet (≥ 1 SOL)"
            elif (( $(echo "$BALANCE_NUM >= 0.5" | bc -l) )); then
                print_warning "Solde suffisant pour devnet mais insuffisant pour mainnet"
                print_info "Recommandé: Au moins 1 SOL pour mainnet"
            else
                print_error "Solde insuffisant pour le déploiement"
                print_info "Minimum requis: 0.5 SOL (devnet) ou 1 SOL (mainnet)"
            fi
        else
            print_warning "Impossible de récupérer le solde du wallet"
        fi
    else
        print_error "Aucun wallet configuré"
        print_info "Créez un wallet avec: solana-keygen new"
    fi
    
    # Vérifier le keypair
    KEYPAIR_PATH=$(solana config get | grep "Keypair Path:" | awk '{print $3}')
    if [ -f "$KEYPAIR_PATH" ]; then
        print_success "Keypair trouvé: $KEYPAIR_PATH"
    else
        print_error "Keypair non trouvé: $KEYPAIR_PATH"
    fi
    
else
    print_error "Solana CLI non installé"
fi

# ═══════════════════════════════════════════════════════════
# 5. VÉRIFICATION DE LA CONNEXION SERVEUR
# ═══════════════════════════════════════════════════════════
print_header "5. Vérification de la Connexion Serveur"

# Vérifier la connexion SSH au serveur
if ssh -o ConnectTimeout=5 -o BatchMode=yes mf "echo 'OK'" &> /dev/null; then
    print_success "Connexion SSH au serveur 'mf' réussie"
    
    # Vérifier Solana CLI sur le serveur
    if ssh mf "command -v solana" &> /dev/null; then
        SERVER_SOLANA_VERSION=$(ssh mf "solana --version 2>&1 | head -n1")
        print_success "Solana CLI sur le serveur: $SERVER_SOLANA_VERSION"
    else
        print_warning "Solana CLI non trouvé sur le serveur"
    fi
    
    # Vérifier Sugar CLI sur le serveur
    if ssh mf "command -v sugar" &> /dev/null; then
        print_success "Sugar CLI trouvé sur le serveur"
    else
        print_warning "Sugar CLI non trouvé sur le serveur"
        print_info "Exécutez: ./setup-server.sh"
    fi
    
else
    print_warning "Impossible de se connecter au serveur 'mf'"
    print_info "Vérifiez votre configuration SSH"
fi

# ═══════════════════════════════════════════════════════════
# 6. VÉRIFICATION DE LA COHÉRENCE ENTRE LES PROJETS
# ═══════════════════════════════════════════════════════════
print_header "6. Vérification de la Cohérence entre les Projets"

# Treasury wallet
HASHLIPS_TREASURY=""
OINKONOMICS_TREASURY=""

if [ -f "$HASHLIPS_DIR/src/config.js" ]; then
    HASHLIPS_TREASURY=$(grep -oP 'address:\s*"\K[^"]+' "$HASHLIPS_DIR/src/config.js" | head -1)
fi

if [ -f "$OINKONOMICS_DIR/lib/constants.ts" ]; then
    OINKONOMICS_TREASURY=$(grep -oP 'TREASURY_WALLET\s*=\s*"\K[^"]+' "$OINKONOMICS_DIR/lib/constants.ts")
fi

if [ -n "$HASHLIPS_TREASURY" ] && [ -n "$OINKONOMICS_TREASURY" ]; then
    if [ "$HASHLIPS_TREASURY" == "$OINKONOMICS_TREASURY" ]; then
        print_success "Treasury wallets cohérents"
        print_info "Wallet: $HASHLIPS_TREASURY"
    else
        print_error "Treasury wallets différents!"
        print_info "Hashlips: $HASHLIPS_TREASURY"
        print_info "Oinkonomics: $OINKONOMICS_TREASURY"
    fi
fi

# Symbol
if [ -f "$HASHLIPS_DIR/src/config.js" ]; then
    if grep -q 'symbol: "OINK"' "$HASHLIPS_DIR/src/config.js"; then
        print_success "Symbol OINK configuré dans hashlips"
    fi
fi

if [ -f "$HASHLIPS_DIR/sugar-config.json" ]; then
    if grep -q '"symbol": "OINK"' "$HASHLIPS_DIR/sugar-config.json"; then
        print_success "Symbol OINK configuré dans sugar-config.json"
    fi
fi

# NFT Count
if [ -f "$HASHLIPS_DIR/sugar-config.json" ]; then
    if grep -q '"number": 300' "$HASHLIPS_DIR/sugar-config.json"; then
        print_success "300 NFTs configurés dans sugar-config.json"
    fi
fi

# ═══════════════════════════════════════════════════════════
# 7. RÉSUMÉ FINAL
# ═══════════════════════════════════════════════════════════
print_header "7. Résumé de la Vérification"

echo ""
echo -e "${BOLD}Résultats:${NC}"
echo -e "${GREEN}  ✅ Succès: $SUCCESS${NC}"
echo -e "${YELLOW}  ⚠️  Avertissements: $WARNINGS${NC}"
echo -e "${RED}  ❌ Erreurs: $ERRORS${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${BOLD}${GREEN}🎉 Tous les tests sont passés! Votre configuration est prête!${NC}"
    echo ""
    echo -e "${BLUE}Prochaines étapes:${NC}"
    echo -e "  1. Assurez-vous d'avoir au moins 1 SOL dans votre wallet"
    echo -e "  2. Testez d'abord sur devnet: solana config set --url devnet"
    echo -e "  3. Puis déployez: cd $HASHLIPS_DIR && ./deploy-nft-mainnet.sh"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${BOLD}${YELLOW}⚠️  Configuration fonctionnelle avec quelques avertissements${NC}"
    echo ""
    echo -e "${YELLOW}Vérifiez les avertissements ci-dessus et corrigez-les si nécessaire.${NC}"
    echo ""
    exit 0
else
    echo -e "${BOLD}${RED}❌ Des erreurs ont été détectées!${NC}"
    echo ""
    echo -e "${RED}Veuillez corriger les erreurs ci-dessus avant de continuer.${NC}"
    echo ""
    echo -e "${BLUE}Ressources:${NC}"
    echo -e "  📖 Guide complet: $HASHLIPS_DIR/GUIDE_CONFIGURATION_COMPLETE.md"
    echo -e "  📖 Guide de déploiement: $HASHLIPS_DIR/MAINNET_DEPLOYMENT_GUIDE.md"
    echo ""
    exit 1
fi
