#!/usr/bin/env node

/**
 * Script de préparation des assets pour Sugar CLI
 * Convertit les métadonnées Hashlips en format compatible Sugar
 */

const fs = require('fs');
const path = require('path');

const BUILD_DIR = path.join(__dirname, 'build');
const ASSETS_DIR = path.join(__dirname, 'assets');
const JSON_DIR = path.join(BUILD_DIR, 'json');
const IMAGES_DIR = path.join(BUILD_DIR, 'images');

console.log('🔄 Préparation des assets pour Sugar CLI...\n');

// Créer le répertoire assets
if (fs.existsSync(ASSETS_DIR)) {
    console.log('🗑️  Suppression de l\'ancien répertoire assets...');
    fs.rmSync(ASSETS_DIR, { recursive: true });
}
fs.mkdirSync(ASSETS_DIR, { recursive: true });

// Vérifier que les fichiers build existent
if (!fs.existsSync(JSON_DIR) || !fs.existsSync(IMAGES_DIR)) {
    console.error('❌ Erreur: Veuillez d\'abord générer les NFTs avec "npm run build"');
    process.exit(1);
}

// Lire tous les fichiers JSON
const jsonFiles = fs.readdirSync(JSON_DIR)
    .filter(file => file.match(/^\d+\.json$/))
    .sort((a, b) => parseInt(a) - parseInt(b));

console.log(`📦 ${jsonFiles.length} NFTs trouvés\n`);

// Traiter chaque NFT
jsonFiles.forEach((jsonFile) => {
    const index = parseInt(jsonFile.replace('.json', ''));
    const jsonPath = path.join(JSON_DIR, jsonFile);
    const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

    // Déterminer la Category basée sur l'index
    let category;
    if (index >= 0 && index < 1000) {
        category = "Piglet";
    } else if (index >= 1000 && index < 2000) {
        category = "City Swine";
    } else if (index >= 2000 && index < 3000) {
        category = "Oinklords";
    } else {
        category = "Unknown";
    }

    // Filtrer les attributs pour éviter les doublons de Tier et Category
    // Le Tier et Category sont déjà ajoutés dans src/main.js, donc on les garde tel quel
    const existingAttributes = metadata.attributes || [];

    // Supprimer les doublons de Tier et Category (garder seulement le dernier)
    const uniqueAttributes = [];
    const seenTiers = new Set();
    const seenCategories = new Set();
    for (let i = existingAttributes.length - 1; i >= 0; i--) {
        const attr = existingAttributes[i];
        if (attr.trait_type === "Tier") {
            if (!seenTiers.has("Tier")) {
                uniqueAttributes.unshift(attr);
                seenTiers.add("Tier");
            }
        } else if (attr.trait_type === "Category") {
            if (!seenCategories.has("Category")) {
                uniqueAttributes.unshift(attr);
                seenCategories.add("Category");
            }
        } else {
            uniqueAttributes.unshift(attr);
        }
    }

    // S'assurer que Category est présent (ajouter si manquant)
    if (!seenCategories.has("Category")) {
        uniqueAttributes.push({
            trait_type: "Category",
            value: category
        });
    }

    // Créer les métadonnées au format Sugar
    // IMPORTANT: Pour les pNFTs, Sugar CLI met à jour le cache.json avec les URLs après l'upload
    // Mais il ne met PAS à jour automatiquement les fichiers JSON dans assets/
    // Il faut utiliser update-assets-uris.js après l'upload pour mettre à jour les fichiers JSON
    const sugarMetadata = {
        name: metadata.name || `${metadata.name}`,
        symbol: "OINK",
        description: metadata.description,
        seller_fee_basis_points: 500,
        // Le nom de fichier local sera remplacé par l'URL complète après l'upload
        // Utilisez update-assets-uris.js après sugar upload pour mettre à jour
        image: `${index}.png`,
        external_url: "https://oinkonomics.mfai.app",
        attributes: uniqueAttributes,
        properties: {
            files: [
                {
                    // L'URI sera mise à jour par update-assets-uris.js après l'upload
                    uri: `${index}.png`,
                    type: "image/png"
                }
            ],
            category: "image",
            creators: [
                {
                    address: "5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z",
                    share: 100
                }
            ]
        }
    };

    // Copier l'image
    const imageName = `${index}.png`;
    const srcImage = path.join(IMAGES_DIR, imageName);
    const dstImage = path.join(ASSETS_DIR, imageName);

    if (fs.existsSync(srcImage)) {
        fs.copyFileSync(srcImage, dstImage);
    } else {
        console.error(`❌ Image manquante: ${imageName}`);
    }

    // Sauvegarder les métadonnées
    const dstJson = path.join(ASSETS_DIR, `${index}.json`);
    fs.writeFileSync(dstJson, JSON.stringify(sugarMetadata, null, 2));

    // Afficher la progression
    if ((index + 1) % 50 === 0 || index === jsonFiles.length - 1) {
        console.log(`✅ Traité: ${index + 1}/${jsonFiles.length} NFTs`);
    }
});

console.log('\n✨ Préparation terminée!');
console.log(`📁 Assets préparés dans: ${ASSETS_DIR}`);
console.log('\n📋 Prochaines étapes:');
console.log('   1. Transférer le dossier sur le serveur si nécessaire');
console.log('   2. Configurer votre wallet Solana: solana config set --url mainnet-beta');
console.log('   3. Valider la configuration: sugar validate');
console.log('   4. Uploader les assets: sugar upload');
console.log('   5. Déployer la collection: sugar deploy');
console.log('   6. Vérifier: sugar verify');
console.log('   7. Lancer la vente: sugar launch');
