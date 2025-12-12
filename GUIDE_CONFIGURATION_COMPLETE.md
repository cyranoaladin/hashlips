# 🎯 Guide Complet de Configuration - Oinkonomics NFT

## 📋 Vue d'ensemble

Ce guide vous accompagne pas à pas pour configurer correctement:
1. **Projet hashlips** (génération et déploiement des NFTs)
2. **Projet oinkonomics** (interface de mint frontend)
3. **Cohérence entre les deux projets**
4. **Transfert de SOL sur votre wallet**

---

## 🏗️ Architecture du Système

```
┌─────────────────────────────────────────────────────────────────┐
│                    HASHLIPS (Backend/Génération)                 │
│  • Génère les 300 NFTs                                          │
│  • Déploie sur Solana avec Sugar CLI                           │
│  • Crée les Candy Machines                                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Produit: Candy Machine IDs
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│              OINKONOMICS (Frontend/Interface Mint)               │
│  • Interface web pour les utilisateurs                         │
│  • Connexion wallet                                            │
│  • Mint des NFTs selon le tier                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📝 PARTIE 1: Configuration du Projet Hashlips

### Étape 1: Créer le fichier .env

Actuellement vous n'avez pas de fichier `.env`. Créons-le:

```bash
cd /home/alaeddine/Bureau/hashlips
cp .env.example .env
```

### Étape 2: Compléter les Variables d'Environnement

Éditez le fichier `.env` et remplissez les valeurs suivantes:

#### 🔹 Variables OBLIGATOIRES à Compléter

```bash
# ═══════════════════════════════════════════════════════════
# CONFIGURATION RÉSEAU SOLANA
# ═══════════════════════════════════════════════════════════

# Pour DEVNET (tests) - GRATUIT
SOLANA_RPC_URL=https://api.devnet.solana.com

# Pour MAINNET (production) - Choisir l'une de ces options:
# Option 1: RPC public (gratuit mais limité)
# SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# Option 2: RPC privé (recommandé pour production)
# Alchemy: https://www.alchemy.com/solana
# SOLANA_RPC_URL=https://solana-mainnet.g.alchemy.com/v2/VOTRE_CLE_API

# Helius: https://www.helius.dev/
# SOLANA_RPC_URL=https://rpc.helius.xyz/?api-key=VOTRE_CLE_API

# QuickNode: https://www.quicknode.com/
# SOLANA_RPC_URL=https://VOTRE_ENDPOINT.quiknode.pro/VOTRE_TOKEN/

# ═══════════════════════════════════════════════════════════
# CONFIGURATION WALLET
# ═══════════════════════════════════════════════════════════

# Chemin vers votre keypair Solana
# Par défaut: ~/.config/solana/id.json
WALLET_PATH=/home/alaeddine/.config/solana/id.json

# Adresse publique du wallet Treasury (DÉJÀ CONFIGURÉ - Ne pas changer)
TREASURY_ADDRESS=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z

# ═══════════════════════════════════════════════════════════
# CONFIGURATION COLLECTION NFT (DÉJÀ CONFIGURÉ)
# ═══════════════════════════════════════════════════════════

NFT_COUNT=300
COLLECTION_SYMBOL=OINK
MINT_PRICE=0.1
ROYALTIES_BASIS_POINTS=500
GO_LIVE_DATE=2025-01-15T00:00:00Z
EXTERNAL_URL=https://oinkonomics.mfai.app

# ═══════════════════════════════════════════════════════════
# CONFIGURATION SUGAR
# ═══════════════════════════════════════════════════════════

UPLOAD_METHOD=bundlr
RETAIN_AUTHORITY=true
IS_MUTABLE=true

# ═══════════════════════════════════════════════════════════
# CONFIGURATION SERVEUR (DÉJÀ CONFIGURÉ)
# ═══════════════════════════════════════════════════════════

