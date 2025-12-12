const basePath = process.cwd();
const { NETWORK } = require(`${basePath}/constants/network.js`);
const fs = require("fs");
const sha1 = require("sha1");
const { createCanvas, loadImage } = require("canvas");
const buildDir = `${basePath}/build`;
const layersDir = `${basePath}/layers`;

// Load performance configuration
const performanceConfig = (() => {
    try {
        return require(`${basePath}/performance.config.js`);
    } catch (e) {
        // Default values if config file doesn't exist
        return {
            BATCH_SIZE: 50,
            BATCH_DELAY: 2000,
            SAVE_METADATA_INTERVAL: 100,
            FORCE_GC: true,
            SHOW_MEMORY_STATS: true
        };
    }
})();
const {
    format,
    baseUri,
    description,
    background,
    uniqueDnaTorrance,
    layerConfigurations,
    rarityDelimiter,
    shuffleLayerConfigurations,
    debugLogs,
    extraMetadata,
    text,
    namePrefix,
    network,
    solanaMetadata,
    gif,
} = require(`${basePath}/src/config.js`);
const canvas = createCanvas(format.width, format.height);
const ctx = canvas.getContext("2d");
ctx.imageSmoothingEnabled = format.smoothing;
const APPEND_MODE = String(process.env.APPEND_MODE || "").toLowerCase() === "true";
const tierFilterRaw = process.env.TIER || process.env.TIERS || "";
const requestedTiers = tierFilterRaw
    .split(",")
    .map((tier) => tier.trim().toUpperCase())
    .filter(Boolean);

const activeLayerConfigurations =
    requestedTiers.length > 0
        ? layerConfigurations.filter((cfg) => requestedTiers.includes(cfg.tier.toUpperCase()))
        : layerConfigurations;

if (requestedTiers.length > 0 && activeLayerConfigurations.length === 0) {
    throw new Error(
        `No layer configurations match the requested tiers: ${requestedTiers.join(", ")}.`
    );
}

let metadataList = [];
let attributesList = [];
const dnaList = new Set();

if (APPEND_MODE) {
    const metadataPath = `${buildDir}/json/_metadata.json`;
    if (fs.existsSync(metadataPath)) {
        try {
            metadataList = JSON.parse(fs.readFileSync(metadataPath));
        } catch (error) {
            console.warn("Unable to preload existing metadata. Continuing with an empty list.", error);
            metadataList = [];
        }
    }
}
const DNA_DELIMITER = "-";
const HashlipsGiffer = require(`${basePath}/modules/HashlipsGiffer.js`);

let hashlipsGiffer = null;

const ensureDir = (dir) => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
};

const buildSetup = () => {
    if (fs.existsSync(buildDir) && !APPEND_MODE) {
        fs.rmdirSync(buildDir, { recursive: true });
    }
    ensureDir(buildDir);
    ensureDir(`${buildDir}/json`);
    ensureDir(`${buildDir}/images`);
    if (gif.export) {
        ensureDir(`${buildDir}/gifs`);
    }
};

const getRarityWeight = (_str) => {
    let nameWithoutExtension = _str.slice(0, -4);
    if (!nameWithoutExtension.includes(rarityDelimiter)) {
        return { name: nameWithoutExtension, weight: 1 };
    }
    var nameWithoutWeight = nameWithoutExtension.split(rarityDelimiter).shift();
    return {
        name: nameWithoutWeight,
        weight: Number(nameWithoutExtension.split(rarityDelimiter).pop()),
    };
};

const cleanDna = (_str) => {
    const withoutOptions = removeQueryStrings(_str);
    var dna = Number(withoutOptions.split(":").shift());
    return dna;
};

const cleanName = (_str) => {
    let nameWithoutExtension = _str.slice(0, -4);
    var nameWithoutWeight = nameWithoutExtension.split(rarityDelimiter).shift();
    return nameWithoutWeight;
};

