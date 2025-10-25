#!/usr/bin/env node
import { mintV2, mplCandyMachine } from '@metaplex-foundation/mpl-candy-machine';
import { fetchDigitalAsset, mplTokenMetadata } from '@metaplex-foundation/mpl-token-metadata';
import {
  createSignerFromKeypair,
  generateSigner,
  publicKey,
  signerIdentity,
  some,
} from '@metaplex-foundation/umi';
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import { ComputeBudgetProgram } from '@solana/web3.js';
import bs58 from 'bs58';
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

const PROJECT_ROOT = process.env.PROJECT_ROOT
  ? path.resolve(process.env.PROJECT_ROOT)
  : defaultProjectRoot;

function requireEnv(name) {
  const value = process.env[name];
  if (value === undefined || value === null || value === '') {
    fail(`Variable d'environnement manquante: ${name}`);
  }
  return value;
}

const resolvePath = (value) => (path.isAbsolute(value) ? value : path.resolve(PROJECT_ROOT, value));

const optionalEnv = (name) => {
  const value = process.env[name];
  return value === undefined || value === null || value === '' ? null : value;
};

const RPC_URL = requireEnv('RPC_URL');
const KEYPAIR_PATH = resolvePath(requireEnv('KEYPAIR_PATH'));
const CACHE_PATH = resolvePath(requireEnv('CACHE_PATH'));
const GUARD_CONFIG_PATH = resolvePath(requireEnv('GUARD_CONFIG_PATH'));
const GUARD_LABEL = requireEnv('GUARD_LABEL');
const THIRD_PARTY_SIGNER_KEYPAIR_PATH = optionalEnv('THIRD_PARTY_SIGNER_KEYPAIR_PATH');

function fail(msg) { console.error(msg); process.exit(1); }

function loadSigner(umi, file) {
  if (!fs.existsSync(file)) fail(`Keypair introuvable: ${file}`);
  let secret;
  try { secret = JSON.parse(fs.readFileSync(file, 'utf8')); }
  catch (e) { fail(`Lecture/JSON du keypair échouée: ${e.message}`); }
  try {
    const kp = umi.eddsa.createKeypairFromSecretKey(Uint8Array.from(secret));
    return createSignerFromKeypair(umi, kp);
  } catch (e) { fail(`Création du keypair Umi échouée: ${e.message}`); }
}

function readJson(file, label) {
  if (!fs.existsSync(file)) fail(`${label} introuvable: ${file}`);
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); }
  catch (e) { fail(`Lecture/JSON de ${label} échouée: ${e.message}`); }
}

function readOptionalJson(file) {
  if (!fs.existsSync(file)) return null;
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); }
  catch (e) { fail(`Lecture/JSON de ${file} échouée: ${e.message}`); }
}

function toUmiInstruction(ix) {
  return {
    instruction: {
      programId: publicKey(ix.programId.toBase58()),
      keys: ix.keys.map((key) => ({
        pubkey: publicKey(key.pubkey.toBase58()),
        isSigner: key.isSigner,
        isWritable: key.isWritable,
      })),
      data: new Uint8Array(ix.data),
    },
    signers: [],
    bytesCreatedOnChain: 0,
  };
}

