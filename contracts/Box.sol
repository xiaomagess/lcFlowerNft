// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Authorizable.sol";
import "./FlowerNft.sol";

contract Box is Authorizable, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public mintLimit;
    uint256 public startTime;
    ERC20 public payTokenContract;
    FlowerNft public nftContract;

    uint256 public price = 100 * 10**18; //盲盒价格

    event OpenBox(address indexed from, uint256 indexed tokenId);

    constructor(address _payTokenAddress, address _nftAddress)
        ERC721("LCBox", "LCBOX")
    {
        payTokenContract = ERC20(_payTokenAddress);
        nftContract = FlowerNft(_nftAddress);
    }

    modifier checkTime() {
        require(block.timestamp >= startTime, "time not yet");
        _;
    }

    /// @dev Checks total.
    modifier checkTotalSupply() {
        require(checkMintLimit(), "mint box limit");
        _;
    }

    /// @dev Checks mint limit.
    function checkMintLimit() public view returns (bool) {
        return _tokenIds.current() < mintLimit;
    }

    /// @dev set start time.
    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    /// @dev set mint limit.
    function setMintLimit(uint256 _mintLimit) public onlyOwner {
        mintLimit = _mintLimit;
    }

    /// @dev set box pprice.
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
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

    /// @dev mint box.
    function mint(address _user)
        public
        checkTotalSupply
        onlyAuthorized
        returns (uint256)
    {
        return create(_user);
    }

    /// @dev buy box.
    function buyBox() public checkTotalSupply checkTime returns (uint256) {
        uint256 balance = payTokenContract.balanceOf(msg.sender);
        require(balance >= price, "payToken Not enough");
        payTokenContract.transferFrom(msg.sender, address(this), price);
        return create(msg.sender);
    }

    function create(address _user) internal returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(_user, tokenId);
        return tokenId;
    }

    /// @dev open box.
    function openBox(uint256 _tokenId)
        public
        checkTime
        returns (uint256 tokenId)
    {
        require(ownerOf(_tokenId) == msg.sender, "_tokenId not yours");
        _burn(_tokenId);
        tokenId = nftContract.mint(msg.sender);
        emit OpenBox(msg.sender, _tokenId);
    }

    function withdraw(address _user) public onlyOwner {
        uint256 balance = payTokenContract.balanceOf(address(this));
        payTokenContract.transfer(_user, balance);
    }
}
