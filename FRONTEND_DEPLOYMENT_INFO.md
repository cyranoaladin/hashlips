# 🚀 Oinkonomics NFT - Frontend Deployment Information

## 📋 Collection Overview
- **Total NFTs**: 900
- **Network**: Solana Devnet (ready for mainnet)
- **Symbol**: OINK
- **Royalties**: 5% (500 basis points)

## 🎯 Tier Distribution (Verified)
- 🐷 **Poor** (NFT #0-299): 300 NFTs
- 🐖 **Mid** (NFT #300-599): 300 NFTs
- 🐗 **Rich** (NFT #600-899): 300 NFTs

## 💰 Pricing Configuration
- **Devnet (Testing)**: 0.01 SOL
- **Mainnet (Production)**: 0.0523 SOL = **6.9 USD** @ 131.88 USD/SOL

---

## 🔑 Critical IDs for Frontend Integration

### Devnet Deployment

#### Candy Machine ID
```
HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe
```

#### Collection NFT ID
```
6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi
```

#### Creator/Treasury Wallet
```
5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
```

#### Candy Machine Authority
```
FFTLr4uWg5HdYpvgtEnxtzMQWHEoFjWVWiPQZ7Wxvsfm
```

#### Candy Machine Program ID (Standard Sugar v3)
```
CndyV3LdqHUfDLmE5naZjVN8rBZz4tqhdefbAnjHG3JR
```

---

## 🔗 Explorer Links

### Candy Machine (Devnet)
- **Solana FM**: https://www.solana.fm/address/HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe?cluster=devnet-alpha
- **Solana Explorer**: https://explorer.solana.com/address/HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe?cluster=devnet

### Collection NFT (Devnet)
- **Solana FM**: https://www.solana.fm/address/6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi?cluster=devnet-alpha
- **Solana Explorer**: https://explorer.solana.com/address/6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi?cluster=devnet

### Creator Wallet (Devnet)
- **Solana FM**: https://www.solana.fm/address/5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z?cluster=devnet-alpha
- **Solana Explorer**: https://explorer.solana.com/address/5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z?cluster=devnet

---

## 🛠️ Frontend Environment Variables

### Required .env Variables for React/Next.js

```bash
# Network Configuration
NEXT_PUBLIC_SOLANA_NETWORK=devnet
# For production, change to: NEXT_PUBLIC_SOLANA_NETWORK=mainnet-beta

# RPC Endpoints
NEXT_PUBLIC_RPC_DEVNET=https://api.devnet.solana.com
NEXT_PUBLIC_RPC_MAINNET=https://api.mainnet-beta.solana.com

# Candy Machine Configuration
NEXT_PUBLIC_CANDY_MACHINE_PROGRAM_ID=CndyV3LdqHUfDLmE5naZjVN8rBZz4tqhdefbAnjHG3JR
NEXT_PUBLIC_CANDY_MACHINE_ID_DEVNET=HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe
NEXT_PUBLIC_CANDY_MACHINE_ID_MAINNET=

# Collection Info
NEXT_PUBLIC_COLLECTION_ID=6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi
NEXT_PUBLIC_TREASURY_WALLET=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z

# Pricing
NEXT_PUBLIC_MINT_PRICE_DEVNET=0.01
NEXT_PUBLIC_MINT_PRICE_MAINNET=0.0523

# Collection Details
NEXT_PUBLIC_COLLECTION_SIZE=900
NEXT_PUBLIC_COLLECTION_NAME=Oinkonomics NFT
NEXT_PUBLIC_COLLECTION_SYMBOL=OINK
NEXT_PUBLIC_COLLECTION_DESCRIPTION=Oinkonomics - Premium NFT Collection on Solana
NEXT_PUBLIC_DOMAIN=oinkonomics.fun
```

---

## 📦 Candy Machine Details

### Current Status
- **Items Available**: 900/900
- **Items Redeemed**: 0
- **Max Supply**: Unlimited (0 = no cap)
- **Is Mutable**: Yes
- **Is Sequential**: Yes (mints in order 0→899)
- **Token Standard**: NonFungible (Standard NFT)

### Metadata Configuration
- **Name Format**: `Oinkonomics #XXX` (where XXX = 0-899)
- **Storage**: Arweave via Irys (permanent)
- **Base URI**: `https://gateway.irys.xyz/`
- **URI Length**: 44 characters

### Attributes (Each NFT has)
- **Background**: Various colors
- **Body**: Different pig body types
- **Eyes**: Various eye styles
- **Mouth**: Different expressions
- **Accessories**: Hats, glasses, etc.
- **Tier**: Poor / Mid / Rich (based on NFT number)

---

## 🎨 Example Mint URLs

### Devnet Mint Page (for testing)
```
https://your-frontend.com/mint?network=devnet&cm=HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe
```

### Mainnet Mint Page (production)
```
https://oinkonomics.fun/mint?network=mainnet&cm=YOUR_MAINNET_CM_ID
```

---

## 🧪 Testing on Devnet

### Get Devnet SOL (Airdrop)
```bash
solana airdrop 1
```

### Test Mint (CLI)
```bash
cd /home/b13/Desktop/hashlips
sugar mint -n 1
```

### Test Mint (Frontend)
1. Switch wallet to Devnet
2. Connect wallet (Phantom, Solflare, etc.)
3. Request devnet airdrop if needed
4. Click "Mint NFT" button
5. Approve transaction (0.01 SOL)

---

## 📝 Integration Code Examples

### TypeScript/React - Get Candy Machine
```typescript
import { Connection, PublicKey } from '@solana/web3.js';
import { Metaplex } from '@metaplex-foundation/js';

const connection = new Connection(
  process.env.NEXT_PUBLIC_RPC_DEVNET!,
  'confirmed'
);

const metaplex = Metaplex.make(connection);

const candyMachineId = new PublicKey(
  process.env.NEXT_PUBLIC_CANDY_MACHINE_ID_DEVNET!
);

const candyMachine = await metaplex
  .candyMachines()
  .findByAddress({ address: candyMachineId });

console.log('Available:', candyMachine.itemsAvailable);
console.log('Redeemed:', candyMachine.itemsRedeemed);
```

### TypeScript/React - Mint NFT
```typescript
import { useWallet } from '@solana/wallet-adapter-react';

const { publicKey, signTransaction } = useWallet();

const mintNft = async () => {
  if (!publicKey) return;

  const candyMachine = await metaplex
    .candyMachines()
    .findByAddress({ address: candyMachineId });

  const { nft } = await metaplex
    .candyMachines()
    .mint({
      candyMachine,
      collectionUpdateAuthority: candyMachine.authorityAddress,
    });

  console.log('Minted NFT:', nft.address.toString());
};
```

---

## 🚦 Deployment Checklist

### Devnet (Current - ✅ Complete)
- [x] Generate 900 NFTs with tier attributes
- [x] Upload images to Arweave (901 files)
- [x] Upload metadata to Arweave (901 files)
- [x] Deploy Candy Machine
- [x] Verify deployment (900/900 items)
- [x] Set mint price (0.01 SOL)
- [x] Test mint (successful)

### Mainnet (Todo - ⏳ Pending)
- [ ] Verify mainnet wallet has sufficient SOL (~0.5-1 SOL for deployment)
- [ ] Update .env: RPC_URL to mainnet
- [ ] Upload to mainnet Arweave
- [ ] Deploy Candy Machine to mainnet
- [ ] Verify mainnet deployment
- [ ] Set mint price (0.0523 SOL = 6.9 USD)
- [ ] Update frontend with mainnet CM ID
- [ ] Test mainnet mint
- [ ] Announce launch!

---

## 💡 Important Notes

1. **Storage**: All assets are on Arweave (permanent, decentralized)
2. **Pricing**: Devnet uses 0.01 SOL for testing, mainnet will use 0.0523 SOL
3. **Tiers**: Automatically assigned based on mint number (0-299=Poor, 300-599=Mid, 600-899=Rich)
4. **Royalties**: 5% goes to treasury wallet on secondary sales
5. **Sequential Minting**: NFTs mint in order from #0 to #899
6. **Verification**: All 900 NFTs verified on-chain ✅

---

## 🔒 Security Reminders

- Never commit private keys to git
- Keep wallet seed phrases secure
- Test thoroughly on devnet before mainnet
- Monitor treasury wallet for payments
- Use hardware wallet for mainnet authority

---

## 📞 Support & Resources

- **Solana Docs**: https://docs.solana.com/
- **Metaplex Docs**: https://docs.metaplex.com/
- **Sugar CLI**: https://docs.metaplex.com/tools/sugar/
- **Wallet Adapter**: https://github.com/solana-labs/wallet-adapter

---

**Last Updated**: December 7, 2025
**Status**: ✅ Devnet Deployed - Ready for Frontend Integration