const getElements = (path) => {
    return fs
        .readdirSync(path)
        .filter((item) => !/(^|\/)\.[^\/\.]/g.test(item))
        .map((i, index) => {
            if (i.includes("-")) {
                throw new Error(`layer name can not contain dashes, please fix: ${i}`);
            }
            return {
                id: index,
                name: cleanName(i),
                filename: i,
                path: `${path}${i}`,
                weight: getRarityWeight(i).weight,
            };
        });
};

const layersSetup = (layersOrder) => {
    const layers = layersOrder.map((layerObj, index) => {
        return {
            id: index,
            elements: getElements(`${layersDir}/${layerObj.name}/`),
            name:
                layerObj.options?.["displayName"] != undefined
                    ? layerObj.options?.["displayName"]
                    : layerObj.name,
            blend:
                layerObj.options?.["blend"] != undefined
                    ? layerObj.options?.["blend"]
                    : "source-over",
            opacity:
                layerObj.options?.["opacity"] != undefined
                    ? layerObj.options?.["opacity"]
                    : 1,
            bypassDNA:
                layerObj.options?.["bypassDNA"] !== undefined
                    ? layerObj.options?.["bypassDNA"]
                    : false,
        };
    });
    return layers;
};

const saveImage = (_editionCount) => {
    fs.writeFileSync(
        `${buildDir}/images/${_editionCount}.png`,
        canvas.toBuffer("image/png")
    );
};

const genColor = () => {
    let hue = Math.floor(Math.random() * 360);
    let pastel = `hsl(${hue}, 100%, 85%)`;
    return pastel;
};

const drawBackground = () => {
    ctx.fillStyle = background.static ? background.default : genColor();
    ctx.fillRect(0, 0, format.width, format.height);
};

const addMetadata = (_dna, _edition, _tier) => {
    let dateTime = Date.now();

    // Determine Category based on edition number
    let category;
    if (_edition >= 0 && _edition < 1000) {
        category = "Piglet";
    } else if (_edition >= 1000 && _edition < 2000) {
        category = "City Swine";
    } else if (_edition >= 2000 && _edition < 3000) {
        category = "Oinklords";
    } else {
        category = "Unknown";
    }

    // Add Tier and Category attributes at the end
    const attributesWithTier = [
        ...attributesList,
        {
            trait_type: "Tier",
            value: _tier === "POOR" ? "Poor" : _tier === "MID" ? "Mid" : "Rich"
        },
        {
            trait_type: "Category",
            value: category
        }
    ];

    let tempMetadata = {
        name: `${namePrefix} #${_edition}`,
        description: description,
        image: `${baseUri}/${_edition}.png`,
        dna: sha1(_dna),
        edition: _edition,
        date: dateTime,
        ...extraMetadata,
        attributes: attributesWithTier,
        compiler: "HashLips Art Engine",
    };
    if (network == NETWORK.sol) {
        tempMetadata = {
            // Added metadata for Solana
            name: tempMetadata.name,
            symbol: solanaMetadata.symbol,
            description: tempMetadata.description,
            // Added metadata for Solana
            seller_fee_basis_points: solanaMetadata.seller_fee_basis_points,
            image: `${_edition}.png`,
            // Added metadata for Solana
            external_url: solanaMetadata.external_url,
            edition: _edition,
            ...extraMetadata,
            attributes: attributesWithTier,
            properties: {
                files: [
                    {
                        uri: `${_edition}.png`,
                        type: "image/png",
                    },
                ],
                category: "image",
                creators: solanaMetadata.creators,
            },
        };
    }
    metadataList = metadataList.filter((meta) => meta.edition !== _edition);
    metadataList.push(tempMetadata);
    attributesList = [];
};

const addAttributes = (_element) => {
    let selectedElement = _element.layer.selectedElement;
    attributesList.push({
        trait_type: _element.layer.name,
        value: selectedElement.name,
    });
};

const loadLayerImg = async (_layer) => {
    try {
        return new Promise(async (resolve) => {
            const image = await loadImage(`${_layer.selectedElement.path}`);
            resolve({ layer: _layer, loadedImage: image });
        });
    } catch (error) {
        console.error("Error loading image:", error);
    }
};