async function main() {
  const umi = createUmi(RPC_URL).use(mplCandyMachine()).use(mplTokenMetadata());
  const payer = loadSigner(umi, KEYPAIR_PATH);
  umi.use(signerIdentity(payer));

  const cache = readJson(CACHE_PATH, 'cache.json');
  const guardConfig = readOptionalJson(GUARD_CONFIG_PATH) ?? {};
  const cmStr = cache?.program?.candyMachine;
  const cgStr = cache?.program?.candyGuard || '';
  const colStr = cache?.program?.collectionMint;
  const cmcStr = cache?.program?.candyMachineCreator;  // <- le PDA délégué par Sugar
  const guardLabel = GUARD_LABEL;

  if (!cmStr || !colStr || !cmcStr) {
    fail('cache.json incomplet: il faut program.candyMachine, program.collectionMint et program.candyMachineCreator');
  }

  const candyMachine = publicKey(cmStr);
  const candyGuard = cgStr ? publicKey(cgStr) : null;
  const collectionMint = publicKey(colStr);

  const envCollectionAuthority = optionalEnv('COLLECTION_UPDATE_AUTHORITY');
  let collectionUpdateAuthority = publicKey(envCollectionAuthority ?? cmcStr);
  try {
    const asset = await fetchDigitalAsset(umi, collectionMint);
    const onChainAuthority = asset.metadata.updateAuthority;
    if (onChainAuthority && onChainAuthority.toString() !== collectionUpdateAuthority.toString()) {
      console.warn(
        '⚠️ Update authority on-chain différent du cache. Utilisation de',
        onChainAuthority.toString(),
        'au lieu de',
        collectionUpdateAuthority.toString(),
      );
      collectionUpdateAuthority = onChainAuthority;
    }
  } catch (error) {
    console.warn('⚠️ Impossible de vérifier la collection:', error?.message ?? error);
  }

  const nftSigner = generateSigner(umi);

  const guardSources = [
    guardConfig?.guards?.[guardLabel],
    guardConfig?.guards?.default,
    cache?.guards?.[guardLabel],
    cache?.guards?.default,
  ].filter(Boolean);

  const mergedGuardSettings = guardSources.reduce((acc, guard) => {
    Object.entries(guard).forEach(([key, value]) => {
      acc[key] = value;
    });
    return acc;
  }, {});

  const guardMintArgs = {};
  const remainingAccountsNotes = [];

  if (mergedGuardSettings.solPayment) {
    const destination = mergedGuardSettings.solPayment.destination
      ? publicKey(mergedGuardSettings.solPayment.destination)
      : collectionUpdateAuthority;
    guardMintArgs.solPayment = some({
      destination,
    });
    remainingAccountsNotes.push(['solPayment', destination.toString()]);
  }

  let thirdPartySigner = null;
  if (mergedGuardSettings.thirdPartySigner) {
    if (!THIRD_PARTY_SIGNER_KEYPAIR_PATH) {
      fail(
        'Le guard thirdPartySigner est actif mais THIRD_PARTY_SIGNER_KEYPAIR_PATH est absent dans .env.',
      );
    }
    const signerPath = resolvePath(THIRD_PARTY_SIGNER_KEYPAIR_PATH);
    thirdPartySigner = loadSigner(umi, signerPath);
    guardMintArgs.thirdPartySigner = some({ signer: thirdPartySigner });
    remainingAccountsNotes.push(['thirdPartySigner', thirdPartySigner.publicKey.toString()]);
  }

  const params = {
    candyMachine,
    collectionMint,
    collectionUpdateAuthority,     // <- au lieu de payer.publicKey
    nftMint: nftSigner,            // signer qui créera le NFT
  };
  if (Object.keys(guardMintArgs).length > 0) {
    params.mintArgs = guardMintArgs;
  }
  if (candyGuard) params.candyGuard = candyGuard;

  console.log('Params envoyés :', {
    candyMachine: candyMachine.toString(),
    candyGuard: candyGuard?.toString?.() ?? null,
    collectionMint: collectionMint.toString(),
    collectionUpdateAuthority: collectionUpdateAuthority.toString(),
    guardArgs: remainingAccountsNotes.map(([guardName, value]) => ({ guard: guardName, value })),
    nftMint: nftSigner.publicKey.toString(),
  });

  try {
    const computeUnitsRaw = requireEnv('COMPUTE_UNITS');
    const priorityMicrolamportsRaw = requireEnv('PRIORITY_MICROLAMPORTS');
    const computeUnits = Number(computeUnitsRaw);
    const priorityMicrolamports = Number(priorityMicrolamportsRaw);
    if (!Number.isFinite(computeUnits) || computeUnits < 0) {
      fail(`COMPUTE_UNITS doit être un nombre positif ou nul. Reçu: ${computeUnitsRaw}`);
    }
    if (!Number.isFinite(priorityMicrolamports) || priorityMicrolamports < 0) {
      fail(
        `PRIORITY_MICROLAMPORTS doit être un nombre positif ou nul. Reçu: ${priorityMicrolamportsRaw}`,
      );
    }
    const extras = [];
    if (Number.isFinite(computeUnits) && computeUnits > 0) {
      extras.push(toUmiInstruction(ComputeBudgetProgram.setComputeUnitLimit({ units: computeUnits })));
    }
    if (Number.isFinite(priorityMicrolamports) && priorityMicrolamports > 0) {
      extras.push(
        toUmiInstruction(
          ComputeBudgetProgram.setComputeUnitPrice({ microLamports: priorityMicrolamports }),
        ),
      );
    }

    const builder = mintV2(umi, params);
    const fullBuilder = extras.length ? builder.prepend(extras) : builder;

    const { signature } = await fullBuilder.sendAndConfirm(umi);
    const signatureText = typeof signature === 'string' ? signature : bs58.encode(signature);
    console.log('✅ Mint réussi');
    console.log('Signature :', signatureText);
    console.log('NFT Mint :', nftSigner.publicKey.toString());
    console.log('Collection Update Authority utilisé :', collectionUpdateAuthority.toString());
  } catch (err) {
    console.error('✊ Mint échoué :', err?.message ?? err);
    console.error(err);
    if (typeof err?.getLogs === 'function') {
      try {
        const logs = await err.getLogs();
        if (Array.isArray(logs) && logs.length) console.error('\nProgram Logs:\n' + logs.join('\n'));
      } catch {}
    } else if (Array.isArray(err?.logs) && err.logs.length) {
      console.error('\nProgram Logs:\n' + err.logs.join('\n'));
    }
    process.exit(1);
  }
}

main();
