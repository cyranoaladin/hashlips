# Oinconomics End-to-End Guide

_This handbook accompanies the MVP presented by **Kamel Ben Rhouma (treizeb)** at the Cypherpunk Hackathon (Colosseum / Solana)._ It explains how to reproduce the entire pipeline—from local asset generation to guarded Candy Machine mints—on any workstation.

---

## 1. Architecture at a Glance

| Layer | Purpose | Tooling |
| --- | --- | --- |
| Art generation | Produce layered PNG assets + metadata | HashLips Art Engine (Node.js) |
| Configuration | Materialize Candy Machine + guard configs from `.env` | `npm run generate-configs` (custom script) |
| Deployment | Upload assets, deploy Candy Machine, configure Candy Guard | Sugar CLI + Solana CLI |
| Tier routing | Map wallet balance to poor/mid/rich Candy Machines while keeping one collection | Server-side logic + `thirdPartySigner` guard |
| Guarded minting | Execute mints with compute budget + guard enforcement | Umi SDK (`umi/mint-guard.mjs`) |
| Documentation | Onboarding, troubleshooting, SOPs | `docs/*.md`, `.env.example` |

---

## 2. Workstation Prerequisites

Install the following packages before cloning the repository:

| Requirement | Version / Notes |
| --- | --- |
| Node.js | 18.x or 20.x LTS (Node 22 works with `canvas >= 2.11.2`) |
| npm | Ships with Node; ensure `npm -v` ≥ 9 |
| Git | For cloning and version control |
| Python 3 | Required to build native `canvas` bindings on Linux |
| Rust toolchain | Install via `rustup` (needed by Sugar CLI) |
| Solana CLI | 1.18+ recommended |
| Sugar CLI | `cargo install sugar-cli` |
| jq | Required by `scripts/gen-env.sh` |

> Mac users: install dependencies via Homebrew (`brew install node python rust solana-cli jq`). Linux users: use your distro package manager and `rustup`.

---

## 3. Repository Setup

```bash
# Clone and enter the project
git clone https://github.com/cyranoaladin/hashlips.git
cd hashlips

# Install HashLips root dependencies (canvas, dotenv, etc.)
npm install

# Install the isolated Umi workspace dependencies
cd umi
npm install
cd ..
```

> Forgetting the `umi/` installation is the #1 cause of "Cannot find module" errors when running the mint scripts.

### Directory Layout

```
hashlips/
├─ assets/             # Layer metadata samples
├─ build/              # Generated images + json (overwritten by npm run build)
├─ docs/               # Onboarding + playbooks
├─ layers/             # Artwork layers used by HashLips
├─ scripts/            # Automation helpers (config generation, smoke tests, env generator)
├─ umi/                # Dedicated Node project for Umi & Candy Machine operations
└─ ...
```

---

## 4. Environment Configuration

All secrets and deployment-specific values live in `.env` files (never commit them). For the tiered setup, clone the template per Candy Machine:

```bash
cp .env.example .env.poor
cp .env.example .env.mid
cp .env.example .env.rich
# or auto-fill from cache.json → scripts/gen-env.sh --cache cache.poor.json --guard guard.poor.json .env.poor
```

Key sections inside each `.env.<tier>`:

1. **Project paths** – `PROJECT_ROOT`, plus tier-specific `CONFIG_JSON_PATH`/`GUARD_CONFIG_JSON_PATH` outputs.
2. **Solana & Umi** – RPC endpoint, payer keypair, `CACHE_PATH`, optional overrides (`COLLECTION_MINT`, `COLLECTION_UPDATE_AUTHORITY`, `THIRD_PARTY_SIGNER_*`).
3. **Candy Machine metadata** – collection name, symbol, royalties, creators (shared across tiers).
4. **Upload backend** – Pinata credentials or other storage providers.
5. **Candy Guard** – optional `SOL_PAYMENT_*` plus the `thirdPartySigner` public key for server-side cosigning.
6. **Local overrides** – development toggles (including `LOCAL_THIRD_PARTY_SIGNER_PUBKEY`).

> The template documents every variable with English annotations so new operators know where to source values and which fields are optional or tier-specific.

