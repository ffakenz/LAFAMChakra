from scripts.utils import OPENSEA_FORMAT
from brownie import LAFAMKeys, accounts, network, config


def awardChakras():
    account = accounts.add(config["wallets"]["from_key"])
    chakra_nft = LAFAMKeys[len(LAFAMKeys) - 1] # Get last one

    print("Minting chakras to " + network.show_active() + " contract: " + chakra_nft.address)
    # chakra_nft.initialize({"from": account})
    chakra_nft.mintBatch(account, "chakras", [1,2,3,4,5,6,7], [1,1,1,1,1,1,1], {"from": account})
    print("Minted!")

def main():
    awardChakras()