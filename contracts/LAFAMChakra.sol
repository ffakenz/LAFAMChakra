// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LAFAMChakra is ERC1155, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    enum Chakra {
        RED,
        ORANGE,
        YELLOW,
        GREEN,
        BLUE,
        INDIGO,
        VIOLET
    }

    event ChakrasAwarded(
        address avatar,
        uint256[] chakras,
        uint256[] amounts,
        uint256 time
    );

    string _baseUri;
    string _uriExtension;

    constructor(string memory baseUri)
        ERC1155(string(abi.encodePacked(baseUri, "{id}", ".json")))
    {
        _baseUri = baseUri;
        _uriExtension = ".json";
    }

    /**
     * @dev public abi
     */
    function mintChakras(
        address avatar,
        uint256 chakraId,
        uint256 amount
    ) public onlyOwner {
        require(
            isValidChakra(chakraId),
            string(abi.encodePacked("invalid chakra id:", chakraId.toString()))
        );

        _mint(avatar, chakraId, amount, "");
        emit ChakrasAwarded(
            avatar,
            asSingletonArray(chakraId),
            asSingletonArray(amount),
            block.timestamp
        );
    }

    function mintChakrasBatch(
        address avatar,
        uint256[] memory chakraIds,
        uint256[] memory amounts
    ) public onlyOwner {
        for (uint256 i; i < chakraIds.length; i++) {
            uint256 chakraId = chakraIds[i];
            require(
                isValidChakra(chakraId),
                string(
                    abi.encodePacked("invalid chakra id:", chakraId.toString())
                )
            );
        }

        _mintBatch(avatar, chakraIds, amounts, "");
        emit ChakrasAwarded(avatar, chakraIds, amounts, block.timestamp);
    }

    function airDropChakrasWithMint(
        address[] memory avatars,
        uint256 chakraId,
        uint256 amount
    ) public onlyOwner {
        for (uint256 i; i < avatars.length; i++) {
            address avatar = avatars[i];
            mintChakras(avatar, chakraId, amount);
        }
    }

    function airDropChakrasWithTransfer(
        address[] memory avatars,
        uint256 chakraId,
        uint256 amount
    ) public onlyOwner {
        uint256 count = avatars.length;
        mintChakras(owner(), chakraId, count.mul(amount));
        for (uint256 i; i < count; i++) {
            address avatar = avatars[i];
            safeTransferFrom(owner(), avatar, chakraId, amount, "");
        }
    }

    /**
     * @dev public view functions
     */
    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return buildURI(id.toString());
    }

    function buildURI(string memory id)
        internal
        view
        virtual
        returns (string memory)
    {
        return string(abi.encodePacked(_baseUri, id, _uriExtension));
    }

    function chackraBalanceOf(address avatar)
        public
        view
        returns (uint256[] memory)
    {
        uint256 chakraCount = maxChakra().add(1);
        uint256[] memory chakraBalance = new uint256[](chakraCount);
        for (uint256 i = minChakra(); i <= maxChakra(); i++) {
            chakraBalance[i] = balanceOf(avatar, i);
        }
        return chakraBalance;
    }

    /**
     * @dev pure functions
     */
    function isValidChakra(uint256 id) public pure virtual returns (bool) {
        return id >= minChakra() && id <= maxChakra();
    }

    function minChakra() public pure virtual returns (uint256) {
        return uint256(type(Chakra).min);
    }

    function maxChakra() public pure virtual returns (uint256) {
        return uint256(type(Chakra).max);
    }

    /**
     * @dev private pure functions
     */
    function asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    }
}