SERVER_HOST=mf
REMOTE_DIR=/root/hashlips
```

#### 🔹 Ce qui est DÉJÀ Configuré (ne pas modifier)

✅ **TREASURY_ADDRESS**: `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z`
✅ **NFT_COUNT**: 300
✅ **COLLECTION_SYMBOL**: OINK
✅ **MINT_PRICE**: 0.1 SOL
✅ **ROYALTIES**: 5%
✅ **EXTERNAL_URL**: https://oinkonomics.mfai.app

---

## 📝 PARTIE 2: Configuration du Projet Oinkonomics

### Étape 1: Créer le fichier .env.local

```bash
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
cp env.example .env.local
```

### Étape 2: Compléter les Variables d'Environnement

Éditez le fichier `.env.local`:

#### 🔹 Variables Frontend (Publiques)

```bash
# ═══════════════════════════════════════════════════════════
# FRONTEND CONFIGURATION (Public - visible dans le navigateur)
# ═══════════════════════════════════════════════════════════

# RPC pour le frontend
# Pour DEVNET (tests)
NEXT_PUBLIC_RPC_URL=https://api.devnet.solana.com

# Pour MAINNET (production)
# NEXT_PUBLIC_RPC_URL=https://api.mainnet-beta.solana.com

# WalletConnect Project ID (optionnel mais recommandé pour mobile)
# Obtenir sur: https://cloud.walletconnect.com/
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your-walletconnect-project-id
```

#### 🔹 Variables Backend (Privées)

```bash
# ═══════════════════════════════════════════════════════════
# BACKEND CONFIGURATION (Secret - jamais commiter!)
# ═══════════════════════════════════════════════════════════

# RPC privé pour le backend (utiliser un service payant)
# Même que celui configuré dans hashlips/.env
RPC_URL=https://api.mainnet-beta.solana.com

# Ou utiliser votre RPC privé
# RPC_URL=https://solana-mainnet.g.alchemy.com/v2/VOTRE_CLE_API

# Chemin vers le keypair du serveur (pour signer les transactions allowlist)
# Ce wallet doit avoir quelques SOL pour payer les frais de transaction
SERVER_KEYPAIR_PATH=/home/alaeddine/.config/solana/server-wallet.json

# ═══════════════════════════════════════════════════════════
# CANDY MACHINE IDs (À COMPLÉTER APRÈS DÉPLOIEMENT)
# ═══════════════════════════════════════════════════════════

# ⚠️ CES VALEURS SERONT OBTENUES APRÈS LE DÉPLOIEMENT AVEC HASHLIPS
# Pour l'instant, laissez vide ou utilisez les IDs de devnet

# Candy Machine pour tier POOR (NFTs #0-99)
POOR_CM_ID=

# Candy Machine pour tier MID (NFTs #100-199)
MID_CM_ID=

# Candy Machine pour tier RICH (NFTs #200-299)
RICH_CM_ID=
```

### Étape 3: Mettre à Jour les Constants.ts

⚠️ **IMPORTANT**: Après le déploiement des Candy Machines avec hashlips, vous devrez mettre à jour:

```typescript
// /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness/lib/constants.ts

// VALEURS ACTUELLES (DEVNET) - À REMPLACER PAR LES VALEURS MAINNET
export const CANDY_MACHINE_ID = "VOTRE_CANDY_MACHINE_ID_MAINNET";
export const COLLECTION_MINT = "VOTRE_COLLECTION_MINT_MAINNET";
export const CANDY_GUARD_ID = "VOTRE_CANDY_GUARD_ID_MAINNET";
export const COLLECTION_UPDATE_AUTHORITY = "VOTRE_UPDATE_AUTHORITY_MAINNET";
export const TREASURY_WALLET = "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z"; // ✅ Déjà correct
```

---

## 💰 PARTIE 3: Comment Transférer des SOL sur Votre Wallet

### Option 1: Vous Avez Déjà un Wallet Phantom/Solflare

#### Étape 1: Obtenir Votre Adresse Wallet

```bash
# Afficher l'adresse de votre wallet
solana address

