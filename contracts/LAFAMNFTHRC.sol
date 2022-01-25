// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LAFAMChakraHRC.sol";

contract LAFAMNFTHRC is LAFAMChakraHRC {

    constructor(
        string memory baseUri
    ) public LAFAMChakraHRC(baseUri) {
    
	}
}