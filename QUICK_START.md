# 🚀 Quick Start - Déploiement Oinkonomics NFT

Guide rapide pour déployer votre collection NFT Oinkonomics sur Solana Mainnet.

## 📦 Fichiers créés pour le déploiement

### Scripts de déploiement
- ✅ **deploy-to-server.sh** - Déploie le projet sur le serveur Money Factory
- ✅ **deploy-nft-mainnet.sh** - Script complet de déploiement mainnet (automatisé)
- ✅ **prepare-sugar-assets.js** - Convertit les métadonnées au format Sugar

### Configuration
- ✅ **sugar-config.json** - Configuration de la Candy Machine
- ✅ **DEPLOYMENT_GUIDE.md** - Guide complet et détaillé

### Commandes npm ajoutées
```bash
npm run prepare-sugar    # Préparer les assets pour Sugar
npm run deploy-server    # Déployer sur le serveur
npm run deploy-mainnet   # Déploiement complet mainnet
```

---

## ⚡ Démarrage rapide

### Option A: Déploiement automatique complet

```bash
cd /home/alaeddine/Bureau/hashlips
npm run deploy-mainnet
```

Cette commande exécute automatiquement tout le processus:
1. Génère les 300 NFTs avec Hashlips
2. Convertit les métadonnées pour Sugar
3. Déploie sur le serveur
4. Configure Solana mainnet
5. Upload les assets sur Arweave
6. Déploie la Candy Machine

### Option B: Déploiement étape par étape

```bash
# 1. Générer les NFTs
cd /home/alaeddine/Bureau/hashlips
npm run build

# 2. Préparer pour Sugar
npm run prepare-sugar

# 3. Déployer sur le serveur
npm run deploy-server

# 4. Sur le serveur, exécuter Sugar
ssh mf
cd /root/hashlips
solana config set --url mainnet-beta
sugar validate
sugar upload
sugar deploy
sugar verify
```

---

## ⚠️ IMPORTANT: Checklist avant le lancement

### 1. Configuration locale
- [ ] Node.js installé (`node --version`)
- [ ] Dépendances installées (`npm install`)
- [ ] SSH configuré pour le serveur `mf`

### 2. Configuration serveur
- [ ] Solana CLI installé sur le serveur
- [ ] Sugar CLI installé sur le serveur
- [ ] Wallet Solana configuré avec seed phrase sauvegardée
- [ ] **~10 SOL dans le wallet** (vérifier avec `ssh mf "solana balance"`)

### 3. Configuration projet
- [ ] Vérifier `src/config.js`:
  - Treasury address: `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z`
  - Symbol: `OINK`
  - Royalties: `500` (5%)
  - `shuffleLayerConfigurations: false`
  
### 4. Test sur Devnet (RECOMMANDÉ)
- [ ] Tester d'abord sur devnet:
  ```bash
  ssh mf
  cd /root/hashlips
  solana config set --url devnet
  solana airdrop 2
  sugar validate
  sugar upload
  sugar deploy
  ```

### 5. Production Mainnet
- [ ] Confirmer que vous avez suffisamment de SOL (~10 SOL)
- [ ] Confirmer que les assets sont finalisés
- [ ] Lancer le déploiement mainnet

---

## 💰 Estimation des coûts

| Élément | Coût | Note |
|---------|------|------|
| Upload 300 NFTs sur Arweave | 3-6 SOL | Via Bundlr |
| Création Candy Machine | 0.01 SOL | Frais on-chain |
| Transactions diverses | 0.5 SOL | Réseau |
| **Budget recommandé** | **10 SOL** | Pour être sûr |

---

## 🔑 Informations importantes

### Adresses clés
- **Treasury Wallet**: `5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z`
- **Serveur**: `88.99.254.59` (alias `mf` dans SSH config)
- **Chemin serveur**: `/root/hashlips`

### Collection details
- **Nom**: Oinkonomics
- **Symbol**: OINK
- **Total NFTs**: 300
- **Tiers**:
  - Poor (0-99): Solde < 1 SOL
  - Mid (100-199): 1 SOL ≤ Solde < 5 SOL
  - Rich (200-299): Solde ≥ 5 SOL
- **Royalties**: 5%
- **Résolution images**: 1000x1000px

---

## 🛠️ Commandes utiles

### Génération et préparation
```bash
npm run build           # Générer les NFTs
npm run rarity         # Analyser la rareté
npm run preview        # Créer une preview
npm run prepare-sugar  # Préparer pour Sugar
```

### Déploiement
```bash
npm run deploy-server   # Déployer sur le serveur
npm run deploy-mainnet  # Déploiement complet mainnet
```

### Gestion sur le serveur
```bash
# Se connecter au serveur
ssh mf

# Voir la configuration Sugar
cd /root/hashlips && sugar show

# Voir le solde
solana balance

# Voir l'adresse du wallet
solana address

# Configurer le réseau
solana config set --url mainnet-beta  # Production
solana config set --url devnet        # Test

# Commandes Sugar
sugar validate   # Valider la config
sugar upload     # Upload des assets
sugar deploy     # Déployer la Candy Machine
sugar verify     # Vérifier le déploiement
sugar launch     # Lancer la vente
sugar show       # Voir les infos
sugar withdraw   # Retirer les fonds
```

---

## 🎯 Après le déploiement

### 1. Récupérer l'adresse de la Candy Machine

```bash
ssh mf "cat /root/hashlips/cache.json"
```

Cherchez le champ `"program"` → C'est l'adresse de votre Candy Machine.

### 2. Tester le mint

Testez le mint avec un wallet de test pour vérifier que tout fonctionne.

### 3. Intégrer dans votre application

Ajoutez l'adresse de la Candy Machine dans votre frontend pour permettre aux utilisateurs de minter les NFTs.

### 4. Vérifier sur Solana Explorer

```
https://explorer.solana.com/address/[VOTRE_CANDY_MACHINE_ADDRESS]
```

---

## 🔥 Lancement de la vente

Une fois tout testé et vérifié:

```bash
ssh mf "cd /root/hashlips && sugar launch"
```

Cela active officiellement la vente de vos NFTs!

---

## 📞 Besoin d'aide?

- **Documentation complète**: Voir `DEPLOYMENT_GUIDE.md`
- **Sugar docs**: https://docs.metaplex.com/tools/sugar
- **Solana docs**: https://docs.solana.com/

---

## ⚡ Commande unique pour tout déployer

Si vous êtes prêt et que tout est configuré:

```bash
cd /home/alaeddine/Bureau/hashlips && npm run deploy-mainnet
```

🚨 **ATTENTION**: Cette commande va utiliser des SOL réels! Assurez-vous d'avoir:
- [x] Testé sur devnet
- [x] Suffisamment de SOL (~10 SOL)
- [x] Sauvegardé votre seed phrase
- [x] Vérifié toutes les configurations

---

**Bonne chance avec le lancement d'Oinkonomics! 🐷🚀**
