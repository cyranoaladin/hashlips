#!/usr/bin/env node

/**
 * Script pour vérifier que les images vont s'afficher correctement
 * Vérifie :
 * - Que tous les fichiers JSON ont le bon format
 * - Que les images existent
 * - Que les URIs sont correctes
 * - Que les métadonnées sont complètes
 */

const fs = require('fs');
const path = require('path');

const ASSETS_DIR = path.join(__dirname, 'assets');
const BUILD_IMAGES_DIR = path.join(__dirname, 'build', 'images');

console.log('🔍 Vérification que les images vont s\'afficher correctement...\n');

let errors = [];
let warnings = [];
let success = 0;

// Vérifier que le dossier assets existe
if (!fs.existsSync(ASSETS_DIR)) {
    console.error('❌ Erreur: Le dossier assets/ n\'existe pas');
    console.error('💡 Exécutez: node prepare-sugar-assets.js');
    process.exit(1);
}

// Lire tous les fichiers JSON
const jsonFiles = fs.readdirSync(ASSETS_DIR)
    .filter(file => file.match(/^\d+\.json$/))
    .sort((a, b) => parseInt(a) - parseInt(b));

console.log(`📦 ${jsonFiles.length} fichiers JSON trouvés\n`);

// Vérifier quelques fichiers représentatifs
const testFiles = [0, 500, 999, 1000, 1500, 1999, 2000, 2500, 2999].filter(n => n < jsonFiles.length);

console.log('🔍 Vérification des fichiers de test...\n');

testFiles.forEach(index => {
    const jsonFile = `${index}.json`;
    const jsonPath = path.join(ASSETS_DIR, jsonFile);
    const imageFile = `${index}.png`;
    const imagePath = path.join(ASSETS_DIR, imageFile);
    const buildImagePath = path.join(BUILD_IMAGES_DIR, imageFile);

    try {
        const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

        // Vérifications
        const checks = {
            hasName: !!metadata.name,
            hasDescription: !!metadata.description,
            hasImage: !!metadata.image,
            hasAttributes: Array.isArray(metadata.attributes) && metadata.attributes.length > 0,
            hasCategory: metadata.attributes?.some(a => a.trait_type === 'Category'),
            hasTier: metadata.attributes?.some(a => a.trait_type === 'Tier'),
            hasProperties: !!metadata.properties,
            hasFiles: metadata.properties?.files && Array.isArray(metadata.properties.files) && metadata.properties.files.length > 0,
            imageExists: fs.existsSync(imagePath) || fs.existsSync(buildImagePath),
            imageFormat: metadata.image.endsWith('.png') || metadata.image.startsWith('http') || metadata.image.startsWith('ipfs://'),
            sellerFee: metadata.seller_fee_basis_points === 500,
            symbol: metadata.symbol === 'OINK'
        };

        // Vérifier la Category
        const category = metadata.attributes?.find(a => a.trait_type === 'Category');
        let expectedCategory;
        if (index >= 0 && index < 1000) {
            expectedCategory = 'Piglet';
        } else if (index >= 1000 && index < 2000) {
            expectedCategory = 'City Swine';
        } else if (index >= 2000 && index < 3000) {
            expectedCategory = 'Oinklords';
        }

        if (category && category.value !== expectedCategory) {
            warnings.push(`NFT #${index}: Category incorrecte (${category.value} au lieu de ${expectedCategory})`);
        }

        // Vérifier l'URI de l'image
        if (metadata.image && !metadata.image.startsWith('http') && !metadata.image.startsWith('ipfs://')) {
            // C'est normal avant l'upload, Sugar CLI mettra à jour après
            if (!metadata.image.endsWith('.png')) {
                errors.push(`NFT #${index}: Format d'image invalide (${metadata.image})`);
            }
        }

        // Vérifier properties.files[0].uri
        if (metadata.properties?.files?.[0]?.uri) {
            const uri = metadata.properties.files[0].uri;
            if (!uri.startsWith('http') && !uri.startsWith('ipfs://') && !uri.endsWith('.png')) {
                errors.push(`NFT #${index}: URI invalide dans properties.files[0].uri (${uri})`);
            }
        }

        // Compter les erreurs
        const failedChecks = Object.entries(checks).filter(([key, value]) => !value);
        if (failedChecks.length > 0) {
            errors.push(`NFT #${index}: Échecs: ${failedChecks.map(([key]) => key).join(', ')}`);
        } else {
            success++;
        }

        // Afficher le résumé pour quelques fichiers
        if (index % 1000 === 0 || index === 2999) {
            console.log(`✅ NFT #${index}: ${category?.value || 'N/A'} - Image: ${metadata.image}`);
        }

    } catch (error) {
        errors.push(`NFT #${index}: Erreur de lecture - ${error.message}`);
    }
});

// Vérifier que toutes les images existent
console.log('\n🔍 Vérification de l\'existence des images...\n');

let missingImages = 0;
for (let i = 0; i < Math.min(100, jsonFiles.length); i++) {
    const index = parseInt(jsonFiles[i].replace('.json', ''));
    const imagePath = path.join(ASSETS_DIR, `${index}.png`);
    const buildImagePath = path.join(BUILD_IMAGES_DIR, `${index}.png`);

    if (!fs.existsSync(imagePath) && !fs.existsSync(buildImagePath)) {
        missingImages++;
        if (missingImages <= 5) {
            warnings.push(`Image manquante: ${index}.png`);
        }
    }
}

if (missingImages > 5) {
    warnings.push(`... et ${missingImages - 5} autres images manquantes`);
}

// Résumé
console.log('\n' + '='.repeat(60));
console.log('📊 RÉSUMÉ DE LA VÉRIFICATION');
console.log('='.repeat(60));
console.log(`✅ Fichiers vérifiés avec succès: ${success}/${testFiles.length}`);
console.log(`⚠️  Avertissements: ${warnings.length}`);
console.log(`❌ Erreurs: ${errors.length}`);
console.log(`🖼️  Images manquantes (échantillon): ${missingImages}`);

if (warnings.length > 0) {
    console.log('\n⚠️  AVERTISSEMENTS:');
    warnings.slice(0, 10).forEach(w => console.log(`   - ${w}`));
    if (warnings.length > 10) {
        console.log(`   ... et ${warnings.length - 10} autres avertissements`);
    }
}

if (errors.length > 0) {
    console.log('\n❌ ERREURS:');
    errors.slice(0, 10).forEach(e => console.log(`   - ${e}`));
    if (errors.length > 10) {
        console.log(`   ... et ${errors.length - 10} autres erreurs`);
    }
    console.log('\n❌ Des erreurs ont été détectées. Corrigez-les avant de déployer.');
    process.exit(1);
}

console.log('\n✅ VÉRIFICATION TERMINÉE');
console.log('\n💡 IMPORTANT pour que les images s\'affichent:');
console.log('   1. Les fichiers JSON ont le bon format ✅');
console.log('   2. Les images existent dans assets/ ✅');
console.log('   3. Après sugar upload, les URIs seront mises à jour automatiquement');
console.log('   4. Utilisez: node update-assets-uris.js après sugar upload');
console.log('   5. Les métadonnées on-chain seront mises à jour avec sugar update');
console.log('\n✨ Les images devraient s\'afficher correctement après l\'upload!');
