// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LAFAMKeys is ERC1155, Ownable {
    using SafeMath for uint;
    using Strings for uint;

    struct NFTCollection {
        uint id;
        string name;
        string tag;
    }
    mapping(uint => NFTCollection) public nftCollections;
    
    mapping(string => bool) public tags;
    string[] public _tags;
    mapping(string => uint[]) public _idsForTag;

    event NFTAwarded(
        address indexed avatar,
        string indexed tag, 
        uint[] ids,
        uint[] amounts,
        uint indexed time
    );
    
    string public _baseUri;
    string public _uriExtension;
    string private _name;
    string private _symbol;

    constructor(
        string memory baseUri
    ) ERC1155(string(abi.encodePacked(baseUri, "{id}", ".json"))) { 
        _baseUri = baseUri;
        _uriExtension = ".json";
        _name = "LAFAM";
        _symbol = "LAFAM";
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

        _tags.push(tag);
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
        _idsForTag[tag].push(id);
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
        }
    }

    function airDropWithTransfer(address[] memory avatars, string memory tag, uint id, uint amount) public onlyOwner { 
        uint count = avatars.length;
        mint(owner(), tag, id, count.mul(amount));
        for(uint i; i < count; i++) {
            address avatar = avatars[i];
            transferFrom(owner(), avatar, id, amount);
        }
    }

    /**
     * @dev public functions
     */
    function uri(uint256 id) override public view virtual returns (string memory) {        
        return buildURI(id);
    }

    function idsForTag(string memory tag) public view returns (uint[] memory) {
        validateTagExists(tag);

        return _idsForTag[tag];
    }

    function tagBalanceOf(address avatar, string memory tag) public view returns (uint[] memory) {
        uint[] memory ids = idsForTag(tag);
        uint[] memory tagBalance = new uint[](ids.length);
        for(uint i; i < ids.length; i++) {
            tagBalance[i] = balanceOf(avatar, i.add(1));
        }
        return tagBalance;
    }

    function transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {    
        safeTransferFrom(from, to, id, amount, "");
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
        validateIdExists(id);

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
}