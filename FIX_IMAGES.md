# 🔧 Correction du problème d'affichage des images NFT

## Problème identifié

Les images des NFTs ne s'affichent pas car :
1. Les fichiers JSON dans `assets/` ont des URIs locales (`0.png`) au lieu d'URLs complètes
2. Les assets n'ont pas été uploadés (tous les `image_link` sont vides dans `cache.json`)
3. La Candy Machine n'est pas déployée

## Solution

### Étape 1: Vérifier que les assets sont prêts

```bash
# Vérifier que vous avez 3000 images et 3000 fichiers JSON
ls -la assets/*.png | wc -l  # Doit afficher 3001 (avec collection.png)
ls -la assets/*.json | wc -l  # Doit afficher 3001 (avec collection.json)
```

### Étape 2: Corriger les métadonnées (déjà fait)

```bash
node fix-assets-metadata.js
```

### Étape 3: Uploader les assets

```bash
# Vérifier la configuration
sugar validate

# Uploader les assets (coûte ~3-6 SOL pour 3000 NFTs)
sugar upload
```

⚠️ **IMPORTANT**: Après l'upload, Sugar CLI met à jour le `cache.json` avec les URLs complètes dans `image_link` et `metadata_link`, mais il **NE MET PAS** automatiquement à jour les fichiers JSON dans `assets/`.

### Étape 4: Mettre à jour les fichiers JSON avec les URLs

```bash
# Mettre à jour les fichiers JSON dans assets/ avec les URLs du cache.json
node update-assets-uris.js
```

Ce script va :
- Lire les URLs du `cache.json`
- Mettre à jour tous les fichiers JSON dans `assets/` avec les bonnes URLs d'image
- Mettre à jour `properties.files[0].uri` avec les bonnes URLs

### Étape 5: Déployer la Candy Machine

```bash
# Déployer la Candy Machine
sugar deploy

# Vérifier le déploiement
sugar verify
```

### Étape 6: Vérifier que les images s'affichent

Après le déploiement, les métadonnées on-chain contiendront les bonnes URLs et les images devraient s'afficher correctement.

## Scripts disponibles

- `fix-assets-metadata.js` : Corrige les métadonnées (doublons Tier, seller_fee_basis_points, etc.)
- `update-assets-uris.js` : Met à jour les URIs d'image dans les fichiers JSON après l'upload

## Notes importantes

1. **Pour les pNFTs**, Sugar CLI ne met pas automatiquement à jour les fichiers JSON dans `assets/` après l'upload
2. Il faut utiliser `update-assets-uris.js` après chaque `sugar upload` pour mettre à jour les fichiers JSON
3. Les métadonnées on-chain sont mises à jour automatiquement par Sugar CLI lors du déploiement
4. Si vous modifiez les métadonnées après le déploiement, utilisez `sugar update` (nécessite `isMutable: true`)

## Vérification

Pour vérifier que tout fonctionne :

```bash
# Vérifier qu'un fichier JSON a une URL complète
cat assets/0.json | grep image

# Devrait afficher quelque chose comme :
# "image": "https://gateway.pinata.cloud/ipfs/Qm..."
# ou
# "image": "https://arweave.net/..."
```

Si vous voyez encore `"image": "0.png"`, alors :
1. Les assets n'ont pas été uploadés → Exécutez `sugar upload`
2. Les fichiers JSON n'ont pas été mis à jour → Exécutez `node update-assets-uris.js`
