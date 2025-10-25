# Guide Complet Oinconomics NFT Project

Ce guide pas-à-pas décrit l’intégralité du workflow Oinconomics : installation de l’environnement, génération des assets HashLips, configuration Candy Machine + Candy Guard, scripts Umi, déploiement et opérations post-mint. L’objectif est qu’un nouveau membre puisse reproduire le projet sans assistance.

---

## 1. Prérequis & Installation

### 1.1 Logiciels système

- **Node.js 18 ou 20** (LTS) avec `npm`. (Node 22 fonctionne, mais nécessite `canvas` ≥ 2.11.2.)
- **Git** pour cloner le dépôt.
- **Rust & Cargo** (requis par `sugar`), installables via `rustup`.
- **Solana CLI** (1.18+) pour interagir avec la blockchain.
- **Sugar CLI** : `cargo install sugar-cli`.
- **Python 3** (pour compilation `canvas` si nécessaire).

### 1.2 Dépendances Node.js

Dans la racine du projet (`hashlips/`) :

```bash
npm install
```

Dans le sous-dossier Umi (`hashlips/umi/`) :

```bash
cd umi
npm install
```

> `npm install` installe notamment `canvas`, `dotenv`, et toutes les dépendances Umi/Candy Machine.

---

## 2. Structure du Projet

```
hashlips/
├── assets/                 # JSON metadata collection + collection.json
├── build/                  # Généré par HashLips (images + metadata)
├── constants/
│   └── network.js          # Définit les réseaux (sol, devnet, etc.)
├── docs/
│   ├── full-project-guide.md   # Guide actuel
│   └── umi-guard-playbook.md   # Documentation mint Umi + guards
├── layers/                 # Dossiers de calques (HashLips)
├── modules/                # Scripts HashLips (HashlipsGiffer.js)
├── scripts/
│   └── generate-configs.mjs    # Génère config.json/guard.config.json
├── src/
│   ├── config.js           # Configuration HashLips (pilotée par .env)
│   └── main.js             # Logiciel de génération HashLips
├── umi/
│   ├── mint-guard.mjs      # Script de mint Umi
│   ├── scripts/
│   │   └── check-collection.mjs
│   └── package.json        # Dépendances Umi
├── .env                    # Variables d’environnement (non versionné)
├── .env.example            # Modèle complet de variables
├── cache.json              # État Candy Machine (généré par Sugar)
├── config.json             # Config Sugar (générée via script)
├── guard.config.json       # Config guard Sugar (générée via script)
├── config.local.json       # Variante locale (générée via script)
├── package.json            # Scripts HashLips + generate-configs
└── README.md               # A compléter selon besoins
```

---

## 3. Variables d’Environnement

Toutes les valeurs personnalisées résident dans `.env` (copier depuis `.env.example`).

```bash
cp .env.example .env
```

### 3.1 Sections clés

- **Runtime paths** : `PROJECT_ROOT`, `CONFIG_JSON_PATH`, etc.
- **Solana + Umi scripts** : `RPC_URL`, `KEYPAIR_PATH`, `CACHE_PATH`, `GUARD_CONFIG_PATH`, `GUARD_LABEL`, `COLLECTION_UPDATE_AUTHORITY`, `COMPUTE_UNITS`, `PRIORITY_MICROLAMPORTS`.
- **Metadata** : `COLLECTION_NAME_PREFIX`, `COLLECTION_DESCRIPTION`, `COLLECTION_BASE_URI`, `COLLECTION_SIZE`, `COLLECTION_SYMBOL`, `COLLECTION_EXTERNAL_URL`, `COLLECTION_NETWORK`, etc.
- **Creators** : `CREATOR_ADDRESS`, `CREATOR_SHARE`, `COLLECTION_CREATORS_JSON` (JSON optionnel pour plusieurs créateurs).
- **Candy Machine** : `TOKEN_STANDARD`, `IS_MUTABLE`, `IS_SEQUENTIAL`, `UPLOAD_METHOD`, `RULE_SET`, `MAX_EDITION_SUPPLY`, `HIDDEN_SETTINGS`, etc.
- **Pinata** : `PINATA_JWT`, `PINATA_API_GATEWAY`, `PINATA_CONTENT_GATEWAY`, `PINATA_PARALLEL_LIMIT`.
- **Guards** : `SOL_PAYMENT_VALUE`, `SOL_PAYMENT_DESTINATION`, plus versions locales (`LOCAL_*`).

