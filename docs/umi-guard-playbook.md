# Candy Machine & Umi Guard Playbook

This document explains how to reproduce the entire Oinconomics Candy Machine workflow for a brand-new collection. It covers asset generation, Candy Machine deployment, guard configuration, scripted mints, and maintenance. Share this guide with any teammate who will operate the pipeline.

---

## 1. Prerequisites

Before touching the project, make sure the workstation has:

- **Node.js 18+** (LTS recommended) and `npm` or `yarn`.
- **Solana CLI** configured for the target network. Example for Devnet:
  ```bash
  solana config set --url https://api.devnet.solana.com
  ```
- **Sugar CLI** (`cargo install sugar-cli`) for Candy Machine management.
- A funded **Solana keypair JSON** for the deployment wallet (Devnet: use airdrops, Mainnet: transfer SOL manually).

Clone the repository and install dependencies:

```bash
cd hashlips/umi
npm install
```

> If you upgrade dependencies later, rerun `npm install` in `umi/` to keep the lockfile in sync.

---

## 2. Environment Configuration

All secrets and environment-specific settings live in `.env`. Start from the template, then adjust the values for your workspace:

```bash
cd hashlips
cp .env.example .env
```

Key variables are grouped by section inside the file:

| Runtime Paths | Purpose |
| --- | --- |
| `PROJECT_ROOT` | (Optional) Explicit project root if you run commands from a different directory. |
| `ENV_PATH` | (Optional) Override path to `.env`. |
| `CONFIG_JSON_PATH`, `GUARD_CONFIG_JSON_PATH`, `CONFIG_LOCAL_JSON_PATH` | Output targets for the generated Sugar configuration files. |

| Solana Script Inputs | Purpose |
| --- | --- |
| `RPC_URL` | Solana endpoint used by scripts and Sugar (`https://api.mainnet-beta.solana.com`, `https://api.devnet.solana.com`, …). |
| `KEYPAIR_PATH` | Absolute or project-relative path to the payer keypair (JSON). |
| `CACHE_PATH` | Path to the Sugar cache produced during deploy. |
| `GUARD_CONFIG_PATH` | Guard configuration file path consumed by the mint script. |
| `GUARD_LABEL` | Candy Guard label to target (`default` or any custom group). |
| `COLLECTION_UPDATE_AUTHORITY` | Optional override when the on-chain authority differs from the cache. Leave blank to auto-detect. |
| `COMPUTE_UNITS`, `PRIORITY_MICROLAMPORTS` | Compute budget tuning for the mint script (set `PRIORITY_MICROLAMPORTS` to `0` to disable). |

| Collection Metadata | Purpose |
| --- | --- |
| `COLLECTION_NAME_PREFIX`, `COLLECTION_DESCRIPTION`, `COLLECTION_BASE_URI` | Core metadata for the art engine outputs. |
| `COLLECTION_SIZE` | Number of NFTs to generate. |
| `COLLECTION_SYMBOL` | Token symbol used by Sugar and on-chain metadata. |
| `COLLECTION_NETWORK` | Network identifier for HashLips (`sol`, `eth`, etc.). |
| `COLLECTION_EXTERNAL_URL` | External project link embedded in metadata. |
| `COLLECTION_SELLER_FEE_BPS` | Secondary sale royalties (basis points). |
| `CREATOR_ADDRESS`, `CREATOR_SHARE` | Default creator entry for metadata. |
| `COLLECTION_CREATORS_JSON` | Optional JSON array to define multiple creators. |

| Candy Machine Options | Purpose |
| --- | --- |
| `TOKEN_STANDARD` | `nft`, `programmableNft`, etc. |
| `IS_MUTABLE`, `IS_SEQUENTIAL` | Core Sugar flags for the mint account. |
| `UPLOAD_METHOD` | Deployment backend (`pinata`, `bundlr`, …). |
| `RULE_SET`, `MAX_EDITION_SUPPLY`, `HIDDEN_SETTINGS` | Advanced Candy Machine knobs (use `null` to disable). |
| `AWS_CONFIG`, `SDRIVE_API_KEY`, `NFT_STORAGE_AUTH_TOKEN`, `SHDW_STORAGE_ACCOUNT` | Provider-specific credentials (optional). |

| Pinata Configuration | Purpose |
| --- | --- |
| `PINATA_JWT` | JWT used for `pinata` upload method. |
| `PINATA_API_GATEWAY`, `PINATA_CONTENT_GATEWAY` | Pinata endpoints. |
| `PINATA_PARALLEL_LIMIT` | Optional concurrency limit. |

