# ⚡ Configuration Rapide - Oinkonomics NFT

## 🎯 Actions Immédiates à Réaliser

### 1️⃣ Configurer Hashlips (5 minutes)

```bash
cd /home/alaeddine/Bureau/hashlips

# Créer le fichier .env
cp .env.example .env

# Éditer avec vos valeurs
nano .env
```

**Variables à configurer dans `.env`:**
```bash
# Pour DEVNET (tests gratuits)
SOLANA_RPC_URL=https://api.devnet.solana.com

# Pour MAINNET (production)
# SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# Wallet path (par défaut)
WALLET_PATH=/home/alaeddine/.config/solana/id.json

# Treasury (DÉJÀ CONFIGURÉ - ne pas modifier)
TREASURY_ADDRESS=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
```

---

### 2️⃣ Configurer Oinkonomics (5 minutes)

```bash
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness

# Créer le fichier .env.local
cp env.example .env.local

# Éditer avec vos valeurs
nano .env.local
```

**Variables à configurer dans `.env.local`:**
```bash
# Frontend (public)
NEXT_PUBLIC_RPC_URL=https://api.devnet.solana.com

# Backend (privé)
RPC_URL=https://api.devnet.solana.com

# Server wallet pour les transactions
SERVER_KEYPAIR_PATH=/home/alaeddine/.config/solana/server-wallet.json

# Candy Machine IDs (à remplir APRÈS le déploiement)
POOR_CM_ID=
MID_CM_ID=
RICH_CM_ID=
```

---

### 3️⃣ Obtenir des SOL (10-30 minutes)

#### Option A: Tests sur Devnet (GRATUIT)
```bash
# Configurer devnet
solana config set --url devnet

# Obtenir 2 SOL gratuits
solana airdrop 2

# Vérifier
solana balance
```

#### Option B: Production sur Mainnet (Acheter des SOL)

**Méthodes rapides:**

1. **Via Binance/Coinbase:**
   - Créer un compte → Acheter SOL → Retirer vers votre wallet
   - Durée: 1-2 heures (avec KYC)

2. **Via Phantom Wallet (Direct):**
   - Ouvrir Phantom → "Buy" → MoonPay/Ramp
   - Durée: 10-15 minutes
   - Coût: ~1 SOL minimum

3. **Votre adresse wallet:**
   ```bash
   solana address
   # Envoyer au moins 1 SOL vers cette adresse
   ```

---

### 4️⃣ Vérifier la Configuration (1 minute)

```bash
cd /home/alaeddine/Bureau/hashlips
./verify-configuration.sh
```

Ce script vérifie automatiquement:
- ✅ Outils installés (Node, Solana, Sugar)
- ✅ Fichiers de configuration
- ✅ Variables d'environnement
- ✅ Solde du wallet
- ✅ Cohérence entre les projets

---

## 🚀 Workflow de Déploiement

### Phase 1: Test sur Devnet (Recommandé d'abord)

```bash
# 1. Configurer devnet
solana config set --url devnet
solana airdrop 2

# 2. Mettre à jour les .env pour devnet
# hashlips/.env → SOLANA_RPC_URL=https://api.devnet.solana.com
# oinkonomics/.env.local → NEXT_PUBLIC_RPC_URL=https://api.devnet.solana.com

# 3. Déployer
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh

# 4. Noter les Candy Machine IDs obtenus

# 5. Mettre à jour oinkonomics avec ces IDs
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
nano lib/constants.ts  # Mettre à jour les IDs

# 6. Tester l'interface
npm run dev  # Ouvrir http://localhost:3000
```

### Phase 2: Déploiement Mainnet (Production)

```bash
# 1. Configurer mainnet
solana config set --url mainnet-beta

# 2. Vérifier le solde (minimum 1 SOL)
solana balance

# 3. Mettre à jour les .env pour mainnet
# hashlips/.env → SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
# oinkonomics/.env.local → NEXT_PUBLIC_RPC_URL=https://api.mainnet-beta.solana.com

# 4. Déployer
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh

# 5. Noter les Candy Machine IDs MAINNET

# 6. Mettre à jour oinkonomics avec les IDs mainnet
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
nano lib/constants.ts  # Mettre à jour avec IDs mainnet

# 7. Déployer l'interface en production
npm run build
```

---

## 📊 Valeurs de Cohérence (Ne Pas Modifier)

Ces valeurs sont **déjà configurées et cohérentes** dans les deux projets:

