#!/usr/bin/env node
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repositoryRoot = path.resolve(__dirname, '..');

const defaultProjectRoot = process.env.PROJECT_ROOT ?? repositoryRoot;
const envPathCandidate = process.env.ENV_PATH ?? path.resolve(defaultProjectRoot, '.env');
if (fs.existsSync(envPathCandidate)) {
  dotenv.config({ path: envPathCandidate });
} else {
  dotenv.config();
  if (process.env.ENV_PATH) {
    console.warn(`⚠️ Fichier d'environnement introuvable: ${envPathCandidate}`);
  }
}

const PROJECT_ROOT = process.env.PROJECT_ROOT
  ? path.resolve(process.env.PROJECT_ROOT)
  : defaultProjectRoot;

const requireEnv = (name) => {
  const value = process.env[name];
  if (value === undefined || value === null || value === '') {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
};

const optionalEnv = (name, fallback = null) => {
  const value = process.env[name];
  if (value === undefined || value === null || value === '') {
    return fallback;
  }
  return value;
};

const getBoolean = (name, fallback = null) => {
  const rawValue = optionalEnv(name, fallback);
  if (rawValue === null) {
    throw new Error(`Missing boolean environment variable: ${name}`);
  }
  if (typeof rawValue === 'boolean') {
    return rawValue;
  }
  const normalised = rawValue.toString().trim().toLowerCase();
  if (['true', '1', 'yes'].includes(normalised)) return true;
  if (['false', '0', 'no'].includes(normalised)) return false;
  throw new Error(`Environment variable ${name} must be boolean (true/false)`);
};

const getNullable = (name, fallback = null, { json = false } = {}) => {
  const raw = optionalEnv(name, null);
  if (raw === null) return fallback;
  const trimmed = raw.trim();
  if (trimmed.toLowerCase() === 'null') return null;
  if (!json) return trimmed;
  try {
    return JSON.parse(trimmed);
  } catch (error) {
    throw new Error(`Invalid JSON provided in ${name}: ${error.message}`);
  }
};

const getNullableNumber = (name, fallback = null) => {
  const raw = optionalEnv(name, null);
  if (raw === null) return fallback;
  const trimmed = raw.trim().toLowerCase();
  if (trimmed === 'null') return null;
  const parsed = Number(raw);
  if (!Number.isFinite(parsed)) {
    throw new Error(`Environment variable ${name} must be numeric`);
  }
  return parsed;
};

const parseCreators = () => {
  const custom = optionalEnv('COLLECTION_CREATORS_JSON', null);
  if (custom) {
    try {
      const parsed = JSON.parse(custom);
      if (!Array.isArray(parsed)) {
        throw new Error('Value must be a JSON array');
      }
      return parsed;
    } catch (error) {
      throw new Error(`Invalid COLLECTION_CREATORS_JSON value: ${error.message}`);
    }
  }
  const address = requireEnv('CREATOR_ADDRESS');
  const shareRaw = optionalEnv('CREATOR_SHARE', '100');
  const share = Number.parseInt(shareRaw, 10);
  if (!Number.isFinite(share)) {
    throw new Error('CREATOR_SHARE must be an integer');
  }
  return [
    {
      address,
      share,
    },
  ];
};

const buildPinataConfig = (uploadMethod) => {
  if (!uploadMethod || uploadMethod.toLowerCase() !== 'pinata') {
    return null;
  }
  const jwt = optionalEnv('PINATA_JWT', null);
  const apiGateway = optionalEnv('PINATA_API_GATEWAY', null);
  const contentGateway = optionalEnv('PINATA_CONTENT_GATEWAY', null);
  const parallelLimitRaw = optionalEnv('PINATA_PARALLEL_LIMIT', null);

  if (!jwt || !apiGateway || !contentGateway) {
    throw new Error('Pinata upload selected but PINATA_JWT/API_GATEWAY/CONTENT_GATEWAY are missing');
  }

  const config = {
    jwt,
    apiGateway,
    contentGateway,
  };

  if (parallelLimitRaw !== null) {
    const parallelLimit = Number(parallelLimitRaw);
    if (!Number.isFinite(parallelLimit)) {
      throw new Error('PINATA_PARALLEL_LIMIT must be numeric');
    }
    config.parallelLimit = parallelLimit;
  }

  return config;
};

const buildLocalPinataConfig = (uploadMethod, fallbackConfig) => {
  if (!uploadMethod || uploadMethod.toLowerCase() !== 'pinata') {
    return null;
  }
  const jwt = optionalEnv('LOCAL_PINATA_JWT', fallbackConfig?.jwt ?? null);
  const apiGateway = optionalEnv('LOCAL_PINATA_API_GATEWAY', fallbackConfig?.apiGateway ?? null);
  const contentGateway = optionalEnv('LOCAL_PINATA_CONTENT_GATEWAY', fallbackConfig?.contentGateway ?? null);
  const parallelLimitRaw = optionalEnv('LOCAL_PINATA_PARALLEL_LIMIT', fallbackConfig?.parallelLimit ?? null);

  if (!jwt || !apiGateway || !contentGateway) {
    throw new Error('Local Pinata configuration is incomplete (LOCAL_PINATA_ variables)');
  }

  const config = {
    jwt,
    apiGateway,
    contentGateway,
  };

  if (parallelLimitRaw !== null) {
    const parsedLimit = Number(parallelLimitRaw);
    if (!Number.isFinite(parsedLimit)) {
      throw new Error('LOCAL_PINATA_PARALLEL_LIMIT must be numeric');
    }
    config.parallelLimit = parsedLimit;
  }

  return config;
};

const resolveOutputPath = (envKey, fallbackName) => {
  const raw = optionalEnv(envKey, path.join(PROJECT_ROOT, fallbackName));
  return path.isAbsolute(raw) ? raw : path.resolve(PROJECT_ROOT, raw);
};

const composeGuard = ({
  solValueKey,
  solDestinationKey,
  thirdPartyKey,
  fallback = {},
}) => {
  const guard = JSON.parse(JSON.stringify(fallback ?? {})) || {};

  const solValue = getNullableNumber(solValueKey, fallback?.solPayment?.value ?? null);
  if (solValue !== null) {
    const destination = optionalEnv(solDestinationKey, fallback?.solPayment?.destination ?? null);
    if (!destination) {
      throw new Error(`${solDestinationKey} must be provided when ${solValueKey} is set`);
    }
    guard.solPayment = {
      value: solValue,
      destination,
    };
  } else if (guard.solPayment) {
    delete guard.solPayment;
  }

  const thirdPartySigner = optionalEnv(thirdPartyKey, fallback?.thirdPartySigner?.signerKey ?? null);
  if (thirdPartySigner) {
    guard.thirdPartySigner = {
      signerKey: thirdPartySigner,
    };
  } else if (guard.thirdPartySigner) {
    delete guard.thirdPartySigner;
  }

  return guard;
};

try {
  const creators = parseCreators();
  const uploadMethod = requireEnv('UPLOAD_METHOD');
  const basePinataConfig = buildPinataConfig(uploadMethod);

  const configBase = {
    tokenStandard: requireEnv('TOKEN_STANDARD'),
    number: Number.parseInt(requireEnv('COLLECTION_SIZE'), 10),
    symbol: requireEnv('COLLECTION_SYMBOL'),
    sellerFeeBasisPoints: Number.parseInt(requireEnv('COLLECTION_SELLER_FEE_BPS'), 10),
    isMutable: getBoolean('IS_MUTABLE'),
    isSequential: getBoolean('IS_SEQUENTIAL', false),
    creators,
    uploadMethod,
    ruleSet: getNullable('RULE_SET'),
    awsConfig: getNullable('AWS_CONFIG', null, { json: true }),
    sdriveApiKey: getNullable('SDRIVE_API_KEY'),
    nftStorageAuthToken: getNullable('NFT_STORAGE_AUTH_TOKEN'),
    shdwStorageAccount: getNullable('SHDW_STORAGE_ACCOUNT'),
    pinataConfig: basePinataConfig,
    hiddenSettings: getNullable('HIDDEN_SETTINGS', null, { json: true }),
    guards: { default: {} },
    maxEditionSupply: getNullableNumber('MAX_EDITION_SUPPLY'),
  };

  const guardConfig = JSON.parse(JSON.stringify(configBase));
  const defaultGuard = composeGuard({
    solValueKey: 'SOL_PAYMENT_VALUE',
    solDestinationKey: 'SOL_PAYMENT_DESTINATION',
    thirdPartyKey: 'THIRD_PARTY_SIGNER_PUBKEY',
    fallback: {},
  });
  guardConfig.guards = { default: defaultGuard };

  const localUploadMethod = optionalEnv('LOCAL_UPLOAD_METHOD', configBase.uploadMethod);
  const localConfig = JSON.parse(JSON.stringify(configBase));
  localConfig.isMutable = getBoolean('LOCAL_IS_MUTABLE', configBase.isMutable);
  localConfig.uploadMethod = localUploadMethod;
  localConfig.ruleSet = getNullable('LOCAL_RULE_SET', configBase.ruleSet);
  localConfig.maxEditionSupply = getNullableNumber('LOCAL_MAX_EDITION_SUPPLY', configBase.maxEditionSupply);
  localConfig.pinataConfig = buildLocalPinataConfig(localUploadMethod, configBase.pinataConfig);

  const localGuard = composeGuard({
    solValueKey: 'LOCAL_SOL_PAYMENT_VALUE',
    solDestinationKey: 'LOCAL_SOL_PAYMENT_DESTINATION',
    thirdPartyKey: 'LOCAL_THIRD_PARTY_SIGNER_PUBKEY',
    fallback: defaultGuard,
  });
  localConfig.guards = { default: localGuard };

  const configPath = resolveOutputPath('CONFIG_JSON_PATH', 'config.json');
  const guardConfigPath = resolveOutputPath('GUARD_CONFIG_JSON_PATH', 'guard.config.json');
  const configLocalPath = resolveOutputPath('CONFIG_LOCAL_JSON_PATH', 'config.local.json');

  const outputs = [
    { label: 'config.json', path: configPath, data: configBase },
    { label: 'guard.config.json', path: guardConfigPath, data: guardConfig },
    { label: 'config.local.json', path: configLocalPath, data: localConfig },
  ];

  outputs.forEach(({ label, path: targetPath, data }) => {
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.writeFileSync(targetPath, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
    console.log(`✅ ${label} écrit → ${targetPath}`);
  });
} catch (error) {
  console.error('❌ Impossible de générer les fichiers de configuration:', error.message ?? error);
  process.exit(1);
}
