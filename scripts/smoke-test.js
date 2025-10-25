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

check('Root node_modules present', () => {
  const nodeModulesPath = path.join(repoRoot, 'node_modules');
  if (!fs.existsSync(nodeModulesPath)) {
    throw new Error('node_modules is missing. Run "npm install" at the repository root.');
  }
});

check('Root dependency resolution (@metaplex-foundation/umi)', () => {
  require.resolve('@metaplex-foundation/umi', { paths: [repoRoot] });
});

check('Canvas available', () => {
  const canvas = require('canvas');
  if (typeof canvas.createCanvas !== 'function') {
    throw new Error('createCanvas export not found.');
  }
});

check('Umi dependencies installed', () => {
  const umiNodeModules = path.join(umiRoot, 'node_modules');
  if (!fs.existsSync(umiNodeModules)) {
    throw new Error('umi/node_modules is missing. Run "npm install" inside the umi/ directory.');
  }
  require.resolve('@metaplex-foundation/umi', { paths: [umiRoot] });
  require.resolve('dotenv', { paths: [umiRoot] });
});

if (failureCount > 0) {
  console.error(`\n${failureCount} check(s) failed. Review the details above.`);
  process.exit(1);
}

console.log('\nEnvironment ready: generation pipeline and Umi scripts can run.');
