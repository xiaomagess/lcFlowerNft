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

    event Sale(address indexed seller, uint256 indexed tokenId, uint256 price);

    event Cancel(address indexed seller, uint256 indexed tokenId);

    event Buy(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId
    );

    /// @dev nft sale
    function sale(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, "price not alow");
        require(nftContract.ownerOf(_tokenId) == msg.sender, "token not alow");
        require(shopOrder[_tokenId].tokenId == 0, "already on sale");
        shopOrder[_tokenId] = Sales(msg.sender, _tokenId, _price);
        shopCount += 1;
        nftContract.approvalForNft(msg.sender, address(this), true);
        emit Sale(msg.sender, _tokenId, _price);
    }

    /// @dev nft scancel
    function cancel(uint256 _tokenId) public {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "token not alow");
        nftContract.approvalForNft(msg.sender, address(this), false);
        delete shopOrder[_tokenId];
        shopCount -= 1;
        emit Cancel(msg.sender, _tokenId);
    }

    /// @dev nft buy
    function buy(uint256 _tokenId) public {
        require(
            shopOrder[_tokenId].price > 0,
            "transaction has been completed"
        );
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
        shopCount -= 1;
        emit Buy(msg.sender, shopOrder[_tokenId].seller, _tokenId);
        delete shopOrder[_tokenId];
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
