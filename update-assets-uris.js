#!/usr/bin/env node

/**
 * Script pour mettre à jour les URIs d'image dans les fichiers JSON assets/
 * avec les URLs du cache.json après l'upload Sugar CLI
 */

const fs = require('fs');
const path = require('path');

const CACHE_FILE = path.join(__dirname, 'cache.json');
const ASSETS_DIR = path.join(__dirname, 'assets');

console.log('🔄 Mise à jour des URIs d\'image dans les fichiers JSON...\n');

// Vérifier que le cache.json existe
if (!fs.existsSync(CACHE_FILE)) {
    console.error('❌ Erreur: cache.json introuvable');
    console.error('💡 Exécutez d\'abord "sugar upload" pour créer le cache.json');
    process.exit(1);
}

// Lire le cache.json avec gestion d'erreur
let cache;
try {
    const cacheContent = fs.readFileSync(CACHE_FILE, 'utf8');
    cache = JSON.parse(cacheContent);
} catch (error) {
    console.error('❌ Erreur lors de la lecture du cache.json:', error.message);
    console.error('💡 Le fichier cache.json est peut-être corrompu');
    console.error('💡 Essayez de régénérer avec: sugar upload');
    process.exit(1);
}

// Vérifier que le dossier assets existe
if (!fs.existsSync(ASSETS_DIR)) {
    console.error('❌ Erreur: Le dossier assets/ n\'existe pas');
    console.error('💡 Exécutez d\'abord "node prepare-sugar-assets.js"');
    process.exit(1);
}

// Compter les items avec des image_link non vides
let itemsWithLinks = 0;
let itemsUpdated = 0;
let itemsWithoutLinks = 0;

// Parcourir tous les items du cache (sauf -1 qui est la collection)
Object.keys(cache.items).forEach((key) => {
    if (key === '-1') return; // Skip collection metadata

    const item = cache.items[key];
    const index = parseInt(key);

    if (item.image_link && item.image_link.trim() !== '') {
        itemsWithLinks++;

        // Chemin du fichier JSON dans assets/
        const jsonPath = path.join(ASSETS_DIR, `${index}.json`);

        if (fs.existsSync(jsonPath)) {
            try {
                // Lire le fichier JSON
                const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

                // Mettre à jour l'URI de l'image
                metadata.image = item.image_link;

                // Mettre à jour l'URI dans properties.files[0].uri
                if (metadata.properties && metadata.properties.files && metadata.properties.files[0]) {
                    metadata.properties.files[0].uri = item.image_link;
                }

                // Sauvegarder le fichier JSON mis à jour
                fs.writeFileSync(jsonPath, JSON.stringify(metadata, null, 2));
                itemsUpdated++;

                // Afficher la progression tous les 500 fichiers
                if (itemsUpdated % 500 === 0) {
                    console.log(`✅ ${itemsUpdated} fichiers mis à jour...`);
                }
            } catch (error) {
                console.error(`❌ Erreur lors de la mise à jour de ${index}.json:`, error.message);
            }
        } else {
            console.warn(`⚠️  Fichier JSON manquant: ${index}.json`);
        }
    } else {
        itemsWithoutLinks++;
    }
});

console.log('\n📊 Résumé:');
console.log(`   • Items avec image_link: ${itemsWithLinks}`);
console.log(`   • Fichiers JSON mis à jour: ${itemsUpdated}`);
console.log(`   • Items sans image_link: ${itemsWithoutLinks}`);

if (itemsWithoutLinks > 0 && itemsWithLinks === 0) {
    console.log('\n⚠️  ATTENTION: Aucun asset n\'a été uploadé!');
    console.log('💡 Exécutez "sugar upload" pour uploader les assets');
} else if (itemsUpdated > 0) {
    console.log('\n✨ Mise à jour terminée avec succès!');
    console.log('💡 Les fichiers JSON dans assets/ ont maintenant les bonnes URIs d\'image');
} else {
    console.log('\n⚠️  Aucun fichier n\'a été mis à jour');
}
