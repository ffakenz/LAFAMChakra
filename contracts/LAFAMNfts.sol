// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LAFAMNfts is ERC1155, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter _globalId; // globalId counter
    struct NFTCollection {
        uint256 id;             // serial id unique per name + tag
        string name;            // represents metadata
        string tag;             // represents collection metadata
        bool enabled;           // flag to check existance
        bool duplicable;        // flag that represents if the nft is duplicable or not
        uint256 globalId;       // unique global id
    }
    // nftCollections[globalId] => NFTCollection
    mapping(uint256 => NFTCollection) public nftCollections;
    // _globalIdFor[id][tag][name] => globalId
    mapping(uint256 => mapping(string => mapping(string => uint256))) public _globalIdFor;

    mapping(string => bool) public tags;
    string[] public _tags;
    mapping(string => uint256[]) public _idsForTag;
    mapping(string => uint256[]) public _globalIdsForTag;

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
        addNFTCollection(0, "ORANGE", "chakras", true); // globaId: 1
        addNFTCollection(0, "YELLOW", "chakras", true); // globaId: 2
        addNFTCollection(0, "GREEN", "chakras", true);  // globaId: 3
        addNFTCollection(0, "BLUE", "chakras", true);   // globaId: 4
        addNFTCollection(0, "INDIGO", "chakras", true); // globaId: 5
        addNFTCollection(0, "VIOLET", "chakras", true); // globaId: 6
        addNFTCollection(0, "RED", "chakras", true);    // globaId: 7
        addNFTCollection(144, "RED", "chakras", false); // globaId: 8
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
        string memory tag,
        bool duplicable
    ) public onlyOwner {
        validateTagExists(tag);
        validateNameNotEmpty(name);
        validateNFTCollectionNotEnabled(id, tag, name);

        _globalId.increment();
        uint globalId = _globalId.current();
        NFTCollection memory c = NFTCollection({
            id: id,
            name: name,
            tag: tag,
            enabled: true,
            duplicable: duplicable,
            globalId: globalId
        });

        nftCollections[id] = c;
        _globalIdFor[id][tag][name] = globalId;
        _idsForTag[tag].push(id);
        _globalIdsForTag[tag].push(globalId);
    }

    // depends on tag and token id existance (addNFTCollection)
    function mint(
        address avatar,
        string memory tag,
        string memory name,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        validateTagExists(tag);
        validateNFTCollectionEnabled(id, tag, name);
        uint globalId = _globalIdFor[id][tag][name];
        validateTagMatchForGlobalId(tag, globalId);

        NFTCollection memory nft = nftCollections[id];
        if(amount > 1) {
            require(nft.duplicable, "NFT is unique");
        }

        _mint(avatar, nft.globalId, amount, "");

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
        string memory name,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyOwner {
        validateTagExists(tag);
        uint totalIds = ids.length;
        uint256[] memory globalIds = new uint256[](totalIds);
        for (uint256 i; i < totalIds; i++) {
            uint256 id = ids[i];
            validateNFTCollectionEnabled(id, tag, name);
            uint globalId = _globalIdFor[id][tag][name];
            validateTagMatchForGlobalId(tag, globalId);
            NFTCollection memory nft = nftCollections[id];
            if(amounts[id] > 1) {
                require(nft.duplicable, "NFT is unique");
            }
            globalIds[id] = nft.globalId;
        }

        _mintBatch(avatar, globalIds, amounts, "");
        emit NFTAwarded(avatar, tag, ids, amounts, block.timestamp);
    }

    // depends on tag and token id existance (addNFTCollection) due to mint
    function airDropWithMint(
        address[] memory avatars,
        string memory tag,
        string memory name,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        for (uint256 i; i < avatars.length; i++) {
            address avatar = avatars[i];
            mint(avatar, tag, name, id, amount);
        }
    }

    // depends on tag and token id existance (addNFTCollection) due to mint
    function airDropWithTransfer(
        address[] memory avatars,
        string memory tag,
        string memory name,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        uint256 count = avatars.length;
        mint(owner(), tag, name, id, count.mul(amount));
        for (uint256 i; i < count; i++) {
            address avatar = avatars[i];
            uint globalId = _globalIdFor[id][tag][name];
            safeTransferFromSender(avatar, globalId, amount);
        }
    }

    /**
     * @dev public functions
     */

    // depends on token id existance due to buildURI
    // id represents globalId
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

    function globalIdsForTag(string memory tag)
        public
        view
        returns (uint256[] memory)
    {
        validateTagExists(tag);

        return _globalIdsForTag[tag];
    }

    // depends on tag existance due to globalIdsForTag
    function tagBalanceOf(address avatar, string memory tag)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory globalIds = globalIdsForTag(tag);
        uint256[] memory tagBalance = new uint256[](globalIds.length);
        for (uint256 i; i < globalIds.length; i++) {
            uint256 globalId = globalIds[i];
            tagBalance[i] = balanceOf(avatar, globalId);
        }
        return tagBalance;
    }

    function safeTransferFromSender(
        address to,
        uint256 globalId,
        uint256 amount
    ) public {
        validateGlobalIdExists(globalId);
        NFTCollection memory nft = nftCollections[globalId];
        if(amount > 1) {
            require(nft.duplicable, "NFT is unique");
        }
        safeTransferFrom(msg.sender, to, globalId, amount, "");
    }

    function safeTransferFromSender(
        address to,
        uint256 id,
        string memory tag,
        string memory name,
        uint256 amount
    ) public {
        validateNFTCollectionEnabled(id, tag, name);
        uint256 globalId = _globalIdFor[id][tag][name];
        validateGlobalIdExists(globalId);
        NFTCollection memory nft = nftCollections[globalId];
        if(amount > 1) {
            require(nft.duplicable, "NFT is unique");
        }
        safeTransferFrom(msg.sender, to, globalId, amount, "");
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

    function validateGlobalIdExists(
        uint256 globalId
    ) public view {
        require(
            nftCollections[globalId].enabled,
            string(abi.encodePacked("invalid globalId - does not exists:", globalId))
        );
    }

    function validateGlobalIdNotExist(
        uint256 globalId
    ) public view {
        require(
            !nftCollections[globalId].enabled,
            string(abi.encodePacked("invalid globalId - already exists", globalId))
        );
    }

    function validateNFTCollectionEnabled(
        uint256 id,
        string memory tag,
        string memory name
    ) public view {
        uint256 globalId = _globalIdFor[id][tag][name];
        require(
            nftCollections[globalId].enabled,
            string(abi.encodePacked("nft collection is disabled: ", globalId))
        );
    }

    function validateNFTCollectionNotEnabled(
        uint256 id,
        string memory tag,
        string memory name
    ) public view {
        uint256 globalId = _globalIdFor[id][tag][name];
        require(
            !nftCollections[globalId].enabled,
            string(abi.encodePacked("nft collection is enabled: ", globalId))
        );
    }

    function validateNameNotEmpty(string memory name) public pure {
        require(bytes(name).length > 0, "invalid name - empty");
    }

    function validateTagNotEmpty(string memory tag) public pure {
        require(bytes(tag).length > 0, "invalid tag - empty");
    }

    function validateTagMatchForGlobalId(string memory tag, uint256 globalId) public view {
        string memory current = nftCollections[globalId].tag;
        require(
            compareStrings(current, tag),
            string(
                abi.encodePacked(
                    "invalid tag - does not match current:",
                    "globalId ",
                    globalId,
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

    function validateNameMatchForGlobalId(string memory name, uint256 globalId)
        public
        view
    {
        string memory current = nftCollections[globalId].name;
        require(
            compareStrings(current, name),
            string(
                abi.encodePacked(
                    "invalid name - does not match current:",
                    "globalId ",
                    globalId,
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
    function buildURI(uint256 globalId) private view returns (string memory) {
        validateGlobalIdExists(globalId);

        NFTCollection memory nft = nftCollections[globalId];
        string memory fileDir = nft.tag;
        string memory fileName = nft.name;
        // string memory fileId = nft.id;
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