| Paramètre | Valeur | Status |
|-----------|--------|--------|
| **Treasury Wallet** | `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z` | ✅ Cohérent |
| **Symbol** | `OINK` | ✅ Cohérent |
| **Total NFTs** | `300` | ✅ Cohérent |
| **Royalties** | `5%` (500 basis points) | ✅ Cohérent |
| **Mint Price** | `0.1 SOL` | ✅ Cohérent |
| **Tiers** | POOR (0-99), MID (100-199), RICH (200-299) | ✅ Cohérent |

---

## 🔐 Sécurité - Points Critiques

### ⚠️ NE JAMAIS Commiter

```bash
hashlips/.env                    ❌ Privé
oinkonomics/.env.local          ❌ Privé
~/.config/solana/id.json        ❌ Très sensible
```

### ✅ Toujours Sauvegarder

```bash
# Backup du keypair
mkdir -p ~/Documents/crypto-backups
cp ~/.config/solana/id.json ~/Documents/crypto-backups/solana-backup-$(date +%Y%m%d).json
chmod 400 ~/Documents/crypto-backups/*.json
```

---

## 💰 Coûts Estimés

### Devnet (Tests)
- **Coût:** GRATUIT 🎉
- **Obtenir des SOL:** `solana airdrop 2`
- **Utilisez-le pour:** Tous vos tests

### Mainnet (Production)
- **Upload Arweave:** ~0.3-0.5 SOL
- **Candy Machine:** ~0.01 SOL
- **Transactions:** ~0.001 SOL
- **Total:** ~0.5-0.8 SOL
- **Recommandé:** 1 SOL minimum

---

## 📞 Commandes Utiles

### Vérifier l'État
```bash
# Wallet
solana address
solana balance

# Configuration
solana config get

# Vérifier tout
cd /home/alaeddine/Bureau/hashlips
./verify-configuration.sh
```

### Changer de Réseau
```bash
# Devnet (tests)
solana config set --url devnet

# Mainnet (production)
solana config set --url mainnet-beta
```

### Diagnostics
```bash
# Version des outils
node --version
npm --version
solana --version
sugar --version

# Tester la connexion RPC
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1, "method":"getHealth"}' \
  https://api.mainnet-beta.solana.com
```

---

## 🆘 Problèmes Courants

### "Insufficient Funds"
```bash
# Devnet: obtenir plus de SOL
solana airdrop 2

# Mainnet: acheter et transférer plus de SOL
```

### "Wallet not found"
```bash
# Créer un nouveau wallet
solana-keygen new --outfile ~/.config/solana/id.json
```

### ".env not found"
```bash
# Hashlips
cd /home/alaeddine/Bureau/hashlips
cp .env.example .env

# Oinkonomics
cd /home/alaeddine/Bureau/oinkonomics-improve-mobile-responsiveness
cp env.example .env.local
```

### "Connection to server 'mf' failed"
```bash
# Vérifier la connexion SSH
ssh mf "echo 'OK'"

# Si échec, vérifier ~/.ssh/config
```

---

## 📚 Documentation Complète

Pour plus de détails, consultez:

- 📖 **Guide Complet:** `GUIDE_CONFIGURATION_COMPLETE.md`
- 📖 **Guide de Déploiement:** `MAINNET_DEPLOYMENT_GUIDE.md`
- 📖 **Analyse du Serveur:** `SERVER_DEPLOYMENT_ANALYSIS.md`

---

## ✅ Checklist Express

### Avant de Déployer
- [ ] Fichier `.env` créé dans hashlips
- [ ] Fichier `.env.local` créé dans oinkonomics
- [ ] Wallet Solana configuré
- [ ] Au moins 1 SOL dans le wallet (mainnet) ou airdrop fait (devnet)
- [ ] Script de vérification exécuté: `./verify-configuration.sh`
- [ ] Tests sur devnet effectués

### Après le Déploiement
- [ ] Candy Machine IDs obtenus et sauvegardés
- [ ] IDs mis à jour dans `oinkonomics/lib/constants.ts`
- [ ] Interface testée localement
- [ ] Backup du keypair effectué
- [ ] Keypair supprimé du serveur distant

---

## 🎯 En Résumé

1. **Créer les fichiers .env** (5 min)
2. **Obtenir des SOL** (10 min devnet / 1h mainnet)
3. **Vérifier avec le script** (1 min)
4. **Tester sur devnet** (15 min)
5. **Déployer sur mainnet** (15 min)
6. **Configurer l'interface** (5 min)
7. **Lancer! 🚀**

**Temps total:** ~1 heure pour tout configurer et déployer sur devnet

---

**Créé le:** 06/12/2025  
**Version:** 1.0  
**Projet:** Oinkonomics NFT - Quick Setup
