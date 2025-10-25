# Oinconomics End-to-End Guide

_This handbook accompanies the MVP presented by **Kamel Ben Rhouma (treizeb)** at the Cypherpunk Hackathon (Colosseum / Solana)._ It explains how to reproduce the entire pipeline—from local asset generation to guarded Candy Machine mints—on any workstation.

---

## 1. Architecture at a Glance

| Layer | Purpose | Tooling |
| --- | --- | --- |
| Art generation | Produce layered PNG assets + metadata | HashLips Art Engine (Node.js) |
| Configuration | Materialize Candy Machine + guard configs from `.env` | `npm run generate-configs` (custom script) |
| Deployment | Upload assets, deploy Candy Machine, configure Candy Guard | Sugar CLI + Solana CLI |
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

All secrets and deployment-specific values live in `.env` (never commit it). Start from the documented template:

```bash
cp .env.example .env
# or auto-fill from cache.json (post-deploy) → scripts/gen-env.sh .env
```

Key sections inside `.env`:

1. **Project paths** – `PROJECT_ROOT`, config output paths.
2. **Solana & Umi** – RPC endpoint, keypair JSON, Candy Machine cache.
3. **Candy Machine metadata** – collection name, symbol, royalty basis points, creators.
4. **Upload backend** – Pinata credentials or other storage providers.
5. **Candy Guard** – solPayment price and destination.
6. **Local overrides** – convenient toggles for dev/test sessions.

> The template documents every variable with English annotations so new operators know where to source values and which fields are optional.

### Environment Generation from `cache.json`

After deploying once with Sugar, use `scripts/gen-env.sh` to extract the correct `COLLECTION_UPDATE_AUTHORITY` (the `candyMachineCreator` PDA). The script:

1. Backs up any existing `.env`.
2. Reads `program.candyMachineCreator` from the given cache.
3. Writes a fresh `.env` with sane defaults and reminders of secrets to fill in.

---

## 5. Configuration Generation

With `.env` populated, run:

```bash
npm run generate-configs
```

This script emits three JSON files (paths configurable via `.env`):

- `config.json` – Standard Candy Machine configuration.
- `guard.config.json` – Candy Guard groups populated with the solPayment guard.
- `config.local.json` – Local override version for rapid testing.

Each invocation overwrites the files, ensuring they never drift from the source-of-truth environment variables.

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

A typical Devnet deployment flow:

```bash
# 1. Upload assets
dotenv -f .env -- sugar upload --cache cache.json

# 2. Deploy the Candy Machine (uses config.json)
dotenv -f .env -- sugar deploy --cache cache.json

# 3. Set up the Candy Guard
dotenv -f .env -- sugar guard set --cache cache.json --config guard.config.json

# 4. Verify collection link
dotenv -f .env -- sugar collection verify --cache cache.json
```

**Tips**
- Always run commands within an environment loader (e.g. `dotenv -f .env -- …`) to avoid mismatched paths.
- After each Sugar step, inspect `cache.json` into version control (never commit secrets) for reproducibility.
- Use Devnet airdrops (`solana airdrop 2`) to fund your wallet.

---

## 8. Guarded Mint with Umi

Ensure `.env` still references the latest cache + guard files, then execute:

```bash
node umi/mint-guard.mjs
```

The script performs the following:

1. Loads `.env` and resolves absolute paths (`PROJECT_ROOT`).
2. Confirms key files exist (`cache.json`, guard config, keypair).
3. Validates the on-chain collection update authority and auto-corrects if `cache.json` is stale.
4. Builds compute budget instructions using `COMPUTE_UNITS` and `PRIORITY_MICROLAMPORTS`.
5. Submits `mintV2` with the configured guard label and solPayment destination.

Output includes the signature (base58) and minted NFT public key. Use `umi/scripts/check-collection.mjs <mint>` to verify that the minted asset is attached to the expected collection authority.

---

## 9. Troubleshooting Checklist

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `Cannot find module` inside `umi/` | `npm install` missing in the `umi/` folder | Run `cd umi && npm install` |
| `IncorrectCollectionAuthority (0x177a)` | `COLLECTION_UPDATE_AUTHORITY` not the Candy Machine PDA | Rerun `scripts/gen-env.sh` or read `.program.candyMachineCreator` from cache |
| `AccountNotRentExempt` during Sugar deploy | Wallet under-funded | `solana airdrop 2` on Devnet or top-up on Mainnet |
| `Mint exceeded the limit` | `MAX_EDITION_SUPPLY` or guard restrictions triggered | Review `guard.config.json` and reset guard values |
| On-chain `solPayment` goes to wrong address | `SOL_PAYMENT_DESTINATION` mismatch | Regenerate configs and reset the Candy Guard |

---

## 10. Security & Production Notes

- `.env`, keypairs, and JWTs must stay out of Git. Add additional ignores in `.gitignore` if you create custom env files.
- Rotate Pinata JWTs and Solana keypairs after public demos.
- For Mainnet, upgrade RPC endpoints to a dedicated provider (GenesysGo, Helius, etc.) for reliability.
- Audit guard combinations before launch—this MVP currently enables only `solPayment`, but other guards (mintLimit, allowList) can be added through the same `.env` pattern.

---

## 11. Preparing the Hackathon Demo

1. **Clean slate** – `git pull`, `npm ci`, `cd umi && npm ci`, `npm test`.
2. **Storytelling** – Emphasize the documentation-first approach enabling teammates to reproduce the flow without tribal knowledge.
3. **Live mint** – Demonstrate a mint on Devnet and open the resulting signature in the Solana Explorer.
4. **Next steps** – Mention roadmap items: extend guard support, integrate analytics dashboards, wrap Umi script in a minimal UI.

---

## 12. Credits

- **Lead & Presenter** – Kamel Ben Rhouma (treizeb)
- **Mentoring & QA** – Oinconomics contributors
- **Base Engine** – HashLips Art Engine (MIT License)

---

Appendix: the previous French guide is preserved as [`docs/full-project-guide.fr.md`](full-project-guide.fr.md) for legacy reference.
