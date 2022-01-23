from scripts.utils import OPENSEA_FORMAT
from brownie import LAFAMChakra, accounts, network, config


def mintChakras():
    account = accounts.add(config["wallets"]["from_key"])
    chakra_nft = LAFAMChakra[len(LAFAMChakra) - 1] # Get last one

    print("Minting chakras to " + network.show_active() + " contract: " + chakra_nft.address)
    chakra_nft.mintChakrasBatch(account, [0,1,2,3,4,5,6], [1,1,1,1,1,1,1], {"from": account})
    print("Minted!")

def main():
    mintChakras()