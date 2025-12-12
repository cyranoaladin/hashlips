# 🔄 Mettre à jour une collection NFT déjà déployée

## ✅ Prérequis

1. **`isMutable: true`** dans la configuration (déjà configuré ✅)
2. La Candy Machine doit être déployée
3. Les assets doivent être uploadés (ou être prêts à être uploadés)

## 📋 Processus de mise à jour

### Option 1: Mettre à jour les métadonnées on-chain (si assets déjà uploadés)

Si les assets sont déjà uploadés et que vous voulez juste corriger les métadonnées:

```bash
# 1. Mettre à jour les fichiers JSON dans assets/ avec les URLs du cache
node update-assets-uris.js

# 2. Mettre à jour les métadonnées on-chain
sugar update
```

### Option 2: Uploader les assets puis mettre à jour

Si les assets n'ont pas été uploadés:

```bash
# 1. Corriger les métadonnées locales
node fix-assets-metadata.js

# 2. Uploader les assets (coûte ~3-6 SOL pour 3000 NFTs)
sugar upload

# 3. Mettre à jour les fichiers JSON avec les URLs
node update-assets-uris.js

# 4. Mettre à jour les métadonnées on-chain
sugar update
```

### Option 3: Si la collection est sur le serveur

Si la collection est déployée sur un serveur distant:

```bash
# 1. Se connecter au serveur
ssh mf  # ou votre serveur

# 2. Aller dans le répertoire
cd /root/hashlips  # ou votre chemin

# 3. Mettre à jour les métadonnées
sugar update
```

## 🔍 Vérifier l'état actuel

### Vérifier si la Candy Machine est déployée

```bash
# Local
sugar show

# Sur le serveur
ssh mf "cd /root/hashlips && sugar show"
```

### Vérifier si les assets sont uploadés

```bash
# Vérifier le cache.json
grep "image_link" cache.json | grep -v '""' | head -5

# Si vous voyez des URLs (ipfs://, https://, etc.), les assets sont uploadés
# Si vous voyez seulement "", les assets ne sont pas uploadés
```

### Vérifier les métadonnées d'un NFT

```bash
# Vérifier un fichier JSON local
cat assets/0.json | grep image

# Devrait afficher:
# "image": "https://gateway.pinata.cloud/ipfs/..." (si uploadé)
# ou
# "image": "0.png" (si pas encore uploadé)
```

## ⚠️ Important

1. **`sugar update`** met à jour **TOUS** les NFTs de la collection
2. Cela peut prendre du temps pour 3000 NFTs
3. Cela coûte des frais de transaction (petits, mais multipliés par le nombre de NFTs)
4. Nécessite `isMutable: true` dans la configuration

## 🛠️ Scripts disponibles

- `fix-assets-metadata.js` : Corrige les métadonnées locales (doublons, seller_fee, etc.)
- `update-assets-uris.js` : Met à jour les URIs d'image dans les fichiers JSON après l'upload
- `update-deployed-collection.js` : Script complet pour mettre à jour une collection déployée

## 📝 Exemple complet

```bash
# 1. Corriger les métadonnées locales
node fix-assets-metadata.js

# 2. Si les assets ne sont pas uploadés, les uploader
sugar upload

# 3. Mettre à jour les fichiers JSON avec les URLs
node update-assets-uris.js

# 4. Vérifier que tout est correct
sugar validate

# 5. Mettre à jour les métadonnées on-chain
sugar update

# 6. Vérifier le résultat
sugar verify
```

## ❓ Problèmes courants

### "Candy Machine not found"
- La Candy Machine n'est pas déployée
- Le cache.json n'a pas l'adresse de la Candy Machine
- Solution: Déployer avec `sugar deploy` ou mettre à jour le cache.json

### "isMutable is false"
- La collection n'est pas mutable
- Solution: Impossible de mettre à jour (sauf si vous avez l'autorité pour changer isMutable)

### "Assets not uploaded"
- Les assets n'ont pas été uploadés
- Solution: Exécuter `sugar upload` d'abord

### "Insufficient funds"
- Pas assez de SOL pour les transactions
- Solution: Ajouter plus de SOL au wallet
