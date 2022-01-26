from scripts.utils import OPENSEA_FORMAT
from brownie import LAFAMKeys, accounts, network, config


def transferChakras():
    account = accounts.add(config["wallets"]["from_key"])
    chakra_nft = LAFAMKeys[len(LAFAMKeys) - 1] # Get last one
    tranfer_account = "0x45BeDb174d2DEE1991B3562283300ca569Fa34e5"
    chakras_ids = [1,2,3,4,5,6,7]
    chakras_amounts = [1,1,1,1,1,1,1]
    print("Transfering chakras to " + tranfer_account + " contract: " + chakra_nft.address)
    chakra_nft.safeBatchTransferFrom(account, tranfer_account, chakras_ids, chakras_amounts, "", {"from": account})
    print("Transfered!")

def main():
    transferChakras()