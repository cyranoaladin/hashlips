# 🚀 Oinkonomics NFT - Quick Deployment Reference

## ✅ DEPLOYMENT COMPLETE ON DEVNET

---

## 🔑 Essential Information

### Candy Machine Details
```
Candy Machine ID: F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6
Collection Mint:  5TvyKsARmXos1AqDbLyAQEXrpVJj6CGLi1d7BeEDn9HG
Creator PDA:      2k6E3F8HygFHGFG7JVWW97CQYS6y3BFHFnroSYWPWRfW
Treasury Wallet:  2cCwkHm8cMP6ni7fuQDrHRX8TG75M3yT24QuH4LPPKmd
```

### Network Info
```
Current Network: Devnet (Test)
RPC Endpoint:    https://api.devnet.solana.com
Explorer:        https://explorer.solana.com/?cluster=devnet
```

### Pricing
```
Devnet Price:  0.01 SOL (test)
Mainnet Price: 0.0523 SOL (~$6.90 USD)
Royalty:       5% (500 basis points)
```

---

## 🎯 Quick Commands

### View Collection Info
```bash
sugar show
```

### Test Mint
```bash
sugar mint
```

### Verify Everything
```bash
sugar verify
```

### Check Balance
```bash
solana balance
```

---

## 🌐 View on Explorer

### Candy Machine
```
https://explorer.solana.com/address/F7McteHG4Sq7wPXDe3MpXNKYQxZkBrFKbFKm6JmcPPy6?cluster=devnet
```

### Collection NFT
```
https://explorer.solana.com/address/5TvyKsARmXos1AqDbLyAQEXrpVJj6CGLi1d7BeEDn9HG?cluster=devnet
```

---

## 📋 Next Steps Checklist

### Testing Phase (Current)
- [ ] Run `sugar mint` to test minting
- [ ] Verify NFT displays correctly in wallet
- [ ] Test with frontend (if built)
- [ ] Check metadata on explorer

### Before Mainnet
- [ ] Generate all 3000 NFTs (currently 10)
- [ ] Test all features thoroughly
- [ ] Fund wallet with real SOL (~0.5-1 SOL)
- [ ] Configure payment guards
- [ ] Switch RPC to mainnet
- [ ] Deploy to mainnet

### Mainnet Deployment
```bash
# 1. Switch network
solana config set --url mainnet-beta

# 2. Validate config
sugar validate

# 3. Upload assets (COSTS REAL SOL)
sugar upload

# 4. Deploy candy machine (COSTS REAL SOL)
sugar deploy

# 5. Add guards
sugar guard add

# 6. Update .env with mainnet addresses
```

---

## 💡 Important Notes

- ✅ All assets uploaded to Irys (permanent storage)
- ✅ Configuration files updated with deployment info
- ⚠️ Guards not configured yet (free minting on devnet)
- ⚠️ Only 10 NFTs uploaded (config set for 3000)

---

## 📞 Need Help?

1. Check logs: `cat sugar.log`
2. View full docs: `DEPLOYMENT_INFO.md`
3. Sugar docs: https://docs.metaplex.com/programs/candy-machine/

---

**Generated**: December 7, 2025  
**Status**: ✅ DEVNET READY FOR TESTING
