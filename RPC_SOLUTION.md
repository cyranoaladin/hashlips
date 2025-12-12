# 🚨 Solution au Rate Limiting RPC

## Problème Actuel
Le RPC public Solana (`https://api.mainnet-beta.solana.com`) bloque vos requêtes avec l'erreur 429 (Too Many Requests).

**État actuel du déploiement:**
- ✅ Candy Machine créée: `V1uPFruGcjeFZ9hh23dnJ8tNnNemhUfgkFZmAmwaBDV`
- ✅ Collection NFT créée: `EpBdTNEBChZV3D1diKALwxiQirgXSGFu6Z6f85B1w53Y`
- ✅ 3001 assets uploadés sur Pinata
- ⚠️ **9 config lines restantes** à déployer (sur 215 au total)

## 🎯 Solutions (par ordre de préférence)

### Option 1: Helius (RECOMMANDÉ - Free Tier Disponible)

**Avantages:**
- 100,000 requêtes/jour gratuites
- Très rapide et fiable
- Pas de carte bancaire nécessaire

**Configuration:**

1. **Créer un compte:** https://www.helius.dev/
2. **Créer une API Key** depuis le dashboard
3. **Mettre à jour config.json:**

```bash
# Éditer votre config.json
nano /home/b13/Desktop/hashlips/config.json
```

Remplacer la ligne `rpcUrl`:
```json
"rpcUrl": "https://mainnet.helius-rpc.com/?api-key=VOTRE_CLE_API_ICI"
```

4. **Relancer le déploiement:**
```bash
cd /home/b13/Desktop/hashlips
sugar deploy
```

---

### Option 2: QuickNode (Premium, 1er mois gratuit)

**Configuration:**

1. **Créer un compte:** https://www.quicknode.com/
2. **Créer un endpoint Solana Mainnet**
3. **Copier l'URL HTTPS**
4. **Mettre à jour config.json:**

```json
"rpcUrl": "https://votre-endpoint.solana-mainnet.quiknode.pro/VOTRE_CLE/"
```

---

### Option 3: Alchemy (Alternative)

**Configuration:**

1. **Créer un compte:** https://www.alchemy.com/
2. **Créer une app Solana Mainnet**
3. **Obtenir l'URL HTTPS**
4. **Mettre à jour config.json:**

```json
"rpcUrl": "https://solana-mainnet.g.alchemy.com/v2/VOTRE_CLE_API"
```

---

### Option 4: Attendre et Réessayer (Non recommandé)

Si vous ne souhaitez pas créer de compte RPC, vous pouvez:

```bash
# Attendre 5 minutes entre chaque tentative
sleep 300 && sugar deploy
```

**⚠️ Inconvénients:**
- Très lent (peut prendre des heures)
- Risque d'échouer à nouveau
- Pas de garantie de succès

---

## 📝 Commandes Rapides

### Vérifier l'état actuel:
```bash
cd /home/b13/Desktop/hashlips
sugar show V1uPFruGcjeFZ9hh23dnJ8tNnNemhUfgkFZmAmwaBDV
```

### Après avoir changé le RPC:
```bash
cd /home/b13/Desktop/hashlips
sugar deploy
```

### Finaliser après déploiement complet:
```bash
sugar verify
```

---

## 🎯 RECOMMANDATION FINALE

**Utilisez Helius (Option 1)**
- Gratuit
- Configuration en 5 minutes
- Permet de finir les 9 transactions restantes immédiatement

Vos données sont **SÉCURISÉES** - la candy machine et tous vos uploads existent déjà sur la blockchain et Pinata. Vous devez juste finir ces 9 dernières transactions de configuration.

---

## 📊 Résumé de votre Projet

| Élément | Statut | Détails |
|---------|--------|---------|
| Candy Machine | ✅ Créée | V1uPFruGcjeFZ9hh23dnJ8tNnNemhUfgkFZmAmwaBDV |
| Collection NFT | ✅ Créée | EpBdTNEBChZV3D1diKALwxiQirgXSGFu6Z6f85B1w53Y |
| Images | ✅ Uploadées | 3001 sur Pinata |
| Metadata | ✅ Uploadés | 3001 sur Pinata |
| Config Lines | ⚠️ 93% | 206/215 déployées, **9 restantes** |

**Vous êtes à 93% du déploiement complet !**
