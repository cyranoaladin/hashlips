#!/usr/bin/env node

/**
 * Script pour corriger les métadonnées dans assets/ pour les pNFTs
 * - Supprime les doublons de Tier
 * - S'assure que seller_fee_basis_points est correct
 * - Vérifie le format des URIs d'image
 */

const fs = require('fs');
const path = require('path');

const ASSETS_DIR = path.join(__dirname, 'assets');

console.log('🔧 Correction des métadonnées dans assets/...\n');

if (!fs.existsSync(ASSETS_DIR)) {
  console.error('❌ Erreur: Le dossier assets/ n\'existe pas');
  process.exit(1);
}

// Lire tous les fichiers JSON
const jsonFiles = fs.readdirSync(ASSETS_DIR)
  .filter(file => file.match(/^\d+\.json$/))
  .sort((a, b) => parseInt(a) - parseInt(b));

console.log(`📦 ${jsonFiles.length} fichiers JSON trouvés\n`);

let fixed = 0;
let errors = 0;

jsonFiles.forEach((jsonFile, fileIndex) => {
  const jsonPath = path.join(ASSETS_DIR, jsonFile);
  const index = parseInt(jsonFile.replace('.json', ''));

  try {
    const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
    let modified = false;

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

    // 1. Supprimer les doublons de Tier et Category (garder seulement le dernier)
    if (metadata.attributes && Array.isArray(metadata.attributes)) {
      const uniqueAttributes = [];
      let lastTier = null;
      let lastCategory = null;

      // Trouver le dernier Tier et Category
      for (let i = metadata.attributes.length - 1; i >= 0; i--) {
        if (metadata.attributes[i].trait_type === 'Tier' && !lastTier) {
          lastTier = metadata.attributes[i];
        }
        if (metadata.attributes[i].trait_type === 'Category' && !lastCategory) {
          lastCategory = metadata.attributes[i];
        }
      }

      // Reconstruire les attributs sans doublons
      const seenTiers = new Set();
      const seenCategories = new Set();
      for (const attr of metadata.attributes) {
        if (attr.trait_type === 'Tier') {
          if (!seenTiers.has('Tier') && lastTier) {
            uniqueAttributes.push(lastTier);
            seenTiers.add('Tier');
          }
        } else if (attr.trait_type === 'Category') {
          if (!seenCategories.has('Category') && lastCategory) {
            uniqueAttributes.push(lastCategory);
            seenCategories.add('Category');
          }
        } else {
          uniqueAttributes.push(attr);
        }
      }

      // S'assurer que Category est présent avec la bonne valeur
      if (!seenCategories.has('Category')) {
        uniqueAttributes.push({
          trait_type: 'Category',
          value: category
        });
        modified = true;
      } else if (lastCategory && lastCategory.value !== category) {
        // Mettre à jour la valeur de Category si elle est incorrecte
        const categoryIndex = uniqueAttributes.findIndex(a => a.trait_type === 'Category');
        if (categoryIndex !== -1) {
          uniqueAttributes[categoryIndex].value = category;
          modified = true;
        }
      }

      if (metadata.attributes.length !== uniqueAttributes.length) {
        metadata.attributes = uniqueAttributes;
        modified = true;
      }
    }

    // 2. S'assurer que seller_fee_basis_points est 500 (5%)
    if (metadata.seller_fee_basis_points !== 500) {
      metadata.seller_fee_basis_points = 500;
      modified = true;
    }

    // 3. Vérifier que l'image est au bon format (nom de fichier local pour Sugar)
    // Sugar CLI mettra à jour automatiquement après l'upload
    const expectedImage = `${parseInt(jsonFile.replace('.json', ''))}.png`;
    if (metadata.image !== expectedImage && !metadata.image.startsWith('http') && !metadata.image.startsWith('ipfs://')) {
      metadata.image = expectedImage;
      modified = true;
    }

    // 4. Vérifier properties.files[0].uri
    if (metadata.properties && metadata.properties.files && metadata.properties.files[0]) {
      const expectedUri = `${parseInt(jsonFile.replace('.json', ''))}.png`;
      if (metadata.properties.files[0].uri !== expectedUri &&
        !metadata.properties.files[0].uri.startsWith('http') &&
        !metadata.properties.files[0].uri.startsWith('ipfs://')) {
        metadata.properties.files[0].uri = expectedUri;
        modified = true;
      }
    }

    // 5. S'assurer que le symbol est OINK
    if (metadata.symbol !== 'OINK') {
      metadata.symbol = 'OINK';
      modified = true;
    }

    // Sauvegarder si modifié
    if (modified) {
      fs.writeFileSync(jsonPath, JSON.stringify(metadata, null, 2));
      fixed++;
    }

    // Afficher la progression
    if ((index + 1) % 500 === 0) {
      console.log(`✅ ${index + 1}/${jsonFiles.length} fichiers traités...`);
    }
  } catch (error) {
    console.error(`❌ Erreur avec ${jsonFile}:`, error.message);
    errors++;
  }
});

console.log('\n📊 Résumé:');
console.log(`   • Fichiers corrigés: ${fixed}`);
console.log(`   • Erreurs: ${errors}`);
console.log(`   • Total: ${jsonFiles.length}`);

if (fixed > 0) {
  console.log('\n✨ Correction terminée!');
  console.log('💡 Les métadonnées sont maintenant prêtes pour l\'upload');
} else {
  console.log('\n✅ Aucune correction nécessaire');
}
