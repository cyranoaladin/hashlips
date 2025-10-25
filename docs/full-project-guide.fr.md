# Guide Complet Oinconomics NFT Project

Ce guide pas-à-pas décrit l’intégralité du workflow Oinconomics : installation de l’environnement, génération des assets HashLips, configuration Candy Machine + Candy Guard, scripts Umi, déploiement et opérations post-mint. L’objectif est qu’un nouveau membre puisse reproduire le projet sans assistance.

> Nouveauté : le projet pilote désormais **trois Candy Machines** (`poor`, `mid`, `rich`) qui pointent toutes vers **une seule collection programmable**. Un serveur signe chaque mint via le guard `thirdPartySigner` pour attribuer le bon palier tout en conservant un mint gratuit.

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
├── assets/                 # JSON metadata collection + collection.json (legacy)
├── assets_poor/            # Assets générés pour le palier "poor"
├── assets_mid/             # Assets générés pour le palier "mid"
├── assets_rich/            # Assets générés pour le palier "rich"
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
├── .env.poor /.env.mid /.env.rich   # Variables d’environnement par palier (non versionnées)
├── .env.example            # Modèle complet de variables
├── cache.poor.json         # État Candy Machine (palier poor)
├── cache.mid.json          # État Candy Machine (palier mid)
├── cache.rich.json         # État Candy Machine (palier rich)
├── config.poor.json        # Config Sugar générée pour le palier poor
├── config.mid.json         # Config Sugar générée pour le palier mid
├── config.rich.json        # Config Sugar générée pour le palier rich
├── guard.poor.json         # Config Candy Guard palier poor
├── guard.mid.json          # Config Candy Guard palier mid
├── guard.rich.json         # Config Candy Guard palier rich
├── config.local.json       # Variante locale (générée via script)
├── package.json            # Scripts HashLips + generate-configs
└── README.md               # A compléter selon besoins
```

---

## 3. Variables d’Environnement

Chaque palier dispose de son propre fichier `.env.<palier>` (jamais versionné). Dupliquez le modèle puis complétez les valeurs :

```bash
cp .env.example .env.poor
cp .env.example .env.mid
cp .env.example .env.rich
# ou générer automatiquement : scripts/gen-env.sh --cache cache.poor.json --guard guard.poor.json .env.poor
```

### 3.1 Sections clés

- **Chemins runtime** : `PROJECT_ROOT`, `CONFIG_JSON_PATH`, `GUARD_CONFIG_JSON_PATH`, `CONFIG_LOCAL_JSON_PATH` (pointez vers les fichiers du palier).
- **Solana + scripts Umi** : `RPC_URL`, `KEYPAIR_PATH`, `CACHE_PATH`, `GUARD_CONFIG_PATH`, `GUARD_LABEL`, `COLLECTION_UPDATE_AUTHORITY`, `COLLECTION_MINT`, `COMPUTE_UNITS`, `PRIORITY_MICROLAMPORTS`, `THIRD_PARTY_SIGNER_KEYPAIR_PATH`, `THIRD_PARTY_SIGNER_PUBKEY`.
- **Métadonnées** : `COLLECTION_NAME_PREFIX`, `COLLECTION_DESCRIPTION`, `COLLECTION_BASE_URI`, `COLLECTION_SIZE`, `COLLECTION_SYMBOL`, `COLLECTION_EXTERNAL_URL`, `COLLECTION_NETWORK`, etc.
- **Creators** : `CREATOR_ADDRESS`, `CREATOR_SHARE`, `COLLECTION_CREATORS_JSON` (JSON optionnel pour plusieurs créateurs).
- **Candy Machine** : `TOKEN_STANDARD` (désormais `pnft`), `IS_MUTABLE`, `IS_SEQUENTIAL`, `UPLOAD_METHOD`, `RULE_SET` (adresse du rule set "no-transfer"), `MAX_EDITION_SUPPLY`, `HIDDEN_SETTINGS`, etc.
- **Pinata** : `PINATA_JWT`, `PINATA_API_GATEWAY`, `PINATA_CONTENT_GATEWAY`, `PINATA_PARALLEL_LIMIT`.
- **Guards** : `SOL_PAYMENT_VALUE` (mettre `null` pour un mint gratuit), `SOL_PAYMENT_DESTINATION`, `THIRD_PARTY_SIGNER_PUBKEY`, plus variantes locales (`LOCAL_*`, dont `LOCAL_THIRD_PARTY_SIGNER_PUBKEY`).

> Chaque `KEYPAIR_PATH` (dans `.env.poor`, `.env.mid`, `.env.rich`) doit pointer vers un fichier JSON secret Solana ; utilisez `solana config get` pour le récupérer.

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

Les fichiers de configuration sont générés pour chaque palier via `.env.<palier>`.

```bash
ENV_PATH=.env.poor npm run generate-configs
ENV_PATH=.env.mid npm run generate-configs
ENV_PATH=.env.rich npm run generate-configs
```

Le script (`scripts/generate-configs.mjs`) s’appuie sur les variables suivantes :

- `TOKEN_STANDARD`, `COLLECTION_SIZE`, `COLLECTION_SYMBOL`, `COLLECTION_SELLER_FEE_BPS`, `IS_MUTABLE`, `UPLOAD_METHOD`, etc.
- Configuration Pinata (nécessite `PINATA_JWT`, `PINATA_API_GATEWAY`, `PINATA_CONTENT_GATEWAY`).
- Paramètres de guards : `SOL_PAYMENT_VALUE` / `SOL_PAYMENT_DESTINATION` (facultatifs), `THIRD_PARTY_SIGNER_PUBKEY`, plus variantes locales `LOCAL_*`.

Chaque exécution écrit `config.<palier>.json`, `guard.<palier>.json` et `config.local.json` selon les chemins définis dans l’environnement.

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
