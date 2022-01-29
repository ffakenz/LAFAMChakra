import os
from brownie import network, accounts, config, LAFAMKeys

def deploy():
    dev = accounts.add(config["wallets"]["from_key"])
    print("Deploying to " + network.show_active())
    # publish_source = True if os.getenv("ETHERSCAN_TOKEN") else False
    publish_source = False
    base_uri = "https://ipfs.io/ipfs/QmRwGfppo8ajddwRsdEAgm2q8tUFpPiBM5Hs8bMyifCGvK/"
    nft_keys = LAFAMKeys.deploy(base_uri, {"from": dev}, publish_source=publish_source)
    nft_keys.initialize({"from": dev})
    print("Deployed!")
    return nft_keys 

def main():
    deploy()
