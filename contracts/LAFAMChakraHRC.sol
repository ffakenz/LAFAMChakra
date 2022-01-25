// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./HRC1155/HRC1155Tradable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LAFAMChakraHRC is HRC1155Tradable {
    using SafeMath for uint;
    using Strings for uint;

    enum Chakra {RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET}
    
    event ChakrasAwarded(address avatar, uint[] chakras, uint[] amounts, uint time);
    event ChakrasAirdropped(address avatar, uint[] chakras, uint[] amounts, uint time);

    string _baseUri;
    string _uriExtension;
    
    constructor(
        string memory baseUri
    ) public HRC1155Tradable("LAFAMNFT", "LAFAM", 0x0000000000000000000000000000000000000000) {
        _baseUri = baseUri;
        _uriExtension = ".json";
		_setBaseMetadataURI(string(abi.encodePacked(baseUri, "{id}", ".json")));
	}

    /**
     * @dev public abi
     */
    function mintChakras(address avatar, uint chakraId, uint amount) 
        public
        onlyOwner {       

        require(
            isValidChakra(chakraId),
            string(abi.encodePacked("invalid chakra id:", chakraId.toString()))
        );

        _mint(avatar, chakraId, amount, "");
        emit ChakrasAwarded(avatar, asSingletonArray(chakraId), asSingletonArray(amount), block.timestamp);
    }

    function mintChakrasBatch(address avatar, uint[] memory chakraIds, uint[] memory amounts)
        public
        onlyOwner {       
        
        for(uint i; i < chakraIds.length; i++) {
            uint chakraId = chakraIds[i];
            require(
                isValidChakra(chakraId),
                string(abi.encodePacked("invalid chakra id:", chakraId.toString()))
            );
        }

        _batchMint(avatar, chakraIds, amounts, "");
        emit ChakrasAwarded(avatar, chakraIds, amounts, block.timestamp);
    }

    function airDropChakrasWithMint(address[] memory avatars, uint chakraId, uint amount)
        public
        onlyOwner { 

        for(uint i; i < avatars.length; i++) {
            address avatar = avatars[i];
            mintChakras(avatar, chakraId, amount);
            emit ChakrasAirdropped(avatar, asSingletonArray(chakraId), asSingletonArray(amount), block.timestamp);
        }
    }

    function airDropChakrasWithTransfer(address[] memory avatars, uint chakraId, uint amount)
        public
        onlyOwner { 

        uint count = avatars.length;
        mintChakras(owner(), chakraId, count.mul(amount));
        for(uint i; i < count; i++) {
            address avatar = avatars[i];
            safeTransferFrom(owner(), avatar, chakraId, amount, "");
            emit ChakrasAirdropped(avatar, asSingletonArray(chakraId), asSingletonArray(amount), block.timestamp);
        }
    }

    /**
     * @dev public view functions
     */
    function uri(uint256 id) override public view virtual returns (string memory) {
        require(_exists(id), "HRC721Tradable#uri: NONEXISTENT_TOKEN");
        return buildURI(id.toString());
    }

    function buildURI(string memory id) internal view virtual returns (string memory) {
        return string(abi.encodePacked(_baseUri, id, _uriExtension));
    }

    function chackraBalanceOf(address avatar) public view returns (uint[] memory) {
        uint chakraCount = maxChakra().add(1);
        uint[] memory chakraBalance = new uint[](chakraCount);
        for(uint i = minChakra(); i <= maxChakra(); i++) {
            chakraBalance[i] = balanceOf(avatar, i);
        }
        return chakraBalance;
    }
    /**
     * @dev pure functions
     */
    function isValidChakra(uint id) public pure virtual returns (bool) {
        return id >= minChakra() && id <= maxChakra();
    }

    function minChakra() public pure virtual returns (uint) {
        return uint(type(Chakra).min);
    }

    function maxChakra() public pure virtual returns (uint) {
        return uint(type(Chakra).max);
    }

    /**
     * @dev private pure functions
     */
    function asSingletonArray(uint256 element) private pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }
}