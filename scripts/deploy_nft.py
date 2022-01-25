import os
from brownie import network, accounts, config, LAFAMChakra

def deploy():
    dev = accounts.add(config["wallets"]["from_key"])
    print("Deploying to " + network.show_active())
    publish_source = True if os.getenv("ETHERSCAN_TOKEN") else False
    base_uri = "https://ipfs.io/ipfs/QmRwGfppo8ajddwRsdEAgm2q8tUFpPiBM5Hs8bMyifCGvK/"
    LAFAMChakra.deploy(base_uri, {"from": dev}, publish_source=publish_source)
    print("Deployed!")

def main():
    deploy()