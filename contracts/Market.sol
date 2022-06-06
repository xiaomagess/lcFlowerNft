// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./FlowerNft.sol";

contract Market {
    ERC20 public payTokenContract;
    FlowerNft public nftContract;

    constructor(address _payTokenAddress, address _nftAddress) {
        payTokenContract = ERC20(_payTokenAddress);
        nftContract = FlowerNft(_nftAddress);
    }

    uint256 public shopCount;
    
    struct Sales {
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Sales) public shopOrder;

    event Sale(uint256 indexed tokenId, address indexed seller, uint256 price);

    event Cancel(uint256 indexed tokenId, address indexed seller);

    event Buy( uint256 indexed tokenId, address indexed buyer, address indexed seller );

    /// @dev nft sale
    function sale(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, "price not alow");
        require(nftContract.ownerOf(_tokenId) == msg.sender, "token not alow");
        shopOrder[_tokenId] = Sales(msg.sender, _tokenId, _price);
        shopCount += 1;
        nftContract.approvalForNft(msg.sender, address(this), true);
        emit Sale(_tokenId, msg.sender, _price);
    }

    /// @dev nft scancel
    function cancel(uint256 _tokenId) public {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "token not alow");
        nftContract.approvalForNft(msg.sender, address(this), false);
        delete shopOrder[_tokenId];
        shopCount -= 1;
        emit Cancel(_tokenId, msg.sender);
    }

    /// @dev nft buy
    function buy(uint256 _tokenId) public {
        require(
            payTokenContract.balanceOf(msg.sender) >= shopOrder[_tokenId].price,
            "no enough money"
        );
        payTokenContract.transferFrom(
            msg.sender,
            shopOrder[_tokenId].seller,
            shopOrder[_tokenId].price
        );
        nftContract.safeTransferFrom(
            shopOrder[_tokenId].seller,
            msg.sender,
            _tokenId
        );
        delete shopOrder[_tokenId];
        shopCount -= 1;
        emit Buy(_tokenId, msg.sender, shopOrder[_tokenId].seller);
    }

    /// @dev get tokenIds shoporder
    function getTokensOrder(uint256[] calldata tokenIds)
        public
        view
        returns (Sales[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (shopOrder[tokenIds[i]].tokenId > 0) {
                count++;
            }
        }
        Sales[] memory list = new Sales[](count);
        for (uint256 i = 0; i < count; i++) {
            list[i] = shopOrder[tokenIds[i]];
        }
        return list;
    }
}
