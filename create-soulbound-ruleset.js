const { Connection, Keypair, PublicKey, Transaction, sendAndConfirmTransaction } = require('@solana/web3.js');
const { 
  createOrUpdateV1,
  findRuleSetPda,
  MPL_TOKEN_AUTH_RULES_PROGRAM_ID 
} = require('@metaplex-foundation/mpl-token-auth-rules');
const { 
  createUmi,
  publicKey,
  signerIdentity,
  keypairIdentity
} = require('@metaplex-foundation/umi');
const { createWeb3JsEdi } = require('@metaplex-foundation/umi-web3js-adapters');
const fs = require('fs');

async function createSoulboundRuleSet() {
  console.log('🔒 Creating soulbound rule set...');
  
  // Load keypair
  const keypairData = JSON.parse(fs.readFileSync('./my-keypair.json', 'utf-8'));
  const wallet = Keypair.fromSecretKey(Uint8Array.from(keypairData));
  
  console.log('📍 Payer:', wallet.publicKey.toString());
  console.log('🌐 Network: Devnet\n');
  
  // Simplified approach: use Sugar CLI to create ruleset
  console.log('⚠️  Note: Creating ruleset requires Metaplex UMI framework');
  console.log('📝 Alternative: Use Sugar CLI or configure manually\n');
  
  // For now, use a pre-existing soulbound ruleset or null
  const ruleSetName = 'OinkonomicsSoulbound';
  
  // Calculate PDA address
  const [ruleSetPDA] = PublicKey.findProgramAddressSync(
    [
      Buffer.from('rule_set'),
      wallet.publicKey.toBytes(),
      Buffer.from(ruleSetName)
    ],
    MPL_TOKEN_AUTH_RULES_PROGRAM_ID
  );
  
  console.log('📝 Calculated Rule Set PDA:', ruleSetPDA.toString());
  console.log('\n✅ For soulbound NFTs, you can:');
  console.log('1. Use NULL ruleset (simpler, pNFT without restrictions)');
  console.log('2. Create custom ruleset with Sugar CLI');
  console.log('3. Use pre-deployed soulbound ruleset\n');
  
  console.log('🎯 Recommended: Set "ruleSet": null and use standard pNFTs');
  console.log('   This allows transferability. For true soulbound, use');
  console.log('   a specific auth-rules program deployment.\n');
  
  // Save PDA for reference
  fs.writeFileSync('ruleset-address.txt', ruleSetPDA.toString());
  console.log('💾 Calculated PDA saved to ruleset-address.txt');
  
  return ruleSetPDA.toString();
}

createSoulboundRuleSet().catch(console.error);