> Le champ `KEYPAIR_PATH` doit pointer vers un fichier JSON secret Solana ; utilisez `solana config get` pour le récupérer.

---

## 4. Génération des Assets (HashLips Art Engine)

### 4.1 Préparer les calques

- Organiser les dossiers `layers/1.Background/`, `layers/2.Skin/`, etc.
- Respecter la nomenclature HashLips `Nom#Rareté.png` ou `Nom.png`.

### 4.2 Configuration (src/config.js)

- Le fichier lit directement `.env`. Remplir les variables avant d’exécuter HashLips.
- `COLLECTION_NETWORK` doit correspondre à une entrée dans `constants/network.js` (`sol`, `eth`, `devnet`).

### 4.3 Génération des images

```bash
npm run build
```

- Produit `build/images/` et `build/json/`.

### 4.4 Vérifications

- Les fichiers JSON générés reprennent les informations `.env` (nom, symbole, créateurs, etc.).
- Ajuster `COLLECTION_BASE_URI` après upload IPFS (ex : Pinata).

---

## 5. Génération Automatique des Configs Sugar

Les fichiers `config.json`, `guard.config.json`, `config.local.json` sont générés depuis `.env`.

```bash
npm run generate-configs
```

Ce script (`scripts/generate-configs.mjs`) utilise les variables suivantes :

- `TOKEN_STANDARD`, `COLLECTION_SIZE`, `COLLECTION_SYMBOL`, `COLLECTION_SELLER_FEE_BPS`, `IS_MUTABLE`, `UPLOAD_METHOD`, etc.
- Configuration Pinata (nécessite `PINATA_JWT`, `PINATA_API_GATEWAY`, `PINATA_CONTENT_GATEWAY`).
- Paramètres Guards : `SOL_PAYMENT_VALUE` (prix mint), `SOL_PAYMENT_DESTINATION` (trésorerie), plus variantes locales `LOCAL_*`.

Il enregistre les fichiers au chemin indiqué par `CONFIG_JSON_PATH`, `GUARD_CONFIG_JSON_PATH`, `CONFIG_LOCAL_JSON_PATH` (défauts : racine du projet).

---

## 6. Upload & Déploiement Candy Machine (Sugar)

### 6.1 Préparer les assets

- Upload IPFS (Pinata) selon la méthode indiquée par `UPLOAD_METHOD`.
- Mettre à jour `COLLECTION_BASE_URI` si nécessaire.

### 6.2 Commandes Sugar (Devnet)

```bash
sugar upload --config guard.config.json --cache cache.json
sugar deploy --config guard.config.json --cache cache.json
sugar guard add --config guard.config.json --cache cache.json
```

- `cache.json` contient les adresses Candy Machine, Candy Guard, collection mint, etc.

### 6.3 Vérification

```bash
sugar show --cache cache.json
```

- Vérifier `items available`, `items redeemed`, `collection mint`, `guards`.

### 6.4 Mise à jour des guards

Pour changer le prix ou la destination :

1. Modifier `.env` (`SOL_PAYMENT_VALUE`, `SOL_PAYMENT_DESTINATION`).
2. Regénérer `guard.config.json` via `npm run generate-configs`.
3. Appliquer :
   ```bash
   sugar guard update --config guard.config.json --cache cache.json
   ```

---

## 7. Scripts Umi

### 7.1 `mint-guard.mjs`

