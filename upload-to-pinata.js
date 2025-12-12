#!/usr/bin/env node

/**
 * Script pour uploader les assets sur Pinata et mettre à jour les métadonnées
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const FormData = require('form-data');

const ASSETS_DIR = path.join(__dirname, 'assets');
// Charger la configuration Pinata depuis sugar-config.json
const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'sugar-config.json'), 'utf8'));
const PINATA_JWT = config.pinataConfig.jwt;
const PINATA_GATEWAY = config.pinataConfig.contentGateway || "https://gateway.pinata.cloud";

console.log('📤 Upload des assets sur Pinata...\n');

// Vérifier que le dossier assets existe
if (!fs.existsSync(ASSETS_DIR)) {
  console.error('❌ Erreur: Le dossier assets/ n\'existe pas');
  process.exit(1);
}

// Fonction pour uploader un fichier sur Pinata
function uploadToPinata(filePath, fileName) {
  return new Promise((resolve, reject) => {
    const form = new FormData();
    form.append('file', fs.createReadStream(filePath), {
      filename: fileName,
      contentType: fileName.endsWith('.png') ? 'image/png' : 'application/json'
    });

    const options = {
      hostname: 'api.pinata.cloud',
      path: '/pinning/pinFileToIPFS',
      method: 'POST',
      headers: {
        ...form.getHeaders(),
        'Authorization': `Bearer ${PINATA_JWT}`
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            const result = JSON.parse(data);
            resolve(result.IpfsHash);
          } catch (error) {
            reject(new Error(`Erreur parsing: ${error.message}`));
          }
        } else {
          reject(new Error(`Erreur HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    form.pipe(req);
  });
}

// Lire tous les fichiers
const jsonFiles = fs.readdirSync(ASSETS_DIR)
  .filter(file => file.match(/^\d+\.json$/))
  .sort((a, b) => parseInt(a) - parseInt(b));

const imageFiles = fs.readdirSync(ASSETS_DIR)
  .filter(file => file.match(/^\d+\.png$/))
  .sort((a, b) => parseInt(a) - parseInt(b));

console.log(`📦 ${jsonFiles.length} fichiers JSON trouvés`);
console.log(`🖼️  ${imageFiles.length} images trouvées\n`);

// Créer un fichier de mapping pour stocker les IPFS hashes
const ipfsMap = {};

// Fonction principale async
async function main() {
  // Uploader les images
  console.log('📤 Upload des images sur Pinata...\n');
  let uploadedImages = 0;
  let failedImages = 0;

  for (let i = 0; i < imageFiles.length; i++) {
    const imageFile = imageFiles[i];
    const index = parseInt(imageFile.replace('.png', ''));
    const imagePath = path.join(ASSETS_DIR, imageFile);

    try {
      console.log(`📤 Upload ${imageFile} (${i + 1}/${imageFiles.length})...`);
      const ipfsHash = await uploadToPinata(imagePath, imageFile);
      ipfsMap[`${index}.png`] = ipfsHash;
      uploadedImages++;

      if ((i + 1) % 50 === 0) {
        console.log(`✅ ${i + 1} images uploadées...`);
      }

      // Petit délai pour éviter le rate limiting
      await new Promise(resolve => setTimeout(resolve, 100));
    } catch (error) {
      console.error(`❌ Erreur avec ${imageFile}: ${error.message}`);
      failedImages++;
    }
  }

  console.log(`\n✅ ${uploadedImages} images uploadées`);
  if (failedImages > 0) {
    console.log(`❌ ${failedImages} images échouées`);
  }

  // Mettre à jour les fichiers JSON avec les URLs Pinata
  console.log('\n🔄 Mise à jour des fichiers JSON avec les URLs Pinata...\n');

  let updated = 0;
  for (const jsonFile of jsonFiles) {
    const index = parseInt(jsonFile.replace('.json', ''));
    const jsonPath = path.join(ASSETS_DIR, jsonFile);
    const imageFile = `${index}.png`;

    try {
      const metadata = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

      // Mettre à jour l'URL de l'image si disponible
      if (ipfsMap[imageFile]) {
        const ipfsUrl = `ipfs://${ipfsMap[imageFile]}`;
        const gatewayUrl = `${PINATA_GATEWAY}/ipfs/${ipfsMap[imageFile]}`;

        metadata.image = gatewayUrl;

        // Mettre à jour properties.files[0].uri
        if (metadata.properties && metadata.properties.files && metadata.properties.files[0]) {
          metadata.properties.files[0].uri = gatewayUrl;
        }

        fs.writeFileSync(jsonPath, JSON.stringify(metadata, null, 2));
        updated++;

        if (updated % 100 === 0) {
          console.log(`✅ ${updated} fichiers JSON mis à jour...`);
        }
      }
    } catch (error) {
      console.error(`❌ Erreur avec ${jsonFile}: ${error.message}`);
    }
  }

  console.log(`\n✅ ${updated} fichiers JSON mis à jour avec les URLs Pinata`);

  // Sauvegarder le mapping IPFS
  const mappingPath = path.join(__dirname, 'pinata-ipfs-map.json');
  fs.writeFileSync(mappingPath, JSON.stringify(ipfsMap, null, 2));
  console.log(`\n💾 Mapping IPFS sauvegardé dans: ${mappingPath}`);

  console.log('\n✨ Upload terminé!');
  if (ipfsMap['0.png']) {
    console.log(`\n📋 URLs format:`);
    console.log(`   - IPFS: ipfs://${ipfsMap['0.png']}`);
    console.log(`   - Gateway: ${PINATA_GATEWAY}/ipfs/${ipfsMap['0.png']}`);
  }
}

// Exécuter la fonction principale
main().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