### Environment Generation from `cache.json`

After deploying once with Sugar, use `scripts/gen-env.sh` to extract the correct `COLLECTION_UPDATE_AUTHORITY` and (optionally) pre-fill tier-specific paths. Examples:

```bash
scripts/gen-env.sh --cache cache.poor.json --guard guard.poor.json --label default .env.poor
scripts/gen-env.sh --cache cache.mid.json  --guard guard.mid.json  --label default .env.mid
scripts/gen-env.sh --cache cache.rich.json --guard guard.rich.json --label default .env.rich
```

The script:

1. Backs up the target `.env.<tier>` when it already exists.
2. Reads `program.candyMachineCreator` and `program.collectionMint` from the given cache.
3. Writes a fresh `.env.<tier>` with sane defaults, leaving placeholders for secrets and the `thirdPartySigner` keys.

---

## 5. Configuration Generation

With `.env` populated, run:

```bash
npm run generate-configs
```

This script emits three JSON files (paths configurable via `.env`):

- `config.json` – Standard Candy Machine configuration (shared metadata, pnft flag, rule set).
- `guard.config.json` – Candy Guard groups reflecting `SOL_PAYMENT_*` and/or `thirdPartySigner` settings.
- `config.local.json` – Local override version for rapid testing (inherits from the tier, can change guard keys).

Run the script once per tier by pointing `ENV_PATH` (or sourcing `.env.<tier>` beforehand):

```bash
ENV_PATH=.env.poor npm run generate-configs
ENV_PATH=.env.mid npm run generate-configs
ENV_PATH=.env.rich npm run generate-configs
```

Each invocation overwrites the outputs for that tier, ensuring they never drift from the source-of-truth environment variables.

---

## 6. Asset Generation (HashLips)

Create or update your art layers in `layers/`. When ready, generate the collection preview:

```bash
npm run build
```

The command wipes `build/`, recreates the directory tree, and produces both PNG images and JSON metadata.

Smoke test before demos:

```bash
npm test
```

This runs `scripts/smoke-test.js`, verifying that the root and Umi dependency trees are installed (`canvas`, `@metaplex-foundation/umi`, `dotenv`).

---

## 7. Candy Machine Deployment with Sugar

Perform the upload/deploy loop once for each tier. Example for the **poor** tier (repeat with `.env.mid`/`.env.rich` and the matching asset/cache/guard files):

```bash
# 1. Upload tier-specific assets (HashLips outputs staged in assets_poor/)
dotenv -f .env.poor -- sugar upload --config config.poor.json --cache cache.poor.json

# 2. Deploy the Candy Machine (tier config)
dotenv -f .env.poor -- sugar deploy --cache cache.poor.json --config config.poor.json

# 3. Attach the guard configuration
dotenv -f .env.poor -- sugar guard set --cache cache.poor.json --config guard.poor.json

# 4. Link the shared collection mint
dotenv -f .env.poor -- sugar collection set    --cache cache.poor.json --collection $COLLECTION_MINT
dotenv -f .env.poor -- sugar collection verify --cache cache.poor.json --collection $COLLECTION_MINT
```

Keep each `cache.<tier>.json` under version control (minus secrets) so operators can regenerate `.env.<tier>` later. The shared collection mint stays constant across tiers—only the Candy Machine, guard PDA, and asset inputs differ.

**Tips**
- Always run commands within an environment loader (e.g. `dotenv -f .env.poor -- …`) to avoid mismatched paths.
- Save the generated caches immediately (`cp cache.json cache.poor.json`) before moving to the next tier to avoid accidental overwrites.
- Use Devnet airdrops (`solana airdrop 2`) to fund your wallet.

---

## 8. Tier Routing & Backend Cosignature

The dApp/backend is responsible for steering wallets into the correct Candy Machine tier while enforcing free mints:

1. Read the connected wallet balance (and any other heuristics) to classify the user as poor, mid, or rich.
2. Select the corresponding Candy Machine and load its `.env.<tier>` configuration (`CACHE_PATH`, `GUARD_CONFIG_PATH`, `THIRD_PARTY_SIGNER_KEYPAIR_PATH`).
3. Build the `mintV2` transaction client-side via Umi, leaving the `thirdPartySigner` account unsigned.
4. Forward the serialized transaction to the backend; it validates eligibility again, signs with the `thirdPartySigner` key, and returns the partially signed payload.
5. The client submits the transaction; guards ensure the user cannot bypass the tier because the server signature is required.

