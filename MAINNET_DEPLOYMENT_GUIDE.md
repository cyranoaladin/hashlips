# 🚀 Guide Complet de Déploiement NFT Oinkonomics sur Solana Mainnet

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration Initiale](#configuration-initiale)
3. [Déploiement Étape par Étape](#déploiement-étape-par-étape)
4. [Vérification et Tests](#vérification-et-tests)
5. [Gestion Post-Déploiement](#gestion-post-déploiement)
6. [Dépannage](#dépannage)
7. [Sécurité](#sécurité)

---

## 🎯 Prérequis

### Sur le Serveur (Déjà Configuré)
- ✅ **Ubuntu 22.04 LTS**
- ✅ **Node.js v20.19.6**
- ✅ **NPM 10.8.2**
- ✅ **Solana CLI 1.18.22** (installé via setup-server.sh)
- ✅ **Sugar CLI** (installé via setup-server.sh)
- ✅ **62 GB RAM** disponible
- ✅ **CPU**: Intel Core i7-8700 (6 cores)

### Sur Votre Machine Locale
- ✅ **SSH configuré** (Host: mf)
- ✅ **Wallet Solana** avec keypair
- 💰 **Minimum 1 SOL** dans le wallet pour le déploiement

### Vérification des Prérequis

```bash
# Vérifier l'accès au serveur
ssh mf "uname -a"

# Vérifier Solana CLI
ssh mf "solana --version"

# Vérifier Sugar CLI
ssh mf "sugar --version"

# Vérifier votre wallet local
solana address
solana balance
```

---

## ⚙️ Configuration Initiale

### Étape 1: Configuration du Serveur

Le script `setup-server.sh` a déjà installé:
- Solana CLI
- Sugar CLI
- Dépendances système pour la génération d'images
- Configuration du réseau mainnet

Si vous devez le relancer:

```bash
# Copier et exécuter le script
scp setup-server.sh mf:/root/
ssh mf "bash /root/setup-server.sh"
```

### Étape 2: Transférer Votre Wallet

⚠️ **IMPORTANT**: Utilisez un wallet dédié avec seulement le SOL nécessaire!

```bash
# Option 1: Transférer votre wallet existant
scp ~/.config/solana/id.json mf:/root/.config/solana/

# Option 2: Créer un nouveau wallet sur le serveur
ssh mf "solana-keygen new --outfile /root/.config/solana/id.json"
# Puis transférez 1 SOL vers cette adresse depuis votre wallet principal
```

### Étape 3: Vérifier la Configuration

```bash
# Vérifier le réseau configuré
ssh mf "solana config get"

# Vérifier le solde du wallet
ssh mf "solana balance"

# Résultat attendu: au moins 1 SOL
```

---

## 🚀 Déploiement Étape par Étape

### Méthode 1: Script Automatique (Recommandé)

Le script `deploy-nft-mainnet.sh` automatise tout le processus:

```bash
# Depuis votre machine locale
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh
```

Ce script effectue automatiquement:
1. ✅ Génération des 300 NFTs
2. ✅ Préparation des assets pour Sugar
3. ✅ Déploiement sur le serveur
4. ✅ Validation de la configuration
5. ✅ Upload sur Arweave
6. ✅ Déploiement de la Candy Machine
7. ✅ Vérification finale

**Durée estimée**: 8-16 minutes

---

### Méthode 2: Déploiement Manuel (Pour Plus de Contrôle)

Si vous préférez contrôler chaque étape:

#### Étape 1: Générer les NFTs Localement

```bash
# Sur votre machine locale
cd /home/alaeddine/Bureau/hashlips

# Supprimer l'ancienne génération si elle existe
rm -rf build

# Générer les 300 NFTs
npm run build

# Vérifier
ls -1 build/images/*.png | wc -l
# Devrait afficher: 300
```

#### Étape 2: Préparer les Assets pour Sugar

```bash
# Convertir au format Sugar
node prepare-sugar-assets.js

# Vérifier
ls -1 assets/*.png | wc -l
# Devrait afficher: 300
```

#### Étape 3: Déployer sur le Serveur

```bash
# Créer le répertoire distant
ssh mf "mkdir -p /root/hashlips"

# Copier les fichiers
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.git' \
  ./ mf:/root/hashlips/

# Installer les dépendances sur le serveur
ssh mf "cd /root/hashlips && npm install"
```

#### Étape 4: Valider la Configuration Sugar

```bash
# Se connecter au serveur
ssh mf

# Naviguer vers le projet
cd /root/hashlips

# Valider la configuration
sugar validate

# Résultat attendu: "✅ Configuration is valid"
```

#### Étape 5: Upload des Assets sur Arweave

⚠️ **ATTENTION**: Cette étape utilise des SOL réels!

```bash
# Toujours sur le serveur
sugar upload

# Ce processus:
# - Upload 300 images (environ 5-10 minutes)
# - Crée un cache.json avec les URLs Arweave
# - Coûte environ 0.3-0.5 SOL
```

**Surveillance en temps réel**:
```bash
# Dans un autre terminal
ssh mf "tail -f /root/hashlips/upload.log"
```

#### Étape 6: Déployer la Candy Machine

```bash
# Déployer sur mainnet
sugar deploy

# Ce processus:
# - Crée la Candy Machine on-chain
# - Configure tous les paramètres
# - Coûte environ 0.01 SOL
```

**⚠️ IMPORTANT**: Notez l'adresse de la Candy Machine qui s'affiche!

```
Candy Machine ID: AbCd1234...Xyz
```

#### Étape 7: Vérifier le Déploiement

```bash
# Vérifier que tout est correct
sugar verify

# Afficher les informations de la collection
sugar show
```

---

## ✅ Vérification et Tests

### Vérifier la Collection

```bash
# Sur le serveur
ssh mf "cd /root/hashlips && sugar show"
```

Informations affichées:
- ✅ Adresse de la Candy Machine
- ✅ Nombre de NFTs (300)
- ✅ Prix de mint (0.1 SOL)
- ✅ Date de lancement
- ✅ Treasury address
- ✅ Royalties (5%)

### Tester le Mint

⚠️ **Test sur un wallet secondaire d'abord!**

```bash
# Mint un NFT de test
sugar mint

# Vérifier dans votre wallet Phantom/Solflare
```

### Vérifier sur Explorer

```bash
# Obtenir l'URL du Solana Explorer
CANDY_MACHINE_ID="<votre_candy_machine_id>"
echo "https://solscan.io/account/${CANDY_MACHINE_ID}?cluster=mainnet"
```

---

## 🎮 Gestion Post-Déploiement

### Lancer la Vente Publique

```bash
# Activer le mint public
ssh mf "cd /root/hashlips && sugar launch"
```

### Mettre à Jour la Configuration

Si vous devez modifier des paramètres:

```bash
# Éditer sugar-config.json
# Puis mettre à jour
ssh mf "cd /root/hashlips && sugar update"
```

### Retirer les Fonds

Une fois la vente terminée:

```bash
# Retirer les SOL de la Candy Machine
ssh mf "cd /root/hashlips && sugar withdraw"
```

### Récupérer les Assets Générés

```bash
# Backup des assets sur votre machine locale
rsync -avz mf:/root/hashlips/build/ ./backup-mainnet-$(date +%Y%m%d)/
rsync -avz mf:/root/hashlips/assets/ ./backup-mainnet-assets-$(date +%Y%m%d)/
```

---

## 🔧 Dépannage

### Problème: "Insufficient Funds"

```bash
# Vérifier le solde
ssh mf "solana balance"

# Si insuffisant, transférer plus de SOL
solana transfer <ADRESSE_SERVEUR> 1 --allow-unfunded-recipient
```

### Problème: "Upload Failed"

```bash
# Reprendre l'upload là où il s'est arrêté
ssh mf "cd /root/hashlips && sugar upload"

# Sugar reprend automatiquement depuis le cache
```

### Problème: "Configuration Invalid"

```bash
# Vérifier les erreurs détaillées
ssh mf "cd /root/hashlips && sugar validate --verbose"

# Vérifier sugar-config.json
ssh mf "cat /root/hashlips/sugar-config.json"
```

### Problème: "Network Error"

```bash
# Vérifier la connexion au réseau Solana
ssh mf "solana cluster-version"

# Changer de RPC si nécessaire
ssh mf "solana config set --url https://api.mainnet-beta.solana.com"
```

### Logs de Débugging

```bash
# Voir les logs système
ssh mf "journalctl -xe"

# Logs Solana
ssh mf "ls -la ~/.config/solana/*.log"

# Logs Sugar (si activé)
ssh mf "cat /root/hashlips/sugar.log"
```

---

## 🔒 Sécurité

### ⚠️ CRITIQUES - À Faire Immédiatement

#### 1. Supprimer le Wallet du Serveur Après Déploiement

```bash
# Après succès du déploiement
ssh mf "rm -f /root/.config/solana/id.json"
ssh mf "rm -f /root/.config/solana/*.json"

# Vérifier
ssh mf "ls -la /root/.config/solana/"
```

#### 2. Sauvegarder Votre Keypair

```bash
# Backup local sécurisé
cp ~/.config/solana/id.json ~/Documents/backups/solana-keypair-$(date +%Y%m%d).json
chmod 400 ~/Documents/backups/solana-keypair-*.json

# Backup chiffré
gpg -c ~/Documents/backups/solana-keypair-$(date +%Y%m%d).json
```

#### 3. Sauvegarder les Informations de la Candy Machine

```bash
# Créer un fichier de référence
cat > candy-machine-info.txt << EOF
Candy Machine ID: <VOTRE_ID>
Date de déploiement: $(date)
Collection: Oinkonomics (OINK)
Nombre de NFTs: 300
Treasury: 5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
Réseau: Mainnet-beta
EOF

# Garder ce fichier en sécurité!
```

### 📋 Checklist de Sécurité

- [ ] Wallet sauvegardé (offline + chiffré)
- [ ] Keypair supprimé du serveur
- [ ] Candy Machine ID documenté
- [ ] Cache.json sauvegardé
- [ ] Assets originaux sauvegardés
- [ ] Adresses vérifiées sur Solana Explorer
- [ ] Test de mint effectué
- [ ] Accès au serveur sécurisé (clés SSH)

---

## 💰 Estimation des Coûts

### Coûts par Opération (Mainnet)

| Opération | Coût Estimé | Description |
|-----------|-------------|-------------|
| **Upload Arweave** | 0.3-0.5 SOL | Upload de 300 images |
| **Création Candy Machine** | 0.01 SOL | Déploiement on-chain |
| **Frais de transaction** | 0.001 SOL | Par transaction |
| **Buffer** | 0.1-0.2 SOL | Marge de sécurité |
| **TOTAL** | **~0.5-0.8 SOL** | Pour 300 NFTs |

### Recommandations Budgétaires

- ✅ **Minimum**: 0.8 SOL dans le wallet
- ✅ **Recommandé**: 1 SOL pour sécurité
- ✅ **Optimal**: 1.5 SOL pour plusieurs tentatives si besoin

---

## 📊 Métriques de Performance

### Temps de Déploiement (Serveur vs Local)

| Étape | Machine Locale | Serveur MF | Gain |
|-------|---------------|------------|------|
| Génération NFTs | 8-12 min | 4-7 min | ~50% |
| Upload Arweave | 25-40 min | 6-10 min | **4x** |
| Déploiement | 1-2 min | 1 min | 0% |
| **TOTAL** | **34-54 min** | **11-18 min** | **3x plus rapide** |

### Ressources Serveur Utilisées

- **CPU**: ~40-60% durant génération
- **RAM**: ~2-3 GB sur 62 GB disponible
- **Bande passante**: ~50-100 Mbps pour upload
- **Stockage**: ~500 MB pour projet + assets

---

## 🎯 Prochaines Étapes Après Déploiement

### 1. Intégration Frontend

```javascript
// Dans votre application web
const CANDY_MACHINE_ID = "VotreCandyMachineID";
const NETWORK = "mainnet-beta";

// Utiliser @metaplex-foundation/js
import { Metaplex } from "@metaplex-foundation/js";

const metaplex = new Metaplex(connection);
const candyMachine = await metaplex
  .candyMachines()
  .findByAddress({ address: CANDY_MACHINE_ID });
```

### 2. Marketing et Communication

- [ ] Annoncer le lancement sur Twitter/X
- [ ] Créer une page de mint sur votre site
- [ ] Préparer les visuels de communication
- [ ] Configurer Magic Eden / Tensor pour le trading

### 3. Monitoring

```bash
# Surveiller les ventes
watch -n 60 'ssh mf "cd /root/hashlips && sugar show"'

# Voir le nombre de NFTs mintés
# Le nombre restant diminue au fur et à mesure
```

---

## 📞 Commandes Utiles Récapitulatif

### Surveillance

```bash
# État de la Candy Machine
ssh mf "cd /root/hashlips && sugar show"

# Vérifier le solde
ssh mf "solana balance"

# Voir les NFTs mintés
ssh mf "cd /root/hashlips && sugar verify"
```

### Gestion

```bash
# Mettre à jour la config
ssh mf "cd /root/hashlips && sugar update"

# Retirer les fonds
ssh mf "cd /root/hashlips && sugar withdraw"

# Geler la collection
ssh mf "cd /root/hashlips && sugar freeze"
```

### Backup

```bash
# Tout sauvegarder
rsync -avz mf:/root/hashlips/ ./backup-complete-$(date +%Y%m%d)/

# Sauvegarder juste le cache
scp mf:/root/hashlips/.cache/temp.json ./cache-backup-$(date +%Y%m%d).json
```

---

## 🎉 Félicitations!

Si vous avez suivi ce guide, votre collection **Oinkonomics** est maintenant déployée sur Solana Mainnet! 🐷

### Points Clés à Retenir

1. ✅ **300 NFTs** répartis en 3 tiers (Poor, Mid, Rich)
2. ✅ **Symbole**: OINK
3. ✅ **Royalties**: 5%
4. ✅ **Prix**: 0.1 SOL par mint
5. ✅ **Hébergé sur Arweave** (stockage permanent)

### Ressources Supplémentaires

- 📖 [Documentation Sugar](https://docs.metaplex.com/tools/sugar)
- 📖 [Solana Documentation](https://docs.solana.com/)
- 🔍 [Solscan Explorer](https://solscan.io/)
- 💬 [Metaplex Discord](https://discord.gg/metaplex)

---

**Créé le**: 06/12/2025  
**Dernière mise à jour**: 06/12/2025  
**Version**: 1.0  
**Projet**: Oinkonomics NFT Collection
