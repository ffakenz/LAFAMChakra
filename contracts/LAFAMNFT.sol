// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LAFAMNFT is ERC1155, Ownable {
    using SafeMath for uint;
    using Strings for uint;

    struct NFTCollection {
        uint id;
        string name;
        string tag;
    }
    mapping(uint => NFTCollection) public nftCollections;
    mapping(string => bool) public tags;

    event NFTAwarded(address avatar, string tag, uint[] ids, uint[] amounts, uint time);
    event NFTAirdropped(address avatar, string tag, uint[] ids, uint[] amounts, uint time);
    
    string _baseUri;
    string _uriExtension;

    constructor(
        string memory baseUri
    ) ERC1155(string(abi.encodePacked(baseUri, "{id}", ".json"))) { 
        _baseUri = baseUri;
        _uriExtension = ".json";

        // addTAG("chakras");
        // addNFTCollection(1, "ORANGE", "chakras");
        // addNFTCollection(2, "YELLOW", "chakras");
        // addNFTCollection(3, "GREEN", "chakras");
        // addNFTCollection(4, "BLUE", "chakras");
        // addNFTCollection(5, "INDIGO", "chakras");
        // addNFTCollection(6, "VIOLET", "chakras");
        // addNFTCollection(7, "RED", "chakras");
    }
    
    // @dev onlyOwner
    function addTAG(string memory tag) public onlyOwner {
        validateTagNotExist(tag);

        tags[tag] = true;
    }

    function addNFTCollection(
        uint id,
        string memory name, 
        string memory tag 
    ) public onlyOwner {
        validateIdNotExist(id);
        validateTagExists(tag);
        validateNameNotEmpty(name);

        NFTCollection memory c = NFTCollection({
            id: id,
            name: name,
            tag: tag
        });

        nftCollections[id] = c;
    }

     function mint(address avatar, string memory tag, uint id, uint amount) public onlyOwner {       
        validateTagExists(tag);
        validateIdExists(id);
        validateTagMatchForId(tag, id);

        _mint(avatar, id, amount, "");
        emit NFTAwarded(avatar, tag, asSingletonArray(id), asSingletonArray(amount), block.timestamp);
    }

    function mintBatch(address avatar, string memory tag, uint[] memory ids, uint[] memory amounts) public onlyOwner {       
        validateTagExists(tag);
        for(uint id; id < ids.length; id++) {
            validateIdExists(id);
            validateTagMatchForId(tag, id);
        }

        _mintBatch(avatar, ids, amounts, "");
        emit NFTAwarded(avatar, tag, ids, amounts, block.timestamp);
    }
    
    function airDropWithMint(address[] memory avatars, string memory tag, uint id, uint amount) public onlyOwner { 
        for(uint i; i < avatars.length; i++) {
            address avatar = avatars[i];
            mint(avatar, tag, id, amount);
            emit NFTAirdropped(avatar, tag, asSingletonArray(id), asSingletonArray(amount), block.timestamp);
        }
    }

    function airDropWithTransfer(address[] memory avatars, string memory tag, uint id, uint amount) public onlyOwner { 
        uint count = avatars.length;
        mint(owner(), tag, id, count.mul(amount));
        for(uint i; i < count; i++) {
            address avatar = avatars[i];
            safeTransferFrom(owner(), avatar, id, amount, "");
            emit NFTAirdropped(avatar, tag, asSingletonArray(id), asSingletonArray(amount), block.timestamp);
        }
    }

    /**
     * @dev public functions
     */
    function uri(uint256 id) override public view virtual returns (string memory) {
        return buildURI(id);
    }

    // @dev validations
    function validateTagNotExist(string memory tag) public view {
        require(
            !tags[tag],
            "invalid tag - already exists"
        );
    }

    function validateTagExists(string memory tag) public view {
        require(
            tags[tag],
            string(abi.encodePacked("invalid tag - does not exists:", tag))
        );
    }

    function validateIdNotExist(uint id) public view {
        require(
            nftCollections[id].id == 0,
            string(abi.encodePacked("invalid nft id - already exists", id))
        );
    }

    function validateIdExists(uint id) public view {
        require(
            nftCollections[id].id != 0,
            string(abi.encodePacked("invalid id - does not exists:", id))
        );
    }
    
    function validateNameNotEmpty(string memory name) public pure {
        require(
            bytes(name).length > 0,
            "invalid name - empty"
        );
    }

    function validateTagMatchForId(string memory tag, uint id) public view {
        string memory current = nftCollections[id].tag;
        require(
            compareStrings(current, tag),
            string(abi.encodePacked("invalid tag - does not match current:",
                "id ", id, ", ",
                "tag ", tag, ", ",
                "current ", current
            ))
        );
    }

    function validateNameMatchForId(string memory name, uint id) public view {
        string memory current = nftCollections[id].name;
        require(
            compareStrings(current, name),
            string(abi.encodePacked("invalid name - does not match current:",
                "id ", id, ", ",
                "name ", name, ", ",
                "current ", current
            ))
        );
    }

    /**
     * @dev private functions
     */
    function buildURI(uint id) private view returns (string memory) {
        NFTCollection memory nft = nftCollections[id];
        string memory fileDir = nft.tag;
        string memory fileName = nft.name;
        return string(abi.encodePacked(_baseUri, fileDir, "/", fileName, _uriExtension));
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function asSingletonArray(uint256 element) private pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }

    // @TODO get tags
    // @TODO get ids for tags
    // @TODO get avatar tag balance
}