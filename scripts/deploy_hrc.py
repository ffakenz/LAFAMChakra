import os
from brownie import network, accounts, config, LAFAMChakraHRC

def deploy():
    dev = accounts.add(config["wallets"]["from_key"])
    print("Deploying to " + network.show_active())
    publish_source = False
    base_uri = "https://ipfs.io/ipfs/QmeRMJz2q8MgiZgAt2yDNjQu5wMspQfZTXjSp59LFBAUF3"
    LAFAMChakraHRC.deploy(base_uri, {"from": dev}, publish_source=publish_source)
    print("Deployed!")

def main():
    deploy()