# 🎉 Oinkonomics NFT Collection - Deployment Complete

## 📊 Deployment Summary

### ✅ Status: DEPLOYED ON DEVNET

---

## 🔑 Key Addresses

| Component | Address |
|-----------|---------|
| **Candy Machine** | `F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6` |
| **Candy Guard** | *(Not configured yet)* |
| **Candy Machine Creator (PDA)** | `2k6E3F8HygFHGFG7JVWW97CQYS6y3BFHFnroSYWPWRfW` |
| **Collection Mint** | `5TvyKsARmXos1AqDbLyAQEXrpVJj6CGLi1d7BeEDn9HG` |
| **Creator/Treasury Wallet** | `2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd` |

---

## 📝 Collection Details

- **Name**: Oinkonomics NFT
- **Symbol**: OINCO (on-chain) / OINK (config)
- **Description**: Oinkonomics - Premium NFT Collection on Solana
- **Total Supply**: 10 NFTs (configured for 3000)
- **Network**: Devnet (test)
- **External URL**: https://oinkonomics.fun

---

## 💰 Pricing Configuration

### Devnet (Testing)
- **Mint Price**: 0.01 SOL
- **Freeze Payment**: 0.01 SOL (if enabled)
- **Destination**: `2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd`

### Mainnet (Production - Ready)
- **Mint Price**: 0.0523 SOL (~$6.90 USD at 131.88 SOL/USD)
- **Freeze Payment**: 0.0523 SOL
- **Freeze Period**: 30 days (2,592,000 seconds)
- **Destination**: `2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd`

---

## 📦 Royalties & Creators

- **Royalty**: 5% (500 basis points / was 1000 in .env)
- **Creator 1**: `2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd` - 100% share
- **Token Standard**: NFT (standard)
- **Mutable**: Yes (can update metadata)
- **Sequential**: Yes (mint in order)

---

## ☁️ Upload & Storage

- **Method**: Bundlr (Irys)
- **Gateway**: https://gateway.irys.xyz/
- **All Assets**: Successfully uploaded on-chain
- **Sample NFT #0**: 
  - Image: `https://gateway.irys.xyz/Ct1StwPo3WGmqn4rFFqcM8K6eYgf1hoi2isp1hb93ehH?ext=png`
  - Metadata: `https://gateway.irys.xyz/1ZV6qfzJeGRDRtLJQs73FYtEeRMLBsd7HvnidmKM1ZQ`

---

## 🌐 Frontend Integration

### Devnet URLs
```
NEXT_PUBLIC_SOLANA_NETWORK=devnet
NEXT_PUBLIC_RPC_DEVNET=https://api.devnet.solana.com
NEXT_PUBLIC_CANDY_MACHINE_ID_DEVNET=F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6
NEXT_PUBLIC_MINT_PRICE_DEVNET=0.01
```

### Mainnet URLs (When Ready)
```
NEXT_PUBLIC_SOLANA_NETWORK=mainnet-beta
NEXT_PUBLIC_RPC_MAINNET=https://api.mainnet-beta.solana.com
NEXT_PUBLIC_CANDY_MACHINE_ID_MAINNET=[TO BE FILLED AFTER MAINNET DEPLOY]
NEXT_PUBLIC_MINT_PRICE_MAINNET=0.0523
```

### Common Config
```
NEXT_PUBLIC_DOMAIN=oinkonomics.fun
NEXT_PUBLIC_CANDY_MACHINE_PROGRAM_ID=CndyV3LdqHUfDLmE5naZjVN8rBZz4tqhdefbAnjHG3JR
NEXT_PUBLIC_TREASURY_WALLET=2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd
```

---

## 🛠️ Testing Commands

### View Candy Machine Info
```bash
sugar show
```

### Mint a Test NFT
```bash
sugar mint
```

### Verify Collection
```bash
sugar verify
```

### Check Wallet Balance
```bash
solana balance
```

### View on Solana Explorer (Devnet)
```
https://explorer.solana.com/address/F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6?cluster=devnet
https://explorer.solana.com/address/5TvyKsARmXos1AqDbLyAQEXrpVJj6CGLi1d7BeEDn9HG?cluster=devnet
```

