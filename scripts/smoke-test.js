#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const umiRoot = path.join(repoRoot, 'umi');

let failureCount = 0;

const check = (label, fn) => {
  try {
    fn();
    console.log(`✅ ${label}`);
  } catch (error) {
    failureCount += 1;
    console.error(`❌ ${label}`);
    console.error(`   → ${error.message}`);
  }
};

check('Racine node_modules présent', () => {
  const nodeModulesPath = path.join(repoRoot, 'node_modules');
  if (!fs.existsSync(nodeModulesPath)) {
    throw new Error('node_modules absent. Exécutez "npm install" à la racine.');
  }
});

check('Dépendances racine résolues (@metaplex-foundation/umi)', () => {
  require.resolve('@metaplex-foundation/umi', { paths: [repoRoot] });
});

check('Canvas disponible', () => {
  const canvas = require('canvas');
  if (typeof canvas.createCanvas !== 'function') {
    throw new Error('la fonction createCanvas est introuvable.');
  }
});

check('Dépendances Umi installées', () => {
  const umiNodeModules = path.join(umiRoot, 'node_modules');
  if (!fs.existsSync(umiNodeModules)) {
    throw new Error('umi/node_modules absent. Exécutez "npm install" dans le dossier umi/.');
  }
  require.resolve('@metaplex-foundation/umi', { paths: [umiRoot] });
  require.resolve('dotenv', { paths: [umiRoot] });
});

if (failureCount > 0) {
  console.error(`\n${failureCount} vérification(s) ont échoué. Voir les messages ci-dessus.`);
  process.exit(1);
}

console.log('\nTout est prêt pour exécuter la génération et les scripts Umi.');