- Charge `.env` (via `dotenv`).
- Vérifie `RPC_URL`, `KEYPAIR_PATH`, `CACHE_PATH`, `GUARD_CONFIG_PATH`, `GUARD_LABEL`, `COMPUTE_UNITS`, `PRIORITY_MICROLAMPORTS`.
- Résout les adresses Candy Machine + Guard depuis `cache.json`.
- Détecte l’update authority réel via `fetchDigitalAsset`. Permet override `COLLECTION_UPDATE_AUTHORITY` si besoin.
- Prépare les instructions compute budget selon `COMPUTE_UNITS` et `PRIORITY_MICROLAMPORTS`.
- Ajoute l’argument `solPayment` pour le guard (`SOL_PAYMENT_DESTINATION`).
- Envoie la transaction et affiche la signature.

**Exécution :**

```bash
cd umi
node mint-guard.mjs
```

> Nécessite un compte Solana financé (`KEYPAIR_PATH`).

### 7.2 `check-collection.mjs`

- Utilise `.env` et se connecte à `RPC_URL`.
- Commande :
  ```bash
  node scripts/check-collection.mjs <mint-address>
  ```
- Affiche l’update authority d’un NFT et la collection attachée.

---

## 8. Autorités & PDA

- `cache.json` contient `program.candyMachine`, `program.candyGuard`, `program.collectionMint`, `program.candyMachineCreator`.
- `mint-guard.mjs` récupère l’update authority on-chain et compare.
- Pour changer l’authority, utiliser `sugar collection set`. Ensuite mettre à jour `.env` si vous souhaitez forcer `COLLECTION_UPDATE_AUTHORITY`.

---

## 9. Processus complet (résumé)

1. **Cloner** le repo et installer dépendances (`npm install`, `cd umi && npm install`).
2. **Créer `.env`** à partir de `.env.example` et renseigner toutes les valeurs.
3. **Configurer** les calques HashLips (`layers/`), ajuster `.env` (nom, description, symbol, base URI).
4. **Générer** les assets (`npm run build`).
5. **Upload** des images/JSON (Pinata) → mettre à jour `COLLECTION_BASE_URI` si nécessaire.
6. **Générer** les fichiers Sugar (`npm run generate-configs`).
7. **Uploader & Déployer** via Sugar (`sugar upload / deploy / guard add`).
8. **Tester** avec `sugar show` + `node mint-guard.mjs` (Devnet).
9. **Ajuster guards** si besoin (`.env` → `npm run generate-configs` → `sugar guard update`).
10. **Minter** (Devnet/Mainnet) via `mint-guard.mjs`.
11. **Vérifier** la collection `node scripts/check-collection.mjs <mint>`, `sugar show`.

---

## 10. Conseils & Sécurité

- Ne jamais committer `.env`, wallets, ou tokens sensibles.
- Utiliser des RPC privés (QuickNode, Triton, Helius) en production ; renseigner `RPC_URL`.
- Sur Mainnet, ajuster `PRIORITY_MICROLAMPORTS` pour garantir les confirmations (ex : `1000` = 0.000001 SOL par CU).
- Faire un test complet sur Devnet avant la production.
- Conserver des sauvegardes de `cache.json` et `guard.config.json` pour audit.

---

## 11. Annexes

- **Scripts utiles**
  - `npm run generate` : alias `npm run build`.
  - `npm run rarity` : analyse des rarités.
  - `node scripts/generate-configs.mjs` : exécution directe si besoin.
- **Dossier `docs/`**
  - `umi-guard-playbook.md` : détails sur le mint Umi, la garde, et le dépannage.
  - `full-project-guide.md` : document actuel.

---

Avec ce guide, un nouveau membre peut installer l’environnement, générer la collection, configurer la Candy Machine/Guard, exécuter les scripts, déployer et gérer les opérations de mint. Gardez le `.env` synchronisé et régénérez toujours les fichiers config via `npm run generate-configs` dès qu’une variable change.