---

## 🚀 Next Steps

### 1. Test on Devnet ✅
- [x] Deploy Candy Machine
- [x] Upload all assets
- [ ] Test minting process
- [ ] Verify metadata display
- [ ] Test with frontend

### 2. Configure Guards (Optional)
```bash
# Add guards for controlled minting
sugar guard add
```

Available guards:
- `solPayment`: Payment in SOL ✅
- `freezeSolPayment`: Freeze NFTs after mint
- `startDate`: Set mint start time
- `endDate`: Set mint end time
- `mintLimit`: Limit per wallet
- `allowList`: Whitelist addresses
- `botTax`: Prevent bot minting

### 3. Deploy to Mainnet

When ready for mainnet:

```bash
# 1. Switch to mainnet
solana config set --url mainnet-beta

# 2. Fund your wallet (real SOL)
# Estimate: ~0.5-1 SOL for 10 NFTs

# 3. Update config for mainnet
# Edit sugar-config.json or config.json

# 4. Validate
sugar validate

# 5. Upload assets
sugar upload

# 6. Deploy
sugar deploy

# 7. Configure guards
sugar guard add

# 8. Update .env with new mainnet IDs
```

---

## 📋 Configuration Files Status

| File | Status | Notes |
|------|--------|-------|
| `.env` | ✅ Updated | All devnet values set |
| `config.json` | ✅ Ready | Set for 3000 NFTs |
| `cache.json` | ✅ Generated | Contains all upload data |
| `sugar-config.json` | ✅ Ready | Contains guard config |
| `assets/` | ✅ Complete | All NFTs + metadata |

---

## 💡 Important Notes

### Current State
- ✅ 10 NFTs successfully uploaded to devnet
- ✅ Candy Machine deployed and verified
- ✅ Collection NFT created
- ⚠️ Guards not yet configured (no payment required for devnet minting)
- ⚠️ Configuration set for 3000 NFTs but only 10 uploaded

### Before Mainnet
1. **Generate all 3000 NFTs** if targeting full collection
2. **Test minting** thoroughly on devnet
3. **Configure payment guards** for mainnet
4. **Fund wallet** with sufficient SOL for deployment
5. **Update RPC endpoints** to mainnet
6. **Double-check pricing** (currently 0.0523 SOL)

### Cost Estimates

**Devnet**: FREE (test network)

**Mainnet** (approximate):
- Upload 3000 NFTs: ~0.3-0.5 SOL (via bundlr)
- Candy Machine creation: ~0.01 SOL
- Transaction fees: ~0.01 SOL
- **Total**: ~0.4-0.6 SOL + buffer

---

## 🔗 Useful Links

### Tools
- [Solana Explorer](https://explorer.solana.com/)
- [Sugar Documentation](https://docs.metaplex.com/programs/candy-machine/how-to-guides/my-first-candy-machine-part1)
- [Candy Machine v3 Docs](https://docs.metaplex.com/programs/candy-machine/)

### Your Collection
- **Devnet Explorer**: https://explorer.solana.com/address/F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6?cluster=devnet
- **Collection Mint**: https://explorer.solana.com/address/5TvyKsARmXos1AqDbLyAQEXrpVJj6CGLi1d7BeEDn9HG?cluster=devnet

---

## 🎯 Quick Reference Commands

```bash
# View candy machine details
sugar show

# Mint a test NFT
sugar mint

# Verify everything is correct
sugar verify

# Update candy machine settings
sugar update

# Withdraw funds (after minting)
sugar withdraw

# Add/update guards
sugar guard add
sugar guard update
sugar guard remove

# Freeze/thaw utilities (if using freeze guard)
sugar freeze initialize
sugar freeze thaw
```

---

## 📞 Support

If you encounter issues:
1. Check `sugar.log` for detailed error messages
2. Verify RPC connectivity: `solana config get`
3. Check wallet balance: `solana balance`
4. Review Sugar documentation: https://docs.metaplex.com/

---

**Last Updated**: December 7, 2025  
**Network**: Devnet  
**Status**: Ready for Testing ✅
