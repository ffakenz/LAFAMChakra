// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LAFAMKeys is ERC1155, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    struct NFTCollection {
        uint256 id;
        string name;
        string tag;
        bool enabled;
    }
    mapping(uint256 => NFTCollection) public nftCollections;

    mapping(string => bool) public tags;
    string[] public _tags;
    mapping(string => uint256[]) public _idsForTag;

    event NFTAwarded(
        address indexed avatar,
        string indexed tag,
        uint256[] ids,
        uint256[] amounts,
        uint256 indexed time
    );

    string public _baseUri;
    string public _uriExtension;

    constructor(string memory baseUri)
        ERC1155(string(abi.encodePacked(baseUri, "{tag}/{id}", ".json")))
    {
        _baseUri = baseUri;
        _uriExtension = ".json";
    }

    function initialize() public onlyOwner {
        addTAG("chakras");
        addNFTCollection(1, "ORANGE", "chakras");
        addNFTCollection(2, "YELLOW", "chakras");
        addNFTCollection(3, "GREEN", "chakras");
        addNFTCollection(4, "BLUE", "chakras");
        addNFTCollection(5, "INDIGO", "chakras");
        addNFTCollection(6, "VIOLET", "chakras");
        addNFTCollection(7, "RED", "chakras");
    }

    // @dev onlyOwner
    function addTAG(string memory tag) public onlyOwner {
        validateTagNotExist(tag);
        validateTagNotEmpty(tag);

        _tags.push(tag);
        tags[tag] = true;
    }

    // depends on tag existance (addTAG)
    function addNFTCollection(
        uint256 id,
        string memory name,
        string memory tag
    ) public onlyOwner {
        validateIdNotExist(id);
        validateTagExists(tag);
        validateNameNotEmpty(name);

        NFTCollection memory c = NFTCollection({
            id: id,
            name: name,
            tag: tag,
            enabled: true
        });

        nftCollections[id] = c;
        _idsForTag[tag].push(id);
    }

    // depends on tag and token id existance (addNFTCollection)
    function mint(
        address avatar,
        string memory tag,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        validateTagExists(tag);
        validateIdExists(id);
        validateTagMatchForId(tag, id);

        _mint(avatar, id, amount, "");

        emit NFTAwarded(
            avatar,
            tag,
            asSingletonArray(id),
            asSingletonArray(amount),
            block.timestamp
        );
    }

    // depends on tag and token id existance (addNFTCollection)
    function mintBatch(
        address avatar,
        string memory tag,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyOwner {
        validateTagExists(tag);
        for (uint256 i; i < ids.length; i++) {
            validateIdExists(ids[i]);
            validateTagMatchForId(tag, ids[i]);
        }

        _mintBatch(avatar, ids, amounts, "");
        emit NFTAwarded(avatar, tag, ids, amounts, block.timestamp);
    }

    // depends on tag and token id existance (addNFTCollection) due to mint
    function airDropWithMint(
        address[] memory avatars,
        string memory tag,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        for (uint256 i; i < avatars.length; i++) {
            address avatar = avatars[i];
            mint(avatar, tag, id, amount);
        }
    }

    // depends on tag and token id existance (addNFTCollection) due to mint
    function airDropWithTransfer(
        address[] memory avatars,
        string memory tag,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        uint256 count = avatars.length;
        mint(owner(), tag, id, count.mul(amount));
        for (uint256 i; i < count; i++) {
            address avatar = avatars[i];
            safeTransferFromSender(avatar, id, amount);
        }
    }

    /**
     * @dev public functions
     */

    // depends on token id existance due to buildURI
    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return buildURI(id);
    }

    function idsForTag(string memory tag)
        public
        view
        returns (uint256[] memory)
    {
        validateTagExists(tag);

        return _idsForTag[tag];
    }

    // depends on tag existance due to idsForTag
    function tagBalanceOf(address avatar, string memory tag)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory ids = idsForTag(tag);
        uint256[] memory tagBalance = new uint256[](ids.length);
        for (uint256 i; i < ids.length; i++) {
            tagBalance[i] = balanceOf(avatar, i.add(1));
        }
        return tagBalance;
    }

    function safeTransferFromSender(
        address to,
        uint256 id,
        uint256 amount
    ) public {
        safeTransferFrom(msg.sender, to, id, amount, "");
    }

    // @dev validations
    function validateTagNotExist(string memory tag) public view {
        require(!tags[tag], "invalid tag - already exists");
    }

    function validateTagExists(string memory tag) public view {
        require(
            tags[tag],
            string(abi.encodePacked("invalid tag - does not exists:", tag))
        );
    }

    function validateIdNotExist(uint256 id) public view {
        require(
            !nftCollections[id].enabled,
            string(abi.encodePacked("invalid nft id - already exists", id))
        );
    }

    function validateIdExists(uint256 id) public view {
        require(
            nftCollections[id].enabled,
            string(abi.encodePacked("invalid id - does not exists:", id))
        );
    }

    function validateNameNotEmpty(string memory name) public pure {
        require(bytes(name).length > 0, "invalid name - empty");
    }

    function validateTagNotEmpty(string memory tag) public pure {
        require(bytes(tag).length > 0, "invalid tag - empty");
    }

    function validateTagMatchForId(string memory tag, uint256 id) public view {
        string memory current = nftCollections[id].tag;
        require(
            compareStrings(current, tag),
            string(
                abi.encodePacked(
                    "invalid tag - does not match current:",
                    "id ",
                    id,
                    ", ",
                    "tag ",
                    tag,
                    ", ",
                    "current ",
                    current
                )
            )
        );
    }

    function validateNameMatchForId(string memory name, uint256 id)
        public
        view
    {
        string memory current = nftCollections[id].name;
        require(
            compareStrings(current, name),
            string(
                abi.encodePacked(
                    "invalid name - does not match current:",
                    "id ",
                    id,
                    ", ",
                    "name ",
                    name,
                    ", ",
                    "current ",
                    current
                )
            )
        );
    }

    /**
     * @dev private functions
     */

    // depends on tag and token id existance (addNFTCollection)
    function buildURI(uint256 id) private view returns (string memory) {
        validateIdExists(id);

        NFTCollection memory nft = nftCollections[id];
        string memory fileDir = nft.tag;
        string memory fileName = nft.name;
        return
            string(
                abi.encodePacked(
                    _baseUri,
                    fileDir,
                    "/",
                    fileName,
                    _uriExtension
                )
            );
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

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
