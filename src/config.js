const fs = require("fs");
const path = require("path");
const dotenv = require("dotenv");

const basePath = process.cwd();
const defaultProjectRoot = process.env.PROJECT_ROOT ?? basePath;
const envCandidate = process.env.ENV_PATH ?? path.resolve(defaultProjectRoot, ".env");
if (fs.existsSync(envCandidate)) {
  dotenv.config({ path: envCandidate });
} else {
  dotenv.config();
}

const { NETWORK } = require(`${basePath}/constants/network.js`);

const required = (key) => {
  const value = process.env[key];
  if (value === undefined || value === null || value === "") {
    throw new Error(`Missing environment variable: ${key}`);
  }
  return value;
};

const optional = (key, fallback) => {
  const value = process.env[key];
  return value === undefined || value === null || value === "" ? fallback : value;
};

const parseInteger = (key) => {
  const raw = required(key);
  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed)) {
    throw new Error(`Environment variable ${key} must be an integer`);
  }
  return parsed;
};

const parseBoolean = (key) => {
  const raw = required(key).trim().toLowerCase();
  if (["true", "1", "yes"].includes(raw)) return true;
  if (["false", "0", "no"].includes(raw)) return false;
  throw new Error(`Environment variable ${key} must be a boolean (true/false)`);
};

const parseCreators = () => {
  const custom = optional("COLLECTION_CREATORS_JSON", null);
  if (custom) {
    try {
      const parsed = JSON.parse(custom);
      if (!Array.isArray(parsed)) {
        throw new Error("COLLECTION_CREATORS_JSON must be a JSON array");
      }
      return parsed;
    } catch (error) {
      throw new Error(`Invalid COLLECTION_CREATORS_JSON value: ${error.message}`);
    }
  }
  const address = required("CREATOR_ADDRESS");
  const share = Number.parseInt(optional("CREATOR_SHARE", "100"), 10);
  if (!Number.isFinite(share)) {
    throw new Error("CREATOR_SHARE must be an integer");
  }
  return [
    {
      address,
      share,
    },
  ];
};

const networkValue = required("COLLECTION_NETWORK").trim().toLowerCase();
if (!Object.values(NETWORK).includes(networkValue)) {
  throw new Error(`Unsupported COLLECTION_NETWORK value: ${networkValue}`);
}
const network = networkValue;

// --- MODIFIEZ CECI VIA .env POUR VOTRE COLLECTION ---
const namePrefix = required("COLLECTION_NAME_PREFIX");
const description = required("COLLECTION_DESCRIPTION");
const baseUri = required("COLLECTION_BASE_URI");
const collectionSize = parseInteger("COLLECTION_SIZE");

// --- METADONNÉES SOLANA ---
const solanaMetadata = {
  symbol: required("COLLECTION_SYMBOL"),
  seller_fee_basis_points: parseInteger("COLLECTION_SELLER_FEE_BPS"),
  external_url: required("COLLECTION_EXTERNAL_URL"),
  creators: parseCreators(),
};

// C'est ici que vous définissez vos calques.
// Assurez-vous que les noms correspondent EXACTEMENT à vos dossiers de calques.
const layerConfigurations = [
  {
    growEditionSizeTo: collectionSize, // Génère le nombre total défini ci-dessus
    layersOrder: [
      { name: "1.Background" },
      { name: "2.Skin" },
      { name: "3.Outfit" },
      { name: "4.Eyes" },
      { name: "5.Nose" },
      { name: "6.Ears" },
      { name: "7.Mouth" },
      { name: "8.Headtop" },
    ],
  },
];
// --- FIN DE LA CONFIGURATION PRINCIPALE ---


const shuffleLayerConfigurations = false;
const debugLogs = false;

const format = {
  width: 512,
  height: 512,
  smoothing: false,
};

const gif = {
  export: false,
  repeat: 0,
  quality: 100,
  delay: 500,
};

const text = {
  only: false,
  color: "#ffffff",
  size: 20,
  xGap: 40,
  yGap: 40,
  align: "left",
  baseline: "top",
  weight: "regular",
  family: "Courier",
  spacer: " ",
};

const pixelFormat = {
  ratio: 2 / 128,
};

const background = {
  generate: true,
  brightness: "80%",
  static: false,
  default: "#000000",
};

const extraMetadata = {};
const rarityDelimiter = "#";
const uniqueDnaTorrance = 10000;

const preview = {
  thumbPerRow: 5,
  thumbWidth: 50,
  imageRatio: format.height / format.width,
  imageName: "preview.png",
};

const preview_gif = {
  numberOfImages: 5,
  order: "ASC", // ASC, DESC, MIXED
  repeat: 0,
  quality: 100,
  delay: 500,
  imageName: "preview.gif",
};

module.exports = {
  format,
  baseUri,
  description,
  background,
  uniqueDnaTorrance,
  layerConfigurations,
  rarityDelimiter,
  preview,
  shuffleLayerConfigurations,
  debugLogs,
  extraMetadata,
  pixelFormat,
  text,
  namePrefix,
  network,
  solanaMetadata,
  gif,
  preview_gif,
};
