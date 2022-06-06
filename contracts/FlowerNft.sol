// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Authorizable.sol";
import "hardhat/console.sol";

contract FlowerNft is Authorizable, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private _baseUri;
    uint8 public breedCount = 6;
    address public signerUser;
    mapping(uint256 => uint256) public tokenBreed;
    mapping(bytes => bool) public signatureUsed;

    event ReceiveMint(address indexed from, uint256 indexed tokenId);
    event Breed(address indexed from, uint256  _tokenfId,uint256 _tokenmId,uint256 tokenId);
    constructor() ERC721("FlowerNft", "FLOWERNFT") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }

    function setBaseURI(string calldata newBaseURI) public onlyOwner {
        _baseUri = newBaseURI;
    }

    function setBreedCount(uint8 _count) public onlyOwner {
        breedCount = _count;
    }

    function setSigner(address _signerUser) public onlyOwner {
        signerUser = _signerUser;
    }

    function tokenIds() public view returns(uint256){
        return _tokenIds.current();
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    /// @dev Allow market contracts to transfer NFT
    function approvalForNft(address owner, address operator,bool approved) public onlyAuthorized{
        _setApprovalForAll(owner,operator,approved);
    }

    function verifySignature(string calldata key, bytes calldata signature)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(abi.encodePacked(key, msg.sender));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        address receivedAddress = ECDSA.recover(message, signature);
        return receivedAddress;
    }

    /// @dev mint receive box.
    function receiveMint(string calldata key, bytes calldata signature) external {
        require(!signatureUsed[signature], "signature has already been used");
        require(
            verifySignature(key, signature) == signerUser,
            "no permissions"
        );
        uint256 tokenId =  create(msg.sender);
        signatureUsed[signature] = true;
        emit ReceiveMint(msg.sender,tokenId);
    }

    function mint(address _user) public onlyAuthorized returns (uint256) {
        return create(_user);
    }

    function create(address _user) internal returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(_user, tokenId);
        return tokenId;
    }

    /// @dev box breed
    function breed(uint256 _tokenfId, uint256 _tokenmId)
        external
        returns (uint256 tokenId)
    {
        require(ownerOf(_tokenfId) == msg.sender, "_tokenId not yours");
        require(ownerOf(_tokenmId) == msg.sender, "_tokenId not yours");
        require(tokenBreed[_tokenfId] < breedCount, "breed than max");
        require(tokenBreed[_tokenmId] < breedCount, "breed than max");
        tokenBreed[_tokenfId] += 1;
        tokenBreed[_tokenmId] += 1;
        tokenId = create(msg.sender);
        emit Breed(msg.sender,_tokenfId,_tokenmId,tokenId);
    
    }
}