const addText = (_sig, x, y, size) => {
    ctx.fillStyle = text.color;
    ctx.font = `${text.weight} ${size}pt ${text.family}`;
    ctx.textBaseline = text.baseline;
    ctx.textAlign = text.align;
    ctx.fillText(_sig, x, y);
};

const drawElement = (_renderObject, _index, _layersLen) => {
    ctx.globalAlpha = _renderObject.layer.opacity;
    ctx.globalCompositeOperation = _renderObject.layer.blend;
    text.only
        ? addText(
            `${_renderObject.layer.name}${text.spacer}${_renderObject.layer.selectedElement.name}`,
            text.xGap,
            text.yGap * (_index + 1),
            text.size
        )
        : ctx.drawImage(
            _renderObject.loadedImage,
            0,
            0,
            format.width,
            format.height
        );

    addAttributes(_renderObject);
};

const constructLayerToDna = (_dna = "", _layers = []) => {
    let mappedDnaToLayers = _layers.map((layer, index) => {
        let selectedElement = layer.elements.find(
            (e) => e.id == cleanDna(_dna.split(DNA_DELIMITER)[index])
        );
        return {
            name: layer.name,
            blend: layer.blend,
            opacity: layer.opacity,
            selectedElement: selectedElement,
        };
    });
    return mappedDnaToLayers;
};

/**
 * In some cases a DNA string may contain optional query parameters for options
 * such as bypassing the DNA isUnique check, this function filters out those
 * items from the DNA string resulting in a pure DNA string.
 *
 * @param {string} _dna New DNA string
 * @returns new DNA string without query parameters.
 */
const removeQueryStrings = (_dna) => {
    const query = /(\?.*$)/;
    return _dna.replace(query, "");
};

const isDnaUnique = (_dnaList = new Set(), _dna = "") => {
    const _filteredDNA = removeQueryStrings(_dna);
    return !_dnaList.has(_filteredDNA);
};

const createDna = (_layers) => {
    let randNum = [];
    _layers.forEach((layer) => {
        var totalWeight = 0;
        layer.elements.forEach((element) => {
            totalWeight += element.weight;
        });
        // number between 0 - totalWeight
        let random = Math.floor(Math.random() * totalWeight);
        for (var i = 0; i < layer.elements.length; i++) {
            // subtract the current weight from the random weight
            random -= layer.elements[i].weight;
            if (random < 0) {
                return randNum.push(
                    `${layer.elements[i].id}:${layer.elements[i].filename}${layer.bypassDNA ? "?bypassDNA=true" : ""
                    }`
                );
            }
        }
    });
    return randNum.join(DNA_DELIMITER);
};

const writeMetaData = (_data) => {
    fs.writeFileSync(`${buildDir}/json/_metadata.json`, JSON.stringify(_data, null, 2));
};

const saveMetaDataSingleFile = (_editionCount) => {
    let metadata = metadataList.find((meta) => meta.edition == _editionCount);
    debugLogs
        ? console.log(
            `Writing metadata for ${_editionCount}: ${JSON.stringify(metadata)}`
        )
        : null;
    fs.writeFileSync(
        `${buildDir}/json/${_editionCount}.json`,
        JSON.stringify(metadata, null, 2)
    );
};

// Performance limits to prevent crashes (from performance.config.js)
const BATCH_SIZE = performanceConfig.BATCH_SIZE;
const BATCH_DELAY = performanceConfig.BATCH_DELAY;
const SAVE_METADATA_INTERVAL = performanceConfig.SAVE_METADATA_INTERVAL;
const FORCE_GC = performanceConfig.FORCE_GC;
const SHOW_MEMORY_STATS = performanceConfig.SHOW_MEMORY_STATS;

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

const showMemoryStats = () => {
    if (!SHOW_MEMORY_STATS) return;
    const used = process.memoryUsage();
    console.log(`📊 Memory: ${Math.round(used.heapUsed / 1024 / 1024)}MB used / ${Math.round(used.heapTotal / 1024 / 1024)}MB total`);
};

