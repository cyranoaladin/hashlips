const basePath = process.cwd();
const { NETWORK } = require(`${basePath}/constants/network.js`);

// IMPORTANT: Ceci est configuré pour le format Solana.
// Le déploiement se fera sur TESTNET (géré par Sugar, pas par ce fichier).
const network = NETWORK.sol; 

// --- MODIFIEZ CECI POUR VOTRE COLLECTION ---
const namePrefix = "Nom de votre NFT"; // Ex: "Singe Bizarre"
const description = "Description de votre collection";
const baseUri = "ipfs://NewUriToReplace"; // On laissera ça comme ça pour l'instant

// Nombre total de NFT à générer. Mettons 10 pour ce test.
const collectionSize = 10; 

// --- METADONNÉES SOLANA (TRÈS IMPORTANT) ---
const solanaMetadata = {
  symbol: "OINCO", // Mettez un symbole court (ex: "SBC")
  // C'est le pourcentage de royalties. 1000 = 10%
  seller_fee_basis_points: 1000, 
  external_url: "https://www.votre-site.com", // Mettez votre site si vous en avez un
  creators: [
    {
      // C'EST VOTRE ADRESSE DE PORTEFEUILLE TESTNET
      address: "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z", 
      share: 100, // Part des royalties (100% pour vous)
    },
  ],
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