# Exemple de résultat:
# 5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
```

#### Étape 2: Acheter du SOL

**Méthodes pour acheter du SOL:**

1. **Via une Exchange (Recommandé)**:
   - Binance: https://www.binance.com/
   - Coinbase: https://www.coinbase.com/
   - Kraken: https://www.kraken.com/
   - Bybit: https://www.bybit.com/

   **Process**:
   ```
   1. Créer un compte sur l'exchange
   2. Vérifier votre identité (KYC)
   3. Déposer des FIAT (EUR, USD, etc.)
   4. Acheter SOL
   5. Retirer vers votre wallet Solana
   ```

2. **Via Phantom Wallet (Direct)**:
   - Ouvrir Phantom
   - Cliquer sur "Buy"
   - Choisir MoonPay, Coinbase Pay, ou Ramp
   - Suivre les instructions

3. **Via des Rampes d'Achat**:
   - MoonPay: https://www.moonpay.com/
   - Ramp Network: https://ramp.network/
   - Transak: https://transak.com/

#### Étape 3: Transférer vers Votre Wallet

Une fois que vous avez du SOL sur une exchange:

```bash
# Sur l'exchange:
1. Aller dans "Withdraw" / "Retrait"
2. Sélectionner SOL
3. Choisir "Solana Network" (pas un autre réseau!)
4. Coller votre adresse: 5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
5. Entrer le montant (minimum 1 SOL recommandé)
6. Confirmer le retrait
7. Attendre la confirmation (généralement 1-2 minutes)
```

#### Étape 4: Vérifier la Réception

```bash
# Vérifier votre solde
solana balance

# Ou vérifier sur Solscan
# https://solscan.io/account/5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
```

### Option 2: Vous N'Avez Pas Encore de Wallet

#### Étape 1: Créer un Wallet Solana

**Méthode A: Via Phantom (Recommandé pour débutants)**

```bash
1. Installer Phantom: https://phantom.app/
2. Créer un nouveau wallet
3. SAUVEGARDER la phrase de récupération (12 mots) ⚠️ CRITIQUE
4. Noter votre adresse publique
```

**Méthode B: Via Solana CLI (Pour développeurs)**

```bash
# Créer un nouveau wallet
solana-keygen new --outfile ~/.config/solana/id.json

# Afficher l'adresse
solana address

# IMPORTANT: Sauvegarder la phrase de récupération affichée!
```

#### Étape 2: Importer dans Phantom/Solflare (Optionnel)

```bash
# Obtenir la clé privée
solana-keygen pubkey ~/.config/solana/id.json

# Puis dans Phantom:
# Settings → Import Private Key → Coller la clé
```

### Option 3: Pour les Tests (Devnet - Gratuit)

Si vous voulez d'abord tester sur devnet:

```bash
# Configurer sur devnet
solana config set --url https://api.devnet.solana.com

# Obtenir des SOL gratuits (airdrop)
solana airdrop 2

# Vérifier
solana balance

# Résultat: 2 SOL (gratuit, uniquement pour tests)
```

---

## 🔗 PARTIE 4: Assurer la Cohérence Entre les Projets

### Vérification des Valeurs Communes

Ces valeurs DOIVENT être identiques dans les deux projets:

| Valeur | Hashlips | Oinkonomics | Status |
|--------|----------|-------------|--------|
| **Treasury Wallet** | `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z` | `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z` | ✅ Cohérent |
| **Symbol** | `OINK` | `OINK` | ✅ Cohérent |
| **Royalties** | `500` (5%) | N/A | ✅ OK |
| **Total NFTs** | `300` | `300` | ✅ Cohérent |
| **Mint Price** | `0.1 SOL` | Configuré dans Candy Machine | ✅ OK |
| **External URL** | `https://oinkonomics.mfai.app` | N/A | ✅ OK |

