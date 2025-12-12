# 🐷 Guide de Déploiement - Oinkonomics NFT Collection

Ce guide explique comment déployer la collection NFT Oinkonomics sur Solana Mainnet en utilisant Hashlips Art Engine et Sugar CLI.

## 📋 Table des matières

1. [Architecture du projet](#architecture-du-projet)
2. [Prérequis](#prérequis)
3. [Configuration initiale](#configuration-initiale)
4. [Logique métier](#logique-métier)
5. [Processus de déploiement](#processus-de-déploiement)
6. [Scripts disponibles](#scripts-disponibles)
7. [Dépannage](#dépannage)
8. [Maintenance](#maintenance)

---

## 🏗️ Architecture du projet

```
hashlips/
├── layers/                    # Couches d'images pour générer les NFTs
│   ├── 1.Background/
│   ├── 2.Skin/
│   ├── 3.Outfit/
│   ├── 4.Eyes/
│   ├── 5.Nose/
│   ├── 6.Ears/
│   ├── 7.Mouth/
│   └── 8.Headtop/
├── src/
│   ├── config.js             # Configuration principale (IMPORTANT!)
│   └── main.js
├── build/                    # Généré par Hashlips
│   ├── images/               # Images PNG des NFTs
│   └── json/                 # Métadonnées brutes
├── assets/                   # Généré par prepare-sugar-assets.js
│   ├── 0.png, 0.json
│   ├── 1.png, 1.json
│   └── ...
├── sugar-config.json         # Configuration Sugar pour Candy Machine
├── prepare-sugar-assets.js   # Script de conversion des métadonnées
├── deploy-to-server.sh       # Déploie le projet sur le serveur
└── deploy-nft-mainnet.sh     # Script complet de déploiement mainnet
```

---

## ✅ Prérequis

### Sur votre machine locale
- **Node.js** (v16+): `node --version`
- **npm**: `npm --version`
- **rsync**: `rsync --version`
- **ssh**: Accès SSH au serveur configuré

### Sur le serveur (88.99.254.59)
- **Node.js** (v16+)
- **Solana CLI** (v1.16+)
- **Sugar CLI** (dernière version)
- **Wallet Solana** avec des SOL pour les frais

---

## ⚙️ Configuration initiale

### 1. Installation des dépendances locales

```bash
cd /home/alaeddine/Bureau/hashlips
npm install
```

### 2. Installation de Solana CLI sur le serveur (si nécessaire)

```bash
ssh mf
sh -c "$(curl -sSfL https://release.solana.com/v1.16.0/install)"
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
echo 'export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc
solana --version
```

### 3. Installation de Sugar CLI sur le serveur (si nécessaire)

```bash
ssh mf
bash <(curl -sSf https://sugar.metaplex.com/install.sh)
export PATH="/root/.cargo/bin:$PATH"
echo 'export PATH="/root/.cargo/bin:$PATH"' >> ~/.bashrc
sugar --version
```

### 4. Configuration du wallet Solana sur le serveur

```bash
ssh mf

# Créer un nouveau wallet (SAUVEGARDER LA SEED PHRASE!)
solana-keygen new --outfile ~/.config/solana/id.json

# OU importer un wallet existant
solana-keygen recover --outfile ~/.config/solana/id.json

# Vérifier l'adresse publique
solana address

# Configurer le réseau (devnet pour les tests)
solana config set --url devnet

# Vérifier le solde
solana balance

# Airdrop pour le devnet (tests uniquement)
solana airdrop 2
```

### 5. Financer le wallet pour le mainnet

**⚠️ IMPORTANT**: Pour le déploiement sur mainnet, vous devez avoir **~5-10 SOL** dans votre wallet pour couvrir:
- Upload des assets sur Arweave (~3-6 SOL pour 300 NFTs)
- Création de la Candy Machine (~0.01 SOL)
- Frais de transaction (~0.5 SOL)

```bash
# Vérifier votre adresse
ssh mf "solana address"

# Transférer des SOL vers cette adresse depuis un exchange (Binance, Coinbase, etc.)
```

---

## 🎯 Logique métier

### Stratégie de tier basée sur le wallet

La collection Oinkonomics suit une logique de **trois tiers** basée sur le solde du wallet de l'utilisateur:

| Tier | Éditions | Condition | Description |
|------|----------|-----------|-------------|
| **Poor** | 0-99 | Solde < 1 SOL | Personnages avec traits basiques |
| **Mid** | 100-199 | 1 SOL ≤ Solde < 5 SOL | Personnages avec traits améliorés |
| **Rich** | 200-299 | Solde ≥ 5 SOL | Personnages avec traits premium |

### Configuration dans `src/config.js`

```javascript
const layerConfigurations = [
    {
        // POOR TIER: #0 - #99
        growEditionSizeTo: 100,
        layersOrder: [
            { name: "1.Background" },
            { name: "2.Skin" },
            // ... autres couches
        ],
    },
    {
        // MID TIER: #100 - #199
        growEditionSizeTo: 200,
        layersOrder: [ /* ... */ ],
    },
    {
        // RICH TIER: #200 - #299
        growEditionSizeTo: 300,
        layersOrder: [ /* ... */ ],
    },
];
```

**🔒 IMPORTANT**: `shuffleLayerConfigurations` doit être `false` pour maintenir l'ordre des tiers!

### Métadonnées et propriétés

- **Symbol**: OINK
- **Royalties**: 5% (500 basis points)
- **Treasury Wallet**: `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z`
- **External URL**: https://oinkonomics.mfai.app
- **Network**: Solana (mainnet-beta)
- **Collection size**: 300 NFTs uniques

---

## 🚀 Processus de déploiement

### Option 1: Script automatique (Recommandé)

Ce script automatise tout le processus:

```bash
cd /home/alaeddine/Bureau/hashlips

# Rendre le script exécutable
chmod +x deploy-nft-mainnet.sh

# Lancer le déploiement complet
./deploy-nft-mainnet.sh
```

Le script exécutera automatiquement:
1. ✅ Génération des 300 NFTs avec Hashlips
2. ✅ Conversion des métadonnées au format Sugar
3. ✅ Déploiement sur le serveur
4. ✅ Vérification de l'environnement Solana
5. ✅ Configuration du mainnet
6. ✅ Validation de la configuration Sugar
7. ✅ Upload des assets sur Arweave
8. ✅ Déploiement de la Candy Machine

### Option 2: Déploiement manuel étape par étape

#### Étape 1: Génération des NFTs

```bash
cd /home/alaeddine/Bureau/hashlips
npm run build
```

Cela génère:
- `build/images/` : 300 images PNG (1000x1000)
- `build/json/` : 300 fichiers de métadonnées

#### Étape 2: Préparation pour Sugar

```bash
node prepare-sugar-assets.js
```

Cela crée le dossier `assets/` avec les métadonnées au format Sugar compatible.

#### Étape 3: Déploiement sur le serveur

```bash
chmod +x deploy-to-server.sh
./deploy-to-server.sh
```

#### Étape 4: Configuration et déploiement Sugar sur le serveur

```bash
# Se connecter au serveur
ssh mf

# Aller dans le répertoire
cd /root/hashlips

# Configurer le mainnet
solana config set --url mainnet-beta

# Vérifier le solde (doit avoir ~5-10 SOL)
solana balance

# Valider la configuration
sugar validate

# Upload des assets (coûte ~3-6 SOL)
sugar upload

# Déployer la Candy Machine
sugar deploy

# Vérifier le déploiement
sugar verify

# Lancer la vente (quand prêt)
sugar launch
```

---

## 📜 Scripts disponibles

### `deploy-to-server.sh`
Copie le projet hashlips sur le serveur et installe les dépendances.

```bash
chmod +x deploy-to-server.sh
./deploy-to-server.sh
```

### `deploy-nft-mainnet.sh`
Script tout-en-un qui automatise l'ensemble du processus de déploiement sur mainnet.

```bash
chmod +x deploy-nft-mainnet.sh
./deploy-nft-mainnet.sh
```

### `prepare-sugar-assets.js`
Convertit les métadonnées Hashlips au format Sugar et ajoute l'attribut "Tier".

```bash
node prepare-sugar-assets.js
```

### Commandes npm disponibles

```bash
npm run build              # Génère les NFTs
npm run rarity            # Analyse la rareté des traits
npm run preview           # Crée une preview de la collection
npm run pixelate          # Pixelise les images
npm run update_info       # Met à jour baseUri et description
```

---

## 🔧 Dépannage

### Problème: "Solana CLI not found"

```bash
ssh mf
curl -sSfL https://release.solana.com/v1.16.0/install | sh
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
```

### Problème: "Sugar CLI not found"

```bash
ssh mf
bash <(curl -sSf https://sugar.metaplex.com/install.sh)
export PATH="/root/.cargo/bin:$PATH"
```

### Problème: "Insufficient funds"

```bash
ssh mf
solana balance
# Transférer plus de SOL vers l'adresse du wallet
```

### Problème: "Upload failed"

- Vérifier que vous êtes sur le bon réseau: `solana config get`
- Vérifier votre solde: `solana balance`
- Réessayer: `sugar upload` (reprend là où il s'est arrêté)

### Problème: "Validation failed"

- Vérifier que `sugar-config.json` est présent
- Vérifier que le dossier `assets/` contient tous les fichiers (0.png, 0.json, 1.png, 1.json, etc.)
- S'assurer que le nombre de fichiers correspond au nombre dans sugar-config.json

### Problème: Metadata incorrectes

Si vous devez régénérer les métadonnées:

```bash
rm -rf build/ assets/
npm run build
node prepare-sugar-assets.js
```

---

## 🛠️ Maintenance

### Voir les informations de la Candy Machine

```bash
ssh mf "cd /root/hashlips && sugar show"
```

### Mettre à jour la configuration

```bash
# Éditer sugar-config.json
# Puis:
ssh mf "cd /root/hashlips && sugar update"
```

### Retirer les fonds de la Candy Machine

```bash
ssh mf "cd /root/hashlips && sugar withdraw"
```

### Mettre à jour les métadonnées après déploiement

**⚠️ Attention**: Cela n'est possible que si `isMutable: true` dans sugar-config.json

```bash
# Modifier les métadonnées
# Puis:
ssh mf "cd /root/hashlips && sugar update"
```

### Monitoring de la vente

```bash
# Voir le statut
ssh mf "cd /root/hashlips && sugar show"

# Voir les logs
ssh mf "journalctl -f"
```

---

## 📊 Estimation des coûts (Mainnet)

| Opération | Coût estimé | Description |
|-----------|-------------|-------------|
| Upload assets (300 NFTs) | ~3-6 SOL | Stockage sur Arweave via Bundlr |
| Candy Machine creation | ~0.01 SOL | Création du programme on-chain |
| Transactions diverses | ~0.5 SOL | Frais de réseau |
| **Total** | **~4-7 SOL** | Budget recommandé: 10 SOL |

**💡 Conseil**: Commencez toujours par tester sur **devnet** (gratuit) avant de déployer sur mainnet!

---

## 🎯 Intégration avec l'application web

Une fois la Candy Machine déployée, vous recevrez une adresse (ID) qu'il faudra intégrer dans votre application web.

### Récupérer l'adresse de la Candy Machine

```bash
ssh mf "cd /root/hashlips && cat cache.json"
```

Cherchez le champ `"program"` qui contient l'adresse de votre Candy Machine.

### Intégration dans le code

Cette adresse doit être ajoutée dans votre configuration frontend pour permettre le mint des NFTs.

---

## 📞 Support

- **Documentation Sugar**: https://docs.metaplex.com/tools/sugar
- **Documentation Solana**: https://docs.solana.com/
- **Hashlips GitHub**: https://github.com/HashLips/hashlips_art_engine

---

## ⚠️ Checklist avant déploiement mainnet

- [ ] Les images des layers sont finalisées et de bonne qualité
- [ ] La configuration dans `src/config.js` est correcte
- [ ] Les NFTs ont été générés et vérifiés localement
- [ ] Les métadonnées sont correctes (symbole, royalties, creator address)
- [ ] Le wallet sur le serveur a suffisamment de SOL (~10 SOL recommandé)
- [ ] Le réseau est configuré sur mainnet-beta
- [ ] Vous avez testé sur devnet d'abord
- [ ] La seed phrase du wallet est sauvegardée en lieu sûr
- [ ] L'adresse du treasury wallet est correcte
- [ ] Vous avez préparé votre application web pour l'intégration

---

## 🎉 Après le déploiement

1. **Tester le mint**: Mintez quelques NFTs pour vérifier que tout fonctionne
2. **Vérifier sur Solana Explorer**: https://explorer.solana.com/
3. **Annoncer le lancement**: Préparez votre communication marketing
4. **Monitorer**: Surveillez les ventes et les métriques
5. **Support**: Soyez disponible pour aider votre communauté

---

**Bonne chance avec votre collection Oinkonomics! 🐷🚀**