| Guard Settings | Purpose |
| --- | --- |
| `SOL_PAYMENT_VALUE` | SOL cost per mint in the active guard group. |
| `SOL_PAYMENT_DESTINATION` | Treasury wallet for guard payments. |

| Local Overrides | Purpose |
| --- | --- |
| `LOCAL_IS_MUTABLE`, `LOCAL_SOL_PAYMENT_VALUE`, `LOCAL_SOL_PAYMENT_DESTINATION` | Overrides for `config.local.json`. |
| `LOCAL_UPLOAD_METHOD`, `LOCAL_RULE_SET`, `LOCAL_MAX_EDITION_SUPPLY` | Optional Sugar overrides for local workflows. |
| `LOCAL_PINATA_JWT`, `LOCAL_PINATA_API_GATEWAY`, `LOCAL_PINATA_CONTENT_GATEWAY`, `LOCAL_PINATA_PARALLEL_LIMIT` | Pinata overrides for local testing. |

> **Never** commit `.env`. The root `.gitignore` already excludes it.

After editing `.env`, generate the Sugar configuration files directly from those variables:

```bash
npm install   # run once to pick up the dotenv dependency
npm run generate-configs
```

This command writes `config.json`, `guard.config.json`, and `config.local.json` to the paths specified in `.env`. Re-run it whenever configuration values change.

---

## 3. Asset Production (HashLips Art Engine)

1. **Prepare trait layers** inside `layers/`, one folder per trait (Background, Head, Eyes, …). Name assets following the `trait#rarity.png` convention.
2. **Configure generation** via `src/config.js`:
   - Update `layerConfigurations` (`growEditionSizeTo`, `layersOrder`).
   - Adjust `format`, `shuffleLayerConfigurations`, `extraMetadata`, etc.
3. **Generate the collection**:
   ```bash
   npm run build
   ```
   - Images land in `build/images/`.
   - JSON metadata goes to `build/json/` and `_metadata.json`.

### Adding or Modifying Assets

- Drop new PNGs into the relevant layer directory with the correct rarity suffix.
- Re-run `npm run build`. Clean `build/` beforehand if you need a fresh run.
- Update metadata fields (names, descriptions) in `src/config.js` as needed.

---

## 4. Uploading Assets & Deploying a New Candy Machine

1. **Authenticate** any third-party pinning (Pinata, nft.storage, …) referenced in `guard.config.json` or Sugar.
2. **Upload** using Sugar (example):
   ```bash
   sugar upload --config guard.config.json --cache cache.json
   ```
3. **Deploy the Candy Machine**:
   ```bash
   sugar deploy --config guard.config.json --cache cache.json
   ```
4. **Attach guards** (if not bundled during deploy):
   ```bash
   sugar guard add --config guard.config.json --cache cache.json
   ```
5. **Verify**:
   ```bash
   sugar show --cache cache.json
   ```
   Confirm `items available`, `items redeemed`, `collection mint`, and guard settings.

> `cache.json` and `guard.config.json` are referenced by their absolute paths in `.env`. Update those paths whenever you relocate or regenerate the files.

---

## 5. Guard Configuration Checklist

`sugar` uses `guard.config.json` for Candy Guard runtime rules. Common edits:

- `guards.default.solPayment.value` – SOL cost per mint.
- `guards.default.solPayment.destination` – Treasury wallet (update in `.env` + `guard.config.json`).
- Additional guard groups (for allowlists, token gates, etc.). Make sure the CLI label matches the `GUARD_LABEL` environment variable.

After any change, run:

```bash
sugar guard update --config guard.config.json --cache cache.json
```

---

## 6. Minting via Umi (`mint-guard.mjs`)

The script in `umi/mint-guard.mjs` mints against a guarded Candy Machine while handling the Candy Guard runtime arguments and compute budget.

### Running a Mint

```bash
cd hashlips/umi
node mint-guard.mjs
```

What the script does:

1. Loads `.env` (or the path provided through `ENV_PATH`).
2. Reads `cache.json` and `guard.config.json` using the paths in the environment.
3. Auto-detects the collection update authority on-chain; falls back to the override in `.env` when provided.
4. Builds `mintArgs` for the `solPayment` guard destination.
5. Prepends compute budget instructions (`COMPUTE_UNITS`, `PRIORITY_MICROLAMPORTS`).
6. Outputs the transaction signature (base58), minted NFT address, and collection authority used.

If the transaction fails, the script surfaces Candy Guard logs for easier debugging.

### Customising Behaviour

