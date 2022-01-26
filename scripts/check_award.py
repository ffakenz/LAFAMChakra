from scripts.utils import OPENSEA_FORMAT
from brownie import LAFAMKeys, accounts, network, config

def balanceOf():
    # account = accounts.add(config["wallets"]["from_key"])
    account = "0x45BeDb174d2DEE1991B3562283300ca569Fa34e5"
    chakra_nft = LAFAMKeys[len(LAFAMKeys) - 1] # Get last one
    balance1 = chakra_nft.balanceOf(account, 1)
    print("1: " + str(balance1))
    balance2 = chakra_nft.balanceOf(account, 2)
    print("2: " + str(balance2))
    balance3 = chakra_nft.balanceOf(account, 3)
    print("3: " + str(balance3))
    balance4 = chakra_nft.balanceOf(account, 4)
    print("4: " + str(balance4))
    balance5 = chakra_nft.balanceOf(account, 5)
    print("5: " + str(balance5))
    balance6 = chakra_nft.balanceOf(account, 6)
    print("6: " + str(balance6))
    balance7 = chakra_nft.balanceOf(account, 7)
    print("7: " + str(balance7))

def main():
    balanceOf()