const startCreating = async () => {
    let failedCount = 0;
    let totalCreated = 0;

    for (const configuration of activeLayerConfigurations) {
        const { growEditionSizeTo, startEdition, layersOrder, tier } = configuration;
        const editionSize = growEditionSizeTo - startEdition;
        const layers = layersSetup(layersOrder);
        const editionQueue = Array.from({ length: editionSize }, (_, index) => startEdition + index);

        if (shuffleLayerConfigurations) {
            editionQueue.sort(() => Math.random() - 0.5);
        }

        console.log(`🚀 Starting generation for tier ${tier}: ${editionSize} editions`);
        console.log(`⚡ Performance mode: ${BATCH_SIZE} NFTs per batch with ${BATCH_DELAY}ms delay`);

        let createdForConfig = 0;
        let batchCount = 0;

        while (createdForConfig < editionSize) {
            let newDna = createDna(layers);
            if (isDnaUnique(dnaList, newDna)) {
                let results = constructLayerToDna(newDna, layers);
                let loadedElements = [];

                results.forEach((layer) => {
                    loadedElements.push(loadLayerImg(layer));
                });

                const editionNumber = editionQueue[0];
                await Promise.all(loadedElements).then((renderObjectArray) => {
                    debugLogs ? console.log("Clearing canvas") : null;
                    ctx.clearRect(0, 0, format.width, format.height);
                    if (gif.export) {
                        hashlipsGiffer = new HashlipsGiffer(
                            canvas,
                            ctx,
                            `${buildDir}/gifs/${editionNumber}.gif`,
                            gif.repeat,
                            gif.quality,
                            gif.delay
                        );
                        hashlipsGiffer.start();
                    }
                    if (background.generate) {
                        drawBackground();
                    }
                    renderObjectArray.forEach((renderObject, index) => {
                        drawElement(renderObject, index, layers.length);
                        if (gif.export) {
                            hashlipsGiffer.add();
                        }
                    });
                    if (gif.export) {
                        hashlipsGiffer.stop();
                    }
                    saveImage(editionNumber);
                    addMetadata(newDna, editionNumber, tier);
                    saveMetaDataSingleFile(editionNumber);
                    console.log(
                        `✅ Created edition: ${editionNumber} (tier ${tier}) [${createdForConfig + 1}/${editionSize}]`
                    );
                });
                dnaList.add(removeQueryStrings(newDna));
                createdForConfig++;
                totalCreated++;
                editionQueue.shift();
                batchCount++;

                // Save metadata periodically
                if (totalCreated % SAVE_METADATA_INTERVAL === 0) {
                    writeMetaData(metadataList);
                    console.log(`💾 Metadata saved (${totalCreated} NFTs generated)`);
                }

                // Batch delay to prevent crashes
                if (batchCount >= BATCH_SIZE && createdForConfig < editionSize) {
                    console.log(`⏸️  Batch complete (${batchCount} NFTs). Pausing ${BATCH_DELAY}ms to prevent crash...`);
                    showMemoryStats();
                    if (FORCE_GC && global.gc) {
                        global.gc(); // Force garbage collection if available
                        console.log(`🗑️  Memory cleaned`);
                        showMemoryStats();
                    }
                    await sleep(BATCH_DELAY);
                    batchCount = 0;
                    console.log(`▶️  Resuming generation...`);
                }
            } else {
                console.log("DNA exists!");
                failedCount++;
                if (failedCount >= uniqueDnaTorrance) {
                    console.log(
                        `You need more layers or elements to grow the ${tier} tier to ${editionSize} artworks!`
                    );
                    process.exit();
                }
            }
        }

        console.log(`✨ Tier ${tier} complete: ${createdForConfig} editions generated\n`);
    }

    writeMetaData(metadataList);
    console.log(`🎉 Generation complete! Total: ${totalCreated} NFTs`);
};

module.exports = { startCreating, buildSetup, getElements };