- **Different guard labels**: set `GUARD_LABEL` in `.env` to the desired group.
- **Higher priority fees**: raise `PRIORITY_MICROLAMPORTS` (e.g. `1000` for 0.000001 SOL per CU).
- **Alternate cache/guard files**: point `CACHE_PATH` / `GUARD_CONFIG_PATH` to new JSON files.
- **Collection authority override**: populate `COLLECTION_UPDATE_AUTHORITY` only when the on-chain value differs from Sugar’s cache (otherwise detection is automatic).

---

## 7. Operational Scripts

### Check the Collection Update Authority

```bash
cd hashlips/umi
node scripts/check-collection.mjs <mint-address>
```

This script uses the same `.env` loader and prints the update authority + collection metadata for any mint. Use it after migrations or manual authority transfers.

### Inspect Candy Machine State

```bash
cd hashlips
sugar show --cache cache.json | sed -n '/items redeemed/p'
```

Confirms how many mints were consumed versus total supply.

---

## 8. Refreshing the Collection for a New Drop

When you want to launch another collection:

1. **Clean the art engine outputs** (`rm -rf build/images build/json`).
2. **Swap in new layers** and regenerate metadata (`npm run build`).
3. **Upload** the new assets (Pinata, nft.storage, etc.).
4. **Deploy** a fresh Candy Machine (create a new `cache.json`).
5. **Update `.env`** with the new cache/guard paths, collection mint, and treasury destinations.
6. **Run `mint-guard.mjs`** on Devnet to smoke-test the end-to-end flow before pointing to Mainnet.

> Re-using an old Candy Machine is discouraged. Always deploy a new one to avoid state conflicts.

---

## 9. Changing Wallets or Destinations

- **Payer wallet**: update `KEYPAIR_PATH` in `.env` and ensure the new wallet is funded.
- **SOL payment treasury**: edit `guard.config.json` (`solPayment.destination`) and `.env` if you store alternate destinations there. Follow with `sugar guard update`.
- **Collection mint / authority**: update `cache.json` and re-run `mint-guard.mjs` once to verify—`check-collection.mjs` is a good sanity check.

Document every change in git (update `.env.example` if defaults change) and keep a copy of previous configs for auditability.

---

## 10. Recommended Validation Workflow

1. **Local dry run**: `node mint-guard.mjs` on Devnet with test data.
2. **On-chain check**: `sugar show` and `node scripts/check-collection.mjs` to confirm supply + authorities.
3. **Guard regression tests**: try minting without enough SOL, with an invalid label, etc., to ensure guards reject as expected.
4. **Mainnet release**: point `.env` to Mainnet RPC, update `KEYPAIR_PATH`, redeploy, and perform one final mint before opening to users.

---

## 11. Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Group not found` | Verify `GUARD_LABEL` matches a guard group in `guard.config.json`. Run `sugar guard show`. |
| `IncorrectCollectionAuthority` | Ensure the collection mint’s update authority matches the guard label configuration. Let `mint-guard.mjs` auto-detect, or set `COLLECTION_UPDATE_AUTHORITY`. |
| `Missing expected remaining account` | The guard runtime arguments were omitted. Confirm `guard.config.json` has `solPayment` under the active label and rerun the script. |
| `Program failed to complete (compute limit)` | Increase `COMPUTE_UNITS` and optionally `PRIORITY_MICROLAMPORTS`. |
| `.env` not applied | Confirm the file path in `.env`, or set `ENV_PATH`. The script warns if the file is missing. |

---

## 12. Version Control & Security Notes

- Never commit private keys. Keep `.env`, wallet files, and API tokens outside version control.
- Commit meaningful configuration changes (`guard.config.json`, `cache.json`, docs) and tag releases around deployments.
- Review dependencies regularly; run `npm audit` in `umi/` to track vulnerabilities.
- For production, restrict RPC access and consider dedicated infrastructure (QuickNode, Triton, etc.).

---

## 13. Quick Reference Commands

```bash
# Install dependencies
cd hashlips/umi && npm install

# Generate art assets
npm run build

# Upload & deploy
sugar upload --config guard.config.json --cache cache.json
sugar deploy --config guard.config.json --cache cache.json
sugar guard add --config guard.config.json --cache cache.json

# Update guards after edits
sugar guard update --config guard.config.json --cache cache.json

# Mint via guarded Candy Machine
node mint-guard.mjs

# Inspect a minted NFT
node scripts/check-collection.mjs <mint-address>

# Check Candy Machine supply
sugar show --cache cache.json | sed -n '/items redeemed/p'
```

Keep this playbook updated as the workflow evolves. When in doubt, document deviations so the next operator can reproduce your steps precisely.
