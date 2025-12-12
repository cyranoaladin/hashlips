# 🎯 Quick Frontend Integration Guide

## 🚀 Essential Information

### Candy Machine ID (Devnet)
```
HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe
```

### Collection ID
```
6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi
```

### Treasury Wallet
```
5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
```

---

## 📋 Copy-Paste .env Configuration

```bash
# Candy Machine - Devnet
NEXT_PUBLIC_CANDY_MACHINE_ID=HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe
NEXT_PUBLIC_COLLECTION_ID=6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi
NEXT_PUBLIC_TREASURY=5zHBXzhaqKXJRMd7KkuWsb4s8zPyakKdijr9E3jgyG8Z
NEXT_PUBLIC_RPC_URL=https://api.devnet.solana.com
NEXT_PUBLIC_NETWORK=devnet
NEXT_PUBLIC_MINT_PRICE=0.01

# Collection Info
NEXT_PUBLIC_TOTAL_SUPPLY=900
NEXT_PUBLIC_COLLECTION_NAME=Oinkonomics NFT
NEXT_PUBLIC_SYMBOL=OINK
```

---

## 🔗 Direct Links

### View Candy Machine
https://www.solana.fm/address/HUaDqY9zX5Ucswobosq81hgZgTrB6EjZoi7nk3RGGYe?cluster=devnet-alpha

### View Collection
https://www.solana.fm/address/6PfSvL43yN6TxKgY2PNVnBSRodf187AVaMxT8E65nRxi?cluster=devnet-alpha

### View First Minted NFT (Test)
https://www.solana.fm/address/EgMFvZgbSQd5i8j51P7owdn6B9vGBQ9Lhquqm8SBZhE2?cluster=devnet-alpha

---

## 🎨 NFT Tier System

| Tier | Range | Count | Rarity |
|------|-------|-------|--------|
| Poor | #0-299 | 300 | Common |
| Mid | #300-599 | 300 | Uncommon |
| Rich | #600-899 | 300 | Rare |

---

## 💰 Pricing

- **Devnet**: 0.01 SOL (for testing)
- **Mainnet**: 0.0523 SOL = 6.9 USD

---

## ✅ Status

- **Total NFTs**: 900
- **Uploaded**: ✅ Yes (Arweave)
- **Deployed**: ✅ Yes (Devnet)
- **Verified**: ✅ Yes (900/900)
- **Tested**: ✅ Yes (1 mint successful)
- **Available**: 899/900

---

## 📦 Quick Test Commands

```bash
# View candy machine details
sugar show

# Mint 1 NFT
sugar mint -n 1

# Verify deployment
sugar verify
```

---

**Ready for frontend integration! 🎉**
