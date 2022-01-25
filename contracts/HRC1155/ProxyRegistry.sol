// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./OwnableDelegateProxy.sol";

contract ProxyRegistry {
	mapping(address => OwnableDelegateProxy) public proxies;
}