### Architecture des Tiers

Les deux projets utilisent la même structure de tiers:

```javascript
// Hashlips (src/config.js)
// NFT #0-99   → POOR tier
// NFT #100-199 → MID tier  
// NFT #200-299 → RICH tier

// Oinkonomics (lib/constants.ts)
TIER_THRESHOLDS = {
  TOO_POOR: { min: 0, max: 10, nftRange: null },        // Pas de mint
  POOR:     { min: 10, max: 1000, nftRange: [1, 100] },   // NFT #0-99
  MID:      { min: 1000, max: 10000, nftRange: [100, 200] }, // NFT #100-199
  RICH:     { min: 10000, max: null, nftRange: [200, 300] }  // NFT #200-299
}
```

✅ **Structure cohérente!**

---

## 🚀 PARTIE 5: Workflow Complet de Déploiement

### Phase 1: Préparation (Vous êtes ici)

```bash
# Hashlips
cd /home/alaeddine/Bureau/hashlips
cp .env.example .env
# Éditer .env avec vos valeurs

# Oinkonomics
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
cp env.example .env.local
# Éditer .env.local avec vos valeurs
```

### Phase 2: Obtenir des SOL

```bash
# 1. Créer/obtenir un wallet Solana
# 2. Acheter au minimum 1 SOL
# 3. Transférer vers votre wallet
# 4. Vérifier la réception

solana balance
# Résultat attendu: >= 1 SOL
```

### Phase 3: Tests sur Devnet (Recommandé)

```bash
# 1. Configurer devnet dans les deux projets
# Hashlips/.env
SOLANA_RPC_URL=https://api.devnet.solana.com

# Oinkonomics/.env.local
NEXT_PUBLIC_RPC_URL=https://api.devnet.solana.com

# 2. Obtenir des SOL gratuits
solana config set --url devnet
solana airdrop 2

# 3. Déployer sur devnet
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh  # Fonctionne aussi pour devnet

# 4. Noter les Candy Machine IDs obtenus
# 5. Mettre à jour oinkonomics avec ces IDs
# 6. Tester l'interface de mint
```

### Phase 4: Déploiement sur Mainnet

```bash
# 1. Reconfigurer pour mainnet
# Hashlips/.env
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# Oinkonomics/.env.local
NEXT_PUBLIC_RPC_URL=https://api.mainnet-beta.solana.com

# 2. Vérifier le solde (minimum 1 SOL)
solana config set --url mainnet-beta
solana balance

# 3. Déployer les NFTs
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh

# 4. Noter les Candy Machine IDs MAINNET
# Exemple de sortie:
# ╔════════════════════════════════════════════╗
# ║  Candy Machine créée avec succès!         ║
# ║  ID: AbCd1234...Xyz                       ║
# ╚════════════════════════════════════════════╝

# 5. Mettre à jour Oinkonomics avec les IDs mainnet
```

### Phase 5: Configuration Finale d'Oinkonomics

```bash
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness

# Mettre à jour lib/constants.ts avec les valeurs mainnet
nano lib/constants.ts
```

Remplacer:
```typescript
export const CANDY_MACHINE_ID = "VOTRE_ID_MAINNET";
export const COLLECTION_MINT = "VOTRE_COLLECTION_MINT_MAINNET";
export const CANDY_GUARD_ID = "VOTRE_GUARD_ID_MAINNET";
// TREASURY_WALLET reste inchangé
```

### Phase 6: Lancement

```bash
# Démarrer l'interface de mint
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
npm run dev

# Ouvrir http://localhost:3000
# Tester la connexion wallet
# Tester le mint selon les tiers
```

---

## 📋 Checklist Finale de Configuration

### Hashlips
- [ ] Fichier `.env` créé
- [ ] `SOLANA_RPC_URL` configuré
- [ ] `WALLET_PATH` vérifié
- [ ] `TREASURY_ADDRESS` vérifié (ne pas modifier)
- [ ] Wallet a au moins 1 SOL
- [ ] Tests sur devnet effectués