Because all three Candy Machines verify against the same programmable collection, downstream tooling (marketplaces, explorers, analytics) still see a single collection—even though supply is segmented by tier.

## 9. Guarded Mint with Umi

Ensure the correct `.env.<tier>` is in scope, then execute:

```bash
ENV_PATH=.env.poor node umi/mint-guard.mjs    # example tier
```

The script performs the following:

1. Loads `.env` and resolves absolute paths (`PROJECT_ROOT`).
2. Confirms key files exist (`cache.json`, guard config, keypair).
3. Validates the on-chain collection update authority and auto-corrects if `cache.json` is stale.
4. Builds compute budget instructions using `COMPUTE_UNITS` and `PRIORITY_MICROLAMPORTS`.
5. Submits `mintV2` with the configured guard label, automatically wiring `solPayment` and/or `thirdPartySigner` arguments based on the tier config.

Output includes the signature (base58) and minted NFT public key. Use `umi/scripts/check-collection.mjs <mint>` to verify that the minted asset is attached to the expected collection authority.

---

## 10. Troubleshooting Checklist

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `Cannot find module` inside `umi/` | `npm install` missing in the `umi/` folder | Run `cd umi && npm install` |
| `IncorrectCollectionAuthority (0x177a)` | `COLLECTION_UPDATE_AUTHORITY` not the Candy Machine PDA | Rerun `scripts/gen-env.sh` or read `.program.candyMachineCreator` from cache |
| `AccountNotRentExempt` during Sugar deploy | Wallet under-funded | `solana airdrop 2` on Devnet or top-up on Mainnet |
| `Mint exceeded the limit` | `MAX_EDITION_SUPPLY` or guard restrictions triggered | Review `guard.config.json` and reset guard values |
| On-chain `solPayment` goes to wrong address | `SOL_PAYMENT_DESTINATION` mismatch | Regenerate configs and reset the Candy Guard |
| `Missing expected remaining account: thirdPartySigner` | `.env.<tier>` lacks the signer path or Candy Guard pubkey | Populate `THIRD_PARTY_SIGNER_KEYPAIR_PATH` / `THIRD_PARTY_SIGNER_PUBKEY` and rerun the mint |

---

## 11. Security & Production Notes

- `.env`, keypairs, and JWTs must stay out of Git. Add additional ignores in `.gitignore` if you create custom env files.
- Rotate Pinata JWTs, Solana keypairs, and the dedicated `thirdPartySigner` key after public demos.
- For Mainnet, upgrade RPC endpoints to a dedicated provider (GenesysGo, Helius, etc.) for reliability.
- Keep the programmable NFT rule set under review—revoke or update the `no-transfer` rule if policy changes.
- Audit guard combinations before launch; the current baseline uses `thirdPartySigner` plus optional `solPayment`, but other guards (mintLimit, allowList) can be layered via the same `.env` pattern.

---

## 12. Preparing the Hackathon Demo

1. **Clean slate** – `git pull`, `npm ci`, `cd umi && npm ci`, `npm test`.
2. **Storytelling** – Emphasize the documentation-first approach enabling teammates to reproduce the flow without tribal knowledge.
3. **Tier showcase** – Walk through how the backend selects `.env.poor` vs `.env.mid` vs `.env.rich`, then demonstrate a live mint on Devnet and open the signature in the Solana Explorer.
4. **Next steps** – Mention roadmap items: extend guard support, integrate analytics dashboards, wrap Umi script in a minimal UI.

---

## 13. Credits

- **Lead & Presenter** – Kamel Ben Rhouma (treizeb)
- **Mentoring & QA** – Oinconomics contributors
- **Base Engine** – HashLips Art Engine (MIT License)

---

Appendix: the previous French guide is preserved as [`docs/full-project-guide.fr.md`](full-project-guide.fr.md) for legacy reference.
