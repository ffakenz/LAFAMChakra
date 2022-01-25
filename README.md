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

# Verify contract
https://docs.harmony.one/home/developers/tools/smart-contract-verification

## prerequisites
1/ install and run https://github.com/poanetwork/solidity-flattener
2/ import metamask harmony-testnet
    host: https://api.s0.b.hmny.io
    chain id: 1666700000
    explorer: https://explorer.pops.one/
    symbol: ONE
3/ set ur metamask private key in .env file

## steps
0/ brownie compile + get faucet
1/ brownie run deploy_nft.py --network harmony-test
2/ ./node_modules/.bin/poa-solidity-flattener ./contracts/LAFAMChakra.sol
4/ copy json abi from remix with optimize 200
5/ verify
    0.8.11+commit.d7f03943
6/ brownie run scripts/award_chakra.py —network harmony-test