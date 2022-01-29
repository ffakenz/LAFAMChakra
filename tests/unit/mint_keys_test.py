import pytest
from brownie import network, LAFAMKeys, accounts, config
from scripts.deploy_nft import deploy


def test_can_create_keys():
    if network.show_active() not in ["development"] or "fork" in network.show_active():
        pytest.skip("Test can only run in 'development' networks")
    account = accounts.add(config["wallets"]["from_key"])

    contract = deploy()
    contract.mintBatch(account, "chakras", [1,2,3,4,5,6,7], [1,1,1,1,1,1,1], {"from": account})
    assert contract.balanceOf(account, 1) == 1
    
