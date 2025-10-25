#!/usr/bin/env node
import { fetchDigitalAsset, mplTokenMetadata } from '@metaplex-foundation/mpl-token-metadata';
import { publicKey } from '@metaplex-foundation/umi';
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

const defaultProjectRoot = process.env.PROJECT_ROOT ?? path.resolve(process.cwd(), '..');
const envPathHint = process.env.ENV_PATH ?? path.resolve(defaultProjectRoot, '.env');
if (fs.existsSync(envPathHint)) {
  dotenv.config({ path: envPathHint });
} else {
  dotenv.config();
  if (process.env.ENV_PATH) {
    console.warn(`⚠️ Fichier d'environnement introuvable: ${envPathHint}`);
  }
}

function requireEnv(name) {
  const value = process.env[name];
  if (value === undefined || value === null || value === '') {
    throw new Error(`Variable d'environnement manquante: ${name}`);
  }
  return value;
}

const RPC_URL = requireEnv('RPC_URL');
const mintArg = process.argv[2];

if (!mintArg) {
  console.error('Usage: node scripts/check-collection.mjs <mintAddress>');
  process.exit(1);
}

async function main() {
  const umi = createUmi(RPC_URL).use(mplTokenMetadata());
  const mint = publicKey(mintArg);
  const asset = await fetchDigitalAsset(umi, mint);
  console.log('Mint:', mintArg);
  console.log('Update authority:', asset.metadata.updateAuthority.toString());
  console.log('Collection details:', asset.metadata.collection?.value ?? null);
}

main().catch((error) => {
  console.error(error?.message ?? error);
  process.exit(1);
});
