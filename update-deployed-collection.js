#!/usr/bin/env node

/**
 * Script pour mettre à jour les métadonnées d'une collection déjà déployée
 * Nécessite isMutable: true dans la configuration
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CACHE_FILE = path.join(__dirname, 'cache.json');
const ASSETS_DIR = path.join(__dirname, 'assets');

console.log('🔄 Mise à jour des métadonnées d\'une collection déjà déployée...\n');

// Vérifier que le cache.json existe
if (!fs.existsSync(CACHE_FILE)) {
    console.error('❌ Erreur: cache.json introuvable');
    console.error('💡 La collection doit être déployée avec sugar deploy');
    process.exit(1);
}

// Lire le cache.json
const cache = JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));

// Vérifier que la Candy Machine est déployée
if (!cache.program || !cache.program.candyMachine || cache.program.candyMachine === '') {
    console.error('❌ Erreur: Aucune Candy Machine trouvée dans le cache.json');
    console.error('💡 La collection doit être déployée avec sugar deploy');
    console.error('💡 Ou le cache.json doit être mis à jour avec l\'adresse de la Candy Machine');
    process.exit(1);
}

console.log(`✅ Candy Machine trouvée: ${cache.program.candyMachine}\n`);

// Vérifier que les assets sont uploadés
let itemsWithLinks = 0;
Object.keys(cache.items).forEach((key) => {
    if (key !== '-1' && cache.items[key].image_link && cache.items[key].image_link.trim() !== '') {
        itemsWithLinks++;
    }
});

if (itemsWithLinks === 0) {
    console.warn('⚠️  ATTENTION: Aucun asset n\'a d\'image_link dans le cache.json');
    console.warn('💡 Les assets doivent être uploadés avec sugar upload');
    console.warn('💡 Voulez-vous continuer quand même? (les métadonnées locales seront mises à jour)\n');

    // Demander confirmation
    const readline = require('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    rl.question('Continuer? (oui/non): ', (answer) => {
        if (answer.toLowerCase() !== 'oui' && answer.toLowerCase() !== 'o' && answer.toLowerCase() !== 'yes' && answer.toLowerCase() !== 'y') {
            console.log('❌ Opération annulée');
            rl.close();
            process.exit(0);
        }
        rl.close();
        updateMetadata();
    });
} else {
    console.log(`✅ ${itemsWithLinks} assets ont des URLs dans le cache.json\n`);
    updateMetadata();
}

function updateMetadata() {
    console.log('📝 Étape 1: Mise à jour des fichiers JSON dans assets/ avec les URLs du cache...\n');

    // Mettre à jour les fichiers JSON avec les URLs du cache
    let updated = 0;
    Object.keys(cache.items).forEach((key) => {
        if (key === '-1') return; // Skip collection metadata

        const item = cache.items[key];
        const index = parseInt(key);

        if (item.image_link && item.image_link.trim() !== '') {
            const jsonPath = path.join(ASSETS_DIR, `${index}.json`);

            if (fs.existsSync(jsonPath)) {
                try {
                    const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

                    // Mettre à jour l'URI de l'image
                    metadata.image = item.image_link;

                    // Mettre à jour l'URI dans properties.files[0].uri
                    if (metadata.properties && metadata.properties.files && metadata.properties.files[0]) {
                        metadata.properties.files[0].uri = item.image_link;
                    }

                    // Sauvegarder
                    fs.writeFileSync(jsonPath, JSON.stringify(metadata, null, 2));
                    updated++;

                    if (updated % 500 === 0) {
                        console.log(`✅ ${updated} fichiers mis à jour...`);
                    }
                } catch (error) {
                    console.error(`❌ Erreur avec ${index}.json:`, error.message);
                }
            }
        }
    });

    console.log(`\n✅ ${updated} fichiers JSON mis à jour dans assets/\n`);

    console.log('📝 Étape 2: Mise à jour des métadonnées on-chain avec sugar update...\n');
    console.log('⚠️  Cette commande va mettre à jour les métadonnées on-chain de tous les NFTs');
    console.log('⚠️  Cela peut prendre du temps et coûter des frais de transaction\n');

    // Demander confirmation
    const readline = require('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    rl.question('Voulez-vous continuer avec sugar update? (oui/non): ', (answer) => {
        if (answer.toLowerCase() !== 'oui' && answer.toLowerCase() !== 'o' && answer.toLowerCase() !== 'yes' && answer.toLowerCase() !== 'y') {
            console.log('\n❌ Opération annulée');
            console.log('💡 Les fichiers JSON dans assets/ ont été mis à jour');
            console.log('💡 Exécutez manuellement: sugar update');
            rl.close();
            process.exit(0);
        }

        rl.close();

        try {
            console.log('\n🚀 Exécution de sugar update...\n');
            execSync('sugar update', { stdio: 'inherit', cwd: __dirname });
            console.log('\n✨ Mise à jour terminée avec succès!');
        } catch (error) {
            console.error('\n❌ Erreur lors de la mise à jour:', error.message);
            console.error('💡 Vérifiez que vous êtes connecté au bon réseau');
            console.error('💡 Vérifiez que isMutable: true dans la configuration');
            process.exit(1);
        }
    });
}
