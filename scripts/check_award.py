from scripts.utils import OPENSEA_FORMAT
from brownie import LAFAMChakra, accounts, network, config

def balanceOf():
    account = accounts.add(config["wallets"]["from_key"])
    chakra_nft = LAFAMChakra[len(LAFAMChakra) - 1] # Get last one
    balance = chakra_nft.balanceOf(account, 1)
    print(balance)


def main():
    balanceOf()