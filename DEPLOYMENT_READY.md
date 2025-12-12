# 🎉 Serveur Prêt pour le Déploiement NFT Mainnet

**Date**: 06/12/2025  
**Projet**: Oinkonomics NFT Collection  
**Collection**: 300 NFTs (Poor: 0-99, Mid: 100-199, Rich: 200-299)

---

## ✅ Configuration Complétée

### 🖥️ Serveur Money Factory

**Spécifications**:
- **Host**: mf (88.99.254.59)
- **CPU**: Intel Core i7-8700 @ 3.20GHz (6 cores, 12 threads)
- **RAM**: 62 GB (59 GB disponible)
- **OS**: Ubuntu 22.04 LTS
- **Localisation**: Allemagne (Hetzner)
- **Connexion**: Datacenter 1 Gbps

**Logiciels Installés**:
- ✅ **Node.js**: v20.19.6
- ✅ **NPM**: 10.8.2
- ✅ **Solana CLI**: 1.18.22
- ⏳ **Sugar CLI**: Installation en cours

---

## 📁 Fichiers Créés

### Scripts de Configuration

1. **`setup-server.sh`** ✅
   - Installation automatique de Solana CLI
   - Installation automatique de Sugar CLI
   - Configuration du réseau mainnet
   - Installation des dépendances système
   - **Status**: En cours d'exécution sur le serveur

2. **`verify-server-setup.sh`** ✅
   - Vérification complète de la configuration
   - Contrôle de tous les prérequis
   - Test de connexion SSH
   - Vérification du wallet
   - **Usage**: `./verify-server-setup.sh`

3. **`deploy-nft-mainnet.sh`** ✅ (déjà existant)
   - Script complet de déploiement automatique
   - Génération → Préparation → Upload → Déploiement
   - Avec confirmations de sécurité
   - **Usage**: `./deploy-nft-mainnet.sh`

4. **`prepare-sugar-assets.js`** ✅ (déjà existant)
   - Conversion des métadonnées au format Sugar
   - Organisation des fichiers pour Sugar CLI
   - Ajout automatique du tier (Poor/Mid/Rich)

### Documentation

5. **`MAINNET_DEPLOYMENT_GUIDE.md`** ✅
   - Guide complet étape par étape
   - Méthode automatique et manuelle
   - Dépannage et solutions
   - Checklist de sécurité
   - Commandes utiles
   - **180+ lignes de documentation détaillée**

6. **`.env.example`** ✅
   - Variables d'environnement documentées
   - Configuration réseau Solana
   - Paramètres de collection
   - Notes de sécurité

7. **`SERVER_DEPLOYMENT_ANALYSIS.md`** ✅ (déjà existant)
   - Analyse des performances
   - Comparaison serveur vs local
   - Recommandations d'utilisation

---

## 🚀 Prochaines Étapes

### Étape 1: Vérifier que Sugar est Installé

```bash
# Dans quelques minutes, vérifier l'installation
ssh mf "sugar --version"

# Ou utiliser le script de vérification
./verify-server-setup.sh
```

**Résultat attendu**:
```
✅ Solana CLI installé: solana-cli 1.18.22
✅ Sugar CLI installé: sugar 2.6.0
✅ Configuration Serveur OK
```

---

### Étape 2: Transférer Votre Wallet

⚠️ **IMPORTANT**: Utilisez un wallet dédié avec uniquement le SOL nécessaire!

```bash
# Option 1: Wallet existant (assurez-vous d'avoir 1+ SOL)
scp ~/.config/solana/id.json mf:/root/.config/solana/

# Option 2: Créer un nouveau wallet sur le serveur
ssh mf "solana-keygen new --outfile /root/.config/solana/id.json"
# Puis transférez 1 SOL depuis votre wallet principal
```

**Vérifier le solde**:
```bash
ssh mf "solana balance"
# Minimum requis: 1 SOL
```

---

### Étape 3: Déployer la Collection

**Option A: Script Automatique (Recommandé)**

```bash
cd /home/alaeddine/Bureau/hashlips
./deploy-nft-mainnet.sh
```

Ce script fait TOUT automatiquement:
- ✅ Génère les 300 NFTs
- ✅ Prépare les assets pour Sugar
- ✅ Déploie sur le serveur
- ✅ Valide la configuration
- ✅ Upload sur Arweave
- ✅ Déploie la Candy Machine
- ✅ Vérifie le déploiement

**Durée estimée**: 10-15 minutes

---

**Option B: Déploiement Manuel (Contrôle Total)**

```bash
# 1. Générer les NFTs localement
npm run build

# 2. Préparer pour Sugar
node prepare-sugar-assets.js

# 3. Déployer sur le serveur
rsync -avz --exclude 'node_modules' --exclude '.git' ./ mf:/root/hashlips/
ssh mf "cd /root/hashlips && npm install"

# 4. Valider
ssh mf "cd /root/hashlips && sugar validate"

# 5. Upload sur Arweave (utilise des SOL réels!)
ssh mf "cd /root/hashlips && sugar upload"

# 6. Déployer la Candy Machine
ssh mf "cd /root/hashlips && sugar deploy"

# 7. Vérifier
ssh mf "cd /root/hashlips && sugar verify"
```

---

## 💰 Estimation des Coûts

Pour 300 NFTs sur Mainnet:

