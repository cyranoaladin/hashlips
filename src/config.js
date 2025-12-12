const basePath = process.cwd();
const { MODE } = require(`${basePath}/constants/blend_mode.js`);
const { NETWORK } = require(`${basePath}/constants/network.js`);

const network = NETWORK.sol;

// General metadata for Ethereum
const namePrefix = "Oinkonomics";
const description = "Oinkonomics is a collection of 3000 unique NFTs on Solana, divided into three tiers: Poor (0-999), Mid (1000-1999), and Rich (2000-2999). Your wallet balance determines your tier!";
const baseUri = "ipfs://NewUriToReplace";

const solanaMetadata = {
    symbol: "OINK",
    seller_fee_basis_points: 500, // 5%
    external_url: "https://oinkonomics.fun",
    creators: [
        {
            address: "2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd", // Treasury Wallet
            share: 100,
        },
    ],
};

// If you have selected Solana then the collection starts from 0 automatically
const parsePositiveInt = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) && parsed > 0 ? Math.floor(parsed) : null;
};

const testTierEditionSize = parsePositiveInt(process.env.TEST_TIER_SIZE);

const buildLayer = (tier, dirName, displayName) => (
    {
        name: `${tier}/${dirName}`,
        options: {
            displayName:
                displayName ?? dirName.replace(/^[0-9]+\./, ""),
        },
    }
);

const buildTierConfiguration = (tier, startEdition, editionSize, layersOrder) => {
    const actualSize = testTierEditionSize !== null ? Math.min(testTierEditionSize, editionSize) : editionSize;
    return {
        tier,
        startEdition,
        growEditionSizeTo: startEdition + actualSize,
        layersOrder,
    };
};

const POOR_LAYERS = [
    buildLayer("POOR", "1.Background", "Background"),
    buildLayer("POOR", "2.Skins", "Skin"),
    buildLayer("POOR", "3.Outfit", "Outfit"),
    buildLayer("POOR", "5.Eyes", "Eyes"),
    buildLayer("POOR", "4.Mouth", "Mouth"),
    buildLayer("POOR", "6.Headtop", "Headtop"),
];

const MID_LAYERS = [
    buildLayer("MID", "1.Background", "Background"),
    buildLayer("MID", "2.Skin", "Skin"),
    buildLayer("MID", "3.Outfit", "Outfit"),
    buildLayer("MID", "4.Eyes", "Eyes"),
    buildLayer("MID", "5.Nose", "Nose"),
    buildLayer("MID", "6.Ears", "Ears"),
    buildLayer("MID", "7.Mouth", "Mouth"),
    buildLayer("MID", "8.Headtop", "Headtop"),
];

const RICH_LAYERS = [
    buildLayer("RICH", "1.Background", "Background"),
    buildLayer("RICH", "2.Skins", "Skin"),
    buildLayer("RICH", "3.Outfit", "Outfit"),
    buildLayer("RICH", "5.Eyes", "Eyes"),
    buildLayer("RICH", "6.Nose", "Nose"),
    buildLayer("RICH", "7.Ears", "Ears"),
    buildLayer("RICH", "4.Mouth", "Mouth"),
    buildLayer("RICH", "8.Headtop", "Headtop"),
];

const layerConfigurations = [
    buildTierConfiguration("POOR", 0, 1000, POOR_LAYERS),
    buildTierConfiguration("MID", 1000, 1000, MID_LAYERS),
    buildTierConfiguration("RICH", 2000, 1000, RICH_LAYERS),
];

const shuffleLayerConfigurations = false; // Must be false to keep tier order

const debugLogs = false;

const format = {
    width: 1000,
    height: 1000,
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
    spacer: " => ",
};

const pixelFormat = {
    ratio: 2 / 128,
};

const background = {
    generate: true,
    brightness: "100%",
    static: false,
    default: "#000000",
};

const extraMetadata = {};

const rarityDelimiter = "#";

const uniqueDnaTorrance = 10000; // Raised to support the 900 edition target

const preview = {
    thumbNail: true,
    thumbNailImageOptions: {
        width: 250,
        height: 250,
    },
    imageName: "preview.png",
    imageFamily: "preview.png",
};

const preview_gif = {
    numberOfImages: 5,
    order: "ASC",
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
