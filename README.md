# Create env vars
## Using .env

Create a `.env` file at root project level

```sh
## CONTRACT DEPLOY
# WALLET PRIV KEY
export PRIVATE_KEY=
export WEB3_INFURA_PROJECT_ID=

## CONTRACT PUBLISH
export ETHERSCAN_TOKEN=

## STORAGE
# export IPFS_URL=http://127.0.0.1:5001
export UPLOAD_IPFS=true
export PINATA_API_KEY=
export PINATA_API_SECRET=
```

# Add harmony testnet to your list of networks
https://docs.harmony.one/home/network/wallets/browser-extensions-wallets/metamask-wallet

```sh
brownie networks add Harmony harmony-test host=https://api.s0.b.hmny.io chainid=1666700000 name="Testnet (Shard 0)"
```

# Faucet
1/ go to https://explorer.pops.one/
2/ search your metamask one address
3/ get your one address
4/ go to https://faucet.pops.one/ and claim faucet tokens

# Install arweave-python-client
https://github.com/MikeHibbert/arweave-python-client

```sh
pipx install arweave-python-client --include-deps
```