### Oinkonomics
- [ ] Fichier `.env.local` créé
- [ ] `NEXT_PUBLIC_RPC_URL` configuré
- [ ] `RPC_URL` configuré (backend)
- [ ] `SERVER_KEYPAIR_PATH` configuré
- [ ] Candy Machine IDs obtenus du déploiement hashlips
- [ ] `lib/constants.ts` mis à jour avec les IDs mainnet
- [ ] `TREASURY_WALLET` vérifié (ne pas modifier)

### Cohérence
- [ ] Treasury wallet identique dans les deux projets
- [ ] Symbol OINK identique
- [ ] Structure des tiers cohérente
- [ ] URLs RPC identiques (devnet ou mainnet)

---

## 🔐 Sécurité - Points Critiques

### ⚠️ NE JAMAIS Commiter

```bash
# Ces fichiers ne doivent JAMAIS être sur Git
hashlips/.env
oinkonomics/.env.local
~/.config/solana/id.json
~/.config/solana/server-wallet.json

# Vérifier qu'ils sont dans .gitignore
cat /home/alaeddine/Bureau/hashlips/.gitignore | grep .env
cat /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness/.gitignore | grep .env
```

### ✅ Toujours Sauvegarder

```bash
# Créer un backup sécurisé de votre keypair
mkdir -p ~/Documents/crypto-backups
cp ~/.config/solana/id.json ~/Documents/crypto-backups/solana-keypair-$(date +%Y%m%d).json
chmod 400 ~/Documents/crypto-backups/solana-keypair-*.json

# Chiffrer le backup (optionnel mais recommandé)
gpg -c ~/Documents/crypto-backups/solana-keypair-*.json
```

### 🔑 Phrases de Récupération

Si vous avez une phrase de récupération (12 ou 24 mots):
- ✅ Écrire sur papier
- ✅ Stocker dans un coffre-fort
- ✅ Ne JAMAIS la partager
- ✅ Ne JAMAIS la stocker numériquement (sauf chiffré)

---

## 🆘 Besoin d'Aide?

### Vérifier la Configuration

```bash
# Vérifier hashlips
cd /home/alaeddine/Bureau/hashlips
cat .env | grep -v "^#" | grep -v "^$"

# Vérifier oinkonomics
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
cat .env.local | grep -v "^#" | grep -v "^$"

# Vérifier le wallet
solana address
solana balance
```

### Commandes de Diagnostic

```bash
# Vérifier la connexion Solana
solana cluster-version

# Vérifier les config
solana config get

# Tester le RPC
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getHealth"}' https://api.mainnet-beta.solana.com
```

---

## 📞 Contacts et Ressources

### Documentation
- 🔗 Solana: https://docs.solana.com/
- 🔗 Metaplex/Sugar: https://docs.metaplex.com/tools/sugar
- 🔗 Phantom Wallet: https://phantom.app/help

### Explorateurs
- 🔍 Solscan: https://solscan.io/
- 🔍 Solana Explorer: https://explorer.solana.com/
- 🔍 SolanaFM: https://solana.fm/

### Marketplaces NFT
- 🛒 Magic Eden: https://magiceden.io/
- 🛒 Tensor: https://www.tensor.trade/
- 🛒 OpenSea: https://opensea.io/

---

## 🎯 Prochaines Étapes

Une fois cette configuration terminée, vous pourrez:

1. **Générer les 300 NFTs** avec hashlips
2. **Déployer sur Solana** avec Sugar CLI
3. **Obtenir les Candy Machine IDs**
4. **Configurer l'interface** oinkonomics avec ces IDs
5. **Lancer le mint** pour vos utilisateurs!

---

**Créé le**: 06/12/2025  
**Version**: 1.0  
**Projet**: Oinkonomics NFT - Configuration Complete