| Opération | Coût |
|-----------|------|
| Upload Arweave (300 images) | 0.3-0.5 SOL |
| Création Candy Machine | 0.01 SOL |
| Frais de transaction | 0.001 SOL |
| Buffer de sécurité | 0.1-0.2 SOL |
| **TOTAL ESTIMÉ** | **~0.5-0.8 SOL** |

**Recommandation**: Avoir **1 SOL** dans le wallet pour sécurité.

---

## 🎯 Configuration de la Collection

Les paramètres actuels dans `sugar-config.json`:

```json
{
  "price": 0.1,              // Prix de mint: 0.1 SOL
  "number": 300,             // 300 NFTs au total
  "symbol": "OINK",          // Symbole: OINK
  "sellerFeeBasisPoints": 500, // Royalties: 5%
  "solTreasuryAccount": "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z",
  "goLiveDate": "2025-01-15T00:00:00Z",
  "uploadMethod": "bundlr",  // Upload via Bundlr/Arweave
  "retainAuthority": true,   // Garder l'autorité
  "isMutable": true          // NFTs modifiables
}
```

---

## 🔒 Checklist de Sécurité

Avant de déployer:

- [ ] Wallet sauvegardé (backup offline + chiffré)
- [ ] Wallet a suffisamment de SOL (minimum 1 SOL)
- [ ] Configuration `sugar-config.json` vérifiée
- [ ] Assets générés et validés (300 NFTs)
- [ ] Connexion SSH au serveur fonctionnelle
- [ ] Solana CLI et Sugar CLI installés sur le serveur

Après le déploiement:

- [ ] Candy Machine ID documenté
- [ ] Cache.json sauvegardé localement
- [ ] Wallet supprimé du serveur (`ssh mf "rm -f /root/.config/solana/id.json"`)
- [ ] Test de mint effectué
- [ ] Collection vérifiée sur Solscan

---

## 📊 Avantages du Serveur

### Performance

| Métrique | Local | Serveur MF | Gain |
|----------|-------|------------|------|
| Génération (300 NFTs) | 8-12 min | 4-7 min | **~50%** |
| Upload Arweave | 25-40 min | 6-10 min | **4x** |
| **Total** | **33-52 min** | **10-17 min** | **3x plus rapide** |

### Stabilité

- ✅ Connexion datacenter (pas de coupure)
- ✅ Bande passante illimitée
- ✅ CPU dédié (pas de ralentissement)
- ✅ 62 GB RAM (aucun risque de saturation)

---

## 🔧 Commandes Utiles

### Surveillance

```bash
# Statut de la Candy Machine
ssh mf "cd /root/hashlips && sugar show"

# Solde du wallet
ssh mf "solana balance"

# Vérifier la configuration
ssh mf "solana config get"
```

### Gestion Post-Déploiement

```bash
# Lancer la vente publique
ssh mf "cd /root/hashlips && sugar launch"

# Mettre à jour la configuration
ssh mf "cd /root/hashlips && sugar update"

# Retirer les fonds
ssh mf "cd /root/hashlips && sugar withdraw"
```

### Backup

```bash
# Sauvegarder les assets
rsync -avz mf:/root/hashlips/build/ ./backup-mainnet-$(date +%Y%m%d)/

# Sauvegarder le cache Sugar
scp mf:/root/hashlips/.cache/temp.json ./cache-backup-$(date +%Y%m%d).json
```

---

## 🆘 Dépannage

### Problème: "Insufficient Funds"
```bash
# Vérifier et ajouter du SOL
ssh mf "solana balance"
solana transfer <ADRESSE_SERVEUR> 1
```

### Problème: "Sugar command not found"
```bash
# Relancer l'installation
ssh mf "bash /root/setup-server.sh"
```

### Problème: "Upload Failed"
```bash
# Reprendre l'upload (Sugar utilise le cache)
ssh mf "cd /root/hashlips && sugar upload"
```

---

## 📚 Documentation Complète

Pour plus de détails, consultez:

1. **`MAINNET_DEPLOYMENT_GUIDE.md`** - Guide détaillé complet
2. **`SERVER_DEPLOYMENT_ANALYSIS.md`** - Analyse technique
3. **`.env.example`** - Variables d'environnement
4. **Scripts officiels**:
   - [Sugar Documentation](https://docs.metaplex.com/tools/sugar)
   - [Solana Documentation](https://docs.solana.com/)

---

## ✨ Résumé

Votre environnement est **presque prêt** pour le déploiement mainnet!

**✅ Complété**:
- Configuration du serveur
- Installation de Solana CLI
- Installation de Sugar CLI (en cours)
- Scripts de déploiement prêts
- Documentation complète créée

**⏳ En Attente**:
- Fin de l'installation de Sugar CLI (quelques minutes)
- Transfert de votre wallet sur le serveur
- Lancement du déploiement

**🎯 Prochaine Action**:

Attendez que Sugar soit installé, puis:

```bash
# 1. Vérifier l'installation
./verify-server-setup.sh

# 2. Transférer le wallet (si prêt)
scp ~/.config/solana/id.json mf:/root/.config/solana/

# 3. Lancer le déploiement!
./deploy-nft-mainnet.sh
```

---

## 🎉 Vous Êtes Prêt!

Une fois Sugar installé (vérifiez avec `./verify-server-setup.sh`), vous pourrez déployer votre collection **Oinkonomics** sur Solana Mainnet en quelques minutes!

**Bon déploiement! 🚀🐷**

---

**Questions?** Consultez `MAINNET_DEPLOYMENT_GUIDE.md` pour toutes les réponses!
