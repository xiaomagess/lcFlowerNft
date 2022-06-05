// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Box.sol";

contract AirdropBoxTwo is Ownable {

    Box public boxContract;

    uint256 public startBlock;

    mapping(address => bool) public recipients;

    constructor(address _address) {
        boxContract = Box(_address);
    }

    /// @dev Checks if the airdrop is enabled.
    modifier isStartBlock {
        require(block.number > startBlock, "airdrop is not start");
        _;
    }

    /// @dev set start status of the airdrop.
    function setBoxContract(address _address) onlyOwner public {
        boxContract = Box(_address);
    }     

    /// @dev set start status of the airdrop.
    function setStartBlock(uint256 _startBlock) onlyOwner public {
        startBlock = _startBlock;
    }     

    /// @dev add user airdrop box
    function setAirdrops(address[] memory _recipients) onlyOwner public {
        for(uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = true;
        }
    }

    /// @dev remove user airdrop box
    function removeRecipients(address[] memory _recipients) onlyOwner public {
        for(uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = false;
        }
    }


    /// @dev sel user airdrop box
    function selAirdrops(address _address) public view returns (bool){
        return recipients[_address];
    }

    /// @dev Redeems unclaimed box.
    function claimAirdrop() isStartBlock external {
        require(recipients[msg.sender] == true, 'recipient not permissions');
        recipients[msg.sender] = false;
        boxContract.mint(msg.sender);
    }

}
