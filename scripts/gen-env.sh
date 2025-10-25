#!/usr/bin/env bash
set -euo pipefail

# Détermine la racine du projet
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
  PROJECT_ROOT="$(pwd)"
fi

# Valeurs par défaut (surchageables via env)
CACHE_PATH="${CACHE_PATH:-$PROJECT_ROOT/cache.json}"
KEYPAIR_PATH="${KEYPAIR_PATH:-$HOME/.config/solana/id.json}"
RPC_URL="${RPC_URL:-https://api.devnet.solana.com}"

# Dépendance jq
if ! command -v jq >/dev/null 2>&1; then
  echo "Erreur: 'jq' est requis (sudo apt-get install jq)"; exit 1
fi

# Présence cache.json
if [ ! -f "$CACHE_PATH" ]; then
  echo "Erreur: cache introuvable: $CACHE_PATH"; exit 1
fi

# Lecture de l'authority (PDA candyMachineCreator)
CMA="$(jq -r '.program.candyMachineCreator // empty' "$CACHE_PATH")"
if [ -z "$CMA" ] || [ "$CMA" = "null" ]; then
  echo "Erreur: .program.candyMachineCreator introuvable dans $CACHE_PATH"; exit 1
fi

ENV_FILE="${1:-.env}"

# Sauvegarde si déjà présent
if [ -f "$ENV_FILE" ]; then
  BKP="${ENV_FILE}.backup.$(date +%s)"
  cp -a "$ENV_FILE" "$BKP"
  echo "Backup créé: $BKP"
fi

cat > "$ENV_FILE" <<EOF
# Auto-généré par scripts/gen-env.sh
# Pour charger:  set -a; source $ENV_FILE; set +a

# --- Chemins / projet ---
PROJECT_ROOT=$PROJECT_ROOT
ENV_PATH=
CONFIG_JSON_PATH=$PROJECT_ROOT/config.json
GUARD_CONFIG_JSON_PATH=$PROJECT_ROOT/guard.config.json
CONFIG_LOCAL_JSON_PATH=$PROJECT_ROOT/config.local.json

# --- Solana / Umi ---
RPC_URL=$RPC_URL
KEYPAIR_PATH=$KEYPAIR_PATH
CACHE_PATH=$CACHE_PATH
GUARD_CONFIG_PATH=$PROJECT_ROOT/guard.config.json
GUARD_LABEL=default
# IMPORTANT: doit être le PDA candyMachineCreator (auto-rempli)
COLLECTION_UPDATE_AUTHORITY=$CMA
COMPUTE_UNITS=400000
PRIORITY_MICROLAMPORTS=0

# --- Métadonnées / CM ---
COLLECTION_NAME_PREFIX=Nom de votre NFT
COLLECTION_DESCRIPTION=Description de votre collection
COLLECTION_BASE_URI=ipfs://NewUriToReplace
COLLECTION_SIZE=10
COLLECTION_SYMBOL=OINCO
COLLECTION_EXTERNAL_URL=https://www.votre-site.com
COLLECTION_SELLER_FEE_BPS=1000
COLLECTION_NETWORK=sol
CREATOR_ADDRESS=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
CREATOR_SHARE=100
COLLECTION_CREATORS_JSON=
TOKEN_STANDARD=nft
IS_MUTABLE=true
IS_SEQUENTIAL=false
UPLOAD_METHOD=pinata
RULE_SET=null
MAX_EDITION_SUPPLY=null
HIDDEN_SETTINGS=null
AWS_CONFIG=null
SDRIVE_API_KEY=
NFT_STORAGE_AUTH_TOKEN=
SHDW_STORAGE_ACCOUNT=

# --- Pinata (à compléter si upload Pinata) ---
PINATA_JWT=
PINATA_API_GATEWAY=https://api.pinata.cloud
PINATA_CONTENT_GATEWAY=https://gateway.pinata.cloud
PINATA_PARALLEL_LIMIT=100

# --- Candy Guard (solPayment) ---
SOL_PAYMENT_VALUE=0.01
SOL_PAYMENT_DESTINATION=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z

# --- Overrides locaux (optionnels) ---
LOCAL_IS_MUTABLE=false
LOCAL_SOL_PAYMENT_VALUE=1
LOCAL_SOL_PAYMENT_DESTINATION=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
LOCAL_UPLOAD_METHOD=
LOCAL_RULE_SET=
LOCAL_MAX_EDITION_SUPPLY=
LOCAL_PINATA_JWT=
LOCAL_PINATA_API_GATEWAY=
LOCAL_PINATA_CONTENT_GATEWAY=
LOCAL_PINATA_PARALLEL_LIMIT=
EOF

echo "✅ Fichier $ENV_FILE généré."
echo "Astuce: édite PINATA_JWT et KEYPAIR_PATH si besoin, puis:  set -a; source $ENV_FILE; set +